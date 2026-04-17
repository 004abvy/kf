const mysql = require('mysql2/promise');

(async () => {
  const c = await mysql.createConnection({
    host: 'nozomi.proxy.rlwy.net',
    user: 'root',
    password: 'CitCWbRfeYSXYexeHzeSgtsUDsLKCoKC',
    database: 'railway',
    port: 37679
  });

  const [payEnums] = await c.query("SHOW COLUMNS FROM Payments WHERE Field = 'payment_status'");
  console.log('Payment status enum:', JSON.stringify(payEnums));

  const [ordEnums] = await c.query("SHOW COLUMNS FROM Orders WHERE Field = 'order_status'");
  console.log('Order status enum:', JSON.stringify(ordEnums));

  // Simulate what /api/categories does
  try {
    const [rows] = await c.query("SELECT * FROM Categories WHERE is_active = TRUE ORDER BY display_order");
    console.log('Categories query works:', rows.length, 'rows');
  } catch (e) {
    console.error('Categories query FAILED:', e.message);
  }

  // Check if DATABASE_URL format works
  try {
    const c2 = await mysql.createConnection('mysql://root:CitCWbRfeYSXYexeHzeSgtsUDsLKCoKC@nozomi.proxy.rlwy.net:37679/railway');
    const [r] = await c2.query('SELECT 1 as test');
    console.log('DATABASE_URL format works:', r);
    await c2.end();
  } catch (e) {
    console.error('DATABASE_URL format FAILED:', e.message);
  }

  await c.end();
})();
