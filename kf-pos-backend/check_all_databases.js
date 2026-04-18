const mysql = require('mysql2/promise');
require('dotenv').config();

async function checkAllDatabases() {
    try {
        const connection = await mysql.createConnection({
            host: process.env.DB_HOST,
            user: process.env.DB_USER,
            password: process.env.DB_PASSWORD,
            port: process.env.DB_PORT || 3306,
        });

        console.log('📊 Checking all databases...\n');

        // List all databases
        const [databases] = await connection.query('SHOW DATABASES');
        console.log('All databases:');
        databases.forEach(db => {
            console.log(`  - ${db.Database}`);
        });

        // Check which database we're configured to use
        console.log(`\n✅ Configured DB_NAME: ${process.env.DB_NAME}`);
        console.log(`✅ Configured DB_HOST: ${process.env.DB_HOST}`);

        // Check modifiers in the configured database
        if (process.env.DB_NAME) {
            const [mods] = await connection.query(`SELECT * FROM ${process.env.DB_NAME}.Modifiers`);
            console.log(`\n📋 Modifiers in ${process.env.DB_NAME}:`);
            mods.forEach(m => {
                console.log(`  - ID: ${m.modifier_id}, Name: ${m.name}`);
            });
        }

        await connection.end();
    } catch (error) {
        console.error('❌ Error:', error.message);
    }
}

checkAllDatabases();
