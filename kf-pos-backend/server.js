const express = require('express');
const cors = require('cors');
const mysql = require('mysql2/promise');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
require('dotenv').config();

// 👇 WHATSAPP / TWILIO IMPORTS
const twilio = require('twilio');
let twilioClient = null;
if (process.env.TWILIO_SID && process.env.TWILIO_TOKEN) {
    twilioClient = twilio(process.env.TWILIO_SID, process.env.TWILIO_TOKEN);
}
const twilioWhatsAppNumber = 'whatsapp:+14155238886'; // Twilio Sandbox Number

// 👇 WEBSOCKET IMPORTS
const http = require('http');
const { Server } = require('socket.io');

const app = express();
app.use(cors());
app.use(express.json());

// 👇 WRAP EXPRESS IN HTTP SERVER FOR WEBSOCKETS
const server = http.createServer(app);
const io = new Server(server, {
    cors: { origin: "*", methods: ["GET", "POST"] }
});

io.on('connection', (socket) => {
    console.log(`⚡ Kitchen Display Connected: ${socket.id}`);
    socket.on('disconnect', () => console.log(`🛑 Kitchen Display Disconnected: ${socket.id}`));
});

// ── LOGGER ──
app.use((req, res, next) => {
    console.log(`[${new Date().toISOString()}] ${req.method} ${req.url}`);
    next();
});

// ── DB CONNECTION ──
let dbConfig;

// If we are on Render, use the Aiven connection string
if (process.env.DATABASE_URL) {
    dbConfig = process.env.DATABASE_URL; 
} else {
    // If we are on your local computer, use the separate variables
    dbConfig = {
        host: process.env.DB_HOST,
        user: process.env.DB_USER,
        password: process.env.DB_PASSWORD,
        database: process.env.DB_NAME,
        waitForConnections: true,
        connectionLimit: 10
    };
}

const pool = mysql.createPool(dbConfig);
// ── AUTHENTICATION ──
app.post('/api/auth/signup', async (req, res) => {
    try {
        const { name, email, password } = req.body;
        if (!name || !email || !password) return res.status(400).json({ message: "All fields are required" });

        const [existing] = await pool.query('SELECT staff_id FROM Staff WHERE email = ?', [email]);
        if (existing.length > 0) return res.status(400).json({ message: "Email already exists" });

        const hashedPassword = await bcrypt.hash(password, 10);
        await pool.query(
            `INSERT INTO Staff (full_name, email, password_hash, role_id) VALUES (?, ?, ?, ?)`,
            [name, email, hashedPassword, 1]
        );
        res.status(201).json({ success: true, message: "Signup successful" });
    } catch (error) { res.status(500).json({ message: "Signup failed", error: error.message }); }
});

app.post('/api/auth/login', async (req, res) => {
    try {
        const { email, password } = req.body;
        const [staff] = await pool.query(`
            SELECT s.*, r.role_name FROM Staff s 
            JOIN Roles r ON s.role_id = r.role_id WHERE s.email = ?`, [email]);

        if (staff.length === 0) return res.status(401).json({ message: 'Invalid credentials' });
        const isMatch = await bcrypt.compare(password, staff[0].password_hash);
        if (!isMatch) return res.status(401).json({ message: 'Invalid credentials' });

        const token = jwt.sign({ id: staff[0].staff_id, role: staff[0].role_name }, process.env.JWT_SECRET || 'kf_secret', { expiresIn: '24h' });
        res.json({ token, user: { name: staff[0].full_name, role: staff[0].role_name } });
    } catch (error) { res.status(500).json({ message: 'Server error' }); }
});

// ── MENU & MODIFIERS ──
app.get('/api/categories', async (req, res) => {
    try {
        const [rows] = await pool.query('SELECT * FROM Categories WHERE is_active = TRUE ORDER BY display_order');
        res.json(rows);
    } catch (err) { res.status(500).send(err); }
});

app.get('/api/items/:categoryId', async (req, res) => {
    try {
        const [rows] = await pool.query(`
            SELECT m.item_id, m.name as item_name, m.image_url, v.variation_id, v.size_name, v.price 
            FROM MenuItems m JOIN ItemVariations v ON m.item_id = v.item_id
            WHERE m.category_id = ? AND m.is_active = TRUE`, [req.params.categoryId]);
        res.json(rows);
    } catch (err) { res.status(500).send(err); }
});

