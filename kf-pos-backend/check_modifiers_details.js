const mysql = require('mysql2/promise');
require('dotenv').config();

async function checkModifiersDetails() {
    const connection = await mysql.createConnection({
        host: process.env.DB_HOST,
        user: process.env.DB_USER,
        password: process.env.DB_PASSWORD,
        database: process.env.DB_NAME,
    });

    try {
        const [modifiers] = await connection.query('SELECT * FROM Modifiers ORDER BY modifier_id');
        console.log(`Total modifiers: ${modifiers.length}\n`);
        modifiers.forEach(m => {
            console.log(`ID: ${m.modifier_id}, Name: "${m.name}", Price: ${m.price}, Active: ${m.is_active}`);
        });
    } catch (error) {
        console.error('Error:', error.message);
    } finally {
        await connection.end();
    }
}

checkModifiersDetails();
