-- phpMyAdmin SQL Dump
-- version 4.7.0
-- https://www.phpmyadmin.net/
--
-- Servidor: localhost
-- Tiempo de generación: 30-06-2018 a las 19:57:47
-- Versión del servidor: 10.1.22-MariaDB
-- Versión de PHP: 7.1.4

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET AUTOCOMMIT = 0;
START TRANSACTION;
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

CREATE DEFINER=`root`@`localhost` PROCEDURE `pInsertGive` (IN `v_id_user` INT, IN `v_id_clients` INT, IN `v_id_userin` INT, IN `v_amount` FLOAT, IN `v_fec_pre` DATE, IN `v_month` SMALLINT, IN `v_fine` FLOAT, IN `v_interest` FLOAT, IN `v_type` VARCHAR(5), IN `v_detail` TEXT, IN `v_gain` FLOAT)  BEGIN
INSERT INTO give VALUES(null,v_id_user,v_id_clients,v_id_userin,v_amount,v_fec_pre,v_month,v_fine,v_interest,v_type,v_detail,v_gain,0,0,0,0,1);
SELECT @@identity AS id,'not' AS error, 'Prestamo registrado.' AS msj;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `pInsertUser` (IN `v_ci` INT, IN `v_ex` VARCHAR(3), IN `v_name` VARCHAR(50), IN `v_last_name` VARCHAR(50), IN `v_email` VARCHAR(100), IN `v_sex` VARCHAR(9), IN `v_pwd` VARCHAR(100), IN `v_type` VARCHAR(5))  BEGIN
IF NOT EXISTS(SELECT id FROM user WHERE email LIKE v_email) THEN
INSERT INTO user VALUES(null,v_ci,v_ex,v_name,v_last_name,v_email,v_sex,'avatar.png',v_pwd,v_type,CURRENT_TIMESTAMP,CURRENT_TIMESTAMP);
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

CREATE DEFINER=`root`@`localhost` PROCEDURE `tInsertPayment` (IN `v_id_give` INT, IN `v_fec_pago_actual` DATE, IN `v_fec_pago` DATE, IN `v_observation` TEXT)  BEGIN
DECLARE g_amount float;
DECLARE g_month smallint(6);
DECLARE g_fine float;
DECLARE g_interest float;
DECLARE g_type varchar(5);
DECLARE g_gain float;

DECLARE p_interests float;
DECLARE p_capital_shares float;
DECLARE p_lender float;
DECLARE p_assistant float;
DECLARE p_month_payment smallint(6);
DECLARE p_dif_pagos int;
DECLARE i int;
DECLARE sum_fine float;
DECLARE pamount int;

DECLARE error int DEFAULT 0;
DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
BEGIN
SET error=1;
SELECT "yes" error,"Transaccion no completada: tInsertPayment" msj;
END;


START TRANSACTION;
SET g_amount = (SELECT amount FROM give WHERE id=v_id_give);
SET g_month = (SELECT month FROM give WHERE id=v_id_give);
SET g_fine = (SELECT fine FROM give WHERE id=v_id_give);
SET g_interest = (SELECT interest FROM give WHERE id=v_id_give);
SET g_type = (SELECT type FROM give WHERE id=v_id_give);
SET g_gain = (SELECT gain FROM give WHERE id=v_id_give);
SET p_month_payment = (SELECT COUNT(id) FROM payment WHERE id_give=v_id_give);

IF g_type = 'men' THEN
SET p_interests = g_amount*(g_interest/100);
IF g_month = (p_month_payment+1) THEN
SET p_capital_shares = g_amount;
UPDATE give SET visible=2 WHERE id=v_id_give;
ELSE
SET p_capital_shares = 0;
END IF;

SET p_dif_pagos = (SELECT DATEDIFF(v_fec_pago,v_fec_pago_actual));
SET i = 0;
SET sum_fine = 0;
while i < p_dif_pagos do
SET sum_fine = sum_fine+g_fine;
SET i=i+1;
end while;
SET p_interests = p_interests+sum_fine;
SET p_lender = p_interests*((100-g_gain)/100);
SET p_assistant = p_interests*(g_gain/100);
ELSE
SET pamount = g_amount/g_month;
SET p_interests = (g_amount-(pamount*p_month_payment))*(g_interest/100);

