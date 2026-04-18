const mysql = require('mysql2/promise');
require('dotenv').config();

async function cleanResetModifiers() {
    const connection = await mysql.createConnection({
        host: process.env.DB_HOST,
        user: process.env.DB_USER,
        password: process.env.DB_PASSWORD,
        database: process.env.DB_NAME,
    });

    try {
        console.log('🔄 Step 1: Delete all modifiers...');
        await connection.query('DELETE FROM Modifiers');

        console.log('🔄 Step 2: Reset AUTO_INCREMENT counter...');
        await connection.query('ALTER TABLE Modifiers AUTO_INCREMENT = 1');

        console.log('🔄 Step 3: Insert ONLY the 2 modifiers you want...');
        await connection.query(`
            INSERT INTO Modifiers (name, price, image_url, is_active) VALUES
            ('Extra Shawarma Bread', 50.00, 'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=600', TRUE),
            ('Add Small Crinkle Fries', 200.00, 'https://images.unsplash.com/photo-1576107232684-1279f3908594?w=600', TRUE)
        `);

        console.log('\n✅ DONE! Verifying...\n');
        const [modifiers] = await connection.query('SELECT * FROM Modifiers ORDER BY modifier_id');
        console.log(`Total modifiers: ${modifiers.length}`);
        modifiers.forEach(m => {
            console.log(`  - ID: ${m.modifier_id}, Name: "${m.name}", Price: ${m.price}`);
        });

    } catch (error) {
        console.error('❌ Error:', error.message);
    } finally {
        await connection.end();
    }
}

cleanResetModifiers();
