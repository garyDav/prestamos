-- phpMyAdmin SQL Dump
-- version 4.5.2
-- http://www.phpmyadmin.net
--
-- Servidor: localhost
-- Tiempo de generación: 14-06-2017 a las 13:17:38
-- Versión del servidor: 10.1.13-MariaDB
-- Versión de PHP: 7.0.8

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de datos: `prestamos`
--

DELIMITER $$
--
-- Procedimientos
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `pInsertClients` (IN `v_ci` INT, IN `v_ex` VARCHAR(3), IN `v_name` VARCHAR(50), IN `v_last_name` VARCHAR(50), IN `v_civil_status` VARCHAR(15), IN `v_profession` VARCHAR(60), IN `v_address` VARCHAR(60), IN `v_cellphone1` VARCHAR(15), IN `v_cellphone2` VARCHAR(15), IN `v_src` VARCHAR(255), IN `v_fec_nac` DATE, IN `v_sex` VARCHAR(9))  BEGIN
IF NOT EXISTS(SELECT id FROM clients WHERE ci LIKE v_ci) THEN
INSERT INTO clients VALUES(null,v_ci,v_ex,v_name,v_last_name,v_civil_status,v_profession,v_address,v_cellphone1,v_cellphone2,v_src,v_fec_nac,v_sex,CURRENT_TIMESTAMP);
SELECT @@identity AS id,'not' AS error, 'Cliente registrado.' AS msj;
ELSE
SELECT 'yes' error,'Error: CI ya registrado.' msj;
END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `pInsertGive` (IN `v_id_user` INT, IN `v_id_clients` INT, IN `v_amount` FLOAT, IN `v_fec_pre` DATE, IN `v_month` SMALLINT, IN `v_fine` FLOAT, IN `v_interest` FLOAT, IN `v_type` VARCHAR(5), IN `v_detail` TEXT)  BEGIN
INSERT INTO give VALUES(null,v_id_user,v_id_clients,v_amount,v_fec_pre,v_month,v_fine,v_interest,v_type,v_detail,0,0,0,0,0);
SELECT @@identity AS id,'not' AS error, 'Prestamo registrado.' AS msj;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `pInsertPayment` (IN `v_id_give` INT, IN `v_fec_pago` DATE, IN `v_interests` FLOAT, IN `v_capital_shares` FLOAT, IN `v_lender` FLOAT, IN `v_assistant` FLOAT, IN `v_observation` TEXT)  BEGIN
INSERT INTO give VALUES(null,v_id_give,v_fec_pago,v_interests,v_capital_shares,v_lender,v_assistant,v_observation);
SELECT @@identity AS id,'not' AS error, 'Prestamo registrado.' AS msj;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `pInsertUser` (IN `v_ci` INT, IN `v_ex` VARCHAR(3), IN `v_name` VARCHAR(50), IN `v_last_name` VARCHAR(50), IN `v_email` VARCHAR(100), IN `v_sex` VARCHAR(9), IN `v_pwd` VARCHAR(100), IN `v_type` VARCHAR(5))  BEGIN
IF NOT EXISTS(SELECT id FROM user WHERE email LIKE v_email) THEN
INSERT INTO user VALUES(null,v_ci,v_ex,v_name,v_last_name,v_email,v_sex,'',v_pwd,v_type,CURRENT_TIMESTAMP,CURRENT_TIMESTAMP);
SELECT @@identity AS id,v_type AS tipo, 'not' AS error, 'Registro insertado.' AS msj;
ELSE
SELECT 'yes' error,'Error: Correo ya registrado.' msj;
END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `pReporte` (IN `v_fecha` DATE)  BEGIN
IF EXISTS(SELECT id FROM pasaje WHERE SUBSTRING(fecha,1,10) LIKE v_fecha) THEN
SELECT p.id,p.num_asiento,p.ubicacion,p.precio,p.fecha,v.horario,
v.origen,v.destino,ch.ci AS ci_chofer,ch.nombre AS nombre_chofer,ch.img AS img_chofer,b.num AS num_bus,
cli.ci AS ci_cliente,cli.nombre AS nombre_cliente,cli.apellido AS apellido_cliente 
FROM bus as b,chofer as ch,viaje as v,cliente as cli,pasaje as p 
WHERE v.id_chofer=ch.id AND v.id_bus=b.id AND p.id_viaje=v.id AND p.id_cliente=cli.id AND 
p.fecha > CONCAT(v_fecha,' ','00:00:01') AND p.fecha < CONCAT(v_fecha,' ','23:59:59');
ELSE
SELECT 'No se encontraron ventas en esa fecha' error;
END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `pSession` (IN `v_email` VARCHAR(100), IN `v_pwd` VARCHAR(100))  BEGIN
DECLARE us int(11);
SET us = (SELECT id FROM user WHERE email LIKE v_email);
IF(us) THEN
IF EXISTS(SELECT id FROM user WHERE id = us AND pwd LIKE v_pwd) THEN
SELECT id,type,'not' AS error,'Espere por favor...' AS msj FROM user WHERE id = us;
ELSE
SELECT 'yes' error,'Error: Contraseña incorrecta.' msj;
END IF;
ELSE
SELECT 'yes' error,'Error: Correo no registrado.' msj;
END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `pUpdateUser` (IN `v_id` INT, IN `v_email` VARCHAR(100), IN `v_pwdA` VARCHAR(100), IN `v_pwdN` VARCHAR(100), IN `v_pwdR` VARCHAR(100), IN `v_src` VARCHAR(255))  BEGIN
DECLARE us int(11);
SET us = (SELECT id FROM user WHERE id=v_id AND pwd LIKE v_pwdA);

IF ( (v_pwdA NOT LIKE '') AND (v_src NOT LIKE '') ) THEN

IF (us) THEN
IF (v_pwdN LIKE v_pwdR) THEN
UPDATE user SET email=v_email,pwd=v_pwdN,src=v_src WHERE id=v_id;
SELECT v_id AS id, 'not' AS error,'Perfil actualizado.' AS msj;
ELSE
SELECT v_id AS id, 'yes' AS error,'Las contraseñas no coinciden, repita bien la nueva contraseña.' AS msj;
END IF;
ELSE
SELECT v_id AS id, 'yes' AS error,'La contraseña antigua no es correcta.' AS msj, (v_pwdA NOT LIKE '') AS res;
END IF;

END IF;

IF ( (v_pwdA LIKE '') AND (v_src LIKE '') ) THEN
UPDATE user SET email=v_email WHERE id=v_id;
SELECT v_id AS id, 'not' AS error,'Perfil actualizado.' AS msj;
ELSE

IF ( (v_pwdA LIKE '') AND (v_src NOT LIKE '') ) THEN
UPDATE user SET email=v_email,src=v_src WHERE id=v_id;
SELECT v_id AS id, 'not' AS error,'Perfil actualizado.' AS msj;
ELSE
IF ( (v_src LIKE '') AND (v_pwdA NOT LIKE '') ) THEN
IF (us) THEN
IF (v_pwdN LIKE v_pwdR) THEN
UPDATE user SET email=v_email,pwd=v_pwdN WHERE id=v_id;
SELECT v_id AS id, 'not' AS error,'Perfil actualizado.' AS msj;
ELSE
SELECT v_id AS id, 'yes' AS error,'Las contraseñas no coinciden, repita bien la nueva contraseña.' AS msj;
END IF;
ELSE
SELECT v_id AS id, 'yes' AS error,'La contraseña antigua no es correcta.' AS msj;
END IF;
END IF;
END IF;

END IF;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `clients`
--

CREATE TABLE `clients` (
  `id` int(11) NOT NULL,
  `ci` int(11) DEFAULT NULL,
  `ex` varchar(3) COLLATE utf8_spanish2_ci DEFAULT NULL,
  `name` varchar(50) COLLATE utf8_spanish2_ci DEFAULT NULL,
  `last_name` varchar(50) COLLATE utf8_spanish2_ci DEFAULT NULL,
  `civil_status` varchar(15) COLLATE utf8_spanish2_ci DEFAULT NULL,
  `profession` varchar(60) COLLATE utf8_spanish2_ci DEFAULT NULL,
  `address` varchar(60) COLLATE utf8_spanish2_ci DEFAULT NULL,
  `cellphone1` varchar(15) COLLATE utf8_spanish2_ci DEFAULT NULL,
  `cellphone2` varchar(15) COLLATE utf8_spanish2_ci DEFAULT NULL,
  `src` varchar(255) COLLATE utf8_spanish2_ci NOT NULL,
  `fec_nac` date DEFAULT NULL,
  `sex` varchar(9) COLLATE utf8_spanish2_ci DEFAULT NULL,
  `registered` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_spanish2_ci;

--
-- Volcado de datos para la tabla `clients`
--

INSERT INTO `clients` (`id`, `ci`, `ex`, `name`, `last_name`, `civil_status`, `profession`, `address`, `cellphone1`, `cellphone2`, `src`, `fec_nac`, `sex`, `registered`) VALUES
(1, 15987987, 'Lp', 'Xavier', 'Nieves', 'solter@', 'Comerciante', 'direccion', '75482155', '7579845', '', '1991-04-07', 'M', '2017-03-15'),
(2, 15987654, 'Lp', 'Colton', 'Hammond', 'solter@', 'Comerciante', 'direccion', '75482155', '7579845', '', '1991-04-07', 'M', '2017-03-15'),
(3, 15654213, 'Lp', 'Louis', 'Lindsey', 'solter@', 'Comerciante', 'direccion', '75482155', '7579845', '', '1991-04-07', 'M', '2017-03-15'),
(4, 15781231, 'Lp', 'Alan', 'Delaney', 'solter@', 'Comerciante', 'direccion', '75482155', '7579845', '', '1991-04-07', 'M', '2017-03-15'),
(5, 15789651, 'Lp', 'Jared', 'Stevenson', 'solter@', 'Comerciante', 'direccion', '75482155', '7579845', '', '1991-04-07', 'M', '2017-03-15'),
(6, 15212345, 'Lp', 'Allen', 'Lynch', 'solter@', 'Comerciante', 'direccion', '75482155', '7579845', '', '1991-04-07', 'M', '2017-03-15'),
(7, 15546465, 'Lp', 'Lester', 'Barry', 'solter@', 'Comerciante', 'direccion', '75482155', '7579845', '', '1991-04-07', 'M', '2017-03-15'),
(8, 15465414, 'Lp', 'Branden', 'Baird', 'solter@', 'Comerciante', 'direccion', '75482155', '7579845', '', '1991-04-07', 'M', '2017-03-15'),
(9, 12212314, 'Lp', 'Armando', 'Guy', 'solter@', 'Comerciante', 'direccion', '75482155', '7579845', '', '1991-04-07', 'M', '2017-03-15'),
(10, 18508100, 'Lp', 'Demetrius', 'Bartlett', 'solter@', 'Comerciante', 'direccion', '75482155', '7579845', '', '1991-04-07', 'M', '2017-03-15'),
(11, 18508111, 'Lp', 'Marvin', 'Maxwell', 'solter@', 'Comerciante', 'direccion', '75482155', '7579845', '', '1991-04-07', 'M', '2017-03-15'),
(12, 18508122, 'Lp', 'Honorato', 'Mcneil', 'solter@', 'Comerciante', 'direccion', '75482155', '7579845', '', '1991-04-07', 'M', '2017-03-15'),
(13, 18508133, 'Lp', 'Tobias', 'Parrish', 'solter@', 'Comerciante', 'direccion', '75482155', '7579845', '', '1991-04-07', 'M', '2017-03-15'),
(14, 18508144, 'Lp', 'Coby', 'Craig', 'solter@', 'Comerciante', 'direccion', '75482155', '7579845', '', '1991-04-07', 'M', '2017-03-15'),
(15, 18508155, 'Lp', 'Roth', 'Battle', 'solter@', 'Comerciante', 'direccion', '75482155', '7579845', '', '1991-04-07', 'M', '2017-03-15'),
(16, 18508166, 'Lp', 'Thor', 'Small', 'solter@', 'Comerciante', 'direccion', '75482155', '7579845', '', '1991-04-07', 'M', '2017-03-15'),
(17, 18508177, 'Lp', 'Jerome', 'Hughes', 'solter@', 'Comerciante', 'direccion', '75482155', '7579845', '', '1991-04-07', 'M', '2017-03-15'),
(18, 18508188, 'Lp', 'Jesse', 'Key', 'solter@', 'Comerciante', 'direccion', '75482155', '7579845', '', '1991-04-07', 'M', '2017-03-15'),
(19, 18508199, 'Lp', 'Moses', 'Greene', 'solter@', 'Comerciante', 'direccion', '75482155', '7579845', '', '1991-04-07', 'M', '2017-03-15'),
(20, 18508200, 'Lp', 'Blaze', 'Munoz', 'solter@', 'Comerciante', 'direccion', '75482155', '7579845', '', '1991-04-07', 'M', '2017-03-15'),
(21, 18508211, 'Lp', 'Tyler', 'Short', 'solter@', 'Comerciante', 'direccion', '75482155', '7579845', '', '1991-04-07', 'M', '2017-03-15'),
(22, 18508222, 'Lp', 'Colton', 'Stark', 'solter@', 'Comerciante', 'direccion', '75482155', '7579845', '', '1991-04-07', 'M', '2017-03-15'),
(23, 18508233, 'Lp', 'Gray', 'Pace', 'solter@', 'Comerciante', 'direccion', '75482155', '7579845', '', '1991-04-07', 'M', '2017-03-15'),
(24, 18508244, 'Lp', 'Hayes', 'Gibson', 'solter@', 'Comerciante', 'direccion', '75482155', '7579845', '', '1991-04-07', 'M', '2017-03-15'),
(25, 18508255, 'Lp', 'Hunter', 'Walters', 'solter@', 'Comerciante', 'direccion', '75482155', '7579845', '', '1991-04-07', 'M', '2017-03-15'),
(26, 18508266, 'Lp', 'Benedict', 'Snow', 'solter@', 'Comerciante', 'direccion', '75482155', '7579845', '', '1991-04-07', 'M', '2017-03-15'),
(27, 18508277, 'Lp', 'Abraham', 'Fletcher', 'solter@', 'Comerciante', 'direccion', '75482155', '7579845', '', '1991-04-07', 'M', '2017-03-15'),
(28, 18508288, 'Lp', 'Channing', 'Parsons', 'solter@', 'Comerciante', 'direccion', '75482155', '7579845', '', '1991-04-07', 'M', '2017-03-15'),
(29, 18508299, 'Lp', 'Rigel', 'Lynch', 'solter@', 'Comerciante', 'direccion', '75482155', '7579845', '', '1991-04-07', 'M', '2017-03-15'),
(30, 18508300, 'Lp', 'Jin', 'Foley', 'solter@', 'Comerciante', 'direccion', '75482155', '7579845', '', '1991-04-07', 'M', '2017-03-15'),
(31, 18508311, 'Lp', 'Chase', 'Garrett', 'solter@', 'Comerciante', 'direccion', '75482155', '7579845', '', '1991-04-07', 'M', '2017-03-15'),
(32, 18508322, 'Lp', 'Dean', 'Clayton', 'solter@', 'Comerciante', 'direccion', '75482155', '7579845', '', '1991-04-07', 'M', '2017-03-15'),
(33, 18508333, 'Lp', 'Burke', 'Bullock', 'solter@', 'Comerciante', 'direccion', '75482155', '7579845', '', '1991-04-07', 'M', '2017-03-15'),
(34, 18508344, 'Lp', 'Herman', 'Frye', 'solter@', 'Comerciante', 'direccion', '75482155', '7579845', '', '1991-04-07', 'M', '2017-03-15'),
(35, 18508355, 'Lp', 'Addison', 'Berg', 'solter@', 'Comerciante', 'direccion', '75482155', '7579845', '', '1991-04-07', 'M', '2017-03-15'),
(36, 18508366, 'Lp', 'Gil', 'Mendoza', 'solter@', 'Comerciante', 'direccion', '75482155', '7579845', '', '1991-04-07', 'M', '2017-03-15'),
(37, 18508377, 'Lp', 'Solomon', 'Durham', 'solter@', 'Comerciante', 'direccion', '75482155', '7579845', '', '1991-04-07', 'M', '2017-03-15'),
(38, 18508388, 'Lp', 'Abbot', 'Noble', 'solter@', 'Comerciante', 'direccion', '75482155', '7579845', '', '1991-04-07', 'M', '2017-03-15'),
(39, 18508399, 'Lp', 'Peter', 'Cunningham', 'solter@', 'Medicina', 'direccion', '75482155', '7579845', '', '1991-04-07', 'M', '2017-03-15'),
(40, 18508400, 'Lp', 'Igor', 'Lang', 'solter@', 'Medicina', 'direccion', '75482155', '7579845', '', '1991-04-07', 'M', '2017-03-15'),
(41, 18508411, 'Lp', 'Travis', 'Byrd', 'solter@', 'Medicina', 'direccion', '75482155', '7579845', '', '1991-04-07', 'M', '2017-03-15'),
(42, 18508422, 'Lp', 'Daniel', 'Frederick', 'solter@', 'Medicina', 'direccion', '75482155', '7579845', '', '1991-04-07', 'M', '2017-03-15'),
(43, 18508433, 'Lp', 'Byron', 'Daniels', 'solter@', 'Medicina', 'direccion', '75482155', '7579845', '', '1991-04-07', 'M', '2017-03-15'),
(44, 18508444, 'Lp', 'Malachi', 'Mcmillan', 'solter@', 'Medicina', 'direccion', '75482155', '7579845', '', '1991-04-07', 'M', '2017-03-15'),
(45, 18508455, 'Lp', 'Cameron', 'Shannon', 'solter@', 'Medicina', 'direccion', '75482155', '7579845', '', '1991-04-07', 'M', '2017-03-15'),
(46, 18508466, 'Lp', 'Joel', 'Brady', 'solter@', 'Medicina', 'direccion', '75482155', '7579845', '', '1991-04-07', 'M', '2017-03-15'),
(47, 18508477, 'Lp', 'Akeem', 'Morrison', 'solter@', 'Medicina', 'direccion', '75482155', '7579845', '', '1991-04-07', 'M', '2017-03-15'),
(48, 18508488, 'Lp', 'Bert', 'Castaneda', 'solter@', 'Medicina', 'direccion', '75482155', '7579845', '', '1991-04-07', 'M', '2017-03-15'),
(49, 18508499, 'Lp', 'Burke', 'Carpenter', 'solter@', 'Medicina', 'direccion', '75482155', '7579845', '', '1991-04-07', 'M', '2017-03-15'),
(50, 18508500, 'Lp', 'Abdul', 'Webster', 'solter@', 'Medicina', 'direccion', '75482155', '7579845', '', '1991-04-07', 'M', '2017-03-15'),
(51, 18508511, 'Lp', 'Ira', 'Heath', 'solter@', 'Medicina', 'direccion', '75482155', '7579845', '', '1991-04-07', 'M', '2017-03-15'),
(52, 18508522, 'Lp', 'Forrest', 'Burton', 'solter@', 'Medicina', 'direccion', '75482155', '7579845', '', '1991-04-07', 'M', '2017-03-15'),
(53, 18508533, 'Lp', 'Marvin', 'Miranda', 'solter@', 'Medicina', 'direccion', '75482155', '7579845', '', '1991-04-07', 'M', '2017-03-15'),
(54, 18508544, 'Lp', 'Omar', 'Collier', 'solter@', 'Medicina', 'direccion', '75482155', '7579845', '', '1991-04-07', 'M', '2017-03-15'),
(55, 18508555, 'Lp', 'Castor', 'Kaufman', 'solter@', 'Medicina', 'direccion', '75482155', '7579845', '', '1991-04-07', 'M', '2017-03-15'),
(56, 18508566, 'Lp', 'Levi', 'Herrera', 'solter@', 'Medicina', 'direccion', '75482155', '7579845', '', '1991-04-07', 'M', '2017-03-15'),
(57, 18508577, 'Lp', 'Beau', 'Arnold', 'solter@', 'Medicina', 'direccion', '75482155', '7579845', '', '1991-04-07', 'M', '2017-03-15'),
(58, 18508588, 'Lp', 'Mason', 'Underwood', 'solter@', 'Medicina', 'direccion', '75482155', '7579845', '', '1991-04-07', 'M', '2017-03-15'),
(59, 18508599, 'Lp', 'Lester', 'Mosley', 'solter@', 'Medicina', 'direccion', '75482155', '7579845', '', '1991-04-07', 'M', '2017-03-15'),
(60, 18508600, 'Lp', 'Rogan', 'Tate', 'solter@', 'Medicina', 'direccion', '75482155', '7579845', '', '1991-04-07', 'M', '2017-03-15'),
(61, 18508611, 'Lp', 'Elton', 'Hoover', 'solter@', 'Medicina', 'direccion', '75482155', '7579845', '', '1991-04-07', 'M', '2017-03-15'),
(62, 18508622, 'Lp', 'Edan', 'Lambert', 'solter@', 'Medicina', 'direccion', '75482155', '7579845', '', '1991-04-07', 'M', '2017-03-15'),
(63, 18508633, 'Lp', 'Hammett', 'Wolfe', 'solter@', 'Medicina', 'direccion', '75482155', '7579845', '', '1991-04-07', 'M', '2017-03-15'),
(64, 18508644, 'Lp', 'Price', 'Burch', 'solter@', 'Medicina', 'direccion', '75482155', '7579845', '', '1991-04-07', 'M', '2017-03-15'),
(65, 18508655, 'Lp', 'Alan', 'Kemp', 'solter@', 'Medicina', 'direccion', '75482155', '7579845', '', '1991-04-07', 'M', '2017-03-15'),
(66, 18508666, 'Lp', 'Tad', 'Mccormick', 'solter@', 'Medicina', 'direccion', '75482155', '7579845', '', '1991-04-07', 'M', '2017-03-15'),
(67, 18508677, 'Lp', 'Ferris', 'Dorsey', 'solter@', 'Medicina', 'direccion', '75482155', '7579845', '', '1991-04-07', 'M', '2017-03-15'),
(68, 18508688, 'Lp', 'Bert', 'Francis', 'solter@', 'Profesor', 'direccion', '75482155', '7579845', '', '1991-04-07', 'M', '2017-03-15'),
(69, 18508699, 'Lp', 'Jelani', 'Roach', 'solter@', 'Profesor', 'direccion', '75482155', '7579845', '', '1991-04-07', 'M', '2017-03-15'),
(70, 18508700, 'Lp', 'Herrod', 'Rowe', 'solter@', 'Profesor', 'direccion', '75482155', '7579845', '', '1991-04-07', 'M', '2017-03-15'),
(71, 18508711, 'Lp', 'Marshall', 'Allison', 'solter@', 'Profesor', 'direccion', '75482155', '7579845', '', '1991-04-07', 'M', '2017-03-15'),
(72, 18508722, 'Lp', 'Dale', 'Wynn', 'solter@', 'Profesor', 'direccion', '75482155', '7579845', '', '1991-04-07', 'M', '2017-03-15'),
(73, 18508733, 'Lp', 'Armando', 'Madden', 'solter@', 'Profesor', 'direccion', '75482155', '7579845', '', '1991-04-07', 'M', '2017-03-15'),
(74, 18508744, 'Lp', 'Carter', 'Collins', 'solter@', 'Profesor', 'direccion', '75482155', '7579845', '', '1991-04-07', 'M', '2017-03-15'),
(75, 18508755, 'Lp', 'Malachi', 'Booker', 'solter@', 'Profesor', 'direccion', '75482155', '7579845', '', '1991-04-07', 'M', '2017-03-15'),
(76, 18508766, 'Lp', 'Darius', 'Simon', 'solter@', 'Profesor', 'direccion', '75482155', '7579845', '', '1991-04-07', 'M', '2017-03-15'),
(77, 18508777, 'Lp', 'Ulric', 'Summers', 'solter@', 'Profesor', 'direccion', '75482155', '7579845', '', '1991-04-07', 'M', '2017-03-15'),
(78, 18508788, 'Lp', 'Oren', 'Cole', 'solter@', 'Profesor', 'direccion', '75482155', '7579845', '', '1991-04-07', 'M', '2017-03-15'),
(79, 18508799, 'Lp', 'Callum', 'Lindsay', 'solter@', 'Profesor', 'direccion', '75482155', '7579845', '', '1991-04-07', 'M', '2017-03-15'),
(80, 18508800, 'Lp', 'Chaney', 'House', 'solter@', 'Profesor', 'direccion', '75482155', '7579845', '', '1991-04-07', 'M', '2017-03-15'),
(81, 18508811, 'Lp', 'Brent', 'Finch', 'solter@', 'Profesor', 'direccion', '75482155', '7579845', '', '1991-04-07', 'M', '2017-03-15'),
(82, 18508822, 'Lp', 'Gannon', 'Petersen', 'solter@', 'Profesor', 'direccion', '75482155', '7579845', '', '1991-04-07', 'M', '2017-03-15'),
(83, 18508833, 'Lp', 'Jerry', 'Delacruz', 'solter@', 'Profesor', 'direccion', '75482155', '7579845', '', '1991-04-07', 'M', '2017-03-15'),
(84, 18508844, 'Lp', 'Eaton', 'Kirk', 'solter@', 'Profesor', 'direccion', '75482155', '7579845', '', '1991-04-07', 'M', '2017-03-15'),
(85, 18508855, 'Lp', 'Neville', 'Richardson', 'solter@', 'Profesor', 'direccion', '75482155', '7579845', '', '1991-04-07', 'M', '2017-03-15'),
(86, 18508866, 'Lp', 'Nash', 'Chan', 'solter@', 'Profesor', 'direccion', '75482155', '7579845', '', '1991-04-07', 'M', '2017-03-15'),
(87, 18508877, 'Lp', 'Chandler', 'Whitney', 'solter@', 'Ing. Civil', 'direccion', '75482155', '7579845', '', '1991-04-07', 'M', '2017-03-15'),
(88, 18508888, 'Lp', 'Leo', 'Bullock', 'solter@', 'Ing. Civil', 'direccion', '75482155', '7579845', '', '1991-04-07', 'M', '2017-03-15'),
(89, 18508899, 'Lp', 'Dante', 'Rivers', 'solter@', 'Ing. Civil', 'direccion', '75482155', '7579845', '', '1991-04-07', 'M', '2017-03-15'),
(90, 18508900, 'Lp', 'Jack', 'Ferrell', 'solter@', 'Ing. Civil', 'direccion', '75482155', '7579845', '', '1991-04-07', 'M', '2017-03-15'),
(91, 18508911, 'Lp', 'Abel', 'Mosley', 'solter@', 'Ing. Civil', 'direccion', '75482155', '7579845', '', '1991-04-07', 'M', '2017-03-15'),
(92, 18508922, 'Lp', 'Otto', 'Willis', 'solter@', 'Ing. Civil', 'direccion', '75482155', '7579845', '', '1991-04-07', 'M', '2017-03-15'),
(93, 18508933, 'Lp', 'Armand', 'Morgan', 'solter@', 'Ing. Civil', 'direccion', '75482155', '7579845', '', '1991-04-07', 'M', '2017-03-15'),
(94, 18508944, 'Lp', 'Otto', 'Valdez', 'solter@', 'Ing. Civil', 'direccion', '75482155', '7579845', '', '1991-04-07', 'M', '2017-03-15'),
(95, 18508955, 'Lp', 'Logan', 'Hansen', 'solter@', 'Ing. Civil', 'direccion', '75482155', '7579845', '', '1991-04-07', 'M', '2017-03-15'),
(96, 18508966, 'Lp', 'Honorato', 'Baxter', 'solter@', 'Ing. Civil', 'direccion', '75482155', '7579845', '', '1991-04-07', 'M', '2017-03-15'),
(97, 18508977, 'Lp', 'Reece', 'Goodwin', 'solter@', 'Ing. Civil', 'direccion', '75482155', '7579845', '', '1991-04-07', 'M', '2017-03-15'),
(98, 18508988, 'Lp', 'Stephen', 'Powell', 'solter@', 'Ing. Civil', 'direccion', '75482155', '7579845', '', '1991-04-07', 'M', '2017-03-15'),
(99, 18508999, 'Lp', 'Nigel', 'Dyer', 'solter@', 'Ing. Civil', 'direccion', '75482155', '7579845', '', '1991-04-07', 'M', '2017-03-15'),
(100, 50500010, 'Lp', 'Omar', 'Burks', 'solter@', 'Ing. Civil', 'direccion', '75482155', '7579845', '', '1991-04-07', 'M', '2017-03-15'),
(101, 50501110, 'Lp', 'Palmer', 'William', 'solter@', 'Ing. Civil', 'direccion', '75482155', '7579845', '', '1991-04-07', 'M', '2017-03-15'),
(102, 50502210, 'Lp', 'Blake', 'Rodriquez', 'solter@', 'Ing. Civil', 'direccion', '75482155', '7579845', '', '1991-04-07', 'M', '2017-03-15'),
(103, 50503310, 'Lp', 'Colby', 'Barron', 'solter@', 'Ing. Civil', 'direccion', '75482155', '7579845', '', '1991-04-07', 'M', '2017-03-15'),
(104, 50504410, 'Lp', 'Brian', 'Sawyer', 'solter@', 'Ing. Civil', 'direccion', '75482155', '7579845', '', '1991-04-07', 'M', '2017-03-15'),
(105, 50505510, 'Lp', 'Guy', 'Nielsen', 'solter@', 'profecion', 'direccion', '75482155', '7579845', '', '1991-04-07', 'M', '2017-03-15'),
(106, 50506610, 'Lp', 'Logan', 'Duran', 'solter@', 'profecion', 'direccion', '75482155', '7579845', '', '1991-04-07', 'M', '2017-03-15'),
(107, 50507710, 'Lp', 'Dustin', 'Tyler', 'solter@', 'profecion', 'direccion', '75482155', '7579845', '', '1991-04-07', 'M', '2017-03-15'),
(108, 50508810, 'Lp', 'Robert', 'Peters', 'solter@', 'profecion', 'direccion', '75482155', '7579845', '', '1991-04-07', 'M', '2017-03-15'),
(109, 50509910, 'Lp', 'Fitzgerald', 'Clements', 'solter@', 'profecion', 'direccion', '75482155', '7579845', '', '1991-04-07', 'M', '2017-03-15'),
(110, 51510011, 'Lp', 'Rogan', 'Guerrero', 'solter@', 'profecion', 'direccion', '75482155', '7579845', '', '1991-04-07', 'M', '2017-03-15'),
(111, 51511111, 'Lp', 'Bernard', 'Rios', 'solter@', 'profecion', 'direccion', '75482155', '7579845', '', '1991-04-07', 'M', '2017-03-15'),
(112, 51512211, 'Lp', 'Zephania', 'Flores', 'solter@', 'profecion', 'direccion', '75482155', '7579845', '', '1991-04-07', 'M', '2017-03-15'),
(113, 51513311, 'Lp', 'Fletcher', 'Preston', 'solter@', 'profecion', 'direccion', '75482155', '7579845', '', '1991-04-07', 'M', '2017-03-15'),
(114, 51514411, 'Lp', 'Salvador', 'Herrera', 'solter@', 'profecion', 'direccion', '75482155', '7579845', '', '1991-04-07', 'M', '2017-03-15'),
(115, 51515511, 'Lp', 'Dillon', 'Anthony', 'solter@', 'profecion', 'direccion', '75482155', '7579845', '', '1991-04-07', 'M', '2017-03-15'),
(116, 51516611, 'Lp', 'Thaddeus', 'Tillman', 'solter@', 'profecion', 'direccion', '75482155', '7579845', '', '1991-04-07', 'M', '2017-03-15'),
(117, 51517711, 'Lp', 'Charles', 'Floyd', 'solter@', 'profecion', 'direccion', '75482155', '7579845', '', '1991-04-07', 'M', '2017-03-15'),
(118, 51518811, 'Lp', 'Daniel', 'Bradley', 'solter@', 'profecion', 'direccion', '75482155', '7579845', '', '1991-04-07', 'M', '2017-03-15'),
(119, 51519911, 'Lp', 'Cole', 'Phillips', 'solter@', 'profecion', 'direccion', '75482155', '7579845', '', '1991-04-07', 'M', '2017-03-15'),
(120, 52520012, 'Lp', 'Steven', 'Fowler', 'solter@', 'profecion', 'direccion', '75482155', '7579845', '', '1991-04-07', 'M', '2017-03-15'),
(121, 52521112, 'Lp', 'Wyatt', 'Collins', 'solter@', 'profecion', 'direccion', '75482155', '7579845', '', '1991-04-07', 'M', '2017-03-15'),
(122, 52522212, 'Lp', 'Barclay', 'Cardenas', 'solter@', 'profecion', 'direccion', '75482155', '7579845', '', '1991-04-07', 'M', '2017-03-15'),
(123, 52523312, 'Lp', 'Nicholas', 'Wilkins', 'solter@', 'profecion', 'direccion', '75482155', '7579845', '', '1991-04-07', 'M', '2017-03-15'),
(124, 52524412, 'Lp', 'Troy', 'Lopez', 'solter@', 'profecion', 'direccion', '75482155', '7579845', '', '1991-04-07', 'M', '2017-03-15'),
(125, 52525512, 'Lp', 'Tucker', 'Madden', 'solter@', 'profecion', 'direccion', '75482155', '7579845', '', '1991-04-07', 'M', '2017-03-15'),
(126, 52526612, 'Lp', 'Hayes', 'Lester', 'solter@', 'profecion', 'direccion', '75482155', '7579845', '', '1991-04-07', 'M', '2017-03-15'),
(127, 52527712, 'Lp', 'Armand', 'Phelps', 'solter@', 'profecion', 'direccion', '75482155', '7579845', '', '1991-04-07', 'M', '2017-03-15'),
(128, 52528812, 'Lp', 'Cruz', 'Warner', 'solter@', 'profecion', 'direccion', '75482155', '7579845', '', '1991-04-07', 'M', '2017-03-15'),
(129, 52529912, 'Lp', 'Brady', 'Gray', 'solter@', 'profecion', 'direccion', '75482155', '7579845', '', '1991-04-07', 'M', '2017-03-15'),
(130, 53530013, 'Lp', 'Avram', 'Hammond', 'solter@', 'profecion', 'direccion', '75482155', '7579845', '', '1991-04-07', 'M', '2017-03-15'),
(131, 53531113, 'Lp', 'Amery', 'Mercado', 'solter@', 'profecion', 'direccion', '75482155', '7579845', '', '1991-04-07', 'M', '2017-03-15'),
(132, 53532213, 'Lp', 'Robert', 'Parsons', 'solter@', 'profecion', 'direccion', '75482155', '7579845', '', '1991-04-07', 'M', '2017-03-15'),
(133, 53533313, 'Lp', 'Rafael', 'Whitaker', 'solter@', 'profecion', 'direccion', '75482155', '7579845', '', '1991-04-07', 'M', '2017-03-15'),
(134, 53534413, 'Lp', 'Salvador', 'Mccarty', 'solter@', 'profecion', 'direccion', '75482155', '7579845', '', '1991-04-07', 'M', '2017-03-15'),
(135, 53535513, 'Lp', 'Colby', 'Mcfadden', 'solter@', 'profecion', 'direccion', '75482155', '7579845', '', '1991-04-07', 'M', '2017-03-15'),
(136, 53536613, 'Lp', 'Ivor', 'Smith', 'solter@', 'profecion', 'direccion', '75482155', '7579845', '', '1991-04-07', 'M', '2017-03-15'),
(137, 53537713, 'Lp', 'Cedric', 'Cote', 'solter@', 'profecion', 'direccion', '75482155', '7579845', '', '1991-04-07', 'M', '2017-03-15'),
(138, 53538813, 'Lp', 'Keane', 'Simmons', 'solter@', 'profecion', 'direccion', '75482155', '7579845', '', '1991-04-07', 'M', '2017-03-15'),
(139, 53539913, 'Lp', 'Ryan', 'Glover', 'solter@', 'profecion', 'direccion', '75482155', '7579845', '', '1991-04-07', 'M', '2017-03-15'),
(140, 54540014, 'Lp', 'Brennan', 'Langley', 'solter@', 'profecion', 'direccion', '75482155', '7579845', '', '1991-04-07', 'M', '2017-03-15'),
(141, 54541114, 'Lp', 'Craig', 'Shaffer', 'solter@', 'profecion', 'direccion', '75482155', '7579845', '', '1991-04-07', 'M', '2017-03-15'),
(142, 54542214, 'Lp', 'Joshua', 'Nixon', 'solter@', 'profecion', 'direccion', '75482155', '7579845', '', '1991-04-07', 'M', '2017-03-15'),
(143, 54543314, 'Lp', 'Valentine', 'Conner', 'solter@', 'profecion', 'direccion', '75482155', '7579845', '', '1991-04-07', 'M', '2017-03-15'),
(144, 54544414, 'Lp', 'Jerry', 'Vaughan', 'solter@', 'profecion', 'direccion', '75482155', '7579845', '', '1991-04-07', 'M', '2017-03-15'),
(145, 54545514, 'Lp', 'Sebastian', 'Slater', 'solter@', 'profecion', 'direccion', '75482155', '7579845', '', '1991-04-07', 'M', '2017-03-15'),
(146, 54546614, 'Lp', 'Richard', 'Burke', 'solter@', 'profecion', 'direccion', '75482155', '7579845', '', '1991-04-07', 'M', '2017-03-15'),
(147, 54547714, 'Lp', 'Simon', 'Cotton', 'solter@', 'profecion', 'direccion', '75482155', '7579845', '', '1991-04-07', 'M', '2017-03-15'),
(148, 54548814, 'Lp', 'Ross', 'Merritt', 'solter@', 'profecion', 'direccion', '75482155', '7579845', '', '1991-04-07', 'M', '2017-03-15'),
(149, 54549914, 'Lp', 'Uriel', 'May', 'solter@', 'profecion', 'direccion', '75482155', '7579845', '', '1991-04-07', 'M', '2017-03-15'),
(150, 55550015, 'Lp', 'Cairo', 'Mayer', 'solter@', 'profecion', 'direccion', '75482155', '7579845', '', '1991-04-07', 'M', '2017-03-15'),
(151, 55551115, 'Lp', 'Berk', 'Lynn', 'solter@', 'profecion', 'direccion', '75482155', '7579845', '', '1991-04-07', 'M', '2017-03-15'),
(152, 55552215, 'Lp', 'Francis', 'Giles', 'solter@', 'profecion', 'direccion', '75482155', '7579845', '', '1991-04-07', 'M', '2017-03-15'),
(153, 55553315, 'Lp', 'Lyle', 'Odonnell', 'solter@', 'profecion', 'direccion', '75482155', '7579845', '', '1991-04-07', 'M', '2017-03-15'),
(154, 55554415, 'Lp', 'Jin', 'Saunders', 'solter@', 'profecion', 'direccion', '75482155', '7579845', '', '1991-04-07', 'M', '2017-03-15'),
(155, 55555515, 'Lp', 'Brendan', 'Flores', 'solter@', 'profecion', 'direccion', '75482155', '7579845', '', '1991-04-07', 'M', '2017-03-15'),
(156, 55556615, 'Lp', 'Ferdinand', 'Peters', 'solter@', 'profecion', 'direccion', '75482155', '7579845', '', '1991-04-07', 'M', '2017-03-15'),
(157, 55557715, 'Lp', 'Arsenio', 'Mckinney', 'solter@', 'profecion', 'direccion', '75482155', '7579845', '', '1991-04-07', 'M', '2017-03-15'),
(158, 55558815, 'Lp', 'Vaughan', 'Cote', 'solter@', 'profecion', 'direccion', '75482155', '7579845', '', '1991-04-07', 'M', '2017-03-15'),
(159, 55559915, 'Lp', 'Colby', 'Banks', 'solter@', 'profecion', 'direccion', '75482155', '7579845', '', '1991-04-07', 'M', '2017-03-15'),
(160, 56560016, 'Lp', 'Dorian', 'Pierce', 'solter@', 'profecion', 'direccion', '75482155', '7579845', '', '1991-04-07', 'M', '2017-03-15'),
(161, 56561116, 'Lp', 'Cade', 'Dean', 'solter@', 'profecion', 'direccion', '75482155', '7579845', '', '1991-04-07', 'M', '2017-03-15'),
(162, 56562216, 'Lp', 'Travis', 'Delacruz', 'solter@', 'profecion', 'direccion', '75482155', '7579845', '', '1991-04-07', 'M', '2017-03-15'),
(163, 56563316, 'Lp', 'Clarke', 'Rosa', 'solter@', 'profecion', 'direccion', '75482155', '7579845', '', '1991-04-07', 'M', '2017-03-15'),
(164, 56564416, 'Lp', 'Omar', 'Buckner', 'solter@', 'profecion', 'direccion', '75482155', '7579845', '', '1991-04-07', 'M', '2017-03-15'),
(165, 56565516, 'Lp', 'Quinlan', 'Barber', 'solter@', 'profecion', 'direccion', '75482155', '7579845', '', '1991-04-07', 'M', '2017-03-15'),
(166, 56566616, 'Lp', 'Nero', 'Mays', 'solter@', 'profecion', 'direccion', '75482155', '7579845', '', '1991-04-07', 'M', '2017-03-15'),
(167, 56567716, 'Lp', 'Walker', 'Harvey', 'solter@', 'profecion', 'direccion', '75482155', '7579845', '', '1991-04-07', 'M', '2017-03-15'),
(168, 56568816, 'Lp', 'Zane', 'Best', 'solter@', 'profecion', 'direccion', '75482155', '7579845', '', '1991-04-07', 'M', '2017-03-15'),
(169, 56569916, 'Lp', 'Vincent', 'Rosario', 'solter@', 'profecion', 'direccion', '75482155', '7579845', '', '1991-04-07', 'M', '2017-03-15'),
(170, 57570017, 'Lp', 'Malachi', 'Hull', 'solter@', 'profecion', 'direccion', '75482155', '7579845', '', '1991-04-07', 'M', '2017-03-15'),
(171, 57571117, 'Lp', 'Ira', 'Roy', 'solter@', 'profecion', 'direccion', '75482155', '7579845', '', '1991-04-07', 'M', '2017-03-15'),
(172, 57572217, 'Lp', 'Drew', 'Casey', 'solter@', 'profecion', 'direccion', '75482155', '7579845', '', '1991-04-07', 'M', '2017-03-15'),
(173, 57573317, 'Lp', 'Lester', 'Hodge', 'solter@', 'profecion', 'direccion', '75482155', '7579845', '', '1991-04-07', 'M', '2017-03-15'),
(174, 57574417, 'Lp', 'Ciaran', 'Calderon', 'solter@', 'profecion', 'direccion', '75482155', '7579845', '', '1991-04-07', 'M', '2017-03-15'),
(175, 57575517, 'Lp', 'Hashim', 'Ballard', 'solter@', 'profecion', 'direccion', '75482155', '7579845', '', '1991-04-07', 'M', '2017-03-15'),
(176, 57576617, 'Lp', 'Ishmael', 'Rivers', 'solter@', 'profecion', 'direccion', '75482155', '7579845', '', '1991-04-07', 'M', '2017-03-15'),
(177, 57577717, 'Lp', 'Declan', 'Lyons', 'solter@', 'profecion', 'direccion', '75482155', '7579845', '', '1991-04-07', 'M', '2017-03-15'),
(178, 57578817, 'Lp', 'Tyrone', 'Norman', 'solter@', 'profecion', 'direccion', '75482155', '7579845', '', '1991-04-07', 'M', '2017-03-15'),
(179, 57579917, 'Lp', 'Cedric', 'Knapp', 'solter@', 'profecion', 'direccion', '75482155', '7579845', '', '1991-04-07', 'M', '2017-03-15'),
(180, 58580018, 'Lp', 'Byron', 'Russo', 'solter@', 'profecion', 'direccion', '75482155', '7579845', '', '1991-04-07', 'M', '2017-03-15'),
(181, 58581118, 'Lp', 'Reece', 'Blackwell', 'solter@', 'profecion', 'direccion', '75482155', '7579845', '', '1991-04-07', 'M', '2017-03-15'),
(182, 58582218, 'Lp', 'Christopher', 'Harrell', 'solter@', 'profecion', 'direccion', '75482155', '7579845', '', '1991-04-07', 'M', '2017-03-15'),
(183, 58583318, 'Lp', 'Abbot', 'Brewer', 'solter@', 'profecion', 'direccion', '75482155', '7579845', '', '1991-04-07', 'M', '2017-03-15'),
(184, 58584418, 'Lp', 'Jason', 'Mcknight', 'solter@', 'profecion', 'direccion', '75482155', '7579845', '', '1991-04-07', 'M', '2017-03-15'),
(185, 58585518, 'Lp', 'Marshall', 'Cole', 'solter@', 'profecion', 'direccion', '75482155', '7579845', '', '1991-04-07', 'M', '2017-03-15'),
(186, 58586618, 'Lp', 'Timothy', 'Velazquez', 'solter@', 'profecion', 'direccion', '75482155', '7579845', '', '1991-04-07', 'M', '2017-03-15'),
(187, 58587718, 'Lp', 'Sean', 'Morgan', 'solter@', 'profecion', 'direccion', '75482155', '7579845', '', '1991-04-07', 'M', '2017-03-15'),
(188, 58588818, 'Lp', 'Guy', 'Farley', 'solter@', 'profecion', 'direccion', '75482155', '7579845', '', '1991-04-07', 'M', '2017-03-15'),
(189, 58589918, 'Lp', 'Ryder', 'Rodriquez', 'solter@', 'profecion', 'direccion', '75482155', '7579845', '', '1991-04-07', 'M', '2017-03-15'),
(190, 59590019, 'Lp', 'Vladimir', 'Schmidt', 'solter@', 'profecion', 'direccion', '75482155', '7579845', '', '1991-04-07', 'M', '2017-03-15'),
(191, 59591119, 'Lp', 'Ian', 'Noble', 'solter@', 'profecion', 'direccion', '75482155', '7579845', '', '1991-04-07', 'M', '2017-03-15'),
(192, 59592219, 'Lp', 'David', 'Nolan', 'solter@', 'profecion', 'direccion', '75482155', '7579845', '', '1991-04-07', 'M', '2017-03-15'),
(193, 59593319, 'Lp', 'Akeem', 'Randall', 'solter@', 'profecion', 'direccion', '75482155', '7579845', '', '1991-04-07', 'M', '2017-03-15'),
(194, 59594419, 'Lp', 'Gary', 'Roy', 'solter@', 'profecion', 'direccion', '75482155', '7579845', '', '1991-04-07', 'M', '2017-03-15'),
(195, 59595519, 'Lp', 'Marshall', 'Hayes', 'solter@', 'profecion', 'direccion', '75482155', '7579845', 'dcc9623513bb6eb8078358d27565bb67-242.jpeg', '1991-05-07', 'Masculino', '2017-03-15'),
(196, 59596619, 'Lp', 'Uriah', 'Franks', 'solter@', 'profecion', 'direccion', '75482155', '7579845', 'los-profesionales-consideran-a-steve-jobs-la-persona-mas-influyente-en-los-videojuegos-img850262.jpg-930.jpeg', '1991-05-07', 'Masculino', '2017-03-15'),
(197, 59597719, 'Lp', 'Perry', 'Nguyen', 'solter@', 'profecion', 'direccion', '75482155', '7579845', 'volumen-ideal-para-rostro-cuadrado.jpg-701.jpeg', '1991-05-07', 'Femenino', '2017-03-15'),
(198, 59598819, 'Lp', 'Evan', 'Mccormick', 'solter@', 'profecion', 'direccion', '75482155', '7579845', '2165947w620.jpg-630.jpeg', '1991-06-07', 'Masculino', '2017-03-15'),
(199, 59599919, 'Lp', 'Emery', 'Howard', 'solter@', 'profecion', 'direccion', '75482155', '7579845', 'mulher_pensativa.jpg-562.jpeg', '1991-08-07', 'Femenino', '2017-03-15');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `give`
--

CREATE TABLE `give` (
  `id` int(11) NOT NULL,
  `id_user` int(11) DEFAULT NULL,
  `id_clients` int(11) DEFAULT NULL,
  `amount` float DEFAULT NULL,
  `fec_pre` date DEFAULT NULL,
  `month` smallint(6) DEFAULT NULL,
  `fine` float DEFAULT NULL,
  `interest` float DEFAULT NULL,
  `type` varchar(5) COLLATE utf8_spanish2_ci DEFAULT NULL,
  `detail` text COLLATE utf8_spanish2_ci,
  `gain` float DEFAULT NULL,
  `total_capital` float DEFAULT NULL,
  `total_interest` float DEFAULT NULL,
  `total_lender` float DEFAULT NULL,
  `total_assistant` float DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_spanish2_ci;

--
-- Volcado de datos para la tabla `give`
--

INSERT INTO `give` (`id`, `id_user`, `id_clients`, `amount`, `fec_pre`, `month`, `fine`, `interest`, `type`, `detail`, `gain`, `total_capital`, `total_interest`, `total_lender`, `total_assistant`) VALUES
(1, 2, 196, 7000, '2017-06-16', 12, 50, 4, 'men', 'Cliente Confiable', 0, 0, 0, 0, 0);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `payment`
--

CREATE TABLE `payment` (
  `id` int(11) NOT NULL,
  `id_give` int(11) DEFAULT NULL,
  `fec_pago` date DEFAULT NULL,
  `interests` float DEFAULT NULL,
  `capital_shares` float DEFAULT NULL,
  `lender` float DEFAULT NULL,
  `assistant` float DEFAULT NULL,
  `observation` text COLLATE utf8_spanish2_ci
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_spanish2_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `user`
--

CREATE TABLE `user` (
  `id` int(11) NOT NULL,
  `ci` int(11) DEFAULT NULL,
  `ex` varchar(3) COLLATE utf8_spanish2_ci DEFAULT NULL,
  `name` varchar(50) COLLATE utf8_spanish2_ci DEFAULT NULL,
  `last_name` varchar(50) COLLATE utf8_spanish2_ci DEFAULT NULL,
  `email` varchar(100) COLLATE utf8_spanish2_ci DEFAULT NULL,
  `sex` varchar(9) COLLATE utf8_spanish2_ci NOT NULL,
  `src` varchar(255) COLLATE utf8_spanish2_ci NOT NULL,
  `pwd` varchar(100) COLLATE utf8_spanish2_ci DEFAULT NULL,
  `type` varchar(5) COLLATE utf8_spanish2_ci DEFAULT NULL,
  `last_connection` datetime DEFAULT NULL,
  `registered` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_spanish2_ci;

--
-- Volcado de datos para la tabla `user`
--

INSERT INTO `user` (`id`, `ci`, `ex`, `name`, `last_name`, `email`, `sex`, `src`, `pwd`, `type`, `last_connection`, `registered`) VALUES
(1, 10917763, 'Lp', 'Gary David', 'Guzmán Muñoz', 'gary@gmail.com', 'Masculino', '1497434542.jpeg', '585f7f3723df82f91fffd25a5c6900597cd4d1c1', 'supad', '2017-06-14 02:24:23', '2017-06-14'),
(2, 20115423, 'Ch', 'Juan Jose', 'Perez Mendoza', 'juan@gmail.com', 'Masculino', '1497436044.jpeg', '585f7f3723df82f91fffd25a5c6900597cd4d1c1', 'user', '2017-06-14 02:27:41', '2017-06-14'),
(3, 630251124, 'Or', 'Ilsen', 'Romero Caraballo', 'terry@gmail.com', 'Femenino', '', '585f7f3723df82f91fffd25a5c6900597cd4d1c1', 'admin', '2017-06-14 02:29:39', '2017-06-14');

--
-- Índices para tablas volcadas
--

--
-- Indices de la tabla `clients`
--
ALTER TABLE `clients`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `give`
--
ALTER TABLE `give`
  ADD PRIMARY KEY (`id`),
  ADD KEY `id_user` (`id_user`),
  ADD KEY `id_clients` (`id_clients`);

--
-- Indices de la tabla `payment`
--
ALTER TABLE `payment`
  ADD PRIMARY KEY (`id`),
  ADD KEY `id_give` (`id_give`);

--
-- Indices de la tabla `user`
--
ALTER TABLE `user`
  ADD PRIMARY KEY (`id`);

--
-- AUTO_INCREMENT de las tablas volcadas
--

--
-- AUTO_INCREMENT de la tabla `clients`
--
ALTER TABLE `clients`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=200;
--
-- AUTO_INCREMENT de la tabla `give`
--
ALTER TABLE `give`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;
--
-- AUTO_INCREMENT de la tabla `payment`
--
ALTER TABLE `payment`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT de la tabla `user`
--
ALTER TABLE `user`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;
--
-- Restricciones para tablas volcadas
--

--
-- Filtros para la tabla `give`
--
ALTER TABLE `give`
  ADD CONSTRAINT `give_ibfk_1` FOREIGN KEY (`id_user`) REFERENCES `user` (`id`),
  ADD CONSTRAINT `give_ibfk_2` FOREIGN KEY (`id_clients`) REFERENCES `clients` (`id`);

--
-- Filtros para la tabla `payment`
--
ALTER TABLE `payment`
  ADD CONSTRAINT `payment_ibfk_1` FOREIGN KEY (`id_give`) REFERENCES `give` (`id`);

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
