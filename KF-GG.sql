-- =====================================================
-- KF Fast Food Restaurant (Kfg) - Full Reset Script
-- Cleaned & Organized Version
-- =====================================================

-- 1. Create database and switch to it
CREATE DATABASE IF NOT EXISTS Kfg;
USE Kfg;

-- 2. Disable safe updates and foreign key checks
SET SQL_SAFE_UPDATES = 0;
SET FOREIGN_KEY_CHECKS = 0;

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
DROP TABLE IF EXISTS delivery_locations;

-- 4. Re-enable safe updates
SET SQL_SAFE_UPDATES = 1;

-- =====================================================
-- TABLE CREATION
-- =====================================================

-- ROLES
CREATE TABLE Roles (
    role_id INT AUTO_INCREMENT PRIMARY KEY,
    role_name VARCHAR(50) NOT NULL UNIQUE
);

-- STAFF
CREATE TABLE Staff (
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
CREATE TABLE DiningTables (
    table_id INT AUTO_INCREMENT PRIMARY KEY,
    table_number VARCHAR(20) NOT NULL UNIQUE,
    seating_capacity INT DEFAULT 4,
    is_active BOOLEAN DEFAULT TRUE
);

-- CATEGORIES
CREATE TABLE Categories (
    category_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    image_url VARCHAR(255) DEFAULT NULL,
    display_order INT DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- MENU ITEMS
CREATE TABLE MenuItems (
    item_id INT AUTO_INCREMENT PRIMARY KEY,
    category_id INT NOT NULL,
    name VARCHAR(150) NOT NULL,
    description TEXT,
    image_url VARCHAR(255) DEFAULT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (category_id) REFERENCES Categories(category_id) ON DELETE RESTRICT
);

-- ITEM VARIATIONS (sizes, half/full, etc.)
CREATE TABLE ItemVariations (
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
CREATE TABLE Modifiers (
    modifier_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    image_url VARCHAR(255) DEFAULT NULL,
    price DECIMAL(10, 2) NOT NULL,
    is_active BOOLEAN DEFAULT TRUE
);

-- ORDERS
CREATE TABLE Orders (
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
    delivery_address VARCHAR(255) DEFAULT NULL,
    rejection_reason VARCHAR(255) DEFAULT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (staff_id) REFERENCES Staff(staff_id),
    FOREIGN KEY (table_id) REFERENCES DiningTables(table_id)
);

-- ORDER ITEMS
CREATE TABLE OrderItems (
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
CREATE TABLE OrderItemModifiers (
    order_item_modifier_id INT AUTO_INCREMENT PRIMARY KEY,
    order_item_id INT NOT NULL,
    modifier_id INT NOT NULL,
    modifier_price DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (order_item_id) REFERENCES OrderItems(order_item_id) ON DELETE CASCADE,
    FOREIGN KEY (modifier_id) REFERENCES Modifiers(modifier_id) ON DELETE RESTRICT
);

-- PAYMENTS
CREATE TABLE Payments (
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
CREATE TABLE delivery_locations (
    id INT AUTO_INCREMENT PRIMARY KEY,
    area_name VARCHAR(100) NOT NULL,
    delivery_fee INT DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================
-- PERFORMANCE INDEXES
-- =====================================================
CREATE INDEX idx_menuitems_category ON MenuItems(category_id);
CREATE INDEX idx_itemvariations_item ON ItemVariations(item_id);
CREATE INDEX idx_orders_status ON Orders(order_status);
CREATE INDEX idx_orders_date ON Orders(created_at);
CREATE INDEX idx_staff_role ON Staff(role_id);

-- =====================================================
-- BASE CONFIGURATION DATA
-- =====================================================

INSERT INTO Roles (role_id, role_name) VALUES 
(1, 'admin'), 
(2, 'manager'), 
(3, 'staff');

INSERT INTO Staff (role_id, full_name, email, password_hash, pin_code, is_active) VALUES 
(1, 'Admin', 'adminkf@gmail.com', '$2a$12$8GGCjBZ1NPH.EJn9frfI/.KMGLqQzH669hUx/ikUW8CcRzOyQHf06', '1323', TRUE),
(3, 'Website System', 'web@kffastfood.com', 'dummy_hash', '0000', TRUE),
(3, 'Counter Register 1', 'counter1@kffastfood.com', 'hash_placeholder', '1234', TRUE);

INSERT INTO DiningTables (table_number, seating_capacity) VALUES 
('T1', 2), ('T2', 4), ('T3', 4), ('T4', 6), ('VIP-1', 8);

INSERT INTO delivery_locations (area_name, delivery_fee) VALUES 
('Sabzazar', 0),
('Awan Town', 100),
('Marghzar Colony', 100);

-- =====================================================
-- CATEGORIES
-- =====================================================
INSERT INTO Categories (category_id, name, display_order, image_url) VALUES 
(1, 'Starters', 1, 'https://images.unsplash.com/photo-1541529086526-db283c563270?auto=format&fit=crop&w=800&q=80'),
(2, 'Main Course', 2, 'https://images.unsplash.com/photo-1555939594-58d7cb561ad1?auto=format&fit=crop&w=800&q=80'),
(3, 'Rice', 3, 'https://images.unsplash.com/photo-1512058564366-18510be2db19?auto=format&fit=crop&w=800&q=80'),
(4, 'Nashville & Loaded', 4, 'https://images.unsplash.com/photo-1626082927389-6cd097cdc6ec?auto=format&fit=crop&w=800&q=80'),
(5, 'Burgers', 5, 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?auto=format&fit=crop&w=800&q=80'),
(6, 'Sandwiches', 6, 'https://images.unsplash.com/photo-1528735602780-2552fd46c7af?auto=format&fit=crop&w=800&q=80'),
(7, 'Wings & Salads', 7, 'https://images.unsplash.com/photo-1524114664604-cd8133cd67ad?auto=format&fit=crop&w=800&q=80'),
(8, 'Platters & Shawarmas', 8, 'https://images.unsplash.com/photo-1529006557810-274b9b2fc783?w=600'),
(9, 'Pizzas', 9, 'https://images.unsplash.com/photo-1513104890138-7c749659a591?auto=format&fit=crop&w=800&q=80'),
(10, 'Pastas & Oven Baked', 10, 'https://images.unsplash.com/photo-1551892374-ecf8754cf8b0?q=80&w=764&auto=format&fit=crop'),
(11, 'Fries', 11, 'https://images.unsplash.com/photo-1630384060421-cb20d0e0649d?q=80&w=1025&auto=format&fit=crop'),
(12, 'Beverages', 12, 'https://images.unsplash.com/photo-1541745038731-f1c2b5a1a49e?q=80&w=1963&auto=format&fit=crop'),
(13, 'Shakes', 13, 'https://images.unsplash.com/photo-1572490122747-3968b75cc699?q=80&w=687&auto=format&fit=crop'),
(14, 'Margaritas & Juices', 14, 'https://images.unsplash.com/photo-1513558161293-cdaf765ed2fd?auto=format&fit=crop&w=800&q=80'),
(15, 'Chillar', 15, 'https://images.unsplash.com/photo-1536935338788-846bb9981813?auto=format&fit=crop&w=800&q=80'),
(16, 'Deals', 16, 'https://plus.unsplash.com/premium_photo-1683657860843-abae8aa03a64?q=80&w=1470&auto=format&fit=crop');

-- =====================================================
-- MENU ITEMS & VARIATIONS
-- =====================================================

-- 1. STARTERS
INSERT INTO MenuItems (item_id, category_id, name, image_url) VALUES
(1, 1, 'Chicken Corn Soup', 'https://images.unsplash.com/photo-1547592180-85f173990554?w=600'),
(2, 1, 'Chicken Hot & Sour Soup', 'https://images.unsplash.com/photo-1585032226651-759b368d7246?w=600'),
(3, 1, 'Fish Cracker', 'https://images.unsplash.com/photo-1563245372-f21724e3856d?w=600'),
(4, 1, 'Drum Sticks (4 Piece)', 'https://images.unsplash.com/photo-1527477396000-e27163b481c2?w=600');

INSERT INTO ItemVariations (item_id, size_name, price) VALUES
(1, 'Half', 220), (1, 'Full', 850), (2, 'Half', 220), (2, 'Full', 850), 
(3, 'Regular', 400), (4, 'Regular', 1000);

-- 2. MAIN COURSE
INSERT INTO MenuItems (item_id, category_id, name, image_url) VALUES
(5, 2, 'Chicken Shashlik With Rice', 'https://images.unsplash.com/photo-1603360946369-dc9bb6258143?w=600'),
(6, 2, 'Chicken Manchurian With Rice', 'https://images.unsplash.com/photo-1565557623262-b51c2513a641?w=600'),
(7, 2, 'Chicken Black Pepper With Rice', 'https://images.unsplash.com/photo-1598514983318-2f64f8f4796c?w=600'),
(8, 2, 'Chicken Garlic With Rice', 'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=600'),
(9, 2, 'Chicken Szechuan With Rice', 'https://images.unsplash.com/photo-1455619452474-d2be8b1e70cd?w=600'),
(10, 2, 'KF Special With Rice', 'https://images.unsplash.com/photo-1603133872878-684f208fb84b?w=600'),
(11, 2, 'Chicken Chilli Dry With Rice', 'https://images.unsplash.com/photo-1569050467447-ce54b3bbc37d?w=600'),
(12, 2, 'Chicken Almond With Rice', 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=600'),
(13, 2, 'King Pao Chicken With Rice', 'https://images.unsplash.com/photo-1534422298391-e4f8c172dddb?w=600'),
(14, 2, 'Chicken Vegetable With Rice', 'https://images.unsplash.com/photo-1512058564366-18510be2db19?w=600'),
(15, 2, 'Chicken Sweet & Sour With Rice', 'https://images.unsplash.com/photo-1540189549336-e6e99c3679fe?w=600'),
(16, 2, 'Hot Sauce Chicken With Rice', 'https://images.unsplash.com/photo-1574484284002-952d92456975?w=600'),
(17, 2, 'Chicken Chowmein', 'https://images.unsplash.com/photo-1585325701165-f1a4d3e81e36?w=600');

INSERT INTO ItemVariations (item_id, size_name, price) VALUES
(5, 'Half', 750), (5, 'Full', 1250), (6, 'Half', 750), (6, 'Full', 1250), 
(7, 'Half', 750), (7, 'Full', 1250), (8, 'Half', 750), (8, 'Full', 1250), 
(9, 'Half', 750), (9, 'Full', 1250), (10, 'Full', 1400), (11, 'Full', 1350), 
(12, 'Full', 1350), (13, 'Full', 1350), (14, 'Full', 1250), (15, 'Full', 1250), 
(16, 'Full', 1250), (17, 'Full', 850);

-- 3. RICE
INSERT INTO MenuItems (item_id, category_id, name, image_url) VALUES
(18, 3, 'Chicken Fried Rice', 'https://images.unsplash.com/photo-1516684732162-798a0062be99?w=600'),
(19, 3, 'Egg Fried Rice', 'https://images.unsplash.com/photo-1555126634-323283e090fa?w=600'),
(20, 3, 'Chicken Masala Rice', 'https://images.unsplash.com/photo-1596560548464-f010549b84d7?w=600');

INSERT INTO ItemVariations (item_id, size_name, price) VALUES
(18, 'Regular', 550), (19, 'Regular', 500), (20, 'Regular', 600);

-- 4. NASHVILLE & LOADED
INSERT INTO MenuItems (item_id, category_id, name, image_url) VALUES
(21, 4, 'KF Loaded Fries', 'https://images.unsplash.com/photo-1630384060421-cb20d0e0649d?w=600'),
(22, 4, 'Hot Cheeto Burrito', 'https://images.unsplash.com/photo-1626700051175-6818013e1d4f?w=600'),
(23, 4, 'KF Nashville Burrito', 'https://images.unsplash.com/photo-1599974579688-8dbdd335c77f?w=600'),
(24, 4, 'KF Nashville', 'https://www.seriouseats.com/thmb/zZLQZ3IvBpcq-NfahgHLZYwvbwg=/1500x0/filters:no_upscale():max_bytes(150000):strip_icc()/20231117-SEA-NashvilleHotChicken-VictorProtasio-01-83231777673a434fa85b8f0ef524b4c9.jpg'),
(25, 4, 'Kzing', 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=600');

INSERT INTO ItemVariations (item_id, size_name, price) VALUES
(21, 'Regular', 550), (22, 'Regular', 990), (23, 'Regular', 950), 
(24, 'Regular', 590), (25, 'Regular', 750);

-- 5. BURGERS
INSERT INTO MenuItems (item_id, category_id, name, image_url) VALUES
(26, 5, 'Beef Classic Cheddar Melt', 'https://images.unsplash.com/photo-1550547660-d9450f859349?w=600'),
(27, 5, 'Double Beef Classic Cheddar Melt', 'https://images.unsplash.com/photo-1553979459-d2229ba7433b?w=600'),
(28, 5, 'Crispy Patty Burger', 'https://images.unsplash.com/photo-1596956470007-2bf6095e7e16?w=600'),
(29, 5, 'Chicken Chapli Kabab Burger', 'https://images.unsplash.com/photo-1572802419224-296b0aeee0d9?w=600'),
(30, 5, 'Zinger Burger', 'https://images.unsplash.com/photo-1571091718767-18b5b1457add?w=600'),
(31, 5, 'Zinger Cheese Burger', 'https://images.unsplash.com/photo-1606755962773-d324e0a13086?w=600'),
(32, 5, 'Double Patty Burger', 'https://images.unsplash.com/photo-1594212699903-ec8a3eca50f5?w=600'),
(33, 5, 'Hot Mirchi Burger', 'https://images.unsplash.com/photo-1610440042657-612c34d95e9f?w=600');

INSERT INTO ItemVariations (item_id, size_name, price) VALUES
(26, 'Regular', 690), (27, 'Regular', 990), (28, 'Regular', 340), (29, 'Regular', 340),
(30, 'Regular', 460), (31, 'Regular', 490), (32, 'Regular', 590), (33, 'Regular', 430);

-- 6. SANDWICHES
INSERT INTO MenuItems (item_id, category_id, name, image_url) VALUES
(34, 6, 'Chicken Sandwich', 'https://images.unsplash.com/photo-1481070555726-e2fe8357725c?w=600'),
(35, 6, 'Chicken Club Sandwich', 'https://images.unsplash.com/photo-1528735602780-2552fd46c7af?w=600'),
(36, 6, 'Chicken Cheese Sandwich', 'https://images.unsplash.com/photo-1550507992-eb63ffee0847?w=600'),
(37, 6, 'Euro Sandwich', 'https://images.unsplash.com/photo-1509722747041-616f39b57569?w=600'),
(38, 6, 'Mexican Cheese Sandwich', 'https://www.seriouseats.com/thmb/BPEON1Ct7wNBA7rRHV4lBuGgGps=/1500x0/filters:no_upscale():max_bytes(150000):strip_icc()/20240304-SEA-Pambazo-Lorena-Masso-28-aa0abb8c8a384c968dc3045471dbd876.jpg');

INSERT INTO ItemVariations (item_id, size_name, price) VALUES
(34, 'Regular', 550), (35, 'Regular', 590), (36, 'Regular', 590), 
(37, 'Regular', 750), (38, 'Regular', 750);

-- 7. WINGS & SALADS
INSERT INTO MenuItems (item_id, category_id, name, image_url) VALUES
(39, 7, 'KF-Signature Wings', 'https://images.unsplash.com/photo-1527477396000-e27163b481c2?w=600'),
(40, 7, 'Saucy Wings Garlic', 'https://images.unsplash.com/photo-1608039829572-78524f79c4c7?w=600'),
(41, 7, 'Hot Honey Wings', 'https://images.unsplash.com/photo-1562802378-063ec186a863?w=600'),
(42, 7, 'Grilled Chicken Salad', 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=600'),
(43, 7, 'Nashville Salad', 'https://images.unsplash.com/photo-1540420773420-3366772f4999?w=600'),
(44, 7, 'Hot Honey Poppers', 'https://images.unsplash.com/photo-1548943487-a2e4e43b4853?w=600');

INSERT INTO ItemVariations (item_id, size_name, price) VALUES
(39, 'Regular', 590), (40, 'Regular', 590), (41, 'Regular', 590), 
(42, 'Regular', 520), (43, 'Regular', 520), (44, 'Regular', 650);

-- 8. PLATTERS & SHAWARMAS
INSERT INTO MenuItems (item_id, category_id, name, image_url) VALUES
(45, 8, 'Chicken Platter', 'https://images.unsplash.com/photo-1606728035253-49e8a23146de?w=600'),
(46, 8, 'Chicken Cheese Platter', 'https://images.unsplash.com/photo-1619895092538-128341789043?w=600'),
(47, 8, 'Chicken Shawarma', 'https://images.unsplash.com/photo-1529006557810-274b9b2fc783?w=600'),
(48, 8, 'Chicken Cheese Shawarma', 'https://media-cdn.tripadvisor.com/media/photo-s/1c/d4/5e/b1/mushroom-chick-shawarma.jpg');

INSERT INTO ItemVariations (item_id, size_name, price) VALUES
(45, 'Regular', 1150), (46, 'Regular', 1180), (47, 'Regular', 420), (48, 'Regular', 460);

-- 9. PIZZAS
INSERT INTO MenuItems (item_id, category_id, name, image_url) VALUES
(49, 9, 'Chicken Tikka Pizza', 'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=600'),
(50, 9, 'Chicken Fajita Pizza', 'https://images.unsplash.com/photo-1513104890138-7c749659a591?w=600'),
(51, 9, 'Hot & Spicy Pizza', 'https://images.unsplash.com/photo-1628840042765-356cda07504e?w=600'),
(52, 9, 'Chicken Mushroom Pizza', 'https://images.unsplash.com/photo-1574071318508-1cdbab80d002?w=600'),
(53, 9, 'BBQ Pizza', 'https://images.unsplash.com/photo-1558030006-450675393462?w=600'),
(54, 9, 'American Hot Pizza', 'https://images.unsplash.com/photo-1534308983496-4fabb1a015ee?w=600'),
(55, 9, 'Pepperoni Pizza', 'https://images.unsplash.com/photo-1548369937-47519962c11a?w=600'),
(56, 9, 'Chicken Supreme Pizza', 'https://images.unsplash.com/photo-1555072956-7758afb20e8f?w=600'),
(57, 9, 'Crown Crust Pizza', 'https://images.unsplash.com/photo-1590947132387-155cc02f3212?w=600'),
(58, 9, 'Behari Kabab Pizza', 'https://images.unsplash.com/photo-1593560708920-61dd98c46a4e?w=600'),
(59, 9, 'K.F Special Pizza', 'https://images.unsplash.com/photo-1571407970349-bc81e7e96d47?w=600'),
(60, 9, 'Malai Boti Pizza', 'https://images.unsplash.com/photo-1604382354936-07c5d9983bd3?w=600'),
(61, 9, 'Mexican Pizza', 'https://images.unsplash.com/photo-1513104890138-7c749659a591?w=600'),
(62, 9, 'Kabab Stuffer', 'https://g-cdn.blinkco.io/ordering-system/55812/dish_image/1733124920.png'),
(63, 9, 'Cheese Stuffer', 'https://images.unsplash.com/photo-1506354666786-959d6d497f1a?w=600');

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
INSERT INTO MenuItems (item_id, category_id, name, image_url) VALUES
(64, 10, 'Kabab Cheesy Roll', 'https://images.unsplash.com/photo-1603360946369-dc9bb6258143?w=600'),
(65, 10, 'Chicken Cheesy Roll', 'https://images.unsplash.com/photo-1600803907087-f56d462fd26b?w=600'),
(66, 10, 'Crunchy Chicken Pasta', 'https://images.unsplash.com/photo-1621996346565-e3dbc646d9a9?w=600'),
(67, 10, 'Creamy Pasta', 'https://images.unsplash.com/photo-1555949258-eb67b1ef0ceb?w=600'),
(68, 10, 'Macaroni Pasta', 'https://www.funfoodfrolic.com/wp-content/uploads/2021/08/Macaroni-Thumbnail-Blog-500x375.jpg'),
(69, 10, 'Oven Baked Wings (10 pcs)', 'https://images.unsplash.com/photo-1567620832903-9fc6debc209f?w=600'),
(70, 10, 'Malai Botti Spin Rolls (4 pcs)', 'https://images.unsplash.com/photo-1590301157890-4810ed352733?w=600'),
(71, 10, 'Chicken Spin Rolls (4 pcs)', 'https://images.unsplash.com/photo-1529543544282-ea669407fca3?w=600'),
(72, 10, 'Chilli Milli Rolls (4 pcs)', 'https://images.unsplash.com/photo-1601050690597-df0568f70950?w=600'),
(73, 10, 'Special Platter', 'https://images.unsplash.com/photo-1544025162-d76694265947?w=600');

INSERT INTO ItemVariations (item_id, size_name, price) VALUES
(64, 'Regular', 950), (65, 'Regular', 950), (66, 'Regular', 850), (67, 'Regular', 750), 
(68, 'Regular', 750), (69, 'Regular', 650), (70, 'Regular', 590), (71, 'Regular', 590), 
(72, 'Regular', 660), (73, 'Regular', 1150);

-- 11. FRIES
INSERT INTO MenuItems (item_id, category_id, name, image_url) VALUES
(74, 11, 'Crinkle Fries', 'https://images.unsplash.com/photo-1576107232684-1279f390859f?w=600');

INSERT INTO ItemVariations (item_id, size_name, price) VALUES
(74, 'Small', 200), (74, 'Large', 320), (74, 'Family', 400);

-- 12. BEVERAGES
INSERT INTO MenuItems (item_id, category_id, name, image_url) VALUES
(75, 12, 'Small Water Bottle', 'https://images.unsplash.com/photo-1548839140-29a749e1cf4d?w=600'),
(76, 12, 'Reg Drink Glass', 'https://jodiabaazar.com/cdn/shop/files/coke250glass.jpg?v=1695053728&width=1445'),
(501, 12, 'Coke', 'https://images.unsplash.com/photo-1629203851122-3726ecdf080e?w=600'),
(502, 12, 'Sprite', 'https://www.cebooze.com/app/uploads/2020/10/spritecan.jpg');

INSERT INTO ItemVariations (item_id, size_name, price) VALUES
(75, 'Regular', 60), (76, 'Regular', 100),
(501, 'Half Litre', 150), (501, '1 Litre', 250),
(502, 'Half Litre', 150), (502, '1 Litre', 250);

-- 13. SHAKES
INSERT INTO MenuItems (item_id, category_id, name, image_url) VALUES
(77, 13, 'Oreo Shake', 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=600'),
(78, 13, 'Chocolate Shake', 'https://cdn.sanity.io/images/5dqbssss/production-v4/3ba3f137c02a6f320c156bb7c39e362bdbd87bb8-1356x1576.jpg'),
(79, 13, 'Strawberry Shake', 'https://images.unsplash.com/photo-1553361371-9b22f78e8b1d?w=600'),
(80, 13, 'Pink Barbie Shake', 'https://images.unsplash.com/photo-1613478223719-2ab802602423?w=600'),
(81, 13, 'Cold Coffee', 'https://images.unsplash.com/photo-1534352956036-cd81e27dd615?w=600'),
(82, 13, 'Pina Colada', 'https://images.unsplash.com/photo-1621263764928-df1444c5e859?w=600'),
(83, 13, 'Blue Lagoon', 'https://images.unsplash.com/photo-1544145945-f90425340c7e?w=600'),
(84, 13, 'Chocolate Peanut Butter Shake', 'https://images.unsplash.com/photo-1569718212165-3a8278d5f624?w=600'),
(85, 13, 'Power House Shake', 'https://sfnutrition.co.uk/cdn/shop/articles/Vanilla_lla_1445x.jpg?v=1707148275');

INSERT INTO ItemVariations (item_id, size_name, price) VALUES
(77, 'Regular', 400), (78, 'Regular', 400), (79, 'Regular', 400), (80, 'Regular', 400), 
(81, 'Regular', 400), (82, 'Regular', 400), (83, 'Regular', 400), (84, 'Regular', 400), 
(85, 'Regular', 400);

-- 14. MARGARITAS & JUICES
INSERT INTO MenuItems (item_id, category_id, name, image_url) VALUES
(86, 14, 'Mint Margarita', 'https://images.unsplash.com/photo-1556679343-c7306c1976bc?w=600'),
(87, 14, 'Mango Smoothie', 'https://images.unsplash.com/photo-1546173159-315724a31696?w=600'),
(88, 14, 'Strawberry Margarita', 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSFbCO3LzLf4CQIQh2oz8-E1KU6yWSse-qBtQ&s'),
(89, 14, 'Peach Smoothie', 'https://images.unsplash.com/photo-1563805042-7684c019e1cb?w=600'),
(90, 14, 'Blueberry Margarita', 'https://images.unsplash.com/photo-1570696516188-ade861b84a49?w=600'),
(91, 14, 'Banana Smoothie', 'https://images.unsplash.com/photo-1553530666-ba11a7da3888?w=600'),
(92, 14, 'Apple Mint', 'https://img-global.cpcdn.com/recipes/9839efbbc71ddbfb/680x781cq80/mint-margarita-recipe-main-photo.jpg'),
(93, 14, 'Gawa Smoothie', 'https://images.unsplash.com/photo-1589733955941-5eeaf752f6dd?w=600'),
(94, 14, 'Lime Margarita', 'https://images.unsplash.com/photo-1513558161293-cdaf765ed2fd?w=600'),
(95, 14, 'Apple Juice', 'https://thumbs.dreamstime.com/b/glass-apple-juice-slice-ice-refreshing-summer-background-249797723.jpg'),
(96, 14, 'Lemu Pani', 'https://images.unsplash.com/photo-1621263764928-df1444c5e859?w=600'),
(97, 14, 'Orange (Seasonal)', 'https://images.unsplash.com/photo-1600271886742-f049cd451bba?w=600');

INSERT INTO ItemVariations (item_id, size_name, price) VALUES
(86, 'Regular', 300), (87, 'Regular', 300), (88, 'Regular', 300), (89, 'Regular', 300), 
(90, 'Regular', 300), (91, 'Regular', 300), (92, 'Regular', 300), (93, 'Regular', 300), 
(94, 'Regular', 300), (95, 'Regular', 300), (96, 'Regular', 300), (97, 'Regular', 300);

-- 15. CHILLAR
INSERT INTO MenuItems (item_id, category_id, name, image_url) VALUES
(98, 15, 'Lemon Soda', 'https://bakesbybrownsugar.com/wp-content/uploads/2023/01/Lemon-Soda-15C.jpg'),
(99, 15, 'Peach Iced Tea', 'https://images.unsplash.com/photo-1556679343-c7306c1976bc?w=600'),
(100, 15, 'Mint Lime Mojito', 'https://images.unsplash.com/photo-1609951651556-5334e2706168?w=600'),
(101, 15, 'Passion Fruit Mojito', 'https://images.unsplash.com/photo-1595981267035-7b04ca84a82d?w=600'),
(102, 15, 'Strawberry Mojito', 'https://images.unsplash.com/photo-1551024709-8f23befc6f87?w=600'),
(103, 15, 'Raspberry Iced Tea', 'https://images.unsplash.com/photo-1571091718767-18b5b1457add?w=600'),
(104, 15, 'Strawberry Kiwi Chillar', 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcT_YAgSHs5CnpiEFykKd26iyd7XEPJrV25YoQ&s'),
(105, 15, 'Lighting Shot', 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=600'),
(106, 15, 'Purple Heaven', 'https://images.unsplash.com/photo-1570696516188-ade861b84a49?w=600'),
(107, 15, 'Electric Lemonade', 'https://images.unsplash.com/photo-1497534446932-c925b458314e?w=600'),
(108, 15, 'Orange Italian Soda', 'https://images.unsplash.com/photo-1523371054106-bbf80586c38c?w=600'),
(109, 15, 'Kiwi Chillar', 'https://images.unsplash.com/photo-1561043433-aaf687c4cf04?w=600');

INSERT INTO ItemVariations (item_id, size_name, price) VALUES
(98, 'Regular', 350), (99, 'Regular', 350), (100, 'Regular', 350), (101, 'Regular', 350), 
(102, 'Regular', 350), (103, 'Regular', 350), (104, 'Regular', 350), (105, 'Regular', 350), 
(106, 'Regular', 350), (107, 'Regular', 350), (108, 'Regular', 350), (109, 'Regular', 350);

-- 16. DEALS
INSERT INTO MenuItems (item_id, category_id, name, image_url) VALUES
(110, 16, 'Nashville Tenders Family Deal', 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTJPlZhhtzokWlRKQEmHO282w5YTw5A510eiA&s'),
(111, 16, 'Nashville Tenders 2 Person Deal', 'https://images.unsplash.com/photo-1562967914-608f82629710?w=600'),
(112, 16, 'Nashville Tenders Single Deal', 'https://images.unsplash.com/photo-1606728035253-49e8a23146de?w=600'),
(113, 16, 'Deal-1 (Mazedari)', 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=600'),
(114, 16, 'Deal-2 (Mazedari)', 'https://images.unsplash.com/photo-1550547660-d9450f859349?w=600'),
(115, 16, 'Deal-3 (Mazedari)', 'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=600'),
(116, 16, 'Deal-4 (Mazedari)', 'https://images.unsplash.com/photo-1603360946369-dc9bb6258143?w=600'),
(117, 16, 'Deal-5 (Mazedari)', 'https://images.unsplash.com/photo-1544025162-d76694265947?w=600'),
(118, 16, 'Deal-6 (Mazedari)', 'https://images.unsplash.com/photo-1604382354936-07c5d9983bd3?w=600'),
(119, 16, 'Deal-7 (Exclusive)', 'https://images.unsplash.com/photo-1513104890138-7c749659a591?w=600'),
(120, 16, 'Deal-8 (Exclusive)', 'https://images.unsplash.com/photo-1555072956-7758afb20e8f?w=600'),
(121, 16, 'Deal-9 (Exclusive)', 'https://images.unsplash.com/photo-1571091718767-18b5b1457add?w=600'),
(122, 16, 'Deal-10 (Exclusive)', 'https://images.unsplash.com/photo-1596956470007-2bf6095e7e16?w=600'),
(123, 16, 'Deal-11 (Exclusive)', 'https://images.unsplash.com/photo-1553979459-d2229ba7433b?w=600'),
(124, 16, 'Deal-12 (Exclusive)', 'https://images.unsplash.com/photo-1553979459-d2229ba7433b?w=600'),
(125, 16, 'Deal-13 (Exclusive)', 'https://images.unsplash.com/photo-1630384060421-cb20d0e0649d?w=600');

INSERT INTO ItemVariations (item_id, size_name, price) VALUES
(110, 'Regular', 2200), (111, 'Regular', 1550), (112, 'Regular', 850),
(113, 'Regular', 590), (114, 'Regular', 460), (115, 'Regular', 790), (116, 'Regular', 1650), 
(117, 'Regular', 2450), (118, 'Regular', 750), (119, 'Regular', 3250), (120, 'Regular', 3550), 
(121, 'Regular', 2650), (122, 'Regular', 2150), (123, 'Regular', 2950), (124, 'Regular', 750), 
(125, 'Regular', 4310);

-- =====================================================
-- MODIFIERS
-- =====================================================
INSERT INTO Modifiers (name, price, image_url, is_active) VALUES
('Each Sauce (Nashville)', 70, 'https://images.unsplash.com/photo-1472476443507-c7a5948772bf?w=600', TRUE),
('Extra Bread', 50, 'https://images.unsplash.com/photo-1598373182133-52452f7691ef?w=600', TRUE),
('Extra Sauce', 50, 'https://images.unsplash.com/photo-1585238341267-1cb0a8d4d7ba?w=600', TRUE),
('Extra Chicken', 500, 'https://images.unsplash.com/photo-1562967914-608f82629710?w=600', TRUE),
('Extra Cheese', 80, 'https://static.tossdown.com/images/aea58297-7638-4970-9fb3-937fd9588b3b.webp', TRUE),
('Extra Shawarma Bread', 50, 'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=600', TRUE),
('Add Small Crinkle Fries', 200, 'https://images.unsplash.com/photo-1576107232684-1279f3908594?w=600', TRUE);