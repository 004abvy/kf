-- =====================================================
-- KF Fast Food Restaurant (Kfg) - Full Reset Script
-- Cleaned & Organized Version
-- =====================================================

-- 1. Create database and switch to it
CREATE DATABASE IF NOT EXISTS Kfg;
USE Kfg;

-- =====================================================
-- Disable Constraints
-- =====================================================
select * from Staff;

SET SQL_SAFE_UPDATES = 0;
SET FOREIGN_KEY_CHECKS = 0;
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
    gmail VARCHAR(255) UNIQUE,
    password VARCHAR(255),
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
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uniq_delivery_area_name (area_name)
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

-- =====================================================
-- 2. RE-INSERT MENU ITEMS (Now with Descriptions)
-- =====================================================

-- 1. STARTERS
INSERT INTO MenuItems (item_id, category_id, name, description, image_url) VALUES
(1, 1, 'Chicken Corn Soup', 'A comforting, classic blend of minced chicken and sweet corn.', 'https://images.unsplash.com/photo-1547592180-85f173990554?w=600'),
(2, 1, 'Chicken Hot & Sour Soup', 'Spicy, tangy, and loaded with chicken and vegetables for the perfect kick.', 'https://images.unsplash.com/photo-1585032226651-759b368d7246?w=600'),
(3, 1, 'Fish Cracker', 'Crispy, deep-fried crackers with a subtle hint of seafood flavor.', 'https://images.unsplash.com/photo-1563245372-f21724e3856d?w=600'),
(4, 1, 'Drum Sticks (4 Piece)', 'Crispy and juicy deep-fried chicken drumsticks, seasoned to perfection.', 'https://images.unsplash.com/photo-1527477396000-e27163b481c2?w=600');



INSERT INTO ItemVariations (item_id, size_name, price) VALUES
(1, 'Half', 220), (1, 'Full', 850), (2, 'Half', 220), (2, 'Full', 850), 
(3, 'Regular', 400), (4, 'Regular', 1000);