IF g_month = (p_month_payment+1) THEN
SET pamount = pamount+(g_amount-(pamount*g_month));
UPDATE give SET visible=2 WHERE id=v_id_give;
END IF;
SET p_capital_shares = pamount;
SET p_dif_pagos = (SELECT DATEDIFF(v_fec_pago,v_fec_pago_actual));
SET i = 0;
SET sum_fine = 0;
while i < p_dif_pagos do
SET sum_fine = sum_fine+g_fine;
SET i=i+1;
end while;
SET p_interests = p_interests+sum_fine;
SET p_lender = p_interests*((100-g_gain)/100);
SET p_assistant = p_interests*(g_gain/100);
END IF;

UPDATE give SET total_capital=total_capital+p_capital_shares,
total_interest=total_interest+p_interests,
total_lender=total_lender+p_lender,
total_assistant=total_assistant+p_assistant WHERE id=v_id_give;
INSERT INTO payment VALUES(null,v_id_give,v_fec_pago,p_interests,p_capital_shares,p_lender,p_assistant,v_observation);
SELECT (p_month_payment+1) AS pago,"not" error,"insertado correctamente" msj;


IF (error = 1) THEN
ROLLBACK;
ELSE
COMMIT;
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
  `src` varchar(255) COLLATE utf8_spanish2_ci DEFAULT NULL,
  `fec_nac` date DEFAULT NULL,
  `sex` varchar(9) COLLATE utf8_spanish2_ci DEFAULT NULL,
  `registered` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_spanish2_ci;

--
-- Volcado de datos para la tabla `clients`
--

