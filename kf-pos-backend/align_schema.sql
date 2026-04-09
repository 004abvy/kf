-- ── ALIGNING AUTHENTICATION WITH STAFF SCHEMA ──
-- This script adds Email and Password support to your existing Staff table
-- so it works perfectly with the new Login Page.

-- 1. Add Email & Password columns to Staff
ALTER TABLE Staff 
ADD COLUMN email VARCHAR(255) UNIQUE AFTER full_name,
ADD COLUMN password_hash VARCHAR(255) AFTER email;

-- 2. Populate Roles (if not already filled)
INSERT IGNORE INTO Roles (role_id, role_name) VALUES 
(1, 'admin'),
(2, 'manager'),
(3, 'staff');

-- 3. (Optional) Create a default admin for testing
-- The password is 'admin123' (hashed)
-- 4. Add is_featured column to MenuItems
ALTER TABLE MenuItems ADD COLUMN is_featured BOOLEAN DEFAULT FALSE;

-- 5. Mark some popular items as featured for the "Most Wanted" section
UPDATE MenuItems SET is_featured = TRUE WHERE name IN ('Mighty Zinger', 'Family Bucket', 'Zinger Burger', 'Hot Wings (10 Pcs)');
