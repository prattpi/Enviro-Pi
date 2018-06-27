-- MySQL dump 10.16  Distrib 10.1.23-MariaDB, for debian-linux-gnueabihf (armv7l)
--
-- Host: localhost    Database: enviropi
-- ------------------------------------------------------
-- Server version	10.1.23-MariaDB-9+deb9u1

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;


--
-- Table structure for table `device`
--

DROP TABLE IF EXISTS `device`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `device` (
  `device_address` char(17) NOT NULL,
  `device_name` varchar(200) NOT NULL,
  `device_description` mediumtext,
  `device_pic_path` varchar(250) DEFAULT NULL,
  PRIMARY KEY (`device_address`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `reading`
--

DROP TABLE IF EXISTS `reading`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `reading` (
  `reading_id` int(11) NOT NULL AUTO_INCREMENT,
  `device_address` char(17) NOT NULL,
  `reading_dt` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `sensor_id` varchar(10) NOT NULL,
  `temp_f` decimal(5,2) DEFAULT NULL,
  `rh` decimal(5,2) DEFAULT NULL,
  PRIMARY KEY (`reading_id`),
  KEY `device_address` (`device_address`),
  KEY `sensor_id` (`sensor_id`),
  CONSTRAINT `reading_ibfk_1` FOREIGN KEY (`device_address`) REFERENCES `device` (`device_address`) ON DELETE NO ACTION ON UPDATE CASCADE,
  CONSTRAINT `reading_ibfk_2` FOREIGN KEY (`sensor_id`) REFERENCES `sensor` (`sensor_id`) ON DELETE NO ACTION ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=11561 DEFAULT CHARSET=utf8mb4;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `sensor`
--

DROP TABLE IF EXISTS `sensor`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sensor` (
  `sensor_id` varchar(10) NOT NULL,
  `sensor_pic_path` varchar(250) DEFAULT NULL,
  PRIMARY KEY (`sensor_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sensor`
--

LOCK TABLES `sensor` WRITE;
/*!40000 ALTER TABLE `sensor` DISABLE KEYS */;
INSERT INTO `sensor` VALUES ('BMP180','http://cdn2.bigcommerce.com/n-zfvgw8/juoflv6a/products/901/images/1497/nrf_sensor_tag_1__90047.1431182745.500.750.jpg'
),('DHT11','https://cdn-shop.adafruit.com/970x728/386-00.jpg'),('Si7021','https://cdn-shop.adafruit.com/970x728/3251-00.jpg'),('TMP35','https://cdn-learn.ada
fruit.com/assets/assets/000/035/444/original/temperature_165-00.jpg?1473013495');
/*!40000 ALTER TABLE `sensor` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

--
-- Temporary table structure for view `summaryData`
--

DROP TABLE IF EXISTS `summaryData`;
/*!50001 DROP VIEW IF EXISTS `summaryData`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE TABLE `summaryData` (
  `num_readings` tinyint NOT NULL,
  `min_temp` tinyint NOT NULL,
  `max_temp` tinyint NOT NULL,
  `avg_temp` tinyint NOT NULL,
  `min_rh` tinyint NOT NULL,
  `max_rh` tinyint NOT NULL,
  `avg_rh` tinyint NOT NULL,
  `last_temp_f` tinyint NOT NULL,
  `last_rh` tinyint NOT NULL,
  `last_reading_dt` tinyint NOT NULL
) ENGINE=MyISAM */;
SET character_set_client = @saved_cs_client;


--
-- Final view structure for view `summaryData`
--

/*!50001 DROP TABLE IF EXISTS `summaryData`*/;
/*!50001 DROP VIEW IF EXISTS `summaryData`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `summaryData` AS select count(0) AS `num_readings`,min(`reading`.`temp_f`) AS `min_temp`,max(`reading`.`temp_f`) AS `max_temp`,round(avg(`reading`.`temp_f`),2) AS `avg_temp`,min(`reading`.`rh`) AS `min_rh`,max(`reading`.`rh`) AS `max_rh`,round(avg(`reading`.`rh`),2) AS `avg_rh`,(select `reading`.`temp_f` from `reading` order by `reading`.`reading_dt` desc limit 1) AS `last_temp_f`,(select `reading`.`rh` from `reading` order by `reading`.`reading_dt` desc limit 1) AS `last_rh`,(select `reading`.`reading_dt` from `reading` order by `reading`.`reading_dt` desc limit 1) AS `last_reading_dt` from `reading` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2018-06-26 16:21:39
