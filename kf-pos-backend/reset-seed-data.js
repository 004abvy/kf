const fs = require("fs");
const path = require("path");
const mysql = require("mysql2/promise");
require("dotenv").config();

function getEffectiveDatabaseName() {
  if (process.env.MYSQLDATABASE) return process.env.MYSQLDATABASE;
  if (process.env.DB_NAME) return process.env.DB_NAME;

  if (process.env.DATABASE_URL) {
    const parsed = new URL(process.env.DATABASE_URL);
    const dbName = parsed.pathname.replace(/^\//, "").trim();
    if (dbName) return dbName;
  }

  throw new Error("No database name configured");
}

function getDbConfig() {
  const dbName = getEffectiveDatabaseName();

  if (process.env.DATABASE_URL) {
    const parsed = new URL(process.env.DATABASE_URL);
    parsed.pathname = `/${dbName}`;
    return parsed.toString();
  }

  return {
    host: process.env.DB_HOST,
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    database: dbName,
    port: process.env.DB_PORT || 3306,
    waitForConnections: true,
    connectionLimit: 5,
  };
}

async function resetSeedData() {
  const schemaPath = path.join(__dirname, "..", "KF-GG.sql");
  const schemaSql = fs.readFileSync(schemaPath, "utf8");

  const statements = schemaSql
    .split("\n")
    .filter((line) => !line.trim().startsWith("--"))
    .join("\n")
    .split(";")
    .map((stmt) => stmt.trim())
    .filter((stmt) => stmt.length > 0)
    .filter((stmt) => !/^CREATE DATABASE IF NOT EXISTS/i.test(stmt))
    .filter((stmt) => !/^USE /i.test(stmt));

  const pool = mysql.createPool(getDbConfig());
  const conn = await pool.getConnection();

  try {
    await conn.beginTransaction();
    await conn.query("SET FOREIGN_KEY_CHECKS = 0");

    // Hard reset data so only align_schema seed remains.
    const truncateOrder = [
      "OrderItemModifiers",
      "OrderItems",
      "Payments",
      "Orders",
      "ItemVariations",
      "MenuItems",
      "Modifiers",
      "Categories",
      "delivery_locations",
      "DiningTables",
      "Staff",
      "Roles",
    ];

    for (const table of truncateOrder) {
      await conn.query(`TRUNCATE TABLE \`${table}\``);
    }

    await conn.query("SET FOREIGN_KEY_CHECKS = 1");

    for (const statement of statements) {
      await conn.query(statement);
    }

    await conn.commit();
    console.log("Seed reset complete. Database now matches KF-GG.sql data.");
  } catch (error) {
    await conn.rollback();
    console.error("Seed reset failed:", error.message);
    process.exitCode = 1;
  } finally {
    conn.release();
    await pool.end();
  }
}

resetSeedData();
