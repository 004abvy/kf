const mysql = require('mysql2/promise');

async function check() {
    const connection = await mysql.createConnection({
        host: 'nozomi.proxy.rlwy.net',
        user: 'root',
        password: 'CitCWbRfeYSXYexeHzeSgtsUDsLKCoKC',
        database: 'railway',
        port: 37679
    });

    try {
        console.log("Checking Categories table...");
        const [rows] = await connection.query('SELECT * FROM Categories WHERE is_active = TRUE ORDER BY display_order');
        console.log("Categories found:", rows.length);
    } catch (error) {
        console.error('Categories Error:', error.message);
    } finally {
        await connection.end();
    }
}

check();
