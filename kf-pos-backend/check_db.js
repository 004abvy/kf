const mysql = require('mysql2/promise');
require('dotenv').config();

async function check() {
    const connection = await mysql.createConnection({
        host: process.env.DB_HOST,
        user: process.env.DB_USER,
        password: process.env.DB_PASSWORD,
        database: process.env.DB_NAME,
    });

    try {
        const [rows] = await connection.query('SELECT count(*) as count FROM MenuItems');
        console.log('Total items in MenuItems:', rows[0].count);
        
        const [featured] = await connection.query('SELECT name FROM MenuItems WHERE is_featured = TRUE');
        console.log('Featured items:', featured.map(f => f.name));
    } catch (error) {
        console.error('Error:', error.message);
    } finally {
        await connection.end();
    }
}

check();
