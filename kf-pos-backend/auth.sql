-- ── AUTHENTICATION SCHEMA ──
-- Creates a secure Users table with role-based access control.

CREATE TABLE IF NOT EXISTS Users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    role ENUM('staff', 'manager', 'admin') DEFAULT 'staff',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ── OPTIONAL: Default Admin ──
-- NOTE: In a real app, you would hash this password manually or via the API.
-- INSERT INTO Users (name, email, password_hash, role) VALUES ('Admin', 'admin@kf.inc', 'PLAIN_TEXT_FOR_NOW', 'admin');