-- 2. MAIN COURSE
INSERT INTO MenuItems (item_id, category_id, name, description, image_url) VALUES
(5, 2, 'Chicken Shashlik With Rice', 'Tender chicken cooked in a tangy red sauce with capsicum and tomatoes, served over rice.', 'https://images.unsplash.com/photo-1603360946369-dc9bb6258143?w=600'),
(6, 2, 'Chicken Manchurian With Rice', 'Classic Indo-Chinese fried chicken in a spicy, sweet, and tangy dark sauce with rice.', 'https://images.unsplash.com/photo-1565557623262-b51c2513a641?w=600'),
(7, 2, 'Chicken Black Pepper With Rice', 'Stir-fried chicken tossed in a savory black pepper sauce, served with steamed rice.', 'https://images.unsplash.com/photo-1598514983318-2f64f8f4796c?w=600'),
(8, 2, 'Chicken Garlic With Rice', 'Juicy chicken chunks cooked in a rich, aromatic garlic sauce, paired with rice.', 'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=600'),
(9, 2, 'Chicken Szechuan With Rice', 'Spicy and flavorful Szechuan-style chicken stir-fry, served over fresh rice.', 'https://images.unsplash.com/photo-1455619452474-d2be8b1e70cd?w=600'),
(10, 2, 'KF Special With Rice', 'Our chef''s special signature chicken gravy with a unique blend of spices and rice.', 'https://images.unsplash.com/photo-1603133872878-684f208fb84b?w=600'),
(11, 2, 'Chicken Chilli Dry With Rice', 'Wok-tossed dry chicken cooked with fiery green chilies and soy, served with rice.', 'https://images.unsplash.com/photo-1569050467447-ce54b3bbc37d?w=600'),
(12, 2, 'Chicken Almond With Rice', 'Mild and nutty chicken dish topped with crunchy toasted almonds and served with rice.', 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=600'),
(13, 2, 'King Pao Chicken With Rice', 'Spicy stir-fried Chinese dish made with chicken, peanuts, vegetables, and chili peppers.', 'https://images.unsplash.com/photo-1534422298391-e4f8c172dddb?w=600'),
(14, 2, 'Chicken Vegetable With Rice', 'A healthy mix of chicken and seasonal vegetables stir-fried in a light soy sauce.', 'https://images.unsplash.com/photo-1512058564366-18510be2db19?w=600'),
(15, 2, 'Chicken Sweet & Sour With Rice', 'Crispy chicken bites coated in a vibrant sweet and sour pineapple sauce.', 'https://images.unsplash.com/photo-1540189549336-e6e99c3679fe?w=600'),
(16, 2, 'Hot Sauce Chicken With Rice', 'Extra spicy chicken chunks drenched in our signature hot sauce, served with rice.', 'https://images.unsplash.com/photo-1574484284002-952d92456975?w=600'),
(17, 2, 'Chicken Chowmein', 'Stir-fried noodles loaded with seasoned chicken, cabbage, carrots, and soy sauce.', 'https://images.unsplash.com/photo-1585325701165-f1a4d3e81e36?w=600');

INSERT INTO ItemVariations (item_id, size_name, price) VALUES
(5, 'Half', 750), (5, 'Full', 1250), (6, 'Half', 750), (6, 'Full', 1250), 
(7, 'Half', 750), (7, 'Full', 1250), (8, 'Half', 750), (8, 'Full', 1250), 
(9, 'Half', 750), (9, 'Full', 1250), (10, 'Full', 1400), (11, 'Full', 1350), 
(12, 'Full', 1350), (13, 'Full', 1350), (14, 'Full', 1250), (15, 'Full', 1250), 
(16, 'Full', 1250), (17, 'Full', 850);

-- 3. RICE
INSERT INTO MenuItems (item_id, category_id, name, description, image_url) VALUES
(18, 3, 'Chicken Fried Rice', 'Wok-tossed rice with shredded chicken, eggs, and finely chopped vegetables.', 'https://images.unsplash.com/photo-1516684732162-798a0062be99?w=600'),
(19, 3, 'Egg Fried Rice', 'Simple, classic Chinese-style fried rice with scrambled eggs and scallions.', 'https://images.unsplash.com/photo-1555126634-323283e090fa?w=600'),
(20, 3, 'Chicken Masala Rice', 'A flavorful, spicy twist on traditional rice mixed with desi chicken masala.', 'https://images.unsplash.com/photo-1596560548464-f010549b84d7?w=600');

INSERT INTO ItemVariations (item_id, size_name, price) VALUES
(18, 'Regular', 550), (19, 'Regular', 500), (20, 'Regular', 600);

-- 4. NASHVILLE & LOADED
INSERT INTO MenuItems (item_id, category_id, name, description, image_url) VALUES
(21, 4, 'KF Loaded Fries', 'Crispy fries smothered in melted cheese, jalapenos, and spicy chicken chunks.', 'https://images.unsplash.com/photo-1630384060421-cb20d0e0649d?w=600'),
(22, 4, 'Hot Cheeto Burrito', 'A fiery burrito wrapped with tender chicken and crunchy Flamin'' Hot Cheetos.', 'https://images.unsplash.com/photo-1626700051175-6818013e1d4f?w=600'),
(23, 4, 'KF Nashville Burrito', 'Our spicy Nashville chicken tightly wrapped in a tortilla with fresh slaw.', 'https://images.unsplash.com/photo-1599974579688-8dbdd335c77f?w=600'),
(24, 4, 'KF Nashville', 'Authentic Nashville-style hot chicken, intensely spicy and incredibly crispy.', 'https://www.seriouseats.com/thmb/zZLQZ3IvBpcq-NfahgHLZYwvbwg=/1500x0/filters:no_upscale():max_bytes(150000):strip_icc()/20231117-SEA-NashvilleHotChicken-VictorProtasio-01-83231777673a434fa85b8f0ef524b4c9.jpg'),
(25, 4, 'Kzing', 'Our signature spicy crunch wrap, packed with zinger flavors and secret sauce.', 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=600');

INSERT INTO ItemVariations (item_id, size_name, price) VALUES
(21, 'Regular', 550), (22, 'Regular', 990), (23, 'Regular', 950), 
(24, 'Regular', 590), (25, 'Regular', 750);

-- 5. BURGERS
INSERT INTO MenuItems (item_id, category_id, name, description, image_url) VALUES
(26, 5, 'Beef Classic Cheddar Melt', 'Juicy beef patty topped with a rich, melting slice of cheddar cheese.', 'https://images.unsplash.com/photo-1550547660-d9450f859349?w=600'),
(27, 5, 'Double Beef Classic Cheddar Melt', 'Two juicy beef patties stacked high with double the melted cheddar goodness.', 'https://images.unsplash.com/photo-1553979459-d2229ba7433b?w=600'),
(28, 5, 'Crispy Patty Burger', 'A perfectly fried, golden crispy patty served with fresh lettuce and mayo.', 'https://images.unsplash.com/photo-1596956470007-2bf6095e7e16?w=600'),
(29, 5, 'Chicken Chapli Kabab Burger', 'Traditional spicy chapli kabab tucked into a soft bun with fresh onions and sauce.', 'https://images.unsplash.com/photo-1572802419224-296b0aeee0d9?w=600'),
(30, 5, 'Zinger Burger', 'The classic ultra-crispy chicken thigh fillet with iceberg lettuce and mayo.', 'https://images.unsplash.com/photo-1571091718767-18b5b1457add?w=600'),
(31, 5, 'Zinger Cheese Burger', 'Our classic Zinger topped with a thick slice of premium cheese.', 'https://images.unsplash.com/photo-1606755962773-d324e0a13086?w=600'),
(32, 5, 'Double Patty Burger', 'For the hungry: two crispy chicken patties packed into one massive burger.', 'https://images.unsplash.com/photo-1594212699903-ec8a3eca50f5?w=600'),
(33, 5, 'Hot Mirchi Burger', 'A fiery burger experience loaded with spicy sauces and jalapenos.', 'https://images.unsplash.com/photo-1610440042657-612c34d95e9f?w=600');

INSERT INTO ItemVariations (item_id, size_name, price) VALUES
(26, 'Regular', 690), (27, 'Regular', 990), (28, 'Regular', 340), (29, 'Regular', 340),
(30, 'Regular', 460), (31, 'Regular', 490), (32, 'Regular', 590), (33, 'Regular', 430);

-- 6. SANDWICHES
INSERT INTO MenuItems (item_id, category_id, name, description, image_url) VALUES
(34, 6, 'Chicken Sandwich', 'Shredded roasted chicken mixed with mayo and spices, pressed between soft bread.', 'https://images.unsplash.com/photo-1481070555726-e2fe8357725c?w=600'),
(35, 6, 'Chicken Club Sandwich', 'The classic triple-decker sandwich layered with chicken, eggs, lettuce, and tomatoes.', 'https://images.unsplash.com/photo-1528735602780-2552fd46c7af?w=600'),
(36, 6, 'Chicken Cheese Sandwich', 'A gooey, melted cheese and chicken sandwich grilled to golden perfection.', 'https://images.unsplash.com/photo-1550507992-eb63ffee0847?w=600'),
(37, 6, 'Euro Sandwich', 'A continental-style cold cut sandwich with special dressing and fresh veggies.', 'https://images.unsplash.com/photo-1509722747041-616f39b57569?w=600'),
(38, 6, 'Mexican Cheese Sandwich', 'Spicy chicken fajita mix layered with cheese and toasted for a Mexican flair.', 'https://www.seriouseats.com/thmb/BPEON1Ct7wNBA7rRHV4lBuGgGps=/1500x0/filters:no_upscale():max_bytes(150000):strip_icc()/20240304-SEA-Pambazo-Lorena-Masso-28-aa0abb8c8a384c968dc3045471dbd876.jpg');

INSERT INTO ItemVariations (item_id, size_name, price) VALUES
(34, 'Regular', 550), (35, 'Regular', 590), (36, 'Regular', 590), 
(37, 'Regular', 750), (38, 'Regular', 750);

-- 7. WINGS & SALADS
INSERT INTO MenuItems (item_id, category_id, name, description, image_url) VALUES
(39, 7, 'KF-Signature Wings', 'Our secret recipe crispy wings, packed with flavor and fried to perfection.', 'https://images.unsplash.com/photo-1527477396000-e27163b481c2?w=600'),
(40, 7, 'Saucy Wings Garlic', 'Crispy chicken wings tossed in a rich, buttery garlic parmesan sauce.', 'https://images.unsplash.com/photo-1608039829572-78524f79c4c7?w=600'),
(41, 7, 'Hot Honey Wings', 'The perfect balance of fiery chili heat and sweet honey glaze.', 'https://images.unsplash.com/photo-1562802378-063ec186a863?w=600'),
(42, 7, 'Grilled Chicken Salad', 'Fresh greens, tomatoes, and cucumbers topped with warm grilled chicken breast.', 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=600'),
(43, 7, 'Nashville Salad', 'A crispy, spicy Nashville chicken fillet sliced over a bed of fresh mixed greens.', 'https://images.unsplash.com/photo-1540420773420-3366772f4999?w=600'),
(44, 7, 'Hot Honey Poppers', 'Bite-sized crispy chicken poppers glazed with our signature hot honey sauce.', 'https://images.unsplash.com/photo-1548943487-a2e4e43b4853?w=600');

INSERT INTO ItemVariations (item_id, size_name, price) VALUES
(39, 'Regular', 590), (40, 'Regular', 590), (41, 'Regular', 590), 
(42, 'Regular', 520), (43, 'Regular', 520), (44, 'Regular', 650);

-- 8. PLATTERS & SHAWARMAS
INSERT INTO MenuItems (item_id, category_id, name, description, image_url) VALUES
(45, 8, 'Chicken Platter', 'A hearty meal featuring grilled chicken, fries, pita, and signature dipping sauces.', 'https://images.unsplash.com/photo-1606728035253-49e8a23146de?w=600'),
(46, 8, 'Chicken Cheese Platter', 'Our classic chicken platter upgraded with a generous drizzle of melted cheese.', 'https://images.unsplash.com/photo-1619895092538-128341789043?w=600'),
(47, 8, 'Chicken Shawarma', 'Authentic rotisserie chicken, pickles, and garlic sauce wrapped in warm pita bread.', 'https://images.unsplash.com/photo-1529006557810-274b9b2fc783?w=600'),
(48, 8, 'Chicken Cheese Shawarma', 'A cheesy twist on our classic chicken shawarma for an extra rich flavor.', 'https://media-cdn.tripadvisor.com/media/photo-s/1c/d4/5e/b1/mushroom-chick-shawarma.jpg');

INSERT INTO ItemVariations (item_id, size_name, price) VALUES
(45, 'Regular', 1150), (46, 'Regular', 1180), (47, 'Regular', 420), (48, 'Regular', 460);

-- 9. PIZZAS
INSERT INTO MenuItems (item_id, category_id, name, description, image_url) VALUES
(49, 9, 'Chicken Tikka Pizza', 'Traditional BBQ chicken tikka chunks with onions and lots of mozzarella cheese.', 'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=600'),
(50, 9, 'Chicken Fajita Pizza', 'Spicy fajita chicken, green peppers, onions, and black olives over a rich tomato base.', 'https://images.unsplash.com/photo-1513104890138-7c749659a591?w=600'),
(51, 9, 'Hot & Spicy Pizza', 'Loaded with spicy ground chicken, jalapenos, and an extra fiery pizza sauce.', 'https://images.unsplash.com/photo-1628840042765-356cda07504e?w=600'),
(52, 9, 'Chicken Mushroom Pizza', 'A mild, earthy delight featuring grilled chicken bits and fresh mushroom slices.', 'https://images.unsplash.com/photo-1574071318508-1cdbab80d002?w=600'),
(53, 9, 'BBQ Pizza', 'Smokey BBQ sauce base topped with grilled chicken, onions, and a cheese blend.', 'https://images.unsplash.com/photo-1558030006-450675393462?w=600'),
(54, 9, 'American Hot Pizza', 'Classic American style pizza with pepperoni, spicy beef, and hot green chilies.', 'https://images.unsplash.com/photo-1534308983496-4fabb1a015ee?w=600'),
(55, 9, 'Pepperoni Pizza', 'The ultimate classic: layers of crispy beef pepperoni over a bed of mozzarella.', 'https://images.unsplash.com/photo-1548369937-47519962c11a?w=600'),
(56, 9, 'Chicken Supreme Pizza', 'The fully loaded experience with chicken, capsicum, olives, mushrooms, and sausages.', 'https://images.unsplash.com/photo-1555072956-7758afb20e8f?w=600'),
(57, 9, 'Crown Crust Pizza', 'A majestic pizza featuring a unique crust stuffed with chicken meatballs and cheese.', 'https://images.unsplash.com/photo-1590947132387-155cc02f3212?w=600'),
(58, 9, 'Behari Kabab Pizza', 'Authentic Pakistani Behari kabab flavors infused into a delicious, cheesy pizza.', 'https://images.unsplash.com/photo-1593560708920-61dd98c46a4e?w=600'),
(59, 9, 'K.F Special Pizza', 'Our secret house special loaded with multiple meats, veggies, and extra cheese.', 'https://images.unsplash.com/photo-1571407970349-bc81e7e96d47?w=600'),
(60, 9, 'Malai Boti Pizza', 'Creamy, melt-in-your-mouth malai boti chicken chunks baked with a rich white sauce.', 'https://images.unsplash.com/photo-1604382354936-07c5d9983bd3?w=600'),
(61, 9, 'Mexican Pizza', 'A tangy, slightly spicy pizza topped with chicken, sweet corn, and jalapenos.', 'https://images.unsplash.com/photo-1513104890138-7c749659a591?w=600'),
(62, 9, 'Kabab Stuffer', 'A specialized crust fully stuffed with juicy seekh kababs all around the edge.', 'https://g-cdn.blinkco.io/ordering-system/55812/dish_image/1733124920.png'),
(63, 9, 'Cheese Stuffer', 'The ultimate cheese pull pizza with a thick crust overflowing with mozzarella.', 'https://images.unsplash.com/photo-1506354666786-959d6d497f1a?w=600');

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
INSERT INTO MenuItems (item_id, category_id, name, description, image_url) VALUES
(64, 10, 'Kabab Cheesy Roll', 'Oven-baked dough rolls stuffed with tender seekh kababs and melted cheese.', 'https://images.unsplash.com/photo-1603360946369-dc9bb6258143?w=600'),
(65, 10, 'Chicken Cheesy Roll', 'Golden baked rolls filled with seasoned chicken chunks and a blend of cheeses.', 'https://images.unsplash.com/photo-1600803907087-f56d462fd26b?w=600'),
(66, 10, 'Crunchy Chicken Pasta', 'A hearty bowl of pasta topped with an incredibly crunchy fried chicken fillet.', 'https://images.unsplash.com/photo-1621996346565-e3dbc646d9a9?w=600'),
(67, 10, 'Creamy Pasta', 'Fettuccine or penne tossed in a rich, velvety white alfredo sauce with chicken.', 'https://images.unsplash.com/photo-1555949258-eb67b1ef0ceb?w=600'),
(68, 10, 'Macaroni Pasta', 'Classic, comforting homestyle macaroni cooked in a savory tomato and chicken sauce.', 'https://www.funfoodfrolic.com/wp-content/uploads/2021/08/Macaroni-Thumbnail-Blog-500x375.jpg'),
(69, 10, 'Oven Baked Wings (10 pcs)', 'Healthier, flavor-packed wings baked in our oven and tossed in signature herbs.', 'https://images.unsplash.com/photo-1567620832903-9fc6debc209f?w=600'),
(70, 10, 'Malai Botti Spin Rolls (4 pcs)', 'Crispy spring rolls loaded with creamy malai boti chicken.', 'https://images.unsplash.com/photo-1590301157890-4810ed352733?w=600'),
(71, 10, 'Chicken Spin Rolls (4 pcs)', 'Deep-fried rolls stuffed with a savory mix of minced chicken and vegetables.', 'https://images.unsplash.com/photo-1529543544282-ea669407fca3?w=600'),
(72, 10, 'Chilli Milli Rolls (4 pcs)', 'Spicy and tangy fried rolls perfect for those who love an extra kick of heat.', 'https://images.unsplash.com/photo-1601050690597-df0568f70950?w=600'),
(73, 10, 'Special Platter', 'A curated assortment of our best oven-baked items and rolls, perfect for sharing.', 'https://images.unsplash.com/photo-1544025162-d76694265947?w=600');

INSERT INTO ItemVariations (item_id, size_name, price) VALUES
(64, 'Regular', 950), (65, 'Regular', 950), (66, 'Regular', 850), (67, 'Regular', 750), 
(68, 'Regular', 750), (69, 'Regular', 650), (70, 'Regular', 590), (71, 'Regular', 590), 
(72, 'Regular', 660), (73, 'Regular', 1150);

-- 11. FRIES
INSERT INTO MenuItems (item_id, category_id, name, description, image_url) VALUES
(74, 11, 'Crinkle Fries', 'Classic, deep-fried crinkle-cut potatoes seasoned with salt and light spices.', 'https://images.unsplash.com/photo-1576107232684-1279f390859f?w=600');

INSERT INTO ItemVariations (item_id, size_name, price) VALUES
(74, 'Small', 200), (74, 'Large', 320), (74, 'Family', 400);

-- 12. BEVERAGES
INSERT INTO MenuItems (item_id, category_id, name, description, image_url) VALUES
(75, 12, 'Small Water Bottle', 'Chilled mineral water to refresh your palate.', 'https://images.unsplash.com/photo-1548839140-29a749e1cf4d?w=600'),
(76, 12, 'Reg Drink Glass', 'A regular glass of your favorite carbonated fountain drink.', 'https://jodiabaazar.com/cdn/shop/files/coke250glass.jpg?v=1695053728&width=1445'),
(501, 12, 'Coke', 'Classic Coca-Cola, served ice cold.', 'https://images.unsplash.com/photo-1629203851122-3726ecdf080e?w=600'),
(502, 12, 'Sprite', 'Crisp, refreshing lemon-lime Sprite.', 'https://www.cebooze.com/app/uploads/2020/10/spritecan.jpg');

INSERT INTO ItemVariations (item_id, size_name, price) VALUES
(75, 'Regular', 60), (76, 'Regular', 100),
(501, 'Half Litre', 150), (501, '1 Litre', 250),
(502, 'Half Litre', 150), (502, '1 Litre', 250);

-- 13. SHAKES
INSERT INTO MenuItems (item_id, category_id, name, description, image_url) VALUES
(77, 13, 'Oreo Shake', 'A thick, creamy vanilla shake blended with crushed Oreo cookies.', 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=600'),
(78, 13, 'Chocolate Shake', 'Rich, indulgent chocolate ice cream blended into a smooth and frosty shake.', 'https://cdn.sanity.io/images/5dqbssss/production-v4/3ba3f137c02a6f320c156bb7c39e362bdbd87bb8-1356x1576.jpg'),
(79, 13, 'Strawberry Shake', 'Sweet and refreshing milkshake made with fresh strawberry flavors.', 'https://images.unsplash.com/photo-1553361371-9b22f78e8b1d?w=600'),
(80, 13, 'Pink Barbie Shake', 'A vibrant, berry-flavored aesthetic shake topped with whipped cream and sprinkles.', 'https://images.unsplash.com/photo-1613478223719-2ab802602423?w=600'),
(81, 13, 'Cold Coffee', 'A heavily chilled, sweet, and creamy iced coffee blend to wake you up.', 'https://images.unsplash.com/photo-1534352956036-cd81e27dd615?w=600'),
(82, 13, 'Pina Colada', 'A tropical blend of sweet pineapple and rich coconut cream.', 'https://images.unsplash.com/photo-1621263764928-df1444c5e859?w=600'),
(83, 13, 'Blue Lagoon', 'A visually stunning, citrusy and sweet mocktail with a vibrant blue hue.', 'https://images.unsplash.com/photo-1544145945-f90425340c7e?w=600'),
(84, 13, 'Chocolate Peanut Butter Shake', 'The ultimate combo: rich chocolate and creamy peanut butter blended thick.', 'https://images.unsplash.com/photo-1569718212165-3a8278d5f624?w=600'),
(85, 13, 'Power House Shake', 'A high-energy, protein-packed shake with nuts and bananas for a quick boost.', 'https://sfnutrition.co.uk/cdn/shop/articles/Vanilla_lla_1445x.jpg?v=1707148275');

INSERT INTO ItemVariations (item_id, size_name, price) VALUES
(77, 'Regular', 400), (78, 'Regular', 400), (79, 'Regular', 400), (80, 'Regular', 400), 
(81, 'Regular', 400), (82, 'Regular', 400), (83, 'Regular', 400), (84, 'Regular', 400), 
(85, 'Regular', 400);

-- 14. MARGARITAS & JUICES
INSERT INTO MenuItems (item_id, category_id, name, description, image_url) VALUES
(86, 14, 'Mint Margarita', 'A slushy, intensely refreshing blend of mint leaves, lemon, and ice.', 'https://images.unsplash.com/photo-1556679343-c7306c1976bc?w=600'),
(87, 14, 'Mango Smoothie', 'A thick, tropical smoothie made from sweet, ripe mangoes.', 'https://images.unsplash.com/photo-1546173159-315724a31696?w=600'),
(88, 14, 'Strawberry Margarita', 'An icy, sweet, and slightly tart strawberry blended mocktail.', 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSFbCO3LzLf4CQIQh2oz8-E1KU6yWSse-qBtQ&s'),
(89, 14, 'Peach Smoothie', 'A light, refreshing, and creamy smoothie made with real peaches.', 'https://images.unsplash.com/photo-1563805042-7684c019e1cb?w=600'),
(90, 14, 'Blueberry Margarita', 'A tangy and sweet icy beverage bursting with blueberry flavor.', 'https://images.unsplash.com/photo-1570696516188-ade861b84a49?w=600'),
(91, 14, 'Banana Smoothie', 'A smooth, sweet, and filling blend of bananas and milk.', 'https://images.unsplash.com/photo-1553530666-ba11a7da3888?w=600'),
(92, 14, 'Apple Mint', 'A crisp and cooling mix of fresh apple juice and crushed mint.', 'https://img-global.cpcdn.com/recipes/9839efbbc71ddbfb/680x781cq80/mint-margarita-recipe-main-photo.jpg'),
(93, 14, 'Gawa Smoothie', 'A sweet and tropical guava-infused creamy smoothie.', 'https://images.unsplash.com/photo-1589733955941-5eeaf752f6dd?w=600'),
(94, 14, 'Lime Margarita', 'The classic, zesty, and highly refreshing lime slushie mocktail.', 'https://images.unsplash.com/photo-1513558161293-cdaf765ed2fd?w=600'),
(95, 14, 'Apple Juice', '100% pure and freshly squeezed sweet apple juice.', 'https://thumbs.dreamstime.com/b/glass-apple-juice-slice-ice-refreshing-summer-background-249797723.jpg'),
(96, 14, 'Lemu Pani', 'Traditional sweet and salty lemonade, perfect for beating the heat.', 'https://images.unsplash.com/photo-1621263764928-df1444c5e859?w=600'),
(97, 14, 'Orange (Seasonal)', 'Freshly squeezed, pulp-rich seasonal orange juice.', 'https://images.unsplash.com/photo-1600271886742-f049cd451bba?w=600');

INSERT INTO ItemVariations (item_id, size_name, price) VALUES
(86, 'Regular', 300), (87, 'Regular', 300), (88, 'Regular', 300), (89, 'Regular', 300), 
(90, 'Regular', 300), (91, 'Regular', 300), (92, 'Regular', 300), (93, 'Regular', 300), 
(94, 'Regular', 300), (95, 'Regular', 300), (96, 'Regular', 300), (97, 'Regular', 300);

-- 15. CHILLAR
INSERT INTO MenuItems (item_id, category_id, name, description, image_url) VALUES
(98, 15, 'Lemon Soda', 'A fizzy, zesty lemon beverage to instantly quench your thirst.', 'https://bakesbybrownsugar.com/wp-content/uploads/2023/01/Lemon-Soda-15C.jpg'),
(99, 15, 'Peach Iced Tea', 'Cool, brewed tea naturally sweetened with a hint of fresh peach.', 'https://images.unsplash.com/photo-1556679343-c7306c1976bc?w=600'),
(100, 15, 'Mint Lime Mojito', 'A virgin mojito loaded with muddled mint leaves, lime juice, and soda.', 'https://images.unsplash.com/photo-1609951651556-5334e2706168?w=600'),
(101, 15, 'Passion Fruit Mojito', 'A tropical, tangy twist on the classic mojito using real passion fruit syrup.', 'https://images.unsplash.com/photo-1595981267035-7b04ca84a82d?w=600'),
(102, 15, 'Strawberry Mojito', 'A sweet and bubbly mocktail bursting with muddled strawberries and mint.', 'https://images.unsplash.com/photo-1551024709-8f23befc6f87?w=600'),
(103, 15, 'Raspberry Iced Tea', 'Chilled black tea infused with the tart and sweet flavor of raspberries.', 'https://images.unsplash.com/photo-1571091718767-18b5b1457add?w=600'),
(104, 15, 'Strawberry Kiwi Chillar', 'A deliciously fruity, ice-cold blend of sweet strawberries and tart kiwis.', 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcT_YAgSHs5CnpiEFykKd26iyd7XEPJrV25YoQ&s'),
(105, 15, 'Lighting Shot', 'An electrifying, energy-boosting citrus mocktail shot to start your meal.', 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=600'),
(106, 15, 'Purple Heaven', 'A beautiful, fruity mocktail blend with a signature violet hue.', 'https://images.unsplash.com/photo-1570696516188-ade861b84a49?w=600'),
(107, 15, 'Electric Lemonade', 'A tart, sweet, and visually striking blue lemonade.', 'https://images.unsplash.com/photo-1497534446932-c925b458314e?w=600'),
(108, 15, 'Orange Italian Soda', 'Sparkling water mixed with sweet orange syrup for a light, fizzy treat.', 'https://images.unsplash.com/photo-1523371054106-bbf80586c38c?w=600'),
(109, 15, 'Kiwi Chillar', 'A sour-sweet, icy kiwi-flavored cooler to beat the heat.', 'https://images.unsplash.com/photo-1561043433-aaf687c4cf04?w=600');

INSERT INTO ItemVariations (item_id, size_name, price) VALUES
(98, 'Regular', 350), (99, 'Regular', 350), (100, 'Regular', 350), (101, 'Regular', 350), 
(102, 'Regular', 350), (103, 'Regular', 350), (104, 'Regular', 350), (105, 'Regular', 350), 
(106, 'Regular', 350), (107, 'Regular', 350), (108, 'Regular', 350), (109, 'Regular', 350);

-- 16. DEALS
INSERT INTO MenuItems (item_id, category_id, name, description, image_url) VALUES
(110, 16, 'Nashville Tenders Family Deal', 'A massive platter of our spicy Nashville chicken tenders, perfect for the whole family.', 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTJPlZhhtzokWlRKQEmHO282w5YTw5A510eiA&s'),
(111, 16, 'Nashville Tenders 2 Person Deal', 'A generous portion of Nashville tenders and fries meant to be shared between two.', 'https://images.unsplash.com/photo-1562967914-608f82629710?w=600'),
(112, 16, 'Nashville Tenders Single Deal', 'Our signature spicy Nashville tenders bundled with fries and a drink for one.', 'https://images.unsplash.com/photo-1606728035253-49e8a23146de?w=600'),
(113, 16, 'Deal-1 (Mazedari)', 'An affordable, delicious combo pack to satisfy your fast food cravings.', 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=600'),
(114, 16, 'Deal-2 (Mazedari)', 'A value-packed meal deal featuring our top-selling classic items.', 'https://images.unsplash.com/photo-1550547660-d9450f859349?w=600'),
(115, 16, 'Deal-3 (Mazedari)', 'The perfect combo for a quick, filling lunch without breaking the bank.', 'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=600'),
(116, 16, 'Deal-4 (Mazedari)', 'A hearty meal bundle perfect for sharing with a friend.', 'https://images.unsplash.com/photo-1603360946369-dc9bb6258143?w=600'),
(117, 16, 'Deal-5 (Mazedari)', 'A supreme value meal featuring an assortment of our crowd favorites.', 'https://images.unsplash.com/photo-1544025162-d76694265947?w=600'),
(118, 16, 'Deal-6 (Mazedari)', 'A budget-friendly box loaded with flavor and crunch.', 'https://images.unsplash.com/photo-1604382354936-07c5d9983bd3?w=600'),
(119, 16, 'Deal-7 (Exclusive)', 'A premium family feast featuring our largest pizzas and select sides.', 'https://images.unsplash.com/photo-1513104890138-7c749659a591?w=600'),
(120, 16, 'Deal-8 (Exclusive)', 'The ultimate party platter deal packed with burgers, sides, and drinks.', 'https://images.unsplash.com/photo-1555072956-7758afb20e8f?w=600'),
(121, 16, 'Deal-9 (Exclusive)', 'An exclusive collection of our chef-recommended items grouped for savings.', 'https://images.unsplash.com/photo-1571091718767-18b5b1457add?w=600'),
(122, 16, 'Deal-10 (Exclusive)', 'A high-end combo deal featuring our specialty gourmet burgers and loaded fries.', 'https://images.unsplash.com/photo-1596956470007-2bf6095e7e16?w=600'),
(123, 16, 'Deal-11 (Exclusive)', 'Our grand feast deal, combining the best of pizzas and pastas.', 'https://images.unsplash.com/photo-1553979459-d2229ba7433b?w=600'),
(124, 16, 'Deal-12 (Exclusive)', 'A targeted combo deal designed for extreme hunger and maximum satisfaction.', 'https://images.unsplash.com/photo-1553979459-d2229ba7433b?w=600'),
(125, 16, 'Deal-13 (Exclusive)', 'The mega exclusive deal featuring all of our heaviest hitters from the menu.', 'https://images.unsplash.com/photo-1630384060421-cb20d0e0649d?w=600');

INSERT INTO ItemVariations (item_id, size_name, price) VALUES
(110, 'Regular', 2200), (111, 'Regular', 1550), (112, 'Regular', 850),
(113, 'Regular', 590), (114, 'Regular', 460), (115, 'Regular', 790), (116, 'Regular', 1650), 
(117, 'Regular', 2450), (118, 'Regular', 750), (119, 'Regular', 3250), (120, 'Regular', 3550), 
(121, 'Regular', 2650), (122, 'Regular', 2150), (123, 'Regular', 2950), (124, 'Regular', 750), 
(125, 'Regular', 4310);

-- =====================================================
-- 3. RE-INSERT MODIFIERS
-- =====================================================
INSERT INTO Modifiers (name, price, image_url, is_active) VALUES
('Extra Shawarma Bread', 50, 'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=600', TRUE),
('Add Small Crinkle Fries', 200, 'https://images.unsplash.com/photo-1576107232684-1279f3908594?w=600', TRUE);