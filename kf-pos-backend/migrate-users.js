const mysql = require("mysql2/promise");
require("dotenv").config();

async function migrate() {
  const dbConfig = {
    host: process.env.DB_HOST,
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    database: process.env.DB_NAME || process.env.MYSQLDATABASE,
    port: process.env.DB_PORT || 3306,
  };

  const connection = await mysql.createConnection(dbConfig);

  try {
    console.log("🚀 Starting migration...");

    // 1. Add 'Customer' role if not exists
    await connection.query("INSERT IGNORE INTO Roles (role_name) VALUES ('customer')");
    console.log("✅ 'customer' role verified.");

    // 2. Add 'customer_id' column to Orders table if not exists
    const [columns] = await connection.query("SHOW COLUMNS FROM Orders LIKE 'customer_id'");
    if (columns.length === 0) {
      await connection.query("ALTER TABLE Orders ADD COLUMN customer_id INT DEFAULT NULL");
      await connection.query("ALTER TABLE Orders ADD CONSTRAINT fk_orders_customer FOREIGN KEY (customer_id) REFERENCES Staff(staff_id)");
      console.log("✅ 'customer_id' column added to Orders table.");
    } else {
      console.log("ℹ️ 'customer_id' column already exists.");
    }

    // 3. Ensure Staff table has gmail and password (it already should)
    console.log("🎉 Migration complete!");
  } catch (error) {
    console.error("❌ Migration failed:", error);
  } finally {
    await connection.end();
  }
}

migrate();
