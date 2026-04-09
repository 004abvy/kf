-- MySQL dump 10.13  Distrib 8.0.44, for Win64 (x86_64)
--
-- Host: localhost    Database: kfg
-- ------------------------------------------------------
-- Server version	8.0.44

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `categories`
--

DROP TABLE IF EXISTS `categories`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `categories` (
  `category_id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `display_order` int DEFAULT '0',
  `is_active` tinyint(1) DEFAULT '1',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `image_url` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`category_id`)
) ENGINE=InnoDB AUTO_INCREMENT=17 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `categories`
--

LOCK TABLES `categories` WRITE;
/*!40000 ALTER TABLE `categories` DISABLE KEYS */;
INSERT INTO `categories` VALUES (1,'Starters',1,1,'2026-04-05 08:17:27','https://images.unsplash.com/photo-1541529086526-db283c563270?auto=format&fit=crop&w=800&q=80'),(2,'Main Course',2,1,'2026-04-05 08:17:27','https://images.unsplash.com/photo-1555939594-58d7cb561ad1?auto=format&fit=crop&w=800&q=80'),(3,'Rice',3,1,'2026-04-05 08:17:27','https://images.unsplash.com/photo-1512058564366-18510be2db19?auto=format&fit=crop&w=800&q=80'),(4,'Nashville & Loaded',4,1,'2026-04-05 08:17:27','https://images.unsplash.com/photo-1626082927389-6cd097cdc6ec?auto=format&fit=crop&w=800&q=80'),(5,'Burgers',5,1,'2026-04-05 08:17:27','https://images.unsplash.com/photo-1568901346375-23c9450c58cd?auto=format&fit=crop&w=800&q=80'),(6,'Sandwiches',6,1,'2026-04-05 08:17:27','https://images.unsplash.com/photo-1528735602780-2552fd46c7af?auto=format&fit=crop&w=800&q=80'),(7,'Wings & Salads',7,1,'2026-04-05 08:17:27','https://images.unsplash.com/photo-1524114664604-cd8133cd67ad?auto=format&fit=crop&w=800&q=80'),(8,'Platters & Shawarmas',8,1,'2026-04-05 08:17:27','https://images.unsplash.com/photo-1529006557810-274b9b2fc783?w=600'),(9,'Pizzas',9,1,'2026-04-05 08:17:27','https://images.unsplash.com/photo-1513104890138-7c749659a591?auto=format&fit=crop&w=800&q=80'),(10,'Pastas & Oven Baked',10,1,'2026-04-05 08:17:27','https://images.unsplash.com/photo-1551892374-ecf8754cf8b0?q=80&w=764&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D'),(11,'Fries',11,1,'2026-04-05 08:17:27','https://images.unsplash.com/photo-1630384060421-cb20d0e0649d?q=80&w=1025&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D'),(12,'Beverages',12,1,'2026-04-05 08:17:27','https://images.unsplash.com/photo-1541745038731-f1c2b5a1a49e?q=80&w=1963&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D'),(13,'Shakes',13,1,'2026-04-05 08:17:27','https://images.unsplash.com/photo-1572490122747-3968b75cc699?q=80&w=687&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D'),(14,'Margaritas & Juices',14,1,'2026-04-05 08:17:27','https://images.unsplash.com/photo-1513558161293-cdaf765ed2fd?auto=format&fit=crop&w=800&q=80'),(15,'Chillar',15,1,'2026-04-05 08:17:27','https://images.unsplash.com/photo-1536935338788-846bb9981813?auto=format&fit=crop&w=800&q=80'),(16,'Deals',16,1,'2026-04-05 08:17:27','https://plus.unsplash.com/premium_photo-1683657860843-abae8aa03a64?q=80&w=1470&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D');
/*!40000 ALTER TABLE `categories` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `delivery_locations`
--

DROP TABLE IF EXISTS `delivery_locations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `delivery_locations` (
  `id` int NOT NULL AUTO_INCREMENT,
  `area_name` varchar(100) NOT NULL,
  `delivery_fee` int DEFAULT '0',
  `is_active` tinyint(1) DEFAULT '1',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `delivery_locations`
--

LOCK TABLES `delivery_locations` WRITE;
/*!40000 ALTER TABLE `delivery_locations` DISABLE KEYS */;
INSERT INTO `delivery_locations` VALUES (1,'Sabzazar',0,1,'2026-04-07 15:15:05'),(2,'Awan Town',100,1,'2026-04-07 15:15:05'),(3,'Marghzar Colony',100,1,'2026-04-07 15:15:05');
/*!40000 ALTER TABLE `delivery_locations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `diningtables`
--

DROP TABLE IF EXISTS `diningtables`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `diningtables` (
  `table_id` int NOT NULL AUTO_INCREMENT,
  `table_number` varchar(20) NOT NULL,
  `seating_capacity` int DEFAULT '4',
  `is_active` tinyint(1) DEFAULT '1',
  PRIMARY KEY (`table_id`),
  UNIQUE KEY `table_number` (`table_number`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `diningtables`
--

LOCK TABLES `diningtables` WRITE;
/*!40000 ALTER TABLE `diningtables` DISABLE KEYS */;
INSERT INTO `diningtables` VALUES (1,'T1',2,1),(2,'T2',4,1),(3,'T3',4,1),(4,'T4',6,1),(5,'VIP-1',8,1);
/*!40000 ALTER TABLE `diningtables` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `itemvariations`
--

DROP TABLE IF EXISTS `itemvariations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `itemvariations` (
  `variation_id` int NOT NULL AUTO_INCREMENT,
  `item_id` int NOT NULL,
  `size_name` varchar(50) DEFAULT 'Regular',
  `price` decimal(10,2) NOT NULL,
  `cost_price` decimal(10,2) DEFAULT '0.00',
  `sku` varchar(50) DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT '1',
  PRIMARY KEY (`variation_id`),
  UNIQUE KEY `sku` (`sku`),
  KEY `idx_itemvariations_item` (`item_id`),
  CONSTRAINT `itemvariations_ibfk_1` FOREIGN KEY (`item_id`) REFERENCES `menuitems` (`item_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=155 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `itemvariations`
--

LOCK TABLES `itemvariations` WRITE;
/*!40000 ALTER TABLE `itemvariations` DISABLE KEYS */;
INSERT INTO `itemvariations` VALUES (1,1,'Half',220.00,0.00,NULL,1),(2,1,'Full',850.00,0.00,NULL,1),(3,2,'Half',220.00,0.00,NULL,1),(4,2,'Full',850.00,0.00,NULL,1),(5,3,'Regular',400.00,0.00,NULL,1),(6,4,'Regular',1000.00,0.00,NULL,1),(7,5,'Half',750.00,0.00,NULL,1),(8,5,'Full',1250.00,0.00,NULL,1),(9,6,'Half',750.00,0.00,NULL,1),(10,6,'Full',1250.00,0.00,NULL,1),(11,7,'Half',750.00,0.00,NULL,1),(12,7,'Full',1250.00,0.00,NULL,1),(13,8,'Half',750.00,0.00,NULL,1),(14,8,'Full',1250.00,0.00,NULL,1),(15,9,'Half',750.00,0.00,NULL,1),(16,9,'Full',1250.00,0.00,NULL,1),(17,10,'Full',1400.00,0.00,NULL,1),(18,11,'Full',1350.00,0.00,NULL,1),(19,12,'Full',1350.00,0.00,NULL,1),(20,13,'Full',1350.00,0.00,NULL,1),(21,14,'Full',1250.00,0.00,NULL,1),(22,15,'Full',1250.00,0.00,NULL,1),(23,16,'Full',1250.00,0.00,NULL,1),(24,17,'Full',850.00,0.00,NULL,1),(25,18,'Regular',550.00,0.00,NULL,1),(26,19,'Regular',500.00,0.00,NULL,1),(27,20,'Regular',600.00,0.00,NULL,1),(28,21,'Regular',550.00,0.00,NULL,1),(29,22,'Regular',990.00,0.00,NULL,1),(30,23,'Regular',950.00,0.00,NULL,1),(31,24,'Regular',590.00,0.00,NULL,1),(32,25,'Regular',750.00,0.00,NULL,1),(33,26,'Regular',690.00,0.00,NULL,1),(34,27,'Regular',990.00,0.00,NULL,1),(35,28,'Regular',340.00,0.00,NULL,1),(36,29,'Regular',340.00,0.00,NULL,1),(37,30,'Regular',460.00,0.00,NULL,1),(38,31,'Regular',490.00,0.00,NULL,1),(39,32,'Regular',590.00,0.00,NULL,1),(40,33,'Regular',430.00,0.00,NULL,1),(41,34,'Regular',550.00,0.00,NULL,1),(42,35,'Regular',590.00,0.00,NULL,1),(43,36,'Regular',590.00,0.00,NULL,1),(44,37,'Regular',750.00,0.00,NULL,1),(45,38,'Regular',750.00,0.00,NULL,1),(46,39,'Regular',590.00,0.00,NULL,1),(47,40,'Regular',590.00,0.00,NULL,1),(48,41,'Regular',590.00,0.00,NULL,1),(49,42,'Regular',520.00,0.00,NULL,1),(50,43,'Regular',520.00,0.00,NULL,1),(51,44,'Regular',650.00,0.00,NULL,1),(52,45,'Regular',1150.00,0.00,NULL,1),(53,46,'Regular',1180.00,0.00,NULL,1),(54,47,'Regular',420.00,0.00,NULL,1),(55,48,'Regular',460.00,0.00,NULL,1),(56,49,'Medium',1250.00,0.00,NULL,1),(57,49,'Large',1590.00,0.00,NULL,1),(58,50,'Medium',1250.00,0.00,NULL,1),(59,50,'Large',1590.00,0.00,NULL,1),(60,51,'Medium',1250.00,0.00,NULL,1),(61,51,'Large',1590.00,0.00,NULL,1),(62,52,'Medium',1250.00,0.00,NULL,1),(63,52,'Large',1590.00,0.00,NULL,1),(64,53,'Medium',1250.00,0.00,NULL,1),(65,53,'Large',1590.00,0.00,NULL,1),(66,54,'Medium',1250.00,0.00,NULL,1),(67,54,'Large',1590.00,0.00,NULL,1),(68,55,'Medium',1250.00,0.00,NULL,1),(69,55,'Large',1590.00,0.00,NULL,1),(70,56,'Medium',1250.00,0.00,NULL,1),(71,56,'Large',1590.00,0.00,NULL,1),(72,57,'Medium',1450.00,0.00,NULL,1),(73,57,'Large',1850.00,0.00,NULL,1),(74,58,'Medium',1450.00,0.00,NULL,1),(75,58,'Large',1850.00,0.00,NULL,1),(76,59,'Small',560.00,0.00,NULL,1),(77,59,'Medium',1250.00,0.00,NULL,1),(78,59,'Large',1790.00,0.00,NULL,1),(79,60,'Medium',1250.00,0.00,NULL,1),(80,60,'Large',1790.00,0.00,NULL,1),(81,61,'Medium',1250.00,0.00,NULL,1),(82,61,'Large',1790.00,0.00,NULL,1),(83,62,'Medium',1450.00,0.00,NULL,1),(84,62,'Large',1950.00,0.00,NULL,1),(85,63,'Medium',1450.00,0.00,NULL,1),(86,63,'Large',1950.00,0.00,NULL,1),(87,64,'Regular',950.00,0.00,NULL,1),(88,65,'Regular',950.00,0.00,NULL,1),(89,66,'Regular',850.00,0.00,NULL,1),(90,67,'Regular',750.00,0.00,NULL,1),(91,68,'Regular',750.00,0.00,NULL,1),(92,69,'Regular',650.00,0.00,NULL,1),(93,70,'Regular',590.00,0.00,NULL,1),(94,71,'Regular',590.00,0.00,NULL,1),(95,72,'Regular',660.00,0.00,NULL,1),(96,73,'Regular',1150.00,0.00,NULL,1),(97,74,'Small',200.00,0.00,NULL,1),(98,74,'Large',320.00,0.00,NULL,1),(99,74,'Family',400.00,0.00,NULL,1),(100,75,'Regular',60.00,0.00,NULL,1),(101,76,'Regular',100.00,0.00,NULL,1),(102,77,'Regular',400.00,0.00,NULL,1),(103,78,'Regular',400.00,0.00,NULL,1),(104,79,'Regular',400.00,0.00,NULL,1),(105,80,'Regular',400.00,0.00,NULL,1),(106,81,'Regular',400.00,0.00,NULL,1),(107,82,'Regular',400.00,0.00,NULL,1),(108,83,'Regular',400.00,0.00,NULL,1),(109,84,'Regular',400.00,0.00,NULL,1),(110,85,'Regular',400.00,0.00,NULL,1),(111,86,'Regular',300.00,0.00,NULL,1),(112,87,'Regular',300.00,0.00,NULL,1),(113,88,'Regular',300.00,0.00,NULL,1),(114,89,'Regular',300.00,0.00,NULL,1),(115,90,'Regular',300.00,0.00,NULL,1),(116,91,'Regular',300.00,0.00,NULL,1),(117,92,'Regular',300.00,0.00,NULL,1),(118,93,'Regular',300.00,0.00,NULL,1),(119,94,'Regular',300.00,0.00,NULL,1),(120,95,'Regular',300.00,0.00,NULL,1),(121,96,'Regular',300.00,0.00,NULL,1),(122,97,'Regular',300.00,0.00,NULL,1),(123,98,'Regular',350.00,0.00,NULL,1),(124,99,'Regular',350.00,0.00,NULL,1),(125,100,'Regular',350.00,0.00,NULL,1),(126,101,'Regular',350.00,0.00,NULL,1),(127,102,'Regular',350.00,0.00,NULL,1),(128,103,'Regular',350.00,0.00,NULL,1),(129,104,'Regular',350.00,0.00,NULL,1),(130,105,'Regular',350.00,0.00,NULL,1),(131,106,'Regular',350.00,0.00,NULL,1),(132,107,'Regular',350.00,0.00,NULL,1),(133,108,'Regular',350.00,0.00,NULL,1),(134,109,'Regular',350.00,0.00,NULL,1),(135,110,'Regular',2200.00,0.00,NULL,1),(136,111,'Regular',1550.00,0.00,NULL,1),(137,112,'Regular',850.00,0.00,NULL,1),(138,113,'Regular',590.00,0.00,NULL,1),(139,114,'Regular',460.00,0.00,NULL,1),(140,115,'Regular',790.00,0.00,NULL,1),(141,116,'Regular',1650.00,0.00,NULL,1),(142,117,'Regular',2450.00,0.00,NULL,1),(143,118,'Regular',750.00,0.00,NULL,1),(144,119,'Regular',3250.00,0.00,NULL,1),(145,120,'Regular',3550.00,0.00,NULL,1),(146,121,'Regular',2650.00,0.00,NULL,1),(147,122,'Regular',2150.00,0.00,NULL,1),(148,123,'Regular',2950.00,0.00,NULL,1),(149,124,'Regular',750.00,0.00,NULL,1),(150,125,'Regular',4310.00,0.00,NULL,1),(151,501,'Half Litre',150.00,0.00,NULL,1),(152,501,'1 Litre',250.00,0.00,NULL,1),(153,502,'Half Litre',150.00,0.00,NULL,1),(154,502,'1 Litre',250.00,0.00,NULL,1);
/*!40000 ALTER TABLE `itemvariations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `menuitems`
--

DROP TABLE IF EXISTS `menuitems`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `menuitems` (
  `item_id` int NOT NULL AUTO_INCREMENT,
  `category_id` int NOT NULL,
  `name` varchar(150) NOT NULL,
  `description` text,
  `image_url` varchar(255) DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT '1',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `is_featured` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`item_id`),
  KEY `idx_menuitems_category` (`category_id`),
  CONSTRAINT `menuitems_ibfk_1` FOREIGN KEY (`category_id`) REFERENCES `categories` (`category_id`) ON DELETE RESTRICT
) ENGINE=InnoDB AUTO_INCREMENT=503 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `menuitems`
--

LOCK TABLES `menuitems` WRITE;
/*!40000 ALTER TABLE `menuitems` DISABLE KEYS */;
INSERT INTO `menuitems` VALUES (1,1,'Chicken Corn Soup',NULL,'https://images.unsplash.com/photo-1547592180-85f173990554?w=600',1,'2026-04-05 08:17:34','2026-04-09 12:50:07',0),(2,1,'Chicken Hot & Sour Soup',NULL,'https://images.unsplash.com/photo-1585032226651-759b368d7246?w=600',1,'2026-04-05 08:17:34','2026-04-09 12:50:07',0),(3,1,'Fish Cracker',NULL,'https://images.unsplash.com/photo-1563245372-f21724e3856d?w=600',1,'2026-04-05 08:17:34','2026-04-09 12:50:07',0),(4,1,'Drum Sticks (4 Piece)',NULL,'https://images.unsplash.com/photo-1527477396000-e27163b481c2?w=600',1,'2026-04-05 08:17:34','2026-04-09 12:50:07',0),(5,2,'Chicken Shashlik With Rice',NULL,'https://images.unsplash.com/photo-1603360946369-dc9bb6258143?w=600',1,'2026-04-05 08:17:39','2026-04-09 12:50:07',0),(6,2,'Chicken Manchurian With Rice',NULL,'https://images.unsplash.com/photo-1565557623262-b51c2513a641?w=600',1,'2026-04-05 08:17:39','2026-04-09 12:50:07',0),(7,2,'Chicken Black Pepper With Rice',NULL,'https://images.unsplash.com/photo-1598514983318-2f64f8f4796c?w=600',1,'2026-04-05 08:17:39','2026-04-09 12:50:07',0),(8,2,'Chicken Garlic With Rice',NULL,'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=600',1,'2026-04-05 08:17:39','2026-04-09 12:50:07',0),(9,2,'Chicken Szechuan With Rice',NULL,'https://images.unsplash.com/photo-1455619452474-d2be8b1e70cd?w=600',1,'2026-04-05 08:17:39','2026-04-09 12:50:07',0),(10,2,'KF Special With Rice',NULL,'https://images.unsplash.com/photo-1603133872878-684f208fb84b?w=600',1,'2026-04-05 08:17:39','2026-04-09 12:50:07',0),(11,2,'Chicken Chilli Dry With Rice',NULL,'https://images.unsplash.com/photo-1569050467447-ce54b3bbc37d?w=600',1,'2026-04-05 08:17:39','2026-04-09 12:50:07',0),(12,2,'Chicken Almond With Rice',NULL,'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=600',1,'2026-04-05 08:17:39','2026-04-09 12:50:07',0),(13,2,'King Pao Chicken With Rice',NULL,'https://images.unsplash.com/photo-1534422298391-e4f8c172dddb?w=600',1,'2026-04-05 08:17:39','2026-04-09 12:50:07',0),(14,2,'Chicken Vegetable With Rice',NULL,'https://images.unsplash.com/photo-1512058564366-18510be2db19?w=600',1,'2026-04-05 08:17:39','2026-04-09 12:50:07',0),(15,2,'Chicken Sweet & Sour With Rice',NULL,'https://images.unsplash.com/photo-1540189549336-e6e99c3679fe?w=600',1,'2026-04-05 08:17:39','2026-04-09 12:50:07',0),(16,2,'Hot Sauce Chicken With Rice',NULL,'https://images.unsplash.com/photo-1574484284002-952d92456975?w=600',1,'2026-04-05 08:17:39','2026-04-09 12:50:07',0),(17,2,'Chicken Chowmein',NULL,'https://images.unsplash.com/photo-1585325701165-f1a4d3e81e36?w=600',1,'2026-04-05 08:17:39','2026-04-09 12:50:07',0),(18,3,'Chicken Fried Rice',NULL,'https://images.unsplash.com/photo-1516684732162-798a0062be99?w=600',1,'2026-04-05 08:17:47','2026-04-09 12:50:07',0),(19,3,'Egg Fried Rice',NULL,'https://images.unsplash.com/photo-1555126634-323283e090fa?w=600',1,'2026-04-05 08:17:47','2026-04-09 12:50:07',0),(20,3,'Chicken Masala Rice',NULL,'https://images.unsplash.com/photo-1596560548464-f010549b84d7?w=600',1,'2026-04-05 08:17:47','2026-04-09 12:50:07',0),(21,4,'KF Loaded Fries',NULL,'https://images.unsplash.com/photo-1630384060421-cb20d0e0649d?w=600',1,'2026-04-05 08:17:51','2026-04-09 12:50:07',0),(22,4,'Hot Cheeto Burrito',NULL,'https://images.unsplash.com/photo-1626700051175-6818013e1d4f?w=600',1,'2026-04-05 08:17:51','2026-04-09 12:50:07',0),(23,4,'KF Nashville Buritto',NULL,'https://images.unsplash.com/photo-1599974579688-8dbdd335c77f?w=600',1,'2026-04-05 08:17:51','2026-04-09 12:50:07',0),(24,4,'KF Nashville',NULL,'https://www.seriouseats.com/thmb/zZLQZ3IvBpcq-NfahgHLZYwvbwg=/1500x0/filters:no_upscale():max_bytes(150000):strip_icc()/20231117-SEA-NashvilleHotChicken-VictorProtasio-01-83231777673a434fa85b8f0ef524b4c9.jpg',1,'2026-04-05 08:17:51','2026-04-09 14:23:17',0),(25,4,'Kzing',NULL,'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=600',1,'2026-04-05 08:17:51','2026-04-09 12:50:07',0),(26,5,'Beef Classic Cheddar Melt',NULL,'https://images.unsplash.com/photo-1550547660-d9450f859349?w=600',1,'2026-04-05 08:17:56','2026-04-09 12:50:07',0),(27,5,'Double Beef Classic Cheddar Melt',NULL,'https://images.unsplash.com/photo-1553979459-d2229ba7433b?w=600',1,'2026-04-05 08:17:56','2026-04-09 12:50:07',0),(28,5,'Crispy Patty Burger',NULL,'https://images.unsplash.com/photo-1596956470007-2bf6095e7e16?w=600',1,'2026-04-05 08:17:56','2026-04-09 12:50:07',0),(29,5,'Chicken Chapli Kabab Burger',NULL,'https://images.unsplash.com/photo-1572802419224-296b0aeee0d9?w=600',1,'2026-04-05 08:17:56','2026-04-09 12:50:07',0),(30,5,'Zinger Burger',NULL,'https://images.unsplash.com/photo-1571091718767-18b5b1457add?w=600',1,'2026-04-05 08:17:56','2026-04-09 12:50:07',1),(31,5,'Zinger Cheese Burger',NULL,'https://images.unsplash.com/photo-1606755962773-d324e0a13086?w=600',1,'2026-04-05 08:17:56','2026-04-09 12:50:07',0),(32,5,'Double Patty Burger',NULL,'https://images.unsplash.com/photo-1594212699903-ec8a3eca50f5?w=600',1,'2026-04-05 08:17:56','2026-04-09 12:50:07',0),(33,5,'Hot Mirchi Burger',NULL,'https://images.unsplash.com/photo-1610440042657-612c34d95e9f?w=600',1,'2026-04-05 08:17:56','2026-04-09 12:50:07',0),(34,6,'Chicken Sandwich',NULL,'https://images.unsplash.com/photo-1481070555726-e2fe8357725c?w=600',1,'2026-04-05 08:18:00','2026-04-09 12:50:07',0),(35,6,'Chicken Club Sandwich',NULL,'https://images.unsplash.com/photo-1528735602780-2552fd46c7af?w=600',1,'2026-04-05 08:18:00','2026-04-09 12:50:07',0),(36,6,'Chicken Cheese Sandwich',NULL,'https://images.unsplash.com/photo-1550507992-eb63ffee0847?w=600',1,'2026-04-05 08:18:00','2026-04-09 12:50:07',0),(37,6,'Euro Sandwich',NULL,'https://images.unsplash.com/photo-1509722747041-616f39b57569?w=600',1,'2026-04-05 08:18:00','2026-04-09 12:50:07',0),(38,6,'Mexican Cheese Sandwich',NULL,'https://www.seriouseats.com/thmb/BPEON1Ct7wNBA7rRHV4lBuGgGps=/1500x0/filters:no_upscale():max_bytes(150000):strip_icc()/20240304-SEA-Pambazo-Lorena-Masso-28-aa0abb8c8a384c968dc3045471dbd876.jpg',1,'2026-04-05 08:18:00','2026-04-09 14:24:39',0),(39,7,'KF-Signature Wings',NULL,'https://images.unsplash.com/photo-1527477396000-e27163b481c2?w=600',1,'2026-04-05 08:18:04','2026-04-09 12:50:07',0),(40,7,'Saucy Wings Garlic',NULL,'https://images.unsplash.com/photo-1608039829572-78524f79c4c7?w=600',1,'2026-04-05 08:18:04','2026-04-09 12:50:07',0),(41,7,'Hot Honey Wings',NULL,'https://images.unsplash.com/photo-1562802378-063ec186a863?w=600',1,'2026-04-05 08:18:04','2026-04-09 12:50:07',0),(42,7,'Grilled Chicken Salad',NULL,'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=600',1,'2026-04-05 08:18:04','2026-04-09 12:50:07',0),(43,7,'Nashville Salad',NULL,'https://images.unsplash.com/photo-1540420773420-3366772f4999?w=600',1,'2026-04-05 08:18:04','2026-04-09 12:50:07',0),(44,7,'Hot Honey Popers',NULL,'https://images.unsplash.com/photo-1548943487-a2e4e43b4853?w=600',1,'2026-04-05 08:18:04','2026-04-09 12:50:07',0),(45,8,'Chicken Platter',NULL,'https://images.unsplash.com/photo-1606728035253-49e8a23146de?w=600',1,'2026-04-05 08:18:13','2026-04-09 12:50:07',0),(46,8,'Chicken Cheese Platter',NULL,'https://images.unsplash.com/photo-1619895092538-128341789043?w=600',1,'2026-04-05 08:18:13','2026-04-09 12:50:07',0),(47,8,'Chicken Shawarma',NULL,'https://images.unsplash.com/photo-1529006557810-274b9b2fc783?w=600',1,'2026-04-05 08:18:13','2026-04-09 12:50:07',0),(48,8,'Chicken Cheese Shawarma',NULL,'https://media-cdn.tripadvisor.com/media/photo-s/1c/d4/5e/b1/mushroom-chick-shawarma.jpg',1,'2026-04-05 08:18:13','2026-04-09 14:25:38',0),(49,9,'Chicken Tikka Pizza',NULL,'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=600',1,'2026-04-05 08:18:18','2026-04-09 12:50:07',0),(50,9,'Chicken Fajita Pizza',NULL,'https://images.unsplash.com/photo-1513104890138-7c749659a591?w=600',1,'2026-04-05 08:18:18','2026-04-09 12:50:07',0),(51,9,'Hot & Spicy Pizza',NULL,'https://images.unsplash.com/photo-1628840042765-356cda07504e?w=600',1,'2026-04-05 08:18:18','2026-04-09 12:50:07',0),(52,9,'Chicken Mushroom Pizza',NULL,'https://images.unsplash.com/photo-1574071318508-1cdbab80d002?w=600',1,'2026-04-05 08:18:18','2026-04-09 12:50:07',0),(53,9,'BBQ Pizza',NULL,'https://images.unsplash.com/photo-1558030006-450675393462?w=600',1,'2026-04-05 08:18:18','2026-04-09 12:50:07',0),(54,9,'American Hot Pizza',NULL,'https://images.unsplash.com/photo-1534308983496-4fabb1a015ee?w=600',1,'2026-04-05 08:18:18','2026-04-09 12:50:07',0),(55,9,'Pepperoni Pizza',NULL,'https://images.unsplash.com/photo-1548369937-47519962c11a?w=600',1,'2026-04-05 08:18:18','2026-04-09 12:50:07',0),(56,9,'Chicken Supreme Pizza',NULL,'https://images.unsplash.com/photo-1555072956-7758afb20e8f?w=600',1,'2026-04-05 08:18:18','2026-04-09 12:50:07',0),(57,9,'Crown Crust Pizza',NULL,'https://images.unsplash.com/photo-1590947132387-155cc02f3212?w=600',1,'2026-04-05 08:18:18','2026-04-09 12:50:07',0),(58,9,'Behari Kabab Pizza',NULL,'https://images.unsplash.com/photo-1593560708920-61dd98c46a4e?w=600',1,'2026-04-05 08:18:18','2026-04-09 12:50:07',0),(59,9,'K.F Special Pizza',NULL,'https://images.unsplash.com/photo-1571407970349-bc81e7e96d47?w=600',1,'2026-04-05 08:18:18','2026-04-09 12:50:07',0),(60,9,'Malai Boti Pizza',NULL,'https://images.unsplash.com/photo-1604382354936-07c5d9983bd3?w=600',1,'2026-04-05 08:18:18','2026-04-09 12:50:07',0),(61,9,'Mexican Pizza',NULL,'https://images.unsplash.com/photo-1513104890138-7c749659a591?w=600',1,'2026-04-05 08:18:18','2026-04-09 12:50:07',0),(62,9,'Kabab Stuffer',NULL,'https://g-cdn.blinkco.io/ordering-system/55812/dish_image/1733124920.png',1,'2026-04-05 08:18:18','2026-04-09 14:26:26',0),(63,9,'Cheese Stuffer',NULL,'https://images.unsplash.com/photo-1506354666786-959d6d497f1a?w=600',1,'2026-04-05 08:18:18','2026-04-09 12:50:07',0),(64,10,'Kabab Cheesy Roll',NULL,'https://images.unsplash.com/photo-1603360946369-dc9bb6258143?w=600',1,'2026-04-05 08:18:22','2026-04-09 12:50:07',0),(65,10,'Chicken Cheesy Roll',NULL,'https://images.unsplash.com/photo-1600803907087-f56d462fd26b?w=600',1,'2026-04-05 08:18:22','2026-04-09 12:50:07',0),(66,10,'Crunchy Chicken Pasta',NULL,'https://images.unsplash.com/photo-1621996346565-e3dbc646d9a9?w=600',1,'2026-04-05 08:18:22','2026-04-09 12:50:07',0),(67,10,'Creamy Pasta',NULL,'https://images.unsplash.com/photo-1555949258-eb67b1ef0ceb?w=600',1,'2026-04-05 08:18:22','2026-04-09 12:50:07',0),(68,10,'Macaroni Pasta',NULL,'https://www.funfoodfrolic.com/wp-content/uploads/2021/08/Macaroni-Thumbnail-Blog-500x375.jpg',1,'2026-04-05 08:18:22','2026-04-09 14:26:59',0),(69,10,'Oven Baked Wings (10 pcs)',NULL,'https://images.unsplash.com/photo-1567620832903-9fc6debc209f?w=600',1,'2026-04-05 08:18:22','2026-04-09 12:50:07',0),(70,10,'Malai Botti Spin Rolls (4 pcs)',NULL,'https://images.unsplash.com/photo-1590301157890-4810ed352733?w=600',1,'2026-04-05 08:18:22','2026-04-09 12:50:07',0),(71,10,'Chicken Spin Rolls (4 pcs)',NULL,'https://images.unsplash.com/photo-1529543544282-ea669407fca3?w=600',1,'2026-04-05 08:18:22','2026-04-09 12:50:07',0),(72,10,'Chilli Milli Rolls (4 pcs)',NULL,'https://images.unsplash.com/photo-1601050690597-df0568f70950?w=600',1,'2026-04-05 08:18:22','2026-04-09 12:50:07',0),(73,10,'Special Platter',NULL,'https://images.unsplash.com/photo-1544025162-d76694265947?w=600',1,'2026-04-05 08:18:22','2026-04-09 12:50:07',0),(74,11,'Crinkle Fries',NULL,'https://images.unsplash.com/photo-1576107232684-1279f390859f?w=600',1,'2026-04-05 08:18:26','2026-04-09 12:50:07',0),(75,12,'Small Water Bottle',NULL,'https://images.unsplash.com/photo-1548839140-29a749e1cf4d?w=600',1,'2026-04-05 08:18:34','2026-04-09 12:50:07',0),(76,12,'Reg Drink Glass',NULL,'https://jodiabaazar.com/cdn/shop/files/coke250glass.jpg?v=1695053728&width=1445',1,'2026-04-05 08:18:34','2026-04-09 14:27:58',0),(77,13,'Oreo Shake',NULL,'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=600',1,'2026-04-05 08:18:34','2026-04-09 12:50:07',0),(78,13,'Chocolate Shake',NULL,'https://cdn.sanity.io/images/5dqbssss/production-v4/3ba3f137c02a6f320c156bb7c39e362bdbd87bb8-1356x1576.jpg',1,'2026-04-05 08:18:34','2026-04-09 14:29:48',0),(79,13,'Strawberry Shake',NULL,'https://images.unsplash.com/photo-1553361371-9b22f78e8b1d?w=600',1,'2026-04-05 08:18:34','2026-04-09 12:50:07',0),(80,13,'Pink Barbie Shake',NULL,'https://images.unsplash.com/photo-1613478223719-2ab802602423?w=600',1,'2026-04-05 08:18:34','2026-04-09 12:50:07',0),(81,13,'Cold Coffee',NULL,'https://images.unsplash.com/photo-1534352956036-cd81e27dd615?w=600',1,'2026-04-05 08:18:34','2026-04-09 12:50:07',0),(82,13,'Pina Colada',NULL,'https://images.unsplash.com/photo-1621263764928-df1444c5e859?w=600',1,'2026-04-05 08:18:34','2026-04-09 12:50:07',0),(83,13,'Blue Lagoon',NULL,'https://images.unsplash.com/photo-1544145945-f90425340c7e?w=600',1,'2026-04-05 08:18:34','2026-04-09 12:50:07',0),(84,13,'Chocolate Peanut Butter Shake',NULL,'https://images.unsplash.com/photo-1569718212165-3a8278d5f624?w=600',1,'2026-04-05 08:18:34','2026-04-09 12:50:07',0),(85,13,'Power House Shake',NULL,'https://sfnutrition.co.uk/cdn/shop/articles/Vanilla_lla_1445x.jpg?v=1707148275',1,'2026-04-05 08:18:34','2026-04-09 14:30:29',0),(86,14,'Mint Margarita',NULL,'https://images.unsplash.com/photo-1556679343-c7306c1976bc?w=600',1,'2026-04-05 08:18:34','2026-04-09 12:50:07',0),(87,14,'Mango Smoothie',NULL,'https://images.unsplash.com/photo-1546173159-315724a31696?w=600',1,'2026-04-05 08:18:34','2026-04-09 12:50:07',0),(88,14,'Strawberry Margarita',NULL,'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSFbCO3LzLf4CQIQh2oz8-E1KU6yWSse-qBtQ&s',1,'2026-04-05 08:18:34','2026-04-09 14:31:04',0),(89,14,'Peach Smoothie',NULL,'https://images.unsplash.com/photo-1563805042-7684c019e1cb?w=600',1,'2026-04-05 08:18:34','2026-04-09 12:50:07',0),(90,14,'Blueberry Margarita',NULL,'https://images.unsplash.com/photo-1570696516188-ade861b84a49?w=600',1,'2026-04-05 08:18:34','2026-04-09 12:50:07',0),(91,14,'Banana Smoothie',NULL,'https://images.unsplash.com/photo-1553530666-ba11a7da3888?w=600',1,'2026-04-05 08:18:34','2026-04-09 12:50:07',0),(92,14,'Apple Mint',NULL,'https://img-global.cpcdn.com/recipes/9839efbbc71ddbfb/680x781cq80/mint-margarita-recipe-main-photo.jpg',1,'2026-04-05 08:18:34','2026-04-09 14:32:17',0),(93,14,'Gawa Smoothie',NULL,'https://images.unsplash.com/photo-1589733955941-5eeaf752f6dd?w=600',1,'2026-04-05 08:18:34','2026-04-09 12:50:07',0),(94,14,'Lime Margarita',NULL,'https://images.unsplash.com/photo-1513558161293-cdaf765ed2fd?w=600',1,'2026-04-05 08:18:34','2026-04-09 12:50:07',0),(95,14,'Apple Juice',NULL,'https://thumbs.dreamstime.com/b/glass-apple-juice-slice-ice-refreshing-summer-background-249797723.jpg',1,'2026-04-05 08:18:34','2026-04-09 14:33:31',0),(96,14,'Lemu Pani',NULL,'https://images.unsplash.com/photo-1621263764928-df1444c5e859?w=600',1,'2026-04-05 08:18:34','2026-04-09 12:50:07',0),(97,14,'Orange (Seasonal)',NULL,'https://images.unsplash.com/photo-1600271886742-f049cd451bba?w=600',1,'2026-04-05 08:18:34','2026-04-09 12:50:07',0),(98,15,'Lemon Soda',NULL,'https://bakesbybrownsugar.com/wp-content/uploads/2023/01/Lemon-Soda-15C.jpg',1,'2026-04-05 08:18:34','2026-04-09 14:34:19',0),(99,15,'Peach Iced Tea',NULL,'https://images.unsplash.com/photo-1556679343-c7306c1976bc?w=600',1,'2026-04-05 08:18:34','2026-04-09 12:50:07',0),(100,15,'Mint Lime Mojito',NULL,'https://images.unsplash.com/photo-1609951651556-5334e2706168?w=600',1,'2026-04-05 08:18:34','2026-04-09 12:50:07',0),(101,15,'Passion Fruit Mojito',NULL,'https://images.unsplash.com/photo-1595981267035-7b04ca84a82d?w=600',1,'2026-04-05 08:18:34','2026-04-09 12:50:07',0),(102,15,'Strawberry Mojito',NULL,'https://images.unsplash.com/photo-1551024709-8f23befc6f87?w=600',1,'2026-04-05 08:18:34','2026-04-09 12:50:07',0),(103,15,'Raspberry Iced Tea',NULL,'https://images.unsplash.com/photo-1571091718767-18b5b1457add?w=600',1,'2026-04-05 08:18:34','2026-04-09 12:50:07',0),(104,15,'Strawberry Kiwi Chillar',NULL,'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcT_YAgSHs5CnpiEFykKd26iyd7XEPJrV25YoQ&s',1,'2026-04-05 08:18:34','2026-04-09 14:35:04',0),(105,15,'Lighting Shot',NULL,'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=600',1,'2026-04-05 08:18:34','2026-04-09 12:50:07',0),(106,15,'Purple Heaven',NULL,'https://images.unsplash.com/photo-1570696516188-ade861b84a49?w=600',1,'2026-04-05 08:18:34','2026-04-09 12:50:07',0),(107,15,'Electric Lemonade',NULL,'https://images.unsplash.com/photo-1497534446932-c925b458314e?w=600',1,'2026-04-05 08:18:34','2026-04-09 12:50:07',0),(108,15,'Orange Italian Soda',NULL,'https://images.unsplash.com/photo-1523371054106-bbf80586c38c?w=600',1,'2026-04-05 08:18:34','2026-04-09 12:50:07',0),(109,15,'Kiwi Chillar',NULL,'https://images.unsplash.com/photo-1561043433-aaf687c4cf04?w=600',1,'2026-04-05 08:18:34','2026-04-09 12:50:07',0),(110,16,'Nashville Tenders Family Deal',NULL,'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTJPlZhhtzokWlRKQEmHO282w5YTw5A510eiA&s',1,'2026-04-05 08:18:38','2026-04-09 14:35:43',0),(111,16,'Nashville Tenders 2 Person Deal',NULL,'https://images.unsplash.com/photo-1562967914-608f82629710?w=600',1,'2026-04-05 08:18:38','2026-04-09 12:50:07',0),(112,16,'Nashville Tenders Single Deal',NULL,'https://images.unsplash.com/photo-1606728035253-49e8a23146de?w=600',1,'2026-04-05 08:18:38','2026-04-09 12:50:07',0),(113,16,'Deal-1 (Mazedari)',NULL,'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=600',1,'2026-04-05 08:18:38','2026-04-09 12:50:07',0),(114,16,'Deal-2 (Mazedari)',NULL,'https://images.unsplash.com/photo-1550547660-d9450f859349?w=600',1,'2026-04-05 08:18:38','2026-04-09 12:50:07',0),(115,16,'Deal-3 (Mazedari)',NULL,'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=600',1,'2026-04-05 08:18:38','2026-04-09 12:50:07',0),(116,16,'Deal-4 (Mazedari)',NULL,'https://images.unsplash.com/photo-1603360946369-dc9bb6258143?w=600',1,'2026-04-05 08:18:38','2026-04-09 12:50:07',0),(117,16,'Deal-5 (Mazedari)',NULL,'https://images.unsplash.com/photo-1544025162-d76694265947?w=600',1,'2026-04-05 08:18:38','2026-04-09 12:50:07',0),(118,16,'Deal-6 (Mazedari)',NULL,'https://images.unsplash.com/photo-1604382354936-07c5d9983bd3?w=600',1,'2026-04-05 08:18:38','2026-04-09 12:50:07',0),(119,16,'Deal-7 (Exclusive)',NULL,'https://images.unsplash.com/photo-1513104890138-7c749659a591?w=600',1,'2026-04-05 08:18:38','2026-04-09 12:50:07',0),(120,16,'Deal-8 (Exclusive)',NULL,'https://images.unsplash.com/photo-1555072956-7758afb20e8f?w=600',1,'2026-04-05 08:18:38','2026-04-09 12:50:07',0),(121,16,'Deal-9 (Exclusive)',NULL,'https://images.unsplash.com/photo-1571091718767-18b5b1457add?w=600',1,'2026-04-05 08:18:38','2026-04-09 12:50:07',0),(122,16,'Deal-10 (Exclusive)',NULL,'https://images.unsplash.com/photo-1596956470007-2bf6095e7e16?w=600',1,'2026-04-05 08:18:38','2026-04-09 12:50:07',0),(123,16,'Deal-11 (Exclusive)',NULL,'https://images.unsplash.com/photo-1553979459-d2229ba7433b?w=600',1,'2026-04-05 08:18:38','2026-04-09 14:36:12',0),(124,16,'Deal-12 (Exclusive)',NULL,'https://images.unsplash.com/photo-1553979459-d2229ba7433b?w=600',1,'2026-04-05 08:18:38','2026-04-09 12:50:07',0),(125,16,'Deal-13 (Exclusive)',NULL,'https://images.unsplash.com/photo-1630384060421-cb20d0e0649d?w=600',1,'2026-04-05 08:18:38','2026-04-09 12:50:07',0),(501,12,'Coke',NULL,'https://images.unsplash.com/photo-1629203851122-3726ecdf080e?w=600',1,'2026-04-06 13:38:13','2026-04-09 12:50:07',0),(502,12,'Sprite',NULL,'https://www.cebooze.com/app/uploads/2020/10/spritecan.jpg',1,'2026-04-06 13:38:13','2026-04-09 14:28:48',0);
/*!40000 ALTER TABLE `menuitems` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `modifiers`
--

DROP TABLE IF EXISTS `modifiers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `modifiers` (
  `modifier_id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `price` decimal(10,2) NOT NULL,
  `is_active` tinyint(1) DEFAULT '1',
  `image_url` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`modifier_id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `modifiers`
--

LOCK TABLES `modifiers` WRITE;
/*!40000 ALTER TABLE `modifiers` DISABLE KEYS */;
INSERT INTO `modifiers` VALUES (1,'Extra Cheese',80.00,1,'https://static.tossdown.com/images/aea58297-7638-4970-9fb3-937fd9588b3b.webp'),(2,'Extra Shawarma Bread',50.00,1,'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=600'),(3,'Add Small  Crinkle Fries',200.00,1,NULL);
/*!40000 ALTER TABLE `modifiers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `orderitemmodifiers`
--

DROP TABLE IF EXISTS `orderitemmodifiers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `orderitemmodifiers` (
  `order_item_modifier_id` int NOT NULL AUTO_INCREMENT,
  `order_item_id` int NOT NULL,
  `modifier_id` int NOT NULL,
  `modifier_price` decimal(10,2) NOT NULL,
  PRIMARY KEY (`order_item_modifier_id`),
  KEY `order_item_id` (`order_item_id`),
  KEY `modifier_id` (`modifier_id`),
  CONSTRAINT `orderitemmodifiers_ibfk_1` FOREIGN KEY (`order_item_id`) REFERENCES `orderitems` (`order_item_id`) ON DELETE CASCADE,
  CONSTRAINT `orderitemmodifiers_ibfk_2` FOREIGN KEY (`modifier_id`) REFERENCES `modifiers` (`modifier_id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `orderitemmodifiers`
--

LOCK TABLES `orderitemmodifiers` WRITE;
/*!40000 ALTER TABLE `orderitemmodifiers` DISABLE KEYS */;
/*!40000 ALTER TABLE `orderitemmodifiers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `orderitems`
--

DROP TABLE IF EXISTS `orderitems`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `orderitems` (
  `order_item_id` int NOT NULL AUTO_INCREMENT,
  `order_id` int NOT NULL,
  `variation_id` int DEFAULT NULL,
  `quantity` int NOT NULL DEFAULT '1',
  `unit_price` decimal(10,2) NOT NULL,
  `subtotal` decimal(10,2) NOT NULL,
  `kitchen_notes` varchar(255) DEFAULT NULL,
  `modifiers` varchar(255) DEFAULT NULL,
  `standalone_name` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`order_item_id`),
  KEY `order_id` (`order_id`),
  KEY `variation_id` (`variation_id`),
  CONSTRAINT `orderitems_ibfk_1` FOREIGN KEY (`order_id`) REFERENCES `orders` (`order_id`) ON DELETE CASCADE,
  CONSTRAINT `orderitems_ibfk_2` FOREIGN KEY (`variation_id`) REFERENCES `itemvariations` (`variation_id`) ON DELETE RESTRICT
) ENGINE=InnoDB AUTO_INCREMENT=53 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `orderitems`
--

LOCK TABLES `orderitems` WRITE;
/*!40000 ALTER TABLE `orderitems` DISABLE KEYS */;
INSERT INTO `orderitems` VALUES (1,1,29,1,990.00,990.00,NULL,NULL,NULL),(2,2,112,1,300.00,300.00,NULL,NULL,NULL),(3,4,33,1,770.00,770.00,NULL,NULL,NULL),(4,5,33,1,770.00,770.00,NULL,NULL,NULL),(5,6,35,1,420.00,420.00,NULL,NULL,NULL),(6,10,52,1,1200.00,1200.00,NULL,'Extra Shawarma Bread',NULL),(7,13,NULL,2,50.00,100.00,NULL,NULL,'Extra Shawarma Bread'),(8,13,52,1,1150.00,1150.00,NULL,NULL,NULL),(9,14,NULL,1,80.00,80.00,NULL,NULL,'Extra Cheese'),(10,15,57,3,1590.00,4770.00,NULL,NULL,NULL),(11,16,46,1,590.00,590.00,NULL,NULL,NULL),(12,17,28,1,550.00,550.00,NULL,NULL,NULL),(13,18,2,1,850.00,850.00,NULL,NULL,NULL),(14,19,5,1,450.00,450.00,NULL,'Extra Shawarma Bread',NULL),(15,20,2,1,850.00,850.00,NULL,NULL,NULL),(16,21,111,1,300.00,300.00,NULL,NULL,NULL),(17,22,2,1,850.00,850.00,NULL,NULL,NULL),(18,23,33,1,690.00,690.00,NULL,NULL,NULL),(19,24,4,1,850.00,850.00,NULL,NULL,NULL),(20,25,4,1,850.00,850.00,NULL,NULL,NULL),(21,26,2,1,850.00,850.00,NULL,NULL,NULL),(22,27,4,1,900.00,900.00,NULL,'Extra Shawarma Bread',NULL),(23,28,1,1,300.00,300.00,NULL,'Extra Cheese',NULL),(24,29,2,1,850.00,850.00,NULL,NULL,NULL),(25,30,111,1,300.00,300.00,NULL,NULL,NULL),(26,30,NULL,3,130.00,390.00,NULL,'Extra Shawarma Bread','Extra Cheese'),(27,31,2,1,1050.00,1050.00,NULL,'Add Small  Crinkle Fries',NULL),(28,32,5,1,400.00,400.00,NULL,NULL,NULL),(29,33,2,1,850.00,850.00,NULL,NULL,NULL),(30,34,2,1,850.00,850.00,NULL,NULL,NULL),(31,35,4,1,850.00,850.00,NULL,NULL,NULL),(32,36,22,1,1250.00,1250.00,NULL,NULL,NULL),(33,36,4,1,850.00,850.00,NULL,NULL,NULL),(34,37,22,1,1250.00,1250.00,NULL,NULL,NULL),(35,37,4,1,850.00,850.00,NULL,NULL,NULL),(36,38,22,1,1250.00,1250.00,NULL,NULL,NULL),(37,38,4,1,850.00,850.00,NULL,NULL,NULL),(38,39,22,1,1250.00,1250.00,NULL,NULL,NULL),(39,39,4,1,850.00,850.00,NULL,NULL,NULL),(40,40,NULL,4,50.00,200.00,NULL,NULL,'Extra Shawarma Bread'),(41,41,46,1,590.00,590.00,NULL,NULL,NULL),(42,42,87,1,950.00,950.00,NULL,NULL,NULL),(43,43,5,1,480.00,480.00,NULL,'Extra Cheese',NULL),(44,44,87,1,950.00,950.00,NULL,NULL,NULL),(45,45,111,1,300.00,300.00,NULL,NULL,NULL),(46,45,115,1,300.00,300.00,NULL,NULL,NULL),(47,45,116,1,300.00,300.00,NULL,NULL,NULL),(48,45,113,1,300.00,300.00,NULL,NULL,NULL),(49,45,144,1,3250.00,3250.00,NULL,NULL,NULL),(50,45,NULL,1,200.00,200.00,NULL,NULL,'Add Small  Crinkle Fries'),(51,46,53,2,1180.00,2360.00,NULL,NULL,NULL),(52,46,2,1,850.00,850.00,NULL,NULL,NULL);
/*!40000 ALTER TABLE `orderitems` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `orders`
--

DROP TABLE IF EXISTS `orders`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `orders` (
  `order_id` int NOT NULL AUTO_INCREMENT,
  `order_number` varchar(50) NOT NULL,
  `staff_id` int NOT NULL,
  `table_id` int DEFAULT NULL,
  `order_type` enum('Dine-in','Takeaway','Delivery','Website Delivery') DEFAULT NULL,
  `order_status` varchar(50) DEFAULT 'Pending',
  `subtotal` decimal(10,2) NOT NULL DEFAULT '0.00',
  `tax_amount` decimal(10,2) NOT NULL DEFAULT '0.00',
  `discount_amount` decimal(10,2) NOT NULL DEFAULT '0.00',
  `total_amount` decimal(10,2) NOT NULL DEFAULT '0.00',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `status` varchar(50) DEFAULT 'Pending',
  `customer_phone` varchar(20) DEFAULT NULL,
  `rejection_reason` varchar(255) DEFAULT NULL,
  `delivery_address` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`order_id`),
  UNIQUE KEY `order_number` (`order_number`),
  KEY `staff_id` (`staff_id`),
  KEY `table_id` (`table_id`),
  KEY `idx_orders_status` (`order_status`),
  KEY `idx_orders_date` (`created_at`),
  CONSTRAINT `orders_ibfk_1` FOREIGN KEY (`staff_id`) REFERENCES `staff` (`staff_id`),
  CONSTRAINT `orders_ibfk_2` FOREIGN KEY (`table_id`) REFERENCES `diningtables` (`table_id`)
) ENGINE=InnoDB AUTO_INCREMENT=47 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `orders`
--

LOCK TABLES `orders` WRITE;
/*!40000 ALTER TABLE `orders` DISABLE KEYS */;
INSERT INTO `orders` VALUES (1,'ORD-1775466735411',1,NULL,'Takeaway','Completed',0.00,0.00,0.00,990.00,'2026-04-06 09:12:15','2026-04-06 09:12:37','Pending','03188164861',NULL,NULL),(2,'ORD-1775468063959',1,NULL,'Takeaway','Completed',0.00,0.00,0.00,300.00,'2026-04-06 09:34:23','2026-04-06 09:34:50','Pending','12345678999',NULL,NULL),(4,'ORD-1775469052073',1,NULL,'Takeaway','Completed',0.00,0.00,0.00,770.00,'2026-04-06 09:50:52','2026-04-06 09:58:42','Pending','78787878784',NULL,NULL),(5,'ORD-1775469484402',1,NULL,'Takeaway','Completed',0.00,0.00,0.00,770.00,'2026-04-06 09:58:04','2026-04-06 09:59:02','Pending','12345678911',NULL,NULL),(6,'ORD-1775469617739',1,NULL,'Takeaway','Completed',0.00,0.00,0.00,420.00,'2026-04-06 10:00:17','2026-04-06 10:00:37','Pending','78784512457',NULL,NULL),(10,'ORD-1775470861265',1,NULL,'Takeaway','Completed',0.00,0.00,0.00,1200.00,'2026-04-06 10:21:01','2026-04-06 10:21:15','Pending','78784578458',NULL,NULL),(13,'ORD-1775482023098',1,NULL,'Takeaway','Completed',0.00,0.00,0.00,1250.00,'2026-04-06 13:27:03','2026-04-06 13:27:30','Pending','12345678978',NULL,NULL),(14,'ORD-1775482254009',1,NULL,'Takeaway','Completed',0.00,0.00,0.00,80.00,'2026-04-06 13:30:54','2026-04-06 13:31:24','Pending','78787878787',NULL,NULL),(15,'ORD-1775482346725',1,NULL,'Takeaway','Completed',0.00,0.00,0.00,4770.00,'2026-04-06 13:32:26','2026-04-06 13:33:01','Pending','78894556789',NULL,NULL),(16,'ORD-1775483308721',1,NULL,'Takeaway','Completed',0.00,0.00,0.00,590.00,'2026-04-06 13:48:28','2026-04-06 13:49:26','Pending','12451252635',NULL,NULL),(17,'ORD-1775483390950',1,NULL,'Takeaway','Rejected',0.00,0.00,0.00,550.00,'2026-04-06 13:49:50','2026-04-06 13:50:01','Pending','77777788778','Outside Delivery Zone',NULL),(18,'ORD-1775483676337',1,NULL,'Takeaway','Rejected',0.00,0.00,0.00,850.00,'2026-04-06 13:54:36','2026-04-06 13:54:47','Pending','77887788457','Out of Stock',NULL),(19,'ORD-1775483744008',1,NULL,'Takeaway','Completed',0.00,0.00,0.00,450.00,'2026-04-06 13:55:44','2026-04-06 13:55:51','Pending','77887788457',NULL,NULL),(20,'ORD-1775483767698',1,NULL,'Takeaway','Rejected',0.00,0.00,0.00,850.00,'2026-04-06 13:56:07','2026-04-06 13:56:21','Pending','778877884522','SOUPS NOT AVAILABLE',NULL),(21,'ORD-1775483943155',1,NULL,'Takeaway','Rejected',0.00,0.00,0.00,300.00,'2026-04-06 13:59:03','2026-04-06 14:01:29','Pending','77777777777','blah blah blah',NULL),(22,'ORD-1775484198529',1,NULL,'Takeaway','Completed',0.00,0.00,0.00,850.00,'2026-04-06 14:03:18','2026-04-06 14:03:55','Pending','44444444444',NULL,NULL),(23,'ORD-1775485181333',1,NULL,'Takeaway','Rejected',0.00,0.00,0.00,690.00,'2026-04-06 14:19:41','2026-04-06 14:19:49','Pending','11445544115','Outside Delivery Zone',NULL),(24,'ORD-1775485223561',1,NULL,'Takeaway','Completed',0.00,0.00,0.00,850.00,'2026-04-06 14:20:23','2026-04-06 14:21:25','Pending','77777777777',NULL,NULL),(25,'ORD-1775485325212',1,NULL,'Takeaway','Completed',0.00,0.00,0.00,850.00,'2026-04-06 14:22:05','2026-04-06 14:22:21','Pending','03188164861',NULL,NULL),(26,'ORD-1775485369130',1,NULL,'Takeaway','Rejected',0.00,0.00,0.00,850.00,'2026-04-06 14:22:49','2026-04-06 14:22:54','Pending','03188164861','Kitchen Too Busy',NULL),(27,'ORD-1775485539578',1,NULL,'Takeaway','Completed',0.00,0.00,0.00,900.00,'2026-04-06 14:25:39','2026-04-06 14:26:02','Pending','03188164861',NULL,NULL),(28,'ORD-1775485590435',1,NULL,'Takeaway','Completed',0.00,0.00,0.00,300.00,'2026-04-06 14:26:30','2026-04-06 14:26:58','Pending','03188164861',NULL,NULL),(29,'ORD-1775485635900',1,NULL,'Takeaway','Rejected',0.00,0.00,0.00,850.00,'2026-04-06 14:27:15','2026-04-06 14:27:20','Pending','03188164861','Out of Stock',NULL),(30,'ORD-1775572682006',1,NULL,'Takeaway','Completed',0.00,0.00,0.00,690.00,'2026-04-07 14:38:02','2026-04-07 14:38:57','Pending','11445588778',NULL,NULL),(31,'ORD-1775573988089',1,NULL,'Takeaway','Completed',0.00,0.00,0.00,1050.00,'2026-04-07 14:59:48','2026-04-07 15:02:13','Pending','77887788778',NULL,NULL),(32,'ORD-1775575338352',1,NULL,'Delivery','Completed',0.00,0.00,0.00,400.00,'2026-04-07 15:22:18','2026-04-07 15:22:30','Pending','03188164861',NULL,'616, Sabzazar'),(33,'ORD-1775575526133',1,NULL,'Delivery','Completed',0.00,0.00,0.00,850.00,'2026-04-07 15:25:26','2026-04-07 15:27:59','Pending','77887788778',NULL,'rdytfui, Sabzazar'),(34,'ORD-1775576131829',1,NULL,'Delivery','Completed',0.00,0.00,0.00,850.00,'2026-04-07 15:35:31','2026-04-07 15:35:44','Pending','778877887784587',NULL,'7878, Sabzazar'),(35,'ORD-1775577102366',1,NULL,'Delivery','Completed',0.00,0.00,0.00,850.00,'2026-04-07 15:51:42','2026-04-07 15:51:54','Pending','778877887784587',NULL,'7878, Sabzazar'),(36,'ORD-1775584259829',1,NULL,'Delivery','Completed',0.00,0.00,0.00,2100.00,'2026-04-07 17:50:59','2026-04-07 17:52:53','Pending','778877887784587',NULL,'7878, Sabzazar'),(37,'ORD-1775584259859',1,NULL,'Delivery','Completed',0.00,0.00,0.00,2100.00,'2026-04-07 17:50:59','2026-04-07 17:52:42','Pending','778877887784587',NULL,'7878, Sabzazar'),(38,'ORD-1775584259868',1,NULL,'Delivery','Completed',0.00,0.00,0.00,2100.00,'2026-04-07 17:50:59','2026-04-07 17:52:51','Pending','778877887784587',NULL,'7878, Sabzazar'),(39,'ORD-1775584320303',1,NULL,'Delivery','Completed',0.00,0.00,0.00,2100.00,'2026-04-07 17:52:00','2026-04-07 17:52:52','Pending','778877887784587',NULL,'7878, Sabzazar'),(40,'ORD-1775631127761',1,NULL,'Delivery','Rejected',0.00,0.00,0.00,200.00,'2026-04-08 06:52:07','2026-04-08 06:53:02','Pending','77887788778','Out of Stock','NASTP delta, Sabzazar'),(41,'ORD-1775632304187',1,NULL,'Delivery','Completed',0.00,0.00,0.00,590.00,'2026-04-08 07:11:44','2026-04-09 12:06:47','Pending','77887788778',NULL,'NASTP delta, Sabzazar'),(42,'ORD-1775633051582',1,NULL,'Delivery','Completed',0.00,0.00,0.00,950.00,'2026-04-08 07:24:11','2026-04-09 12:06:49','Pending','77887788778',NULL,'NASTP delta, Sabzazar'),(43,'ORD-1775633051601',1,NULL,'Delivery','Completed',0.00,0.00,0.00,480.00,'2026-04-08 07:24:11','2026-04-09 12:06:52','Pending','77887788778',NULL,'NASTP delta, Sabzazar'),(44,'ORD-1775633051614',1,NULL,'Delivery','Completed',0.00,0.00,0.00,950.00,'2026-04-08 07:24:11','2026-04-09 12:06:53','Pending','77887788778',NULL,'NASTP delta, Sabzazar'),(45,'ORD-1775633826899',1,NULL,'Delivery','Completed',0.00,0.00,0.00,4650.00,'2026-04-08 07:37:06','2026-04-09 12:06:57','Pending','77887788778',NULL,'NASTP delta, Sabzazar'),(46,'ORD-1775739382110',1,NULL,'Delivery','Completed',0.00,0.00,0.00,3210.00,'2026-04-09 12:56:22','2026-04-09 12:57:08','Pending','77777777777',NULL,'kiijo, Sabzazar');
/*!40000 ALTER TABLE `orders` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `payments`
--

DROP TABLE IF EXISTS `payments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `payments` (
  `payment_id` int NOT NULL AUTO_INCREMENT,
  `order_id` int NOT NULL,
  `payment_method` enum('Cash','Card','cod','wallet','bank') DEFAULT NULL,
  `amount_paid` decimal(10,2) NOT NULL,
  `payment_status` varchar(50) DEFAULT 'Pending',
  `transaction_reference` varchar(100) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `transaction_id` varchar(100) DEFAULT 'N/A',
  PRIMARY KEY (`payment_id`),
  KEY `order_id` (`order_id`),
  CONSTRAINT `payments_ibfk_1` FOREIGN KEY (`order_id`) REFERENCES `orders` (`order_id`) ON DELETE RESTRICT
) ENGINE=InnoDB AUTO_INCREMENT=41 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `payments`
--

LOCK TABLES `payments` WRITE;
/*!40000 ALTER TABLE `payments` DISABLE KEYS */;
INSERT INTO `payments` VALUES (1,1,'cod',0.00,'Paid',NULL,'2026-04-06 09:12:15','N/A'),(2,2,'cod',0.00,'Paid',NULL,'2026-04-06 09:34:23','N/A'),(3,4,'cod',0.00,'Paid',NULL,'2026-04-06 09:50:52','N/A'),(4,5,'cod',0.00,'Paid',NULL,'2026-04-06 09:58:04','N/A'),(5,6,'cod',0.00,'Paid',NULL,'2026-04-06 10:00:17','N/A'),(6,10,'cod',0.00,'Paid',NULL,'2026-04-06 10:21:01','N/A'),(7,13,'cod',0.00,'Paid',NULL,'2026-04-06 13:27:03','N/A'),(8,14,'cod',0.00,'Paid',NULL,'2026-04-06 13:30:54','N/A'),(9,15,'cod',0.00,'Paid',NULL,'2026-04-06 13:32:26','N/A'),(10,16,'cod',0.00,'Paid',NULL,'2026-04-06 13:48:28','N/A'),(11,17,'cod',0.00,'Pending',NULL,'2026-04-06 13:49:50','N/A'),(12,18,'cod',0.00,'Pending',NULL,'2026-04-06 13:54:36','N/A'),(13,19,'cod',0.00,'Paid',NULL,'2026-04-06 13:55:44','N/A'),(14,20,'cod',0.00,'Pending',NULL,'2026-04-06 13:56:07','N/A'),(15,21,'cod',0.00,'Pending',NULL,'2026-04-06 13:59:03','N/A'),(16,22,'cod',0.00,'Paid',NULL,'2026-04-06 14:03:18','N/A'),(17,23,'cod',0.00,'Pending',NULL,'2026-04-06 14:19:41','N/A'),(18,24,'cod',0.00,'Paid',NULL,'2026-04-06 14:20:23','N/A'),(19,25,'cod',0.00,'Paid',NULL,'2026-04-06 14:22:05','N/A'),(20,26,'cod',0.00,'Pending',NULL,'2026-04-06 14:22:49','N/A'),(21,27,'cod',0.00,'Paid',NULL,'2026-04-06 14:25:39','N/A'),(22,28,'cod',0.00,'Paid',NULL,'2026-04-06 14:26:30','N/A'),(23,29,'cod',0.00,'Pending',NULL,'2026-04-06 14:27:15','N/A'),(24,30,'cod',0.00,'Paid',NULL,'2026-04-07 14:38:02','N/A'),(25,31,'cod',0.00,'Paid',NULL,'2026-04-07 14:59:48','N/A'),(26,32,'cod',0.00,'Paid',NULL,'2026-04-07 15:22:18','N/A'),(27,33,'cod',0.00,'Paid',NULL,'2026-04-07 15:25:26','N/A'),(28,34,'cod',0.00,'Paid',NULL,'2026-04-07 15:35:31','N/A'),(29,35,'cod',0.00,'Paid',NULL,'2026-04-07 15:51:42','N/A'),(30,36,'cod',0.00,'Paid',NULL,'2026-04-07 17:50:59','N/A'),(31,37,'cod',0.00,'Paid',NULL,'2026-04-07 17:50:59','N/A'),(32,38,'cod',0.00,'Paid',NULL,'2026-04-07 17:50:59','N/A'),(33,39,'cod',0.00,'Paid',NULL,'2026-04-07 17:52:00','N/A'),(34,40,'cod',0.00,'Pending',NULL,'2026-04-08 06:52:07','N/A'),(35,41,'cod',0.00,'Paid',NULL,'2026-04-08 07:11:44','N/A'),(36,42,'cod',0.00,'Paid',NULL,'2026-04-08 07:24:11','N/A'),(37,43,'cod',0.00,'Paid',NULL,'2026-04-08 07:24:11','N/A'),(38,44,'cod',0.00,'Paid',NULL,'2026-04-08 07:24:11','N/A'),(39,45,'cod',0.00,'Paid',NULL,'2026-04-08 07:37:06','N/A'),(40,46,'cod',0.00,'Paid',NULL,'2026-04-09 12:56:22','N/A');
/*!40000 ALTER TABLE `payments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `roles`
--

DROP TABLE IF EXISTS `roles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `roles` (
  `role_id` int NOT NULL AUTO_INCREMENT,
  `role_name` varchar(50) NOT NULL,
  PRIMARY KEY (`role_id`),
  UNIQUE KEY `role_name` (`role_name`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `roles`
--

LOCK TABLES `roles` WRITE;
/*!40000 ALTER TABLE `roles` DISABLE KEYS */;
INSERT INTO `roles` VALUES (1,'Admin'),(3,'Cashier'),(2,'Manager');
/*!40000 ALTER TABLE `roles` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `staff`
--

DROP TABLE IF EXISTS `staff`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `staff` (
  `staff_id` int NOT NULL AUTO_INCREMENT,
  `role_id` int NOT NULL,
  `full_name` varchar(100) NOT NULL,
  `email` varchar(255) DEFAULT NULL,
  `password_hash` varchar(255) DEFAULT NULL,
  `pin_code` varchar(10) DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT '1',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`staff_id`),
  UNIQUE KEY `pin_code` (`pin_code`),
  UNIQUE KEY `email` (`email`),
  KEY `role_id` (`role_id`),
  CONSTRAINT `staff_ibfk_1` FOREIGN KEY (`role_id`) REFERENCES `roles` (`role_id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `staff`
--

LOCK TABLES `staff` WRITE;
/*!40000 ALTER TABLE `staff` DISABLE KEYS */;
INSERT INTO `staff` VALUES (1,3,'Default Staff','staff@kf.com','demo123','1111',1,'2026-04-06 09:05:32');
/*!40000 ALTER TABLE `staff` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-04-09 20:45:24