INSERT INTO `clients` (`id`, `ci`, `ex`, `name`, `last_name`, `civil_status`, `profession`, `address`, `cellphone1`, `cellphone2`, `src`, `fec_nac`, `sex`, `registered`) VALUES
(1, 10344150, 'Ch', 'Rufina', 'Callaguara', 'casad@', 'Comerciante', 'Cll: America S/N', '0000', '0000', 'avatar.png', '1966-06-16', 'Femenino', '2017-07-04'),
(2, 1145633, 'Ch', 'José Luis', 'Zegarra Sossa', 'concubin@', 'Empleado público', 'Calle independencia S/N', '0000', '0000', 'avatar.png', '1970-09-21', 'Masculino', '2017-07-05'),
(3, 3635050, 'Ch', 'Antolin Esteban', 'Ortiz Bautista', 'concubin@', 'Empleado público', 'Calle Barrio Villa San Isidro S/N', '0000', '0000', 'avatar.png', '1970-09-02', 'Masculino', '2017-07-05'),
(4, 1053504, 'Ch', 'Laura', 'Gutierrez de Zarate', 'casad@', 'Comerciante', 'Cll: Avaroa Nº', '0000', '0000', 'avatar.png', '1998-08-17', 'Femenino', '2017-07-08'),
(5, 4086021, 'Ch', 'Danitza', 'Ramires', 'concubin@', 'Comerciante', 'Cll: Avenida 6 de agosto Nº231', '0000', '0000', 'avatar.png', '1994-09-15', 'Femenino', '2017-07-13'),
(6, 1883028, 'Tj', 'Teodora', 'Condori Churata', 'concubin@', 'Labores de casa', 'Barrio Cascadita S/N', '0000', '0000', 'avatar.png', '1970-05-03', 'Femenino', '2017-07-13'),
(7, 4632805, 'Ch', 'Sebastiana', 'Alaca Churqui de Huanca', 'casad@', 'Labores de casa', 'Zona bajo Aranjuez S/N', '0000', '0000', 'avatar.png', '1970-07-09', 'Femenino', '2017-07-13'),
(8, 5633757, 'Ch', 'Elizabeth', 'Serrudo Zeballos', 'solter@', 'Labores de casa', 'Barrio Aranjuez S/N', '0000', '0000', 'avatar.png', '1986-06-12', 'Femenino', '2017-07-13'),
(9, 7512668, 'Ch', 'Roberta', 'Medina Yarui', 'solter@', 'Labores de casa', 'Res. en Lechuguillas', '0000', '0000', 'avatar.png', '1970-04-17', 'Femenino', '2017-07-13'),
(10, 5485549, 'Ch', 'Eva', 'Avendaño Sanchez', 'solter@', 'Labores de casa', 'Barrio America S/N', '0000', '0000', 'avatar.png', '1973-01-23', 'Femenino', '2017-07-13'),
(11, 4083972, 'Ch', 'Dania', 'Reynoso Villegas', 'solter@', 'Estudiante', 'J. prudencio bustillos N°656', '0000', '0000', 'avatar.png', '1976-04-11', 'Femenino', '2017-07-13'),
(12, 0, 'Ch', 'Rosa', 'Churqui Zarate', 'solter@', 'Comerciante', 'no se', '0000', '0000', 'avatar.png', '1995-01-29', 'Femenino', '2017-08-16'),
(13, 4118035, 'Ch', 'Angelica Adriana', 'Gonzales Paniagua', 'concubin@', 'Comerciante', 'pendiente', '0000', '0000', 'avatar.png', '1956-06-05', 'Femenino', '2017-08-16'),
(14, 100, 'Ch', 'Norma', 'Rojas', 'solter@', 'pendiente', 'pendiente', '123', '123', 'avatar.png', '1988-03-02', 'Masculino', '2017-08-16'),
(15, 10315984, 'Ch', 'Marcos', 'Coragua Flores', 'solter@', 'Comeriante', 'Cll: Medinaceli S/N', '0000', '0000', 'avatar.png', '1990-10-10', 'Masculino', '2018-01-27'),
(17, 12345, 'Ch', 'Juna', 'Florez Vasquez', 'solter@', 'Comerciante', 'sin direccion', '0000', '0000', 'avatar.png', '1990-01-01', 'Femenino', '2018-01-27'),
(18, 112345, 'Ch', 'Martha', 'Mamani Ramos', 'solter@', 'Comerciante', 'sin direccion', '0000', '0000', 'avatar.png', '1990-01-01', 'Femenino', '2018-01-27'),
(19, 3680266, 'Pt', 'Santusa', 'Flores Burgos', 'solter@', 'Labores de Casa', '8 de Mayo de 2019', '0000', '0000', 'avatar.png', '1972-12-20', 'Femenino', '2018-03-25');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `give`
--

