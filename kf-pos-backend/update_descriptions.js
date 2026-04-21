const fs = require('fs');
const mysql = require('mysql2/promise');
require('dotenv').config();

async function run() {
  const sql = fs.readFileSync('c:/Users/Admin/Desktop/KF/KF-GG.sql', 'utf8');
  const pool = mysql.createPool({
    host: process.env.DB_HOST,
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    database: process.env.DB_NAME,
    port: process.env.DB_PORT || 3306
  });

  // Regex to match (item_id, category_id, 'name', 'description', 'image_url')
  const matches = sql.match(/\((\d+),\s*\d+,\s*'[^']*',\s*'([^']*)',\s*'([^']*)'\)/g);
  
  if (!matches) {
    console.log("No matches found in SQL file");
    return;
  }

  let count = 0;
  for (const match of matches) {
    const parsed = match.match(/\((\d+),\s*\d+,\s*'[^']*',\s*'([^']*)',\s*'([^']*)'\)/);
    if (parsed) {
      const [all, id, desc, img] = parsed;
      await pool.query('UPDATE MenuItems SET description = ?, image_url = ? WHERE item_id = ?', [desc, img, id]);
      count++;
    }
  }

  console.log(`Updated ${count} items.`);
  process.exit(0);
}

run();
