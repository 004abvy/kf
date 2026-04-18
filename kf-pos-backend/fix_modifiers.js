const mysql = require('mysql2/promise');
require('dotenv').config();

async function fixModifiers() {
    const connection = await mysql.createConnection({
        host: process.env.DB_HOST,
        user: process.env.DB_USER,
        password: process.env.DB_PASSWORD,
        database: process.env.DB_NAME,
    });

    try {
        // Delete all modifiers
        await connection.query('DELETE FROM Modifiers');
        console.log('✅ All modifiers deleted');

        // Insert only the 2 we want
        await connection.query(`
            INSERT INTO Modifiers (name, price, image_url, is_active) VALUES
            ('Extra Shawarma Bread', 50, 'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=600', TRUE),
            ('Add Small Crinkle Fries', 200, 'https://images.unsplash.com/photo-1576107232684-1279f3908594?w=600', TRUE)
        `);
        console.log('✅ Inserted exactly 2 modifiers');

        // Verify
        const [modifiers] = await connection.query('SELECT * FROM Modifiers');
        console.log('\nCurrent modifiers:');
        modifiers.forEach(m => {
            console.log(`  - ID: ${m.modifier_id}, Name: ${m.name}, Price: ${m.price}`);
        });
    } catch (error) {
        console.error('❌ Error:', error.message);
    } finally {
        await connection.end();
    }
}

fixModifiers();