CREATE TABLE `give` (
  `id` int(11) NOT NULL,
  `id_user` int(11) DEFAULT NULL,
  `id_clients` int(11) DEFAULT NULL,
  `id_userin` int(11) DEFAULT NULL,
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
  `total_assistant` float DEFAULT NULL,
  `visible` tinyint(1) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_spanish2_ci;

--
-- Volcado de datos para la tabla `give`
--

INSERT INTO `give` (`id`, `id_user`, `id_clients`, `id_userin`, `amount`, `fec_pre`, `month`, `fine`, `interest`, `type`, `detail`, `gain`, `total_capital`, `total_interest`, `total_lender`, `total_assistant`, `visible`) VALUES
(1, 3, 1, 2, 10000, '2017-03-19', 12, 50, 4, 'men', 'SIN observación.', 20, 0, 2400, 1920, 480, 1),
(2, 3, 2, 2, 2500, '2017-05-06', 5, 50, 4, 'men', 'CANCELADO.', 20, 2500, 400, 320, 80, 2),
(3, 3, 3, 2, 3500, '2017-05-06', 5, 50, 4, 'men', 'CANCELADO.', 20, 3500, 560, 448, 112, 2),
(4, 1, 4, 2, 15000, '2017-06-07', 12, 50, 4, 'men', 'OBSERVADO por: fecha de préstamo.\nPréstamo para el alquiler:\n7 de mayo del 2018', 0, 0, 4800, 4800, 0, 1),
(5, 3, 6, 2, 7000, '2017-05-21', 14, 50, 4, 'men', 'OBSERVADO por: empezó el 21 de NOV de 2016, se fue alargando: Hasta 21 de diciembre 2018', 20, 0, 2240, 1792, 448, 1),
(6, 3, 10, 2, 5000, '2017-02-17', 24, 50, 4, 'men', 'SIN observación.', 20, 0, 2200, 1760, 440, 1),
(7, 3, 9, 2, 7000, '2017-04-24', 12, 50, 4, 'men', 'SIN observación.', 20, 0, 3080, 2464, 616, 1),
(8, 3, 8, 2, 8000, '2017-01-18', 18, 50, 4, 'men', 'Código Verde', 20, 8000, 3840, 3040, 800, 1),
(9, 3, 7, 2, 16000, '2016-12-22', 24, 100, 4, 'men', 'Código Verde Sebastian Alaca Churqui-Juana Flores', 20, 16000, 7680, 6016, 1664, 1),
(10, 3, 11, 2, 5500, '2017-05-23', 14, 50, 4, 'men', 'Código verde', 20, 5500, 1100, 880, 220, 1),
(11, 3, 5, 2, 5000, '2017-06-27', 12, 50, 4, 'men', 'Prestamos alargado,  10 meses previamente, código amarillo', 20, 0, 1400, 1120, 280, 1),
(12, 3, 12, 2, 10000, '2017-07-17', 7, 50, 4, 'men', 'Sin observacion', 20, 0, 800, 640, 160, 1),
(13, 3, 13, 2, 7500, '2017-07-21', 12, 50, 4, 'men', 'Sin observacion', 20, 0, 1800, 1440, 360, 1),
(14, 3, 14, 2, 11000, '2017-08-30', 12, 50, 4, 'men', 'OBSERVADO por: No existe contrato, ni carnet, y el nombre aun no es confiable.', 20, 0, 1760, 1408, 352, 1),
(15, 3, 4, 2, 3000, '2017-12-28', 6, 50, 4, 'men', 'OBSERVADO por:  Doble préstamo, tener cuidado con el cliente, OBSERVADO por las fechas', 20, 0, 120, 96, 24, 1),
(16, 3, 15, 2, 10000, '2017-10-23', 12, 50, 4, 'men', 'SIN observación.', 20, 0, 1200, 960, 240, 1),
(17, 3, 17, 2, 5000, '2017-10-21', 12, 50, 4, 'men', 'SIN observación.', 20, 0, 0, 0, 0, 1),
(18, 3, 18, 2, 10000, '2018-01-05', 12, 50, 4, 'men', 'OBSERVADO por: a partir de este préstamo tiene que ser en $ dólares,  con el tipo de cambio compra de C: 6.86', 20, 0, 0, 0, 0, 1),
(19, 3, 19, 1, 3000, '2018-03-13', 12, 50, 4, 'men', 'Sin observaciones', 20, 0, 0, 0, 0, 1),
(20, 1, 19, 1, 2000, '2018-03-13', 12, 50, 4, 'men', 'Sin observacion', 0, 0, 0, 0, 0, 1);

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

--
-- Volcado de datos para la tabla `payment`
--

INSERT INTO `payment` (`id`, `id_give`, `fec_pago`, `interests`, `capital_shares`, `lender`, `assistant`, `observation`) VALUES
(40, 9, '2017-01-22', 640, 0, 448, 192, 'Depósito en '),
(41, 9, '2017-02-22', 640, 0, 448, 192, 'Depósito en '),
(42, 8, '2017-02-18', 320, 0, 224, 96, 'Depósito en '),
(43, 10, '2017-06-23', 220, 0, 176, 44, 'Depósito en '),
(44, 10, '2017-07-23', 220, 0, 176, 44, 'Depósito en '),
(45, 9, '2017-03-22', 640, 0, 512, 128, 'Depósito en '),
(46, 9, '2017-04-22', 640, 0, 512, 128, 'Depósito en '),
(47, 9, '2017-05-22', 640, 0, 512, 128, 'Depósito en '),
(48, 9, '2017-06-22', 640, 0, 512, 128, 'Depósito en '),
(49, 9, '2017-07-22', 640, 0, 512, 128, 'Depósito en '),
(50, 8, '2017-03-18', 320, 0, 256, 64, 'Depósito en '),
(51, 8, '2017-04-18', 320, 0, 256, 64, 'Depósito en '),
(52, 8, '2017-05-18', 320, 0, 256, 64, 'Depósito en '),
(53, 8, '2017-06-18', 320, 0, 256, 64, 'Depósito en '),
(54, 8, '2017-07-18', 320, 0, 256, 64, 'Depósito en '),
(55, 7, '2017-03-24', 280, 0, 224, 56, 'Depósito en '),
(56, 7, '2017-04-24', 280, 0, 224, 56, 'Depósito en '),
(57, 7, '2017-05-24', 280, 0, 224, 56, 'Depósito en '),
(58, 7, '2017-06-24', 280, 0, 224, 56, 'Depósito en '),
(59, 7, '2017-07-24', 280, 0, 224, 56, 'Depósito en '),
(60, 6, '2017-03-17', 200, 0, 160, 40, 'Depósito en '),
(61, 6, '2017-04-17', 200, 0, 160, 40, 'Depósito en '),
(62, 6, '2017-05-17', 200, 0, 160, 40, 'Depósito en '),
(63, 6, '2017-06-17', 200, 0, 160, 40, 'Depósito en '),
(64, 6, '2017-07-17', 200, 0, 160, 40, 'Depósito en '),
(65, 5, '2017-06-21', 280, 0, 224, 56, 'Depósito en '),
(66, 5, '2017-07-21', 280, 0, 224, 56, 'Depósito en '),
(67, 4, '2017-07-07', 600, 0, 600, 0, 'Depósito en '),
(68, 3, '2017-06-06', 140, 0, 112, 28, 'Depósito en '),
(69, 3, '2017-07-06', 140, 0, 112, 28, 'Depósito en '),
(70, 2, '2017-06-06', 100, 0, 80, 20, 'Depósito en '),
(71, 2, '2017-07-06', 100, 0, 80, 20, 'Depósito en '),
(72, 1, '2017-04-19', 400, 0, 320, 80, 'Depósito en '),
(73, 1, '2017-05-19', 400, 0, 320, 80, 'Depósito en '),
(74, 1, '2017-06-19', 400, 0, 320, 80, 'Depósito en '),
(75, 1, '2017-07-19', 400, 0, 320, 80, 'Depósito en '),
(76, 11, '2017-07-27', 200, 0, 160, 40, 'Depósito en '),
(77, 13, '2017-08-21', 300, 0, 240, 60, 'Depósito en Union'),
(78, 13, '2017-09-21', 300, 0, 240, 60, 'Depósito en Union'),
(79, 12, '2017-08-17', 400, 0, 320, 80, 'Depósito en Union'),
(80, 11, '2017-08-27', 200, 0, 160, 40, 'Depósito en '),
(81, 12, '2017-09-17', 400, 0, 320, 80, 'Depósito en '),
(82, 10, '2017-08-23', 220, 0, 176, 44, 'Depósito en '),
(83, 10, '2017-09-23', 220, 0, 176, 44, 'Depósito en Union'),
(84, 9, '2017-08-22', 640, 0, 512, 128, 'Depósito en Union'),
(85, 9, '2017-09-22', 640, 0, 512, 128, 'Depósito en Union'),
(86, 8, '2017-08-18', 320, 0, 256, 64, 'Depósito en Union'),
(87, 8, '2017-09-18', 320, 0, 256, 64, 'Depósito en Union'),
(88, 7, '2017-08-24', 280, 0, 224, 56, 'Depósito en Union'),
(89, 7, '2017-09-24', 280, 0, 224, 56, 'Depósito en Union'),
(90, 6, '2017-08-17', 200, 0, 160, 40, 'Depósito en Union'),
(91, 6, '2017-09-17', 200, 0, 160, 40, 'Depósito en Union'),
(92, 5, '2017-08-21', 280, 0, 224, 56, 'Depósito en Union'),
(93, 5, '2017-09-21', 280, 0, 224, 56, 'Depósito en Union'),
(94, 4, '2017-08-07', 600, 0, 600, 0, 'Depósito en Union'),
(95, 4, '2017-09-07', 600, 0, 600, 0, 'Depósito en Union'),
(96, 3, '2017-08-06', 140, 0, 112, 28, 'Depósito en Union'),
(97, 3, '2017-09-06', 140, 3500, 112, 28, 'Depósito en Union'),
(98, 2, '2017-08-06', 100, 0, 80, 20, 'Depósito en Union'),
(99, 2, '2017-09-06', 100, 2500, 80, 20, 'Depósito en Union'),
(100, 1, '2017-08-19', 400, 0, 320, 80, 'Depósito en Union'),
(101, 1, '2017-09-19', 400, 0, 320, 80, 'Depósito en Union'),
(102, 14, '2017-09-30', 440, 0, 352, 88, 'Depósito en BNB'),
(103, 15, '2018-01-28', 120, 0, 96, 24, 'Depósito en Union'),
(104, 16, '2017-11-23', 400, 0, 320, 80, 'Depósito en Unión'),
(105, 16, '2017-12-23', 400, 0, 320, 80, 'Depósito en Unión'),
(106, 16, '2018-01-23', 400, 0, 320, 80, 'Depósito en Unión'),
(107, 14, '2017-10-30', 440, 0, 352, 88, 'Depósito en Unión'),
(108, 14, '2017-11-30', 440, 0, 352, 88, 'Depósito en Unión'),
(109, 14, '2017-12-30', 440, 0, 352, 88, 'Depósito en Unión'),
(110, 13, '2017-10-21', 300, 0, 240, 60, 'Depósito en Unión'),
(111, 13, '2017-11-21', 300, 0, 240, 60, 'Depósito en Unión'),
(112, 13, '2017-12-21', 300, 0, 240, 60, 'Depósito en Unión'),
(113, 13, '2018-01-21', 300, 0, 240, 60, 'Depósito en Unión'),
(114, 11, '2017-09-27', 200, 0, 160, 40, 'Depósito en Unión'),
(115, 11, '2017-10-27', 200, 0, 160, 40, 'Depósito en Unión'),
(116, 11, '2017-11-27', 200, 0, 160, 40, 'Depósito en Unión'),
(117, 11, '2017-12-27', 200, 0, 160, 40, 'Depósito en Unión'),
(118, 11, '2018-01-27', 200, 0, 160, 40, 'Depósito en Unión'),
(119, 10, '2017-10-23', 220, 5500, 176, 44, 'Depósito en Unión'),
(120, 9, '2017-10-22', 640, 0, 512, 128, 'Depósito en Unión'),
(121, 9, '2017-11-22', 640, 0, 512, 128, 'Depósito en Unión'),
(122, 9, '2017-12-22', 640, 16000, 512, 128, 'Depósito en Unión'),
(123, 8, '2017-10-18', 320, 0, 256, 64, 'Depósito en Unión'),
(124, 8, '2017-11-18', 320, 0, 256, 64, 'Depósito en Unión'),
(125, 8, '2017-12-18', 320, 0, 256, 64, 'Depósito en Unión'),
(126, 8, '2018-01-18', 320, 8000, 256, 64, 'Depósito en Unión'),
(127, 6, '2017-10-17', 200, 0, 160, 40, 'Depósito en Unión'),
(128, 7, '2017-10-24', 280, 0, 224, 56, 'Depósito en Unión'),
(129, 7, '2017-11-24', 280, 0, 224, 56, 'Depósito en Unión'),
(130, 7, '2017-12-24', 280, 0, 224, 56, 'Depósito en Unión'),
(131, 7, '2018-01-24', 280, 0, 224, 56, 'Depósito en Unión'),
(132, 6, '2017-11-17', 200, 0, 160, 40, 'Depósito en Unión'),
(133, 6, '2017-12-17', 200, 0, 160, 40, 'Depósito en Unión'),
(134, 6, '2018-01-17', 200, 0, 160, 40, 'Depósito en Unión'),
(135, 5, '2017-10-21', 280, 0, 224, 56, 'Depósito en Unión'),
(136, 5, '2017-11-21', 280, 0, 224, 56, 'Depósito en Unión'),
(137, 5, '2017-12-21', 280, 0, 224, 56, 'Depósito en Unión'),
(138, 5, '2018-01-21', 280, 0, 224, 56, 'Depósito en Unión'),
(139, 4, '2017-10-07', 600, 0, 600, 0, 'Depósito en Unión'),
(140, 4, '2017-11-07', 600, 0, 600, 0, 'Depósito en Unión'),
(141, 4, '2017-12-07', 600, 0, 600, 0, 'Depósito en Unión'),
(142, 4, '2017-12-07', 600, 0, 600, 0, 'Depósito en Unión'),
(143, 4, '2017-12-07', 600, 0, 600, 0, 'Depósito en Unión');

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
  `sex` varchar(9) COLLATE utf8_spanish2_ci DEFAULT NULL,
  `src` varchar(255) COLLATE utf8_spanish2_ci DEFAULT NULL,
  `pwd` varchar(100) COLLATE utf8_spanish2_ci DEFAULT NULL,
  `type` varchar(5) COLLATE utf8_spanish2_ci DEFAULT NULL,
  `last_connection` datetime DEFAULT NULL,
  `registered` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_spanish2_ci;

--
-- Volcado de datos para la tabla `user`
--

INSERT INTO `user` (`id`, `ci`, `ex`, `name`, `last_name`, `email`, `sex`, `src`, `pwd`, `type`, `last_connection`, `registered`) VALUES
(1, 10917763, 'Lp', 'Gary David', 'Guzmán Muñoz', 'gary.2810.dav@gmail.com', 'Masculino', 'whatsapp image 2017-05-28 at 2.18.37 am.-921.jpeg', '39757e328cf361b2577a6a4bb509172f6d41f6d0', 'supad', '2017-07-04 17:57:13', '2017-07-04'),
(2, 4086001, 'Ch', 'Elizabeth', 'Muñoz Escobar', 'elizabethme79@hotmail.com', 'Femenino', '19399698_10156007915758484_3742577124046735941_n-840.jpeg', '585f7f3723df82f91fffd25a5c6900597cd4d1c1', 'user', '2017-07-04 18:14:17', '2017-07-04'),
(3, 3505115, 'Pt', 'Daniel', 'Guzmán Zenteno', 'gz_dann.24@hotmail.com', 'Masculino', '1235172_152985218236104_1920928629_n-742.jpeg', '585f7f3723df82f91fffd25a5c6900597cd4d1c1', 'admin', '2017-07-04 18:20:37', '2017-07-04'),
(4, 7578870, 'Ch', 'Ilsen', 'Romero Caraballo', 'terryselt@gmail.com', 'Femenino', 'attack on titan 22-859.jpeg', '585f7f3723df82f91fffd25a5c6900597cd4d1c1', 'admin', '2017-07-07 22:12:08', '2017-07-07');

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
  ADD KEY `id_clients` (`id_clients`),
  ADD KEY `id_userin` (`id_userin`);

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
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=20;
--
-- AUTO_INCREMENT de la tabla `give`
--
ALTER TABLE `give`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=21;
--
-- AUTO_INCREMENT de la tabla `payment`
--
ALTER TABLE `payment`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=144;
--
-- AUTO_INCREMENT de la tabla `user`
--
ALTER TABLE `user`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;
--
-- Restricciones para tablas volcadas
--

--
-- Filtros para la tabla `give`
--
ALTER TABLE `give`
  ADD CONSTRAINT `give_ibfk_1` FOREIGN KEY (`id_user`) REFERENCES `user` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `give_ibfk_2` FOREIGN KEY (`id_clients`) REFERENCES `clients` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `give_ibfk_3` FOREIGN KEY (`id_userin`) REFERENCES `user` (`id`) ON DELETE SET NULL;

--
-- Filtros para la tabla `payment`
--
ALTER TABLE `payment`
  ADD CONSTRAINT `payment_ibfk_1` FOREIGN KEY (`id_give`) REFERENCES `give` (`id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
