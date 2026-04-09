const mysql = require('mysql2/promise');
require('dotenv').config();

async function migrate() {
    const connection = await mysql.createConnection({
        host: process.env.DB_HOST,
        user: process.env.DB_USER,
        password: process.env.DB_PASSWORD,
        database: process.env.DB_NAME,
    });

    try {
        console.log('Starting migration...');
        
        // 1. Check if column exists
        const [columns] = await connection.query('SHOW COLUMNS FROM MenuItems LIKE "is_featured"');
        
        if (columns.length === 0) {
            console.log('Adding is_featured column...');
            await connection.query('ALTER TABLE MenuItems ADD COLUMN is_featured BOOLEAN DEFAULT FALSE');
        } else {
            console.log('is_featured column already exists.');
        }

        // 2. Mark items as featured
        console.log('Updating featured items...');
        await connection.query(`
            UPDATE MenuItems 
            SET is_featured = TRUE 
            WHERE name IN ('Mighty Zinger', 'Family Bucket', 'Zinger Burger', 'Hot Wings (10 Pcs)')
        `);

        console.log('Migration completed successfully! ✅');
    } catch (error) {
        console.error('Migration failed: ❌', error.message);
    } finally {
        await connection.end();
    }
}

migrate();