app.get('/api/modifiers', async (req, res) => {
    try {
        const [modifiers] = await pool.query(`SELECT modifier_id, name, price FROM Modifiers WHERE is_active = TRUE`);
        res.json(modifiers);
    } catch (error) { res.status(500).json({ message: "Error fetching modifiers" }); }
});

// ── DELIVERY LOCATIONS (FIXED pool.query) ──
app.get('/api/locations', async (req, res) => {
  try {
    const [rows] = await pool.query('SELECT * FROM delivery_locations WHERE is_active = TRUE');
    res.json(rows);
  } catch (error) {
    console.error("Error fetching locations:", error);
    res.status(500).json({ success: false, message: "Server error fetching locations" });
  }
});

// ── CHECKOUT (UPDATED FOR DELIVERY ADDRESS) ──
app.post('/api/checkout', async (req, res) => {
    // Extracted deliveryAddress and deliveryFee from the frontend request
    const { items, total, method, walletDetails, customerPhone, deliveryAddress, deliveryFee } = req.body;
    const connection = await pool.getConnection();

    try {
        await connection.beginTransaction();
        const orderNumber = `ORD-${Date.now()}`;
        const [staff] = await connection.query('SELECT staff_id FROM Staff LIMIT 1');
        const staffId = staff[0]?.staff_id || null;

        // Determine if it's a delivery or takeaway based on whether an address was provided
        const orderType = deliveryAddress ? 'Delivery' : 'Takeaway';

        // Insert into Orders with the new delivery_address column
        const [orderResult] = await connection.query(
            `INSERT INTO Orders (order_number, staff_id, order_type, total_amount, order_status, customer_phone, delivery_address) 
             VALUES (?, ?, ?, ?, ?, ?, ?)`,
            [orderNumber, staffId, orderType, total, 'Pending', customerPhone || null, deliveryAddress || null]
        );

        const orderId = orderResult.insertId;

        for (const item of items) {
            const modString = item.modifiers && item.modifiers.length > 0 ? item.modifiers.map(m => m.name).join(', ') : null;
            const isStandalone = String(item.variation_id).startsWith('mod-var-');
            const dbVariationId = isStandalone ? null : item.variation_id;
            const dbStandaloneName = isStandalone ? item.item_name : null;

            await connection.query(
                `INSERT INTO OrderItems (order_id, variation_id, quantity, unit_price, subtotal, modifiers, standalone_name) 
                 VALUES (?, ?, ?, ?, ?, ?, ?)`,
                [orderId, dbVariationId, item.quantity, item.price, item.price * item.quantity, modString, dbStandaloneName]
            );
        }

        const tid = (method === 'wallet' || method === 'bank') ? (walletDetails?.number || 'N/A') : 'N/A';
        const paymentStatus = (method === 'cod') ? 'Pending' : 'Pending Verification';

        await connection.query(
            `INSERT INTO Payments (order_id, payment_method, amount_paid, payment_status, transaction_id) 
             VALUES (?, ?, ?, ?, ?)`,
            [orderId, method, 0, paymentStatus, tid]
        );

        await connection.commit();
        
        io.emit('new_order');

        res.status(201).json({ success: true, orderNumber });
    } catch (error) {
        await connection.rollback();
        console.error("❌ Checkout error:", error);
        res.status(500).json({ success: false, message: 'Failed to place order' });
    } finally {
        connection.release();
    }
});

// ── STAFF DASHBOARD ──
app.get('/api/staff/orders', async (req, res) => {
    try {
        const [orders] = await pool.query(`
            SELECT o.order_id, o.order_number, o.total_amount, o.order_status as status, o.created_at, o.customer_phone, o.rejection_reason, o.delivery_address,
                   p.payment_method, p.payment_status, p.transaction_id
            FROM Orders o LEFT JOIN Payments p ON o.order_id = p.order_id
            WHERE o.order_status != 'Completed' AND o.order_status != 'Cancelled' AND o.order_status != 'Rejected' ORDER BY o.created_at ASC
        `);

        for (let order of orders) {
            const [items] = await pool.query(`
                SELECT oi.quantity, 
                       COALESCE(m.name, oi.standalone_name) as item_name, 
                       CONCAT_WS(' | ', v.size_name, oi.modifiers) as size_name
                FROM OrderItems oi 
                LEFT JOIN ItemVariations v ON oi.variation_id = v.variation_id
                LEFT JOIN MenuItems m ON v.item_id = m.item_id 
                WHERE oi.order_id = ?
            `, [order.order_id]);
            order.items = items;
        }
        res.json(orders);
    } catch (error) { res.status(500).json({ message: "Error" }); }
});

