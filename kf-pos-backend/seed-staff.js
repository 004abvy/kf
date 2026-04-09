const mysql = require('mysql2/promise');
require('dotenv').config();

(async () => {
  const pool = mysql.createPool({
    host: process.env.DB_HOST,
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    database: process.env.DB_NAME,
  });

  const conn = await pool.getConnection();

  try {
    // Insert default staff
    await conn.query(
      `INSERT INTO Staff (role_id, full_name, email, password_hash, pin_code, is_active) 
       VALUES (3, 'Default Staff', 'staff@kf.com', 'demo123', '1111', TRUE)`
    );

    const [rows] = await conn.query('SELECT staff_id, full_name, role_id FROM Staff');
    console.log('✅ Default staff created:', rows);
  } catch (err) {
    console.error('❌ Error:', err.message);
  } finally {
    conn.release();
    process.exit(0);
  }
})();
