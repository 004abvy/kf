const mysql = require("mysql2/promise");
const fs = require("fs");
const path = require("path");
require("dotenv").config();

async function initializeDatabase() {
  // First connection (without database) to create DB
  const connection = await mysql.createConnection({
    host: process.env.DB_HOST,
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    port: process.env.DB_PORT || 3306,
  });

  try {
    console.log("🔧 Checking/Creating database...");

    // Create database if it doesn't exist
    await connection.query(`CREATE DATABASE IF NOT EXISTS \`${process.env.DB_NAME}\``);
    console.log(`✅ Database '${process.env.DB_NAME}' ready`);

    // Now connect to the database
    await connection.changeUser({ database: process.env.DB_NAME });

    // Read and execute schema SQL
    const schemaPath = path.join(__dirname, "align_schema.sql");
    if (fs.existsSync(schemaPath)) {
      const schemaSql = fs.readFileSync(schemaPath, "utf8");
      // Split by ; and filter empty statements
      const statements = schemaSql
        .split(";")
        .map((s) => s.trim())
        .filter((s) => s.length > 0 && !s.startsWith("--"));

      for (const statement of statements) {
        await connection.query(statement);
      }
      console.log("✅ Schema initialized");

      // Create indexes with error handling for idempotency
      const indexes = [
        "CREATE INDEX idx_menuitems_category ON MenuItems(category_id)",
        "CREATE INDEX idx_itemvariations_item ON ItemVariations(item_id)",
        "CREATE INDEX idx_orders_status ON Orders(order_status)",
        "CREATE INDEX idx_orders_date ON Orders(created_at)",
        "CREATE INDEX idx_staff_role ON Staff(role_id)",
      ];

      for (const indexStatement of indexes) {
        try {
          await connection.query(indexStatement);
        } catch (error) {
          // Ignore "duplicate key name" errors - index already exists
          if (!error.message.includes("Duplicate key name")) {
            throw error;
          }
        }
      }
      console.log("✅ Indexes created/verified");
    }

    console.log("🎉 Database initialization complete!");
  } catch (error) {
    console.error("❌ Database initialization failed:", error.message);
    process.exit(1);
  } finally {
    await connection.end();
  }
}

module.exports = initializeDatabase;

// Run if called directly
if (require.main === module) {
  initializeDatabase();
}