// 👇 UPDATED: WHATSAPP INTEGRATION WITH ORDER DETAILS & PRICE
app.post('/api/staff/update-status', async (req, res) => {
    try {
        const { orderId, newStatus, newPaymentStatus, rejectionReason } = req.body;
        if (!orderId || !newStatus) return res.status(400).json({ message: "Missing required fields" });

        // 1. Fetch main order details
        const [orderData] = await pool.query('SELECT customer_phone, order_number, total_amount FROM Orders WHERE order_id = ?', [orderId]);
        const phone = orderData[0]?.customer_phone;
        const shortOrderNum = orderData[0]?.order_number.slice(-6);
        const totalAmount = orderData[0]?.total_amount;

        // 2. Fetch the specific items for this order so we can list them in the WhatsApp message
        const [itemsData] = await pool.query(`
            SELECT oi.quantity, 
                   COALESCE(m.name, oi.standalone_name) as item_name, 
                   CONCAT_WS(' | ', v.size_name, oi.modifiers) as size_name
            FROM OrderItems oi 
            LEFT JOIN ItemVariations v ON oi.variation_id = v.variation_id
            LEFT JOIN MenuItems m ON v.item_id = m.item_id 
            WHERE oi.order_id = ?
        `, [orderId]);

        // Format items into a neat list: "▫️ 2x Burger (Standard)"
        const itemsList = itemsData.map(item => {
            let details = item.size_name && item.size_name.trim() !== '' ? ` (${item.size_name})` : '';
            return `▫️ ${item.quantity}x ${item.item_name}${details}`;
        }).join('\n');

        // 3. Update Database
        await pool.query('UPDATE Orders SET order_status = ?, rejection_reason = ? WHERE order_id = ?', [newStatus, rejectionReason || null, orderId]);
        if (newPaymentStatus) await pool.query('UPDATE Payments SET payment_status = ? WHERE order_id = ?', [newPaymentStatus, orderId]);
        
        // 4. Broadcast WebSocket
        io.emit('order_updated');

        // 5. Build and Send WhatsApp Message
        if (phone && phone.length >= 10) {
            let msg = '';
            
            if (newStatus === 'Preparing') {
                msg = `🍔 *KF ORDER ACCEPTED!*\n\nHi! We are preparing your order (#${shortOrderNum}).\n\n*Your Order:*\n${itemsList}\n\n*Total:* ${totalAmount.toLocaleString()} PKR\n\nWe will let you know when it's on the way!`;
            } else if (newStatus === 'Rejected') {
                msg = `❌ *KF ORDER CANCELLED*\n\nHi, we unfortunately had to cancel your order (#${shortOrderNum}).\n\n*Reason:* ${rejectionReason}\n\nWe apologize for the inconvenience.`;
            } else if (newStatus === 'On the Way') {
                msg = `🛵 *ORDER DISPATCHED!*\n\nGreat news! Your KF order (#${shortOrderNum}) is on the way.\n\n*Amount Due:* ${totalAmount.toLocaleString()} PKR\n\nGet ready to eat!`;
            }

            if (msg) {
                // Convert local Pakistani number (0300...) to International (+92300...)
                let formattedPhone = phone;
                if (phone.startsWith('0')) {
                    formattedPhone = '+92' + phone.substring(1);
                }

                if (twilioClient) {
                    try {
                        await twilioClient.messages.create({
                            body: msg,
                            from: twilioWhatsAppNumber,
                            to: `whatsapp:${formattedPhone}`
                        });
                        console.log(`✅ WHATSAPP SENT TO ${formattedPhone}`);
                    } catch (smsErr) {
                        console.error("❌ WhatsApp Failed to Send:", smsErr.message);
                    }
                } else {
                    console.log(`\n📱 [MOCK WHATSAPP to ${formattedPhone}]:\n${msg}\n`);
                }
            }
        }

        res.json({ success: true, message: "Order updated" });
    } catch (error) { 
        console.error("Update error:", error);
        res.status(500).json({ message: "Error updating order" }); 
    }
});

