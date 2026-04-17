-- =====================================================
-- KF Fast Food Restaurant (Kfg) - Full Reset Script
-- Cleaned & Organized Version
-- =====================================================

-- 1. Create database and switch to it
CREATE DATABASE IF NOT EXISTS railway;
USE railway;

-- =====================================================
-- TABLE CREATION
-- =====================================================

-- ROLES
CREATE TABLE IF NOT EXISTS Roles (
    role_id INT AUTO_INCREMENT PRIMARY KEY,
    role_name VARCHAR(50) NOT NULL UNIQUE
);

-- STAFF
CREATE TABLE IF NOT EXISTS Staff (
    staff_id INT AUTO_INCREMENT PRIMARY KEY,
    role_id INT NOT NULL,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(255) UNIQUE,
    password_hash VARCHAR(255),
    pin_code VARCHAR(10) UNIQUE,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (role_id) REFERENCES Roles(role_id)
);

-- DINING TABLES
CREATE TABLE IF NOT EXISTS DiningTables (
    table_id INT AUTO_INCREMENT PRIMARY KEY,
    table_number VARCHAR(20) NOT NULL UNIQUE,
    seating_capacity INT DEFAULT 4,
    is_active BOOLEAN DEFAULT TRUE
);

-- CATEGORIES
CREATE TABLE IF NOT EXISTS Categories (
    category_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    image_url VARCHAR(255) DEFAULT NULL,
    display_order INT DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- MENU ITEMS
CREATE TABLE IF NOT EXISTS MenuItems (
    item_id INT AUTO_INCREMENT PRIMARY KEY,
    category_id INT NOT NULL,
    name VARCHAR(150) NOT NULL,
    description TEXT,
    image_url VARCHAR(255) DEFAULT NULL,
    is_featured BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (category_id) REFERENCES Categories(category_id) ON DELETE RESTRICT
);

-- ITEM VARIATIONS (sizes, half/full, etc.)
CREATE TABLE IF NOT EXISTS ItemVariations (
    variation_id INT AUTO_INCREMENT PRIMARY KEY,
    item_id INT NOT NULL,
    size_name VARCHAR(50) DEFAULT 'Regular',
    price DECIMAL(10, 2) NOT NULL,
    cost_price DECIMAL(10, 2) DEFAULT 0.00,
    sku VARCHAR(50) UNIQUE DEFAULT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (item_id) REFERENCES MenuItems(item_id) ON DELETE CASCADE
);

-- MODIFIERS
CREATE TABLE IF NOT EXISTS Modifiers (
    modifier_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    image_url VARCHAR(255) DEFAULT NULL,
    price DECIMAL(10, 2) NOT NULL,
    is_active BOOLEAN DEFAULT TRUE
);

-- ORDERS
CREATE TABLE IF NOT EXISTS Orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    order_number VARCHAR(50) UNIQUE NOT NULL,
    staff_id INT NOT NULL,
    table_id INT DEFAULT NULL,
    order_type ENUM('Dine-in', 'Takeaway', 'Delivery', 'Website Delivery') NOT NULL,
    order_status ENUM('Pending', 'Preparing', 'Ready', 'Completed', 'Cancelled') DEFAULT 'Pending',
    subtotal DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    tax_amount DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    discount_amount DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    total_amount DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    customer_phone VARCHAR(20) DEFAULT NULL,
    delivery_address VARCHAR(255) DEFAULT NULL,
    rejection_reason VARCHAR(255) DEFAULT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (staff_id) REFERENCES Staff(staff_id),
    FOREIGN KEY (table_id) REFERENCES DiningTables(table_id)
);

-- ORDER ITEMS
CREATE TABLE IF NOT EXISTS OrderItems (
    order_item_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    variation_id INT DEFAULT NULL,
    standalone_name VARCHAR(100) DEFAULT NULL,
    quantity INT NOT NULL DEFAULT 1,
    unit_price DECIMAL(10, 2) NOT NULL,
    subtotal DECIMAL(10, 2) NOT NULL,
    kitchen_notes VARCHAR(255) DEFAULT NULL,
    modifiers VARCHAR(255) DEFAULT NULL,
    FOREIGN KEY (order_id) REFERENCES Orders(order_id) ON DELETE CASCADE,
    FOREIGN KEY (variation_id) REFERENCES ItemVariations(variation_id) ON DELETE RESTRICT
);

-- ORDER ITEM MODIFIERS
CREATE TABLE IF NOT EXISTS OrderItemModifiers (
    order_item_modifier_id INT AUTO_INCREMENT PRIMARY KEY,
    order_item_id INT NOT NULL,
    modifier_id INT NOT NULL,
    modifier_price DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (order_item_id) REFERENCES OrderItems(order_item_id) ON DELETE CASCADE,
    FOREIGN KEY (modifier_id) REFERENCES Modifiers(modifier_id) ON DELETE RESTRICT
);

-- PAYMENTS
CREATE TABLE IF NOT EXISTS Payments (
    payment_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    payment_method ENUM('Cash', 'Card', 'COD', 'Wallet', 'Bank') NOT NULL,
    amount_paid DECIMAL(10, 2) NOT NULL,
    payment_status ENUM('Pending', 'Completed', 'Failed', 'Refunded') DEFAULT 'Pending',
    transaction_id VARCHAR(100) DEFAULT 'N/A',
    transaction_reference VARCHAR(100) DEFAULT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES Orders(order_id) ON DELETE RESTRICT
);

-- DELIVERY LOCATIONS
CREATE TABLE IF NOT EXISTS delivery_locations (
    id INT AUTO_INCREMENT PRIMARY KEY,
    area_name VARCHAR(100) NOT NULL,
    delivery_fee INT DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================
-- SEED DATA
-- =====================================================

-- 2. Populate Roles (if not already filled)
INSERT IGNORE INTO Roles (role_id, role_name) VALUES 
(1, 'admin'),
(2, 'manager'),
(3, 'staff');

-- 3. Add Modifiers with images
INSERT IGNORE INTO Modifiers (name, image_url, price, is_active) VALUES
('Each Sauce (Nashville)', 'https://images.unsplash.com/photo-1472476443507-c7a5948772bf?w=600', 50.00, TRUE),
('Extra Bread', 'https://images.unsplash.com/photo-1598373182133-52452f7691ef?w=600', 30.00, TRUE),
('Extra Sauce', 'https://images.unsplash.com/photo-1585238341267-1cb0a8d4d7ba?w=600', 25.00, TRUE),
('Extra Chicken', 'https://images.unsplash.com/photo-1562967914-608f82629710?w=600', 100.00, TRUE),
('Extra Cheese', 'https://static.tossdown.com/images/aea58297-7638-4970-9fb3-937fd9588b3b.webp', 40.00, TRUE),
('Add Small Crinkle Fries', 'https://images.unsplash.com/photo-1576107232684-1279f3908594?w=600', 150.00, TRUE);

-- 4. Add Categories
INSERT IGNORE INTO Categories (category_id, name, image_url, display_order, is_active) VALUES
(1, 'Burgers', 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=600', 1, TRUE),
(2, 'Wings', 'https://images.unsplash.com/photo-1626082927389-6cd097cdc6ec?w=600', 2, TRUE),
(3, 'Shawarma', 'https://images.unsplash.com/photo-1599599810694-f3f0efb1588b?w=600', 3, TRUE),
(4, 'Sides', 'https://images.unsplash.com/photo-1576107232684-1279f3908594?w=600', 4, TRUE),
(5, 'Desserts', 'https://images.unsplash.com/photo-1578985545062-69928b1d9587?w=600', 5, TRUE),
(6, 'Beverages', 'https://images.unsplash.com/photo-1554866585-c4db4d2b3e23?w=600', 6, TRUE);

-- 5. Add Menu Items
INSERT IGNORE INTO MenuItems (item_id, category_id, name, description, image_url, is_featured, is_active) VALUES
(1, 1, 'Mighty Zinger', 'Spicy crispy chicken burger with special sauce', 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=600', TRUE, TRUE),
(2, 1, 'Zinger Burger', 'Classic golden fried chicken burger', 'https://images.unsplash.com/photo-1550547990-3-4bab63c9b60?w=600', TRUE, TRUE),
(3, 2, 'Hot Wings (10 Pcs)', 'Crispy hot and spicy chicken wings', 'https://images.unsplash.com/photo-1626082927389-6cd097cdc6ec?w=600', TRUE, TRUE),
(4, 2, 'Family Bucket', 'Mixed chicken bucket - perfect for family', 'https://images.unsplash.com/photo-1626082927389-6cd097cdc6ec?w=600', TRUE, TRUE),
(5, 3, 'Chicken Shawarma', 'Grilled chicken shawarma with tahini sauce', 'https://images.unsplash.com/photo-1599599810694-f3f0efb1588b?w=600', FALSE, TRUE),
(6, 3, 'Beef Shawarma', 'Tender beef shawarma with garlic sauce', 'https://images.unsplash.com/photo-1599599810694-f3f0efb1588b?w=600', FALSE, TRUE),
(7, 4, 'Crinkle Fries', 'Golden crispy waffle fries', 'https://images.unsplash.com/photo-1576107232684-1279f3908594?w=600', FALSE, TRUE),
(8, 4, 'Onion Rings', 'Crispy battered onion rings', 'https://images.unsplash.com/photo-1473093295203-cad00df16207?w=600', FALSE, TRUE),
(9, 5, 'Chocolate Cake', 'Rich and moist chocolate cake', 'https://images.unsplash.com/photo-1578985545062-69928b1d9587?w=600', FALSE, TRUE),
(10, 6, 'Coca Cola', 'Cold refreshing cola drink', 'https://images.unsplash.com/photo-1554866585-c4db4d2b3e23?w=600', FALSE, TRUE);

-- 6. Add Item Variations (Prices)
INSERT IGNORE INTO ItemVariations (variation_id, item_id, size_name, price, cost_price, is_active) VALUES
(1, 1, 'Regular', 450.00, 200.00, TRUE),
(2, 1, 'Large', 550.00, 250.00, TRUE),
(3, 2, 'Regular', 380.00, 160.00, TRUE),
(4, 2, 'Large', 480.00, 210.00, TRUE),
(5, 3, 'Regular', 520.00, 220.00, TRUE),
(6, 3, 'Family', 1200.00, 500.00, TRUE),
(7, 4, 'Family Pack', 1800.00, 750.00, TRUE),
(8, 5, 'Full', 450.00, 180.00, TRUE),
(9, 5, 'Half', 280.00, 120.00, TRUE),
(10, 6, 'Full', 480.00, 190.00, TRUE),
(11, 6, 'Half', 300.00, 130.00, TRUE),
(12, 7, 'Small', 150.00, 60.00, TRUE),
(13, 7, 'Large', 250.00, 100.00, TRUE),
(14, 8, 'Regular', 180.00, 70.00, TRUE),
(15, 9, 'Single', 200.00, 80.00, TRUE),
(16, 10, 'Small', 120.00, 40.00, TRUE),
(17, 10, 'Large', 180.00, 60.00, TRUE);
