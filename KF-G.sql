-- =====================================================
-- KF Fast Food Restaurant (Kf-g) - Full Reset Script
-- =====================================================

-- 1. Create database and switch to it
CREATE DATABASE Kfg;
USE Kfg;
ALTER TABLE OrderItems ADD COLUMN modifiers VARCHAR(255) DEFAULT NULL;
INSERT INTO Modifiers (name, price, is_active) VALUES ('Extra Cheese', 80.00, TRUE);
INSERT INTO Modifiers (name, price, is_active) VALUES ('Extra Shawarma Bread', 50.00, TRUE);
INSERT INTO Modifiers (name, price, is_active) VALUES ('Add Small  Crinkle Fries', 200.00, TRUE);

ALTER TABLE OrderItems MODIFY variation_id INT NULL;
ALTER TABLE OrderItems ADD COLUMN standalone_name VARCHAR(100) DEFAULT NULL;

ALTER TABLE Orders ADD COLUMN rejection_reason VARCHAR(255) DEFAULT NULL;









-- 1. Create the delivery locations table
CREATE TABLE delivery_locations (
    id INT AUTO_INCREMENT PRIMARY KEY,
    area_name VARCHAR(100) NOT NULL,
    delivery_fee INT DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 2. Insert default predefined areas (Sabzazar & nearby)
INSERT INTO delivery_locations (area_name, delivery_fee) VALUES 
('Sabzazar', 0),
('Awan Town', 100),
('Marghzar Colony', 100);


ALTER TABLE Orders ADD COLUMN delivery_address VARCHAR(255) NULL;








ALTER TABLE Payments ADD COLUMN transaction_id VARCHAR(100) DEFAULT 'N/A';
Truncate table Modifiers;
DELETE FROM Staff;
ALTER TABLE Staff AUTO_INCREMENT = 1;

ALTER TABLE Orders MODIFY COLUMN order_status VARCHAR(50) DEFAULT 'Pending';


ALTER TABLE Payments MODIFY COLUMN payment_status VARCHAR(50) DEFAULT 'Pending';

ALTER TABLE Orders ADD COLUMN status VARCHAR(50) DEFAULT 'Pending';


ALTER TABLE Payments ADD COLUMN payment_status VARCHAR(50) DEFAULT 'Pending';


ALTER TABLE Payments MODIFY COLUMN payment_method ENUM('Cash', 'Card', 'cod', 'wallet', 'bank');

ALTER TABLE Orders MODIFY COLUMN order_type ENUM('Dine-in', 'Takeaway', 'Delivery', 'Website Delivery');

INSERT INTO Staff (role_id, full_name, email, password_hash, pin_code, is_active) 
VALUES (3, 'Website System', 'web@kffastfood.com', 'dummy_hash', '0000', TRUE);


-- 2. Disable safe updates and foreign key checks
SET SQL_SAFE_UPDATES = 1;
SET FOREIGN_KEY_CHECKS = 1;

-- 3. Drop all tables if they exist (order matters due to FK)
DROP TABLE IF EXISTS OrderItemModifiers;
DROP TABLE IF EXISTS OrderItems;
DROP TABLE IF EXISTS Payments;
DROP TABLE IF EXISTS Orders;
DROP TABLE IF EXISTS ItemVariations;
DROP TABLE IF EXISTS MenuItems;
DROP TABLE IF EXISTS Modifiers;
DROP TABLE IF EXISTS Categories;
DROP TABLE IF EXISTS DiningTables;
DROP TABLE IF EXISTS Staff;
DROP TABLE IF EXISTS Roles;

-- 4. Re-enable safe updates (optional)
SET SQL_SAFE_UPDATES = 1;

-- =====================================================
-- 5. Create tables
-- =====================================================
CREATE TABLE Roles (
    role_id INT AUTO_INCREMENT PRIMARY KEY,
    role_name VARCHAR(50) NOT NULL UNIQUE
);


ALTER TABLE Staff MODIFY pin_code VARCHAR(10) NULL;

CREATE TABLE Staff (
    staff_id INT AUTO_INCREMENT PRIMARY KEY,
    role_id INT NOT NULL,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(255) UNIQUE,
    password_hash VARCHAR(255),
    pin_code VARCHAR(10) UNIQUE NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (role_id) REFERENCES Roles(role_id)
);

CREATE TABLE IF NOT EXISTS DiningTables (
    table_id INT AUTO_INCREMENT PRIMARY KEY,
    table_number VARCHAR(20) NOT NULL UNIQUE,
    seating_capacity INT DEFAULT 4,
    is_active BOOLEAN DEFAULT TRUE
);

-- ==========================================
-- 2. MENU ARCHITECTURE (Categories, Items, Modifiers)
-- ==========================================

CREATE TABLE IF NOT EXISTS Categories (
    category_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    display_order INT DEFAULT 0, -- To sort tabs on the POS screen
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS MenuItems (
    item_id INT AUTO_INCREMENT PRIMARY KEY,
    category_id INT NOT NULL,
    name VARCHAR(150) NOT NULL,
    description TEXT,
    image_url VARCHAR(255) DEFAULT NULL, -- Future-proof for digital menus
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (category_id) REFERENCES Categories(category_id) ON DELETE RESTRICT
);

-- "Variations" handles sizes, half/full, and single-size items securely
CREATE TABLE IF NOT EXISTS ItemVariations (
    variation_id INT AUTO_INCREMENT PRIMARY KEY,
    item_id INT NOT NULL,
    size_name VARCHAR(50) DEFAULT 'Regular', 
    price DECIMAL(10, 2) NOT NULL,
    cost_price DECIMAL(10, 2) DEFAULT 0.00, -- Future-proof for profit margin tracking
    sku VARCHAR(50) UNIQUE DEFAULT NULL, -- Barcode/Internal code
    is_active BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (item_id) REFERENCES MenuItems(item_id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS Modifiers (
    modifier_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    is_active BOOLEAN DEFAULT TRUE
);

-- ==========================================
-- 3. TRANSACTION ENGINE (Orders, Payments)
-- ==========================================

CREATE TABLE IF NOT EXISTS Orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    order_number VARCHAR(50) UNIQUE NOT NULL, -- e.g., ORD-20260404-001
    staff_id INT NOT NULL,
    table_id INT DEFAULT NULL, -- NULL if takeaway/delivery
    order_type ENUM('Dine-In', 'Takeaway', 'Delivery') NOT NULL,
    order_status ENUM('Pending', 'Preparing', 'Ready', 'Completed', 'Cancelled') DEFAULT 'Pending',
    subtotal DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    tax_amount DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    discount_amount DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    total_amount DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (staff_id) REFERENCES Staff(staff_id),
    FOREIGN KEY (table_id) REFERENCES DiningTables(table_id)
);

CREATE TABLE IF NOT EXISTS OrderItems (
    order_item_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    variation_id INT NOT NULL,
    quantity INT NOT NULL DEFAULT 1,
    unit_price DECIMAL(10, 2) NOT NULL, -- Locked in at time of sale
    subtotal DECIMAL(10, 2) NOT NULL,
    kitchen_notes VARCHAR(255) DEFAULT NULL, -- e.g., "No onions"
    FOREIGN KEY (order_id) REFERENCES Orders(order_id) ON DELETE CASCADE,
    FOREIGN KEY (variation_id) REFERENCES ItemVariations(variation_id) ON DELETE RESTRICT
);

CREATE TABLE IF NOT EXISTS OrderItemModifiers (
    order_item_modifier_id INT AUTO_INCREMENT PRIMARY KEY,
    order_item_id INT NOT NULL,
    modifier_id INT NOT NULL,
    modifier_price DECIMAL(10, 2) NOT NULL, -- Locked in at time of sale
    FOREIGN KEY (order_item_id) REFERENCES OrderItems(order_item_id) ON DELETE CASCADE,
    FOREIGN KEY (modifier_id) REFERENCES Modifiers(modifier_id) ON DELETE RESTRICT
);

CREATE TABLE IF NOT EXISTS Payments (
    payment_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    payment_method ENUM('Cash', 'Credit Card', 'Debit Card', 'Mobile Wallet') NOT NULL,
    amount_paid DECIMAL(10, 2) NOT NULL,
    payment_status ENUM('Pending', 'Completed', 'Failed', 'Refunded') DEFAULT 'Completed',
    transaction_reference VARCHAR(100) DEFAULT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES Orders(order_id) ON DELETE RESTRICT
);

-- ==========================================
-- INDEXES FOR PERFORMANCE (Crucial for large queries)
-- ==========================================
CREATE INDEX idx_menuitems_category ON MenuItems(category_id);
CREATE INDEX idx_itemvariations_item ON ItemVariations(item_id);
CREATE INDEX idx_orders_status ON Orders(order_status);
CREATE INDEX idx_orders_date ON Orders(created_at);

-- =================================================================
-- BASE CONFIGURATION DATA INSERTION
-- =================================================================

INSERT INTO Roles (role_name) VALUES ('Admin'), ('Manager'), ('Cashier');
INSERT INTO Staff (role_id, full_name, pin_code) VALUES (1, 'System Admin', '9999'), (3, 'Counter Register 1', '1234');
INSERT INTO DiningTables (table_number, seating_capacity) VALUES ('T1', 2), ('T2', 4), ('T3', 4), ('T4', 6), ('VIP-1', 8);

-- =================================================================
-- COMPLETE MENU DATA INSERTION
-- =================================================================

INSERT INTO Categories (category_id, name, display_order) VALUES 
(1, 'Starters', 1), (2, 'Main Course', 2), (3, 'Rice', 3), (4, 'Nashville & Loaded', 4), 
(5, 'Burgers', 5), (6, 'Sandwiches', 6), (7, 'Wings & Salads', 7), (8, 'Platters & Shawarmas', 8), 
(9, 'Pizzas', 9), (10, 'Pastas & Oven Baked', 10), (11, 'Fries', 11), (12, 'Beverages', 12), 
(13, 'Shakes', 13), (14, 'Margaritas & Juices', 14), (15, 'Chillar', 15), (16, 'Deals', 16);

-- 1. STARTERS
INSERT INTO MenuItems (item_id, category_id, name) VALUES
(1, 1, 'Chicken Corn Soup'), (2, 1, 'Chicken Hot & Sour Soup'), (3, 1, 'Fish Cracker'), (4, 1, 'Drum Sticks (4 Piece)');
INSERT INTO ItemVariations (item_id, size_name, price) VALUES
(1, 'Half', 220), (1, 'Full', 850), (2, 'Half', 220), (2, 'Full', 850), (3, 'Regular', 400), (4, 'Regular', 1000);

-- 2. MAIN COURSE
INSERT INTO MenuItems (item_id, category_id, name) VALUES
(5, 2, 'Chicken Shashlik With Rice'), (6, 2, 'Chicken Manchurian With Rice'), (7, 2, 'Chicken Black Pepper With Rice'), 
(8, 2, 'Chicken Garlic With Rice'), (9, 2, 'Chicken Szechuan With Rice'), (10, 2, 'KF Special With Rice'), 
(11, 2, 'Chicken Chilli Dry With Rice'), (12, 2, 'Chicken Almond With Rice'), (13, 2, 'King Pao Chicken With Rice'), 
(14, 2, 'Chicken Vegetable With Rice'), (15, 2, 'Chicken Sweet & Sour With Rice'), (16, 2, 'Hot Sauce Chicken With Rice'), 
(17, 2, 'Chicken Chowmein');
INSERT INTO ItemVariations (item_id, size_name, price) VALUES
(5, 'Half', 750), (5, 'Full', 1250), (6, 'Half', 750), (6, 'Full', 1250), (7, 'Half', 750), (7, 'Full', 1250),
(8, 'Half', 750), (8, 'Full', 1250), (9, 'Half', 750), (9, 'Full', 1250), (10, 'Full', 1400), (11, 'Full', 1350), 
(12, 'Full', 1350), (13, 'Full', 1350), (14, 'Full', 1250), (15, 'Full', 1250), (16, 'Full', 1250), (17, 'Full', 850);

-- 3. RICE
INSERT INTO MenuItems (item_id, category_id, name) VALUES
(18, 3, 'Chicken Fried Rice'), (19, 3, 'Egg Fried Rice'), (20, 3, 'Chicken Masala Rice');
INSERT INTO ItemVariations (item_id, size_name, price) VALUES
(18, 'Regular', 550), (19, 'Regular', 500), (20, 'Regular', 600);

-- 4. NASHVILLE & LOADED
INSERT INTO MenuItems (item_id, category_id, name) VALUES
(21, 4, 'KF Loaded Fries'), (22, 4, 'Hot Cheeto Burrito'), (23, 4, 'KF Nashville Buritto'), (24, 4, 'KF Nashville'), (25, 4, 'Kzing');
INSERT INTO ItemVariations (item_id, size_name, price) VALUES
(21, 'Regular', 550), (22, 'Regular', 990), (23, 'Regular', 950), (24, 'Regular', 590), (25, 'Regular', 750);

-- 5. BURGERS
INSERT INTO MenuItems (item_id, category_id, name) VALUES
(26, 5, 'Beef Classic Cheddar Melt'), (27, 5, 'Double Beef Classic Cheddar Melt'), (28, 5, 'Crispy Patty Burger'), 
(29, 5, 'Chicken Chapli Kabab Burger'), (30, 5, 'Zinger Burger'), (31, 5, 'Zinger Cheese Burger'), 
(32, 5, 'Double Patty Burger'), (33, 5, 'Hot Mirchi Burger');
INSERT INTO ItemVariations (item_id, size_name, price) VALUES
(26, 'Regular', 690), (27, 'Regular', 990), (28, 'Regular', 340), (29, 'Regular', 340),
(30, 'Regular', 460), (31, 'Regular', 490), (32, 'Regular', 590), (33, 'Regular', 430);

-- 6. SANDWICHES
INSERT INTO MenuItems (item_id, category_id, name) VALUES
(34, 6, 'Chicken Sandwich'), (35, 6, 'Chicken Club Sandwich'), (36, 6, 'Chicken Cheese Sandwich'),
(37, 6, 'Euro Sandwich'), (38, 6, 'Mexican Cheese Sandwich');
INSERT INTO ItemVariations (item_id, size_name, price) VALUES
(34, 'Regular', 550), (35, 'Regular', 590), (36, 'Regular', 590), (37, 'Regular', 750), (38, 'Regular', 750);

-- 7. WINGS & SALADS
INSERT INTO MenuItems (item_id, category_id, name) VALUES
(39, 7, 'KF-Signature Wings'), (40, 7, 'Saucy Wings Garlic'), (41, 7, 'Hot Honey Wings'),
(42, 7, 'Grilled Chicken Salad'), (43, 7, 'Nashville Salad'), (44, 7, 'Hot Honey Popers');
INSERT INTO ItemVariations (item_id, size_name, price) VALUES
(39, 'Regular', 590), (40, 'Regular', 590), (41, 'Regular', 590), (42, 'Regular', 520), (43, 'Regular', 520), (44, 'Regular', 650);

-- 8. PLATTERS & SHAWARMAS
INSERT INTO MenuItems (item_id, category_id, name) VALUES
(45, 8, 'Chicken Platter'), (46, 8, 'Chicken Cheese Platter'), (47, 8, 'Chicken Shawarma'), (48, 8, 'Chicken Cheese Shawarma');
INSERT INTO ItemVariations (item_id, size_name, price) VALUES
(45, 'Regular', 1150), (46, 'Regular', 1180), (47, 'Regular', 420), (48, 'Regular', 460);

-- 9. PIZZAS
INSERT INTO MenuItems (item_id, category_id, name) VALUES
(49, 9, 'Chicken Tikka Pizza'), (50, 9, 'Chicken Fajita Pizza'), (51, 9, 'Hot & Spicy Pizza'), (52, 9, 'Chicken Mushroom Pizza'), 
(53, 9, 'BBQ Pizza'), (54, 9, 'American Hot Pizza'), (55, 9, 'Pepperoni Pizza'), (56, 9, 'Chicken Supreme Pizza'), 
(57, 9, 'Crown Crust Pizza'), (58, 9, 'Behari Kabab Pizza'), (59, 9, 'K.F Special Pizza'), (60, 9, 'Malai Boti Pizza'),
(61, 9, 'Mexican Pizza'), (62, 9, 'Kabab Stuffer'), (63, 9, 'Cheese Stuffer');
INSERT INTO ItemVariations (item_id, size_name, price) VALUES
(49, 'Medium', 1250), (49, 'Large', 1590), (50, 'Medium', 1250), (50, 'Large', 1590),
(51, 'Medium', 1250), (51, 'Large', 1590), (52, 'Medium', 1250), (52, 'Large', 1590),
(53, 'Medium', 1250), (53, 'Large', 1590), (54, 'Medium', 1250), (54, 'Large', 1590),
(55, 'Medium', 1250), (55, 'Large', 1590), (56, 'Medium', 1250), (56, 'Large', 1590),
(57, 'Medium', 1450), (57, 'Large', 1850), (58, 'Medium', 1450), (58, 'Large', 1850),
(59, 'Small', 560), (59, 'Medium', 1250), (59, 'Large', 1790),
(60, 'Medium', 1250), (60, 'Large', 1790), (61, 'Medium', 1250), (61, 'Large', 1790),
(62, 'Medium', 1450), (62, 'Large', 1950), (63, 'Medium', 1450), (63, 'Large', 1950);

-- 10. PASTAS & OVEN BAKED
INSERT INTO MenuItems (item_id, category_id, name) VALUES
(64, 10, 'Kabab Cheesy Roll'), (65, 10, 'Chicken Cheesy Roll'), (66, 10, 'Crunchy Chicken Pasta'), (67, 10, 'Creamy Pasta'), 
(68, 10, 'Macaroni Pasta'), (69, 10, 'Oven Baked Wings (10 pcs)'), (70, 10, 'Malai Botti Spin Rolls (4 pcs)'), 
(71, 10, 'Chicken Spin Rolls (4 pcs)'), (72, 10, 'Chilli Milli Rolls (4 pcs)'), (73, 10, 'Special Platter');
INSERT INTO ItemVariations (item_id, size_name, price) VALUES
(64, 'Regular', 950), (65, 'Regular', 950), (66, 'Regular', 850), (67, 'Regular', 750), (68, 'Regular', 750), 
(69, 'Regular', 650), (70, 'Regular', 590), (71, 'Regular', 590), (72, 'Regular', 660), (73, 'Regular', 1150);

-- 11. FRIES
INSERT INTO MenuItems (item_id, category_id, name) VALUES (74, 11, 'Crinkle Fries');
INSERT INTO ItemVariations (item_id, size_name, price) VALUES (74, 'Small', 200), (74, 'Large', 320), (74, 'Family', 400);

-- 12-15. BEVERAGES, SHAKES, MARGARITAS, CHILLAR
INSERT INTO MenuItems (item_id, category_id, name) VALUES
(75, 12, 'Small Water Bottle'), (76, 12, 'Reg Drink Glass'), (77, 13, 'Oreo Shake'), (78, 13, 'Chocolate Shake'), 
(79, 13, 'Strawberry Shake'), (80, 13, 'Pink Barbie Shake'), (81, 13, 'Cold Coffee'), (82, 13, 'Pina Colada'), 
(83, 13, 'Blue Lagoon'), (84, 13, 'Chocolate Peanut Butter Shake'), (85, 13, 'Power House Shake'),
(86, 14, 'Mint Margarita'), (87, 14, 'Mango Smoothie'), (88, 14, 'Strawberry Margarita'), (89, 14, 'Peach Smoothie'), 
(90, 14, 'Blueberry Margarita'), (91, 14, 'Banana Smoothie'), (92, 14, 'Apple Mint'), (93, 14, 'Gawa Smoothie'), 
(94, 14, 'Lime Margarita'), (95, 14, 'Apple Juice'), (96, 14, 'Lemu Pani'), (97, 14, 'Orange (Seasonal)'),
(98, 15, 'Lemon Soda'), (99, 15, 'Peach Iced Tea'), (100, 15, 'Mint Lime Mojito'), (101, 15, 'Passion Fruit Mojito'), 
(102, 15, 'Strawberry Mojito'), (103, 15, 'Raspberry Iced Tea'), (104, 15, 'Strawberry Kiwi Chillar'), 
(105, 15, 'Lighting Shot'), (106, 15, 'Purple Heaven'), (107, 15, 'Electric Lemonade'), (108, 15, 'Orange Italian Soda'), (109, 15, 'Kiwi Chillar');




-- 1. Insert Coke and Sprite with safely high IDs
INSERT INTO MenuItems (item_id, category_id, name) VALUES 
(501, 12, 'Coke'), 
(502, 12, 'Sprite');

-- 2. Link the Half Litre and 1 Litre sizes to Coke (501)
INSERT INTO ItemVariations (item_id, size_name, price) VALUES
(501, 'Half Litre', 150.00),
(501, '1 Litre', 250.00);

-- 3. Link the Half Litre and 1 Litre sizes to Sprite (502)
INSERT INTO ItemVariations (item_id, size_name, price) VALUES
(502, 'Half Litre', 150.00),
(502, '1 Litre', 250.00);




INSERT INTO ItemVariations (item_id, size_name, price) VALUES
(75, 'Regular', 60), (76, 'Regular', 100),
(77, 'Regular', 400), (78, 'Regular', 400), (79, 'Regular', 400), (80, 'Regular', 400), (81, 'Regular', 400), 
(82, 'Regular', 400), (83, 'Regular', 400), (84, 'Regular', 400), (85, 'Regular', 400),
(86, 'Regular', 300), (87, 'Regular', 300), (88, 'Regular', 300), (89, 'Regular', 300), (90, 'Regular', 300), 
(91, 'Regular', 300), (92, 'Regular', 300), (93, 'Regular', 300), (94, 'Regular', 300), (95, 'Regular', 300), 
(96, 'Regular', 300), (97, 'Regular', 300),
(98, 'Regular', 350), (99, 'Regular', 350), (100, 'Regular', 350), (101, 'Regular', 350), (102, 'Regular', 350), 
(103, 'Regular', 350), (104, 'Regular', 350), (105, 'Regular', 350), (106, 'Regular', 350), (107, 'Regular', 350), 
(108, 'Regular', 350), (109, 'Regular', 350);

-- 16. DEALS
INSERT INTO MenuItems (item_id, category_id, name) VALUES
(110, 16, 'Nashville Tenders Family Deal'), (111, 16, 'Nashville Tenders 2 Person Deal'), (112, 16, 'Nashville Tenders Single Deal'), 
(113, 16, 'Deal-1 (Mazedari)'), (114, 16, 'Deal-2 (Mazedari)'), (115, 16, 'Deal-3 (Mazedari)'), (116, 16, 'Deal-4 (Mazedari)'), 
(117, 16, 'Deal-5 (Mazedari)'), (118, 16, 'Deal-6 (Mazedari)'), (119, 16, 'Deal-7 (Exclusive)'), (120, 16, 'Deal-8 (Exclusive)'), 
(121, 16, 'Deal-9 (Exclusive)'), (122, 16, 'Deal-10 (Exclusive)'), (123, 16, 'Deal-11 (Exclusive)'), (124, 16, 'Deal-12 (Exclusive)'), (125, 16, 'Deal-13 (Exclusive)');
INSERT INTO ItemVariations (item_id, size_name, price) VALUES
(110, 'Regular', 2200), (111, 'Regular', 1550), (112, 'Regular', 850),
(113, 'Regular', 590), (114, 'Regular', 460), (115, 'Regular', 790), (116, 'Regular', 1650), (117, 'Regular', 2450), 
(118, 'Regular', 750), (119, 'Regular', 3250), (120, 'Regular', 3550), (121, 'Regular', 2650), (122, 'Regular', 2150), 
(123, 'Regular', 2950), (124, 'Regular', 750), (125, 'Regular', 4310);

-- =================================================================
-- MODIFIERS
-- =================================================================
INSERT INTO Modifiers (name, price) VALUES
('Each Sauce (Nashville)', 70), ('Extra Bread', 50), ('Extra Sauce', 50), 
('Extra Chicken', 500), ('Extra Cheese', 80), ('Extra Shawarma Bread', 50);






-- Insert fresh default data
INSERT INTO Roles (role_id, role_name) VALUES 
(1, 'admin'), 
(2, 'manager'), 
(3, 'staff');

INSERT INTO Staff (role_id, full_name, email, password_hash, pin_code) 
VALUES (1, 'Admin', 'adminkf@gmail.com', '$2a$12$8GGCjBZ1NPH.EJn9frfI/.KMGLqQzH669hUx/ikUW8CcRzOyQHf06', '1323');






SELECT 
    s.staff_id, 
    s.full_name, 
    s.email, 
    r.role_name, 
    s.pin_code, 
    s.is_active 
FROM Staff s
JOIN Roles r ON s.role_id = r.role_id;

DELETE FROM Staff;



































ALTER TABLE MenuItems ADD COLUMN image_url VARCHAR(255) DEFAULT NULL;





-- 1. STARTERS
UPDATE MenuItems SET image_url = 'https://www.connoisseurusveg.com/vegetable-noodle-soup/' WHERE item_id = 1;
UPDATE MenuItems SET image_url = 'https://PASTE-GOOGLE-LINK-HERE/hot-and-sour-soup.jpg' WHERE item_id = 2;
UPDATE MenuItems SET image_url = 'https://PASTE-GOOGLE-LINK-HERE/fish-cracker.jpg' WHERE item_id = 3;
UPDATE MenuItems SET image_url = 'https://PASTE-GOOGLE-LINK-HERE/drum-sticks.jpg' WHERE item_id = 4;

-- 2. MAIN COURSE
UPDATE MenuItems SET image_url = 'https://PASTE-GOOGLE-LINK-HERE/chicken-shashlik.jpg' WHERE item_id = 5;
UPDATE MenuItems SET image_url = 'https://PASTE-GOOGLE-LINK-HERE/chicken-manchurian.jpg' WHERE item_id = 6;
UPDATE MenuItems SET image_url = 'https://PASTE-GOOGLE-LINK-HERE/chicken-black-pepper.jpg' WHERE item_id = 7;
UPDATE MenuItems SET image_url = 'https://PASTE-GOOGLE-LINK-HERE/chicken-garlic.jpg' WHERE item_id = 8;
UPDATE MenuItems SET image_url = 'https://PASTE-GOOGLE-LINK-HERE/chicken-szechuan.jpg' WHERE item_id = 9;
UPDATE MenuItems SET image_url = 'https://PASTE-GOOGLE-LINK-HERE/kf-special-rice.jpg' WHERE item_id = 10;
UPDATE MenuItems SET image_url = 'https://PASTE-GOOGLE-LINK-HERE/chicken-chilli-dry.jpg' WHERE item_id = 11;
UPDATE MenuItems SET image_url = 'https://PASTE-GOOGLE-LINK-HERE/chicken-almond.jpg' WHERE item_id = 12;
UPDATE MenuItems SET image_url = 'https://PASTE-GOOGLE-LINK-HERE/king-pao-chicken.jpg' WHERE item_id = 13;
UPDATE MenuItems SET image_url = 'https://PASTE-GOOGLE-LINK-HERE/chicken-vegetable.jpg' WHERE item_id = 14;
UPDATE MenuItems SET image_url = 'https://PASTE-GOOGLE-LINK-HERE/sweet-and-sour-chicken.jpg' WHERE item_id = 15;
UPDATE MenuItems SET image_url = 'https://PASTE-GOOGLE-LINK-HERE/hot-sauce-chicken.jpg' WHERE item_id = 16;
UPDATE MenuItems SET image_url = 'https://PASTE-GOOGLE-LINK-HERE/chicken-chowmein.jpg' WHERE item_id = 17;

-- 3. RICE
UPDATE MenuItems SET image_url = 'https://PASTE-GOOGLE-LINK-HERE/chicken-fried-rice.jpg' WHERE item_id = 18;
UPDATE MenuItems SET image_url = 'https://PASTE-GOOGLE-LINK-HERE/egg-fried-rice.jpg' WHERE item_id = 19;
UPDATE MenuItems SET image_url = 'https://PASTE-GOOGLE-LINK-HERE/chicken-masala-rice.jpg' WHERE item_id = 20;

-- 4. NASHVILLE & LOADED
UPDATE MenuItems SET image_url = 'https://PASTE-GOOGLE-LINK-HERE/kf-loaded-fries.jpg' WHERE item_id = 21;
UPDATE MenuItems SET image_url = 'https://PASTE-GOOGLE-LINK-HERE/hot-cheeto-burrito.jpg' WHERE item_id = 22;
UPDATE MenuItems SET image_url = 'https://PASTE-GOOGLE-LINK-HERE/nashville-burrito.jpg' WHERE item_id = 23;
UPDATE MenuItems SET image_url = 'https://PASTE-GOOGLE-LINK-HERE/kf-nashville.jpg' WHERE item_id = 24;
UPDATE MenuItems SET image_url = 'https://PASTE-GOOGLE-LINK-HERE/kzing.jpg' WHERE item_id = 25;

-- 5. BURGERS
UPDATE MenuItems SET image_url = 'https://PASTE-GOOGLE-LINK-HERE/beef-cheddar-melt.jpg' WHERE item_id = 26;
UPDATE MenuItems SET image_url = 'https://PASTE-GOOGLE-LINK-HERE/double-beef-melt.jpg' WHERE item_id = 27;
UPDATE MenuItems SET image_url = 'https://PASTE-GOOGLE-LINK-HERE/crispy-patty-burger.jpg' WHERE item_id = 28;
UPDATE MenuItems SET image_url = 'https://PASTE-GOOGLE-LINK-HERE/chapli-kabab-burger.jpg' WHERE item_id = 29;
UPDATE MenuItems SET image_url = 'https://PASTE-GOOGLE-LINK-HERE/zinger-burger.jpg' WHERE item_id = 30;
UPDATE MenuItems SET image_url = 'https://PASTE-GOOGLE-LINK-HERE/zinger-cheese-burger.jpg' WHERE item_id = 31;
UPDATE MenuItems SET image_url = 'https://PASTE-GOOGLE-LINK-HERE/double-patty-burger.jpg' WHERE item_id = 32;
UPDATE MenuItems SET image_url = 'https://PASTE-GOOGLE-LINK-HERE/hot-mirchi-burger.jpg' WHERE item_id = 33;

-- 6. SANDWICHES
UPDATE MenuItems SET image_url = 'https://PASTE-GOOGLE-LINK-HERE/chicken-sandwich.jpg' WHERE item_id = 34;
UPDATE MenuItems SET image_url = 'https://PASTE-GOOGLE-LINK-HERE/club-sandwich.jpg' WHERE item_id = 35;
UPDATE MenuItems SET image_url = 'https://PASTE-GOOGLE-LINK-HERE/chicken-cheese-sandwich.jpg' WHERE item_id = 36;
UPDATE MenuItems SET image_url = 'https://PASTE-GOOGLE-LINK-HERE/euro-sandwich.jpg' WHERE item_id = 37;
UPDATE MenuItems SET image_url = 'https://PASTE-GOOGLE-LINK-HERE/mexican-cheese-sandwich.jpg' WHERE item_id = 38;

-- 7. WINGS & SALADS
UPDATE MenuItems SET image_url = 'https://PASTE-GOOGLE-LINK-HERE/signature-wings.jpg' WHERE item_id = 39;
UPDATE MenuItems SET image_url = 'https://PASTE-GOOGLE-LINK-HERE/garlic-wings.jpg' WHERE item_id = 40;
UPDATE MenuItems SET image_url = 'https://PASTE-GOOGLE-LINK-HERE/hot-honey-wings.jpg' WHERE item_id = 41;
UPDATE MenuItems SET image_url = 'https://PASTE-GOOGLE-LINK-HERE/grilled-chicken-salad.jpg' WHERE item_id = 42;
UPDATE MenuItems SET image_url = 'https://PASTE-GOOGLE-LINK-HERE/nashville-salad.jpg' WHERE item_id = 43;
UPDATE MenuItems SET image_url = 'https://PASTE-GOOGLE-LINK-HERE/hot-honey-poppers.jpg' WHERE item_id = 44;

-- 8. PLATTERS & SHAWARMAS
UPDATE MenuItems SET image_url = 'https://PASTE-GOOGLE-LINK-HERE/chicken-platter.jpg' WHERE item_id = 45;
UPDATE MenuItems SET image_url = 'https://PASTE-GOOGLE-LINK-HERE/cheese-platter.jpg' WHERE item_id = 46;
UPDATE MenuItems SET image_url = 'https://PASTE-GOOGLE-LINK-HERE/chicken-shawarma.jpg' WHERE item_id = 47;
UPDATE MenuItems SET image_url = 'https://PASTE-GOOGLE-LINK-HERE/cheese-shawarma.jpg' WHERE item_id = 48;

-- 9. PIZZAS
UPDATE MenuItems SET image_url = 'https://PASTE-GOOGLE-LINK-HERE/chicken-tikka-pizza.jpg' WHERE item_id = 49;
UPDATE MenuItems SET image_url = 'https://PASTE-GOOGLE-LINK-HERE/fajita-pizza.jpg' WHERE item_id = 50;
UPDATE MenuItems SET image_url = 'https://PASTE-GOOGLE-LINK-HERE/hot-and-spicy-pizza.jpg' WHERE item_id = 51;
UPDATE MenuItems SET image_url = 'https://PASTE-GOOGLE-LINK-HERE/mushroom-pizza.jpg' WHERE item_id = 52;
UPDATE MenuItems SET image_url = 'https://PASTE-GOOGLE-LINK-HERE/bbq-pizza.jpg' WHERE item_id = 53;
UPDATE MenuItems SET image_url = 'https://PASTE-GOOGLE-LINK-HERE/american-hot-pizza.jpg' WHERE item_id = 54;
UPDATE MenuItems SET image_url = 'https://PASTE-GOOGLE-LINK-HERE/pepperoni-pizza.jpg' WHERE item_id = 55;
UPDATE MenuItems SET image_url = 'https://PASTE-GOOGLE-LINK-HERE/supreme-pizza.jpg' WHERE item_id = 56;
UPDATE MenuItems SET image_url = 'https://PASTE-GOOGLE-LINK-HERE/crown-crust-pizza.jpg' WHERE item_id = 57;
UPDATE MenuItems SET image_url = 'https://PASTE-GOOGLE-LINK-HERE/behari-kabab-pizza.jpg' WHERE item_id = 58;
UPDATE MenuItems SET image_url = 'https://PASTE-GOOGLE-LINK-HERE/kf-special-pizza.jpg' WHERE item_id = 59;
UPDATE MenuItems SET image_url = 'https://PASTE-GOOGLE-LINK-HERE/malai-boti-pizza.jpg' WHERE item_id = 60;
UPDATE MenuItems SET image_url = 'https://PASTE-GOOGLE-LINK-HERE/mexican-pizza.jpg' WHERE item_id = 61;
UPDATE MenuItems SET image_url = 'https://PASTE-GOOGLE-LINK-HERE/kabab-stuffer.jpg' WHERE item_id = 62;
UPDATE MenuItems SET image_url = 'https://PASTE-GOOGLE-LINK-HERE/cheese-stuffer.jpg' WHERE item_id = 63;

-- 10. PASTAS & OVEN BAKED
UPDATE MenuItems SET image_url = 'https://PASTE-GOOGLE-LINK-HERE/kabab-cheesy-roll.jpg' WHERE item_id = 64;
UPDATE MenuItems SET image_url = 'https://PASTE-GOOGLE-LINK-HERE/chicken-cheesy-roll.jpg' WHERE item_id = 65;
UPDATE MenuItems SET image_url = 'https://PASTE-GOOGLE-LINK-HERE/crunchy-chicken-pasta.jpg' WHERE item_id = 66;
UPDATE MenuItems SET image_url = 'https://PASTE-GOOGLE-LINK-HERE/creamy-pasta.jpg' WHERE item_id = 67;
UPDATE MenuItems SET image_url = 'https://PASTE-GOOGLE-LINK-HERE/macaroni-pasta.jpg' WHERE item_id = 68;
UPDATE MenuItems SET image_url = 'https://PASTE-GOOGLE-LINK-HERE/oven-baked-wings.jpg' WHERE item_id = 69;
UPDATE MenuItems SET image_url = 'https://PASTE-GOOGLE-LINK-HERE/malai-boti-rolls.jpg' WHERE item_id = 70;
UPDATE MenuItems SET image_url = 'https://PASTE-GOOGLE-LINK-HERE/chicken-spin-rolls.jpg' WHERE item_id = 71;
UPDATE MenuItems SET image_url = 'https://PASTE-GOOGLE-LINK-HERE/chilli-milli-rolls.jpg' WHERE item_id = 72;
UPDATE MenuItems SET image_url = 'https://PASTE-GOOGLE-LINK-HERE/special-platter.jpg' WHERE item_id = 73;

-- 11. FRIES
UPDATE MenuItems SET image_url = 'https://PASTE-GOOGLE-LINK-HERE/crinkle-fries.jpg' WHERE item_id = 74;

-- 12-15. BEVERAGES, SHAKES, MARGARITAS, CHILLAR
UPDATE MenuItems SET image_url = 'https://PASTE-GOOGLE-LINK-HERE/water-bottle.jpg' WHERE item_id = 75;
UPDATE MenuItems SET image_url = 'https://PASTE-GOOGLE-LINK-HERE/drink-glass.jpg' WHERE item_id = 76;
UPDATE MenuItems SET image_url = 'https://PASTE-GOOGLE-LINK-HERE/oreo-shake.jpg' WHERE item_id = 77;
UPDATE MenuItems SET image_url = 'https://PASTE-GOOGLE-LINK-HERE/chocolate-shake.jpg' WHERE item_id = 78;
UPDATE MenuItems SET image_url = 'https://PASTE-GOOGLE-LINK-HERE/strawberry-shake.jpg' WHERE item_id = 79;
UPDATE MenuItems SET image_url = 'https://PASTE-GOOGLE-LINK-HERE/pink-barbie-shake.jpg' WHERE item_id = 80;
UPDATE MenuItems SET image_url = 'https://PASTE-GOOGLE-LINK-HERE/cold-coffee.jpg' WHERE item_id = 81;
UPDATE MenuItems SET image_url = 'https://PASTE-GOOGLE-LINK-HERE/pina-colada.jpg' WHERE item_id = 82;
UPDATE MenuItems SET image_url = 'https://PASTE-GOOGLE-LINK-HERE/blue-lagoon.jpg' WHERE item_id = 83;
UPDATE MenuItems SET image_url = 'https://PASTE-GOOGLE-LINK-HERE/peanut-butter-shake.jpg' WHERE item_id = 84;
UPDATE MenuItems SET image_url = 'https://PASTE-GOOGLE-LINK-HERE/power-house-shake.jpg' WHERE item_id = 85;
UPDATE MenuItems SET image_url = 'https://PASTE-GOOGLE-LINK-HERE/mint-margarita.jpg' WHERE item_id = 86;
UPDATE MenuItems SET image_url = 'https://PASTE-GOOGLE-LINK-HERE/mango-smoothie.jpg' WHERE item_id = 87;
UPDATE MenuItems SET image_url = 'https://PASTE-GOOGLE-LINK-HERE/strawberry-margarita.jpg' WHERE item_id = 88;
UPDATE MenuItems SET image_url = 'https://PASTE-GOOGLE-LINK-HERE/peach-smoothie.jpg' WHERE item_id = 89;
UPDATE MenuItems SET image_url = 'https://PASTE-GOOGLE-LINK-HERE/blueberry-margarita.jpg' WHERE item_id = 90;
UPDATE MenuItems SET image_url = 'https://PASTE-GOOGLE-LINK-HERE/banana-smoothie.jpg' WHERE item_id = 91;
UPDATE MenuItems SET image_url = 'https://PASTE-GOOGLE-LINK-HERE/apple-mint.jpg' WHERE item_id = 92;
UPDATE MenuItems SET image_url = 'https://PASTE-GOOGLE-LINK-HERE/gawa-smoothie.jpg' WHERE item_id = 93;
UPDATE MenuItems SET image_url = 'https://PASTE-GOOGLE-LINK-HERE/lime-margarita.jpg' WHERE item_id = 94;
UPDATE MenuItems SET image_url = 'https://PASTE-GOOGLE-LINK-HERE/apple-juice.jpg' WHERE item_id = 95;
UPDATE MenuItems SET image_url = 'https://PASTE-GOOGLE-LINK-HERE/lemu-pani.jpg' WHERE item_id = 96;
UPDATE MenuItems SET image_url = 'https://PASTE-GOOGLE-LINK-HERE/orange-juice.jpg' WHERE item_id = 97;
UPDATE MenuItems SET image_url = 'https://PASTE-GOOGLE-LINK-HERE/lemon-soda.jpg' WHERE item_id = 98;
UPDATE MenuItems SET image_url = 'https://PASTE-GOOGLE-LINK-HERE/peach-iced-tea.jpg' WHERE item_id = 99;
UPDATE MenuItems SET image_url = 'https://PASTE-GOOGLE-LINK-HERE/mint-lime-mojito.jpg' WHERE item_id = 100;
UPDATE MenuItems SET image_url = 'https://PASTE-GOOGLE-LINK-HERE/passion-fruit-mojito.jpg' WHERE item_id = 101;
UPDATE MenuItems SET image_url = 'https://PASTE-GOOGLE-LINK-HERE/strawberry-mojito.jpg' WHERE item_id = 102;
UPDATE MenuItems SET image_url = 'https://PASTE-GOOGLE-LINK-HERE/raspberry-iced-tea.jpg' WHERE item_id = 103;
UPDATE MenuItems SET image_url = 'https://PASTE-GOOGLE-LINK-HERE/strawberry-kiwi-chillar.jpg' WHERE item_id = 104;
UPDATE MenuItems SET image_url = 'https://PASTE-GOOGLE-LINK-HERE/lighting-shot.jpg' WHERE item_id = 105;
UPDATE MenuItems SET image_url = 'https://PASTE-GOOGLE-LINK-HERE/purple-heaven.jpg' WHERE item_id = 106;
UPDATE MenuItems SET image_url = 'https://PASTE-GOOGLE-LINK-HERE/electric-lemonade.jpg' WHERE item_id = 107;
UPDATE MenuItems SET image_url = 'https://PASTE-GOOGLE-LINK-HERE/orange-italian-soda.jpg' WHERE item_id = 108;
UPDATE MenuItems SET image_url = 'https://PASTE-GOOGLE-LINK-HERE/kiwi-chillar.jpg' WHERE item_id = 109;

-- 16. DEALS
UPDATE MenuItems SET image_url = 'https://PASTE-GOOGLE-LINK-HERE/nashville-tenders-family.jpg' WHERE item_id = 110;
UPDATE MenuItems SET image_url = 'https://PASTE-GOOGLE-LINK-HERE/nashville-tenders-2person.jpg' WHERE item_id = 111;
UPDATE MenuItems SET image_url = 'https://PASTE-GOOGLE-LINK-HERE/nashville-tenders-single.jpg' WHERE item_id = 112;
UPDATE MenuItems SET image_url = 'https://PASTE-GOOGLE-LINK-HERE/deal-1.jpg' WHERE item_id = 113;
UPDATE MenuItems SET image_url = 'https://PASTE-GOOGLE-LINK-HERE/deal-2.jpg' WHERE item_id = 114;
UPDATE MenuItems SET image_url = 'https://PASTE-GOOGLE-LINK-HERE/deal-3.jpg' WHERE item_id = 115;
UPDATE MenuItems SET image_url = 'https://PASTE-GOOGLE-LINK-HERE/deal-4.jpg' WHERE item_id = 116;
UPDATE MenuItems SET image_url = 'https://PASTE-GOOGLE-LINK-HERE/deal-5.jpg' WHERE item_id = 117;
UPDATE MenuItems SET image_url = 'https://PASTE-GOOGLE-LINK-HERE/deal-6.jpg' WHERE item_id = 118;
UPDATE MenuItems SET image_url = 'https://PASTE-GOOGLE-LINK-HERE/deal-7.jpg' WHERE item_id = 119;
UPDATE MenuItems SET image_url = 'https://PASTE-GOOGLE-LINK-HERE/deal-8.jpg' WHERE item_id = 120;
UPDATE MenuItems SET image_url = 'https://PASTE-GOOGLE-LINK-HERE/deal-9.jpg' WHERE item_id = 121;
UPDATE MenuItems SET image_url = 'https://PASTE-GOOGLE-LINK-HERE/deal-10.jpg' WHERE item_id = 122;
UPDATE MenuItems SET image_url = 'https://PASTE-GOOGLE-LINK-HERE/deal-11.jpg' WHERE item_id = 123;
UPDATE MenuItems SET image_url = 'https://PASTE-GOOGLE-LINK-HERE/deal-12.jpg' WHERE item_id = 124;
UPDATE MenuItems SET image_url = 'https://PASTE-GOOGLE-LINK-HERE/deal-13.jpg' WHERE item_id = 125;

-- EXTRA BEVERAGES
UPDATE MenuItems SET image_url = 'https://PASTE-GOOGLE-LINK-HERE/coke-bottle.jpg' WHERE item_id = 501;
UPDATE MenuItems SET image_url = 'https://PASTE-GOOGLE-LINK-HERE/sprite-bottle.jpg' WHERE item_id = 502;




































-- ============================================================
-- MenuItems Image URLs — Free Unsplash images (distinct per item)
-- ============================================================

-- 1. STARTERS
UPDATE MenuItems SET image_url = 'https://images.unsplash.com/photo-1547592180-85f173990554?w=600' WHERE item_id = 1; -- vegetable noodle soup
UPDATE MenuItems SET image_url = 'https://images.unsplash.com/photo-1585032226651-759b368d7246?w=600' WHERE item_id = 2; -- hot and sour soup
UPDATE MenuItems SET image_url = 'https://images.unsplash.com/photo-1563245372-f21724e3856d?w=600' WHERE item_id = 3; -- fish cracker
UPDATE MenuItems SET image_url = 'https://images.unsplash.com/photo-1527477396000-e27163b481c2?w=600' WHERE item_id = 4; -- drum sticks

-- 2. MAIN COURSE
UPDATE MenuItems SET image_url = 'https://images.unsplash.com/photo-1603360946369-dc9bb6258143?w=600' WHERE item_id = 5;  -- chicken shashlik
UPDATE MenuItems SET image_url = 'https://images.unsplash.com/photo-1565557623262-b51c2513a641?w=600' WHERE item_id = 6;  -- chicken manchurian
UPDATE MenuItems SET image_url = 'https://images.unsplash.com/photo-1598514983318-2f64f8f4796c?w=600' WHERE item_id = 7;  -- chicken black pepper
UPDATE MenuItems SET image_url = 'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=600' WHERE item_id = 8;  -- chicken garlic
UPDATE MenuItems SET image_url = 'https://images.unsplash.com/photo-1455619452474-d2be8b1e70cd?w=600' WHERE item_id = 9;  -- chicken szechuan
UPDATE MenuItems SET image_url = 'https://images.unsplash.com/photo-1603133872878-684f208fb84b?w=600' WHERE item_id = 10; -- kf special rice
UPDATE MenuItems SET image_url = 'https://images.unsplash.com/photo-1569050467447-ce54b3bbc37d?w=600' WHERE item_id = 11; -- chicken chilli dry
UPDATE MenuItems SET image_url = 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=600' WHERE item_id = 12; -- chicken almond
UPDATE MenuItems SET image_url = 'https://images.unsplash.com/photo-1534422298391-e4f8c172dddb?w=600' WHERE item_id = 13; -- kung pao chicken
UPDATE MenuItems SET image_url = 'https://images.unsplash.com/photo-1512058564366-18510be2db19?w=600' WHERE item_id = 14; -- chicken vegetable
UPDATE MenuItems SET image_url = 'https://images.unsplash.com/photo-1540189549336-e6e99c3679fe?w=600' WHERE item_id = 15; -- sweet and sour chicken
UPDATE MenuItems SET image_url = 'https://images.unsplash.com/photo-1574484284002-952d92456975?w=600' WHERE item_id = 16; -- hot sauce chicken
UPDATE MenuItems SET image_url = 'https://images.unsplash.com/photo-1585325701165-f1a4d3e81e36?w=600' WHERE item_id = 17; -- chicken chowmein

-- 3. RICE
UPDATE MenuItems SET image_url = 'https://images.unsplash.com/photo-1516684732162-798a0062be99?w=600' WHERE item_id = 18; -- chicken fried rice
UPDATE MenuItems SET image_url = 'https://images.unsplash.com/photo-1555126634-323283e090fa?w=600' WHERE item_id = 19; -- egg fried rice
UPDATE MenuItems SET image_url = 'https://images.unsplash.com/photo-1596560548464-f010549b84d7?w=600' WHERE item_id = 20; -- chicken masala rice

-- 4. NASHVILLE & LOADED
UPDATE MenuItems SET image_url = 'https://images.unsplash.com/photo-1630384060421-cb20d0e0649d?w=600' WHERE item_id = 21; -- kf loaded fries
UPDATE MenuItems SET image_url = 'https://images.unsplash.com/photo-1626700051175-6818013e1d4f?w=600' WHERE item_id = 22; -- hot cheeto burrito
UPDATE MenuItems SET image_url = 'https://images.unsplash.com/photo-1599974579688-8dbdd335c77f?w=600' WHERE item_id = 23; -- nashville burrito
UPDATE MenuItems SET image_url = 'https://images.unsplash.com/photo-1641673275926-e6dd53f7e4d0?w=600' WHERE item_id = 24; -- kf nashville
UPDATE MenuItems SET image_url = 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=600' WHERE item_id = 25; -- kzing

-- 5. BURGERS
UPDATE MenuItems SET image_url = 'https://images.unsplash.com/photo-1550547660-d9450f859349?w=600' WHERE item_id = 26; -- beef cheddar melt
UPDATE MenuItems SET image_url = 'https://images.unsplash.com/photo-1553979459-d2229ba7433b?w=600' WHERE item_id = 27; -- double beef melt
UPDATE MenuItems SET image_url = 'https://images.unsplash.com/photo-1596956470007-2bf6095e7e16?w=600' WHERE item_id = 28; -- crispy patty burger
UPDATE MenuItems SET image_url = 'https://images.unsplash.com/photo-1572802419224-296b0aeee0d9?w=600' WHERE item_id = 29; -- chapli kabab burger
UPDATE MenuItems SET image_url = 'https://images.unsplash.com/photo-1571091718767-18b5b1457add?w=600' WHERE item_id = 30; -- zinger burger
UPDATE MenuItems SET image_url = 'https://images.unsplash.com/photo-1606755962773-d324e0a13086?w=600' WHERE item_id = 31; -- zinger cheese burger
UPDATE MenuItems SET image_url = 'https://images.unsplash.com/photo-1594212699903-ec8a3eca50f5?w=600' WHERE item_id = 32; -- double patty burger
UPDATE MenuItems SET image_url = 'https://images.unsplash.com/photo-1610440042657-612c34d95e9f?w=600' WHERE item_id = 33; -- hot mirchi burger

-- 6. SANDWICHES
UPDATE MenuItems SET image_url = 'https://images.unsplash.com/photo-1481070555726-e2fe8357725c?w=600' WHERE item_id = 34; -- chicken sandwich
UPDATE MenuItems SET image_url = 'https://images.unsplash.com/photo-1528735602780-2552fd46c7af?w=600' WHERE item_id = 35; -- club sandwich
UPDATE MenuItems SET image_url = 'https://images.unsplash.com/photo-1550507992-eb63ffee0847?w=600' WHERE item_id = 36; -- chicken cheese sandwich
UPDATE MenuItems SET image_url = 'https://images.unsplash.com/photo-1509722747041-616f39b57569?w=600' WHERE item_id = 37; -- euro sandwich
UPDATE MenuItems SET image_url = 'https://images.unsplash.com/photo-1504515252342-f56f6e18e5c3?w=600' WHERE item_id = 38; -- mexican cheese sandwich

-- 7. WINGS & SALADS
UPDATE MenuItems SET image_url = 'https://images.unsplash.com/photo-1527477396000-e27163b481c2?w=600' WHERE item_id = 39; -- signature wings
UPDATE MenuItems SET image_url = 'https://images.unsplash.com/photo-1608039829572-78524f79c4c7?w=600' WHERE item_id = 40; -- garlic wings
UPDATE MenuItems SET image_url = 'https://images.unsplash.com/photo-1562802378-063ec186a863?w=600' WHERE item_id = 41; -- hot honey wings
UPDATE MenuItems SET image_url = 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=600' WHERE item_id = 42; -- grilled chicken salad
UPDATE MenuItems SET image_url = 'https://images.unsplash.com/photo-1540420773420-3366772f4999?w=600' WHERE item_id = 43; -- nashville salad
UPDATE MenuItems SET image_url = 'https://images.unsplash.com/photo-1548943487-a2e4e43b4853?w=600' WHERE item_id = 44; -- hot honey poppers

-- 8. PLATTERS & SHAWARMAS
UPDATE MenuItems SET image_url = 'https://images.unsplash.com/photo-1606728035253-49e8a23146de?w=600' WHERE item_id = 45; -- chicken platter
UPDATE MenuItems SET image_url = 'https://images.unsplash.com/photo-1619895092538-128341789043?w=600' WHERE item_id = 46; -- cheese platter
UPDATE MenuItems SET image_url = 'https://images.unsplash.com/photo-1529006557810-274b9b2fc783?w=600' WHERE item_id = 47; -- chicken shawarma
UPDATE MenuItems SET image_url = 'https://images.unsplash.com/photo-1642951988052-35d45a3ed4e3?w=600' WHERE item_id = 48; -- cheese shawarma

-- 9. PIZZAS
UPDATE MenuItems SET image_url = 'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=600' WHERE item_id = 49; -- chicken tikka pizza
UPDATE MenuItems SET image_url = 'https://images.unsplash.com/photo-1513104890138-7c749659a591?w=600' WHERE item_id = 50; -- fajita pizza
UPDATE MenuItems SET image_url = 'https://images.unsplash.com/photo-1628840042765-356cda07504e?w=600' WHERE item_id = 51; -- hot and spicy pizza
UPDATE MenuItems SET image_url = 'https://images.unsplash.com/photo-1574071318508-1cdbab80d002?w=600' WHERE item_id = 52; -- mushroom pizza
UPDATE MenuItems SET image_url = 'https://images.unsplash.com/photo-1558030006-450675393462?w=600' WHERE item_id = 53; -- bbq pizza
UPDATE MenuItems SET image_url = 'https://images.unsplash.com/photo-1534308983496-4fabb1a015ee?w=600' WHERE item_id = 54; -- american hot pizza
UPDATE MenuItems SET image_url = 'https://images.unsplash.com/photo-1548369937-47519962c11a?w=600' WHERE item_id = 55; -- pepperoni pizza
UPDATE MenuItems SET image_url = 'https://images.unsplash.com/photo-1555072956-7758afb20e8f?w=600' WHERE item_id = 56; -- supreme pizza
UPDATE MenuItems SET image_url = 'https://images.unsplash.com/photo-1590947132387-155cc02f3212?w=600' WHERE item_id = 57; -- crown crust pizza
UPDATE MenuItems SET image_url = 'https://images.unsplash.com/photo-1593560708920-61dd98c46a4e?w=600' WHERE item_id = 58; -- behari kabab pizza
UPDATE MenuItems SET image_url = 'https://images.unsplash.com/photo-1571407970349-bc81e7e96d47?w=600' WHERE item_id = 59; -- kf special pizza
UPDATE MenuItems SET image_url = 'https://images.unsplash.com/photo-1604382354936-07c5d9983bd3?w=600' WHERE item_id = 60; -- malai boti pizza
UPDATE MenuItems SET image_url = 'https://images.unsplash.com/photo-1513104890138-7c749659a591?w=600' WHERE item_id = 61; -- mexican pizza
UPDATE MenuItems SET image_url = 'https://images.unsplash.com/photo-1585325701165-f1a4d3e81e36?w=600' WHERE item_id = 62; -- kabab stuffer
UPDATE MenuItems SET image_url = 'https://images.unsplash.com/photo-1506354666786-959d6d497f1a?w=600' WHERE item_id = 63; -- cheese stuffer

-- 10. PASTAS & OVEN BAKED
UPDATE MenuItems SET image_url = 'https://images.unsplash.com/photo-1603360946369-dc9bb6258143?w=600' WHERE item_id = 64; -- kabab cheesy roll
UPDATE MenuItems SET image_url = 'https://images.unsplash.com/photo-1600803907087-f56d462fd26b?w=600' WHERE item_id = 65; -- chicken cheesy roll
UPDATE MenuItems SET image_url = 'https://images.unsplash.com/photo-1621996346565-e3dbc646d9a9?w=600' WHERE item_id = 66; -- crunchy chicken pasta
UPDATE MenuItems SET image_url = 'https://images.unsplash.com/photo-1555949258-eb67b1ef0ceb?w=600' WHERE item_id = 67; -- creamy pasta
UPDATE MenuItems SET image_url = 'https://images.unsplash.com/photo-1612370815901-4a1ba21d1853?w=600' WHERE item_id = 68; -- macaroni pasta
UPDATE MenuItems SET image_url = 'https://images.unsplash.com/photo-1567620832903-9fc6debc209f?w=600' WHERE item_id = 69; -- oven baked wings
UPDATE MenuItems SET image_url = 'https://images.unsplash.com/photo-1590301157890-4810ed352733?w=600' WHERE item_id = 70; -- malai boti rolls
UPDATE MenuItems SET image_url = 'https://images.unsplash.com/photo-1529543544282-ea669407fca3?w=600' WHERE item_id = 71; -- chicken spin rolls
UPDATE MenuItems SET image_url = 'https://images.unsplash.com/photo-1601050690597-df0568f70950?w=600' WHERE item_id = 72; -- chilli milli rolls
UPDATE MenuItems SET image_url = 'https://images.unsplash.com/photo-1544025162-d76694265947?w=600' WHERE item_id = 73; -- special platter

-- 11. FRIES
UPDATE MenuItems SET image_url = 'https://images.unsplash.com/photo-1576107232684-1279f390859f?w=600' WHERE item_id = 74; -- crinkle fries

-- 12. BEVERAGES
UPDATE MenuItems SET image_url = 'https://images.unsplash.com/photo-1548839140-29a749e1cf4d?w=600' WHERE item_id = 75; -- water bottle
UPDATE MenuItems SET image_url = 'https://images.unsplash.com/photo-1625772452859-1c03d884dcd7?w=600' WHERE item_id = 76; -- drink glass

-- 13. SHAKES
UPDATE MenuItems SET image_url = 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=600' WHERE item_id = 77; -- oreo shake
UPDATE MenuItems SET image_url = 'https://images.unsplash.com/photo-1572490122747-3e9197aa173f?w=600' WHERE item_id = 78; -- chocolate shake
UPDATE MenuItems SET image_url = 'https://images.unsplash.com/photo-1553361371-9b22f78e8b1d?w=600' WHERE item_id = 79; -- strawberry shake
UPDATE MenuItems SET image_url = 'https://images.unsplash.com/photo-1613478223719-2ab802602423?w=600' WHERE item_id = 80; -- pink barbie shake
UPDATE MenuItems SET image_url = 'https://images.unsplash.com/photo-1534352956036-cd81e27dd615?w=600' WHERE item_id = 81; -- cold coffee
UPDATE MenuItems SET image_url = 'https://images.unsplash.com/photo-1621263764928-df1444c5e859?w=600' WHERE item_id = 82; -- pina colada
UPDATE MenuItems SET image_url = 'https://images.unsplash.com/photo-1544145945-f90425340c7e?w=600' WHERE item_id = 83; -- blue lagoon
UPDATE MenuItems SET image_url = 'https://images.unsplash.com/photo-1569718212165-3a8278d5f624?w=600' WHERE item_id = 84; -- peanut butter shake
UPDATE MenuItems SET image_url = 'https://images.unsplash.com/photo-1585325701956-60dd9c8bc012?w=600' WHERE item_id = 85; -- power house shake

-- 14. MARGARITAS & SMOOTHIES
UPDATE MenuItems SET image_url = 'https://images.unsplash.com/photo-1556679343-c7306c1976bc?w=600' WHERE item_id = 86; -- mint margarita
UPDATE MenuItems SET image_url = 'https://images.unsplash.com/photo-1546173159-315724a31696?w=600' WHERE item_id = 87; -- mango smoothie
UPDATE MenuItems SET image_url = 'https://images.unsplash.com/photo-1604487488024-e1b5e3f5b3d9?w=600' WHERE item_id = 88; -- strawberry margarita
UPDATE MenuItems SET image_url = 'https://images.unsplash.com/photo-1563805042-7684c019e1cb?w=600' WHERE item_id = 89; -- peach smoothie
UPDATE MenuItems SET image_url = 'https://images.unsplash.com/photo-1570696516188-ade861b84a49?w=600' WHERE item_id = 90; -- blueberry margarita
UPDATE MenuItems SET image_url = 'https://images.unsplash.com/photo-1553530666-ba11a7da3888?w=600' WHERE item_id = 91; -- banana smoothie
UPDATE MenuItems SET image_url = 'https://images.unsplash.com/photo-1587015990127-424b954b6a21?w=600' WHERE item_id = 92; -- apple mint
UPDATE MenuItems SET image_url = 'https://images.unsplash.com/photo-1589733955941-5eeaf752f6dd?w=600' WHERE item_id = 93; -- guava smoothie
UPDATE MenuItems SET image_url = 'https://images.unsplash.com/photo-1513558161293-cdaf765ed2fd?w=600' WHERE item_id = 94; -- lime margarita

-- 15. JUICES & CHILLAR
UPDATE MenuItems SET image_url = 'https://images.unsplash.com/photo-1576173011850-e3e6bf2c3f94?w=600' WHERE item_id = 95; -- apple juice
UPDATE MenuItems SET image_url = 'https://images.unsplash.com/photo-1621263764928-df1444c5e859?w=600' WHERE item_id = 96; -- lemu pani
UPDATE MenuItems SET image_url = 'https://images.unsplash.com/photo-1600271886742-f049cd451bba?w=600' WHERE item_id = 97; -- orange juice
UPDATE MenuItems SET image_url = 'https://images.unsplash.com/photo-1567282093-f3f74ff1d765?w=600' WHERE item_id = 98; -- lemon soda
UPDATE MenuItems SET image_url = 'https://images.unsplash.com/photo-1556679343-c7306c1976bc?w=600' WHERE item_id = 99; -- peach iced tea
UPDATE MenuItems SET image_url = 'https://images.unsplash.com/photo-1609951651556-5334e2706168?w=600' WHERE item_id = 100; -- mint lime mojito
UPDATE MenuItems SET image_url = 'https://images.unsplash.com/photo-1595981267035-7b04ca84a82d?w=600' WHERE item_id = 101; -- passion fruit mojito
UPDATE MenuItems SET image_url = 'https://images.unsplash.com/photo-1551024709-8f23befc6f87?w=600' WHERE item_id = 102; -- strawberry mojito
UPDATE MenuItems SET image_url = 'https://images.unsplash.com/photo-1571091718767-18b5b1457add?w=600' WHERE item_id = 103; -- raspberry iced tea
UPDATE MenuItems SET image_url = 'https://images.unsplash.com/photo-1638429347076-fcbf9efc9e62?w=600' WHERE item_id = 104; -- strawberry kiwi chillar
UPDATE MenuItems SET image_url = 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=600' WHERE item_id = 105; -- lightning shot
UPDATE MenuItems SET image_url = 'https://images.unsplash.com/photo-1570696516188-ade861b84a49?w=600' WHERE item_id = 106; -- purple heaven
UPDATE MenuItems SET image_url = 'https://images.unsplash.com/photo-1497534446932-c925b458314e?w=600' WHERE item_id = 107; -- electric lemonade
UPDATE MenuItems SET image_url = 'https://images.unsplash.com/photo-1523371054106-bbf80586c38c?w=600' WHERE item_id = 108; -- orange italian soda
UPDATE MenuItems SET image_url = 'https://images.unsplash.com/photo-1561043433-aaf687c4cf04?w=600' WHERE item_id = 109; -- kiwi chillar

-- 16. DEALS
UPDATE MenuItems SET image_url = 'https://images.unsplash.com/photo-1598514982901-dfcf1f0eab5b?w=600' WHERE item_id = 110; -- nashville tenders family
UPDATE MenuItems SET image_url = 'https://images.unsplash.com/photo-1562967914-608f82629710?w=600' WHERE item_id = 111; -- nashville tenders 2person
UPDATE MenuItems SET image_url = 'https://images.unsplash.com/photo-1606728035253-49e8a23146de?w=600' WHERE item_id = 112; -- nashville tenders single
UPDATE MenuItems SET image_url = 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=600' WHERE item_id = 113; -- deal 1
UPDATE MenuItems SET image_url = 'https://images.unsplash.com/photo-1550547660-d9450f859349?w=600' WHERE item_id = 114; -- deal 2
UPDATE MenuItems SET image_url = 'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=600' WHERE item_id = 115; -- deal 3
UPDATE MenuItems SET image_url = 'https://images.unsplash.com/photo-1603360946369-dc9bb6258143?w=600' WHERE item_id = 116; -- deal 4
UPDATE MenuItems SET image_url = 'https://images.unsplash.com/photo-1544025162-d76694265947?w=600' WHERE item_id = 117; -- deal 5
UPDATE MenuItems SET image_url = 'https://images.unsplash.com/photo-1604382354936-07c5d9983bd3?w=600' WHERE item_id = 118; -- deal 6
UPDATE MenuItems SET image_url = 'https://images.unsplash.com/photo-1513104890138-7c749659a591?w=600' WHERE item_id = 119; -- deal 7
UPDATE MenuItems SET image_url = 'https://images.unsplash.com/photo-1555072956-7758afb20e8f?w=600' WHERE item_id = 120; -- deal 8
UPDATE MenuItems SET image_url = 'https://images.unsplash.com/photo-1571091718767-18b5b1457add?w=600' WHERE item_id = 121; -- deal 9
UPDATE MenuItems SET image_url = 'https://images.unsplash.com/photo-1596956470007-2bf6095e7e16?w=600' WHERE item_id = 122; -- deal 10
UPDATE MenuItems SET image_url = 'https://images.unsplash.com/photo-1528735602780-2556fd46c7af?w=600' WHERE item_id = 123; -- deal 11
UPDATE MenuItems SET image_url = 'https://images.unsplash.com/photo-1553979459-d2229ba7433b?w=600' WHERE item_id = 124; -- deal 12
UPDATE MenuItems SET image_url = 'https://images.unsplash.com/photo-1630384060421-cb20d0e0649d?w=600' WHERE item_id = 125; -- deal 13

-- EXTRA BEVERAGES
UPDATE MenuItems SET image_url = 'https://images.unsplash.com/photo-1629203851122-3726ecdf080e?w=600' WHERE item_id = 501; -- coke bottle
UPDATE MenuItems SET image_url = 'https://images.unsplash.com/photo-1625772452859-1c03d884dcd7?w=600' WHERE item_id = 502; -- sprite bottle