// ── ORDER TRACKER ──
app.get('/api/orders/status/:id', async (req, res) => {
    try {
        const [order] = await pool.query('SELECT order_status as status, rejection_reason FROM Orders WHERE order_number = ? OR order_id = ?', [req.params.id, req.params.id]);
        if (order.length === 0) return res.status(404).json({ message: "Order not found" });
        res.json({ status: order[0].status, rejection_reason: order[0].rejection_reason });
    } catch (error) { res.status(500).json({ message: "Error" }); }
});

// ── ADMIN STATS ──
app.get('/api/admin/stats', async (req, res) => {
    try {
        const [revenue] = await pool.query(`SELECT SUM(total_amount) as daily_total FROM Orders WHERE order_status = 'Completed' AND DATE(created_at) = CURDATE()`);
        const [counts] = await pool.query(`SELECT COUNT(*) as total_orders FROM Orders WHERE DATE(created_at) = CURDATE()`);
        
        const [popular] = await pool.query(`
            SELECT COALESCE(m.name, oi.standalone_name) as name, SUM(oi.quantity) as total_sold 
            FROM OrderItems oi
            LEFT JOIN ItemVariations v ON oi.variation_id = v.variation_id 
            LEFT JOIN MenuItems m ON v.item_id = m.item_id
            GROUP BY COALESCE(m.name, oi.standalone_name) 
            ORDER BY total_sold DESC LIMIT 5
        `);

        const [revenueTrendRaw] = await pool.query(`
            SELECT DATE(created_at) as date, SUM(total_amount) as revenue
            FROM Orders WHERE order_status = 'Completed' AND created_at >= DATE_SUB(CURDATE(), INTERVAL 6 DAY)
            GROUP BY DATE(created_at) ORDER BY DATE(created_at) ASC
        `);
        const revenueTrend = revenueTrendRaw.map(row => ({ date: new Date(row.date).toLocaleDateString('en-US', { month: 'short', day: '2-digit' }), revenue: row.revenue }));
        const [paymentStats] = await pool.query(`
            SELECT CASE WHEN payment_method = 'wallet' THEN 'JazzCash/EasyPaisa' ELSE 'Cash on Delivery' END as name, COUNT(*) as value 
            FROM Payments p JOIN Orders o ON p.order_id = o.order_id WHERE o.order_status = 'Completed' GROUP BY payment_method
        `);

        res.json({ revenue: revenue[0].daily_total || 0, orderCount: counts[0].total_orders, popular: popular, revenueTrend: revenueTrend, paymentStats: paymentStats });
    } catch (error) { 
        console.error("Admin Stats Error:", error); 
        res.status(500).json({ message: "Error fetching analytics" }); 
    }
});

// ── CUSTOMER PROFILE ── 
app.get('/api/customer/history/:phone', async (req, res) => {
    try {
        const [orders] = await pool.query(`
            SELECT order_id, order_number, total_amount, order_status as status, rejection_reason, created_at
            FROM Orders WHERE customer_phone = ? ORDER BY created_at DESC LIMIT 10
        `, [req.params.phone]);

        for (let order of orders) {
            const [items] = await pool.query(`
                SELECT oi.quantity, 
                       COALESCE(m.name, oi.standalone_name) as item_name, 
                       oi.variation_id, m.image_url, oi.unit_price as price, 
                       CONCAT_WS(' | ', v.size_name, oi.modifiers) as size_name
                FROM OrderItems oi 
                LEFT JOIN ItemVariations v ON oi.variation_id = v.variation_id
                LEFT JOIN MenuItems m ON v.item_id = m.item_id 
                WHERE oi.order_id = ?
            `, [order.order_id]);
            order.items = items;
        }
        res.json(orders);
    } catch (error) { res.status(500).json({ message: "Error fetching history" }); }
});

// ── START SERVER ──
const PORT = process.env.PORT || 3000;
server.listen(PORT, () => console.log(`✅ KF POS Backend Online w/ WebSockets: http://localhost:${PORT}`));

server.on('error', (err) => {
    if (err.code === 'EADDRINUSE') console.error(`🚨 Port ${PORT} already in use`);
    else console.error('🚨 SERVER ERROR:', err.message);
});

process.on('uncaughtException', (err) => console.error('🚨 FATAL CRASH:', err.message));
process.on('unhandledRejection', (err) => console.error('🚨 PROMISE REJECTION:', err.message));