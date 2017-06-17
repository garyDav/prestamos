CREATE DATABASE prestamos;
use prestamos;

CREATE TABLE user (
	id int PRIMARY KEY AUTO_INCREMENT NOT NULL,
	ci int,
	ex varchar(3),
	name varchar(50),
	last_name varchar(50),
	email varchar(100),
	sex varchar(9),
	src varchar(255),
	pwd varchar(100),
	type varchar(5),
	last_connection datetime,
	registered date
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_spanish2_ci;

CREATE TABLE clients (
	id int PRIMARY KEY AUTO_INCREMENT NOT NULL,
	ci int,
	ex varchar(3),
	name varchar(50),
	last_name varchar(50),
	civil_status varchar(15),
	profession varchar(60),
	address varchar(60),
	cellphone1 varchar(15),
	cellphone2 varchar(15),
	src varchar(255),
	fec_nac date,
	sex varchar(9),
	registered date
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_spanish2_ci;

CREATE TABLE give (
	id int PRIMARY KEY AUTO_INCREMENT NOT NULL,
	id_user int,
	id_clients int,
	amount float,
	fec_pre date,
	month smallint,
	fine float,
	interest float,
	type varchar(5),
	detail text,
	gain float,
	total_capital float,
	total_interest float,
	total_lender float,
	total_assistant float,

	FOREIGN KEY (id_user) REFERENCES user(id),
	FOREIGN KEY (id_clients) REFERENCES clients(id) 

) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_spanish2_ci;

CREATE TABLE payment (
	id int PRIMARY KEY AUTO_INCREMENT NOT NULL,
	id_give int,
	fec_pago date,
	interests float,
	capital_shares float,
	lender float,
	assistant float,
	observation text,

	FOREIGN KEY (id_give) REFERENCES give(id)

) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_spanish2_ci;















/*Procediminetos Almacenados*/
delimiter //
DROP PROCEDURE IF EXISTS pSession;
CREATE PROCEDURE pSession(
	IN v_email varchar(100),
	IN v_pwd varchar(100)
)
BEGIN
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
END //

DROP PROCEDURE IF EXISTS pInsertUser;
CREATE PROCEDURE pInsertUser (
	IN v_ci int,
	IN v_ex varchar(3),
	IN v_name varchar(50),
	IN v_last_name varchar(50),
	IN v_email varchar(100),
	IN v_sex varchar(9),
	IN v_pwd varchar(100),
	IN v_type varchar(5)
)
BEGIN
	IF NOT EXISTS(SELECT id FROM user WHERE email LIKE v_email) THEN
		INSERT INTO user VALUES(null,v_ci,v_ex,v_name,v_last_name,v_email,v_sex,'',v_pwd,v_type,CURRENT_TIMESTAMP,CURRENT_TIMESTAMP);
		SELECT @@identity AS id,v_type AS tipo, 'not' AS error, 'Registro insertado.' AS msj;
	ELSE
		SELECT 'yes' error,'Error: Correo ya registrado.' msj;
	END IF;
END //


DROP PROCEDURE IF EXISTS pInsertClients;
CREATE PROCEDURE pInsertClients (
	IN v_ci int,
	IN v_ex varchar(3),
	IN v_name varchar(50),
	IN v_last_name varchar(50),
	IN v_civil_status varchar(15),
	IN v_profession varchar(60),
	IN v_address varchar(60),
	IN v_cellphone1 varchar(15),
	IN v_cellphone2 varchar(15),
	IN v_src varchar(255),
	IN v_fec_nac date,
	IN v_sex varchar(9)
)
BEGIN
	IF NOT EXISTS(SELECT id FROM clients WHERE ci LIKE v_ci) THEN
		INSERT INTO clients VALUES(null,v_ci,v_ex,v_name,v_last_name,v_civil_status,v_profession,v_address,v_cellphone1,v_cellphone2,v_src,v_fec_nac,v_sex,CURRENT_TIMESTAMP);
		SELECT @@identity AS id,'not' AS error, 'Cliente registrado.' AS msj;
	ELSE
		SELECT 'yes' error,'Error: CI ya registrado.' msj;
	END IF;
END //

DROP PROCEDURE IF EXISTS pInsertGive;
CREATE PROCEDURE pInsertGive (
	IN v_id_user int,
	IN v_id_clients int,
	IN v_amount float,
	IN v_fec_pre date,
	IN v_month smallint,
	IN v_fine float,
	IN v_interest float,
	IN v_type varchar(5),
	IN v_detail text
)
BEGIN
	INSERT INTO give VALUES(null,v_id_user,v_id_clients,v_amount,v_fec_pre,v_month,v_fine,v_interest,v_type,v_detail,0,0,0,0,0);
	SELECT @@identity AS id,'not' AS error, 'Prestamo registrado.' AS msj;
END //

/*DROP PROCEDURE IF EXISTS pInsertGive;
CREATE PROCEDURE pInsertGive (
	IN v_id_user int,
	IN v_id_clients int,
	IN v_amount float,
	IN v_fec_pre date,
	IN v_month smallint,
	IN v_fine float,
	IN v_interest float,
	IN v_type varchar(5),
	IN v_detail text,
	IN v_gain float,
	IN v_total_capital float,
	IN v_total_interest float,
	IN v_total_lender float,
	IN v_total_assistant float
)
BEGIN
	INSERT INTO give VALUES(null,v_id_user,v_id_clients,v_amount,v_fec_pre,v_month,v_fine,v_interest,v_type,v_detail,v_gain,float,v_total_capital,v_total_interest,v_total_lender,v_total_assistant);
	SELECT @@identity AS id,'not' AS error, 'Prestamo registrado.' AS msj;
END //*/

DROP PROCEDURE IF EXISTS pInsertPayment;
CREATE PROCEDURE pInsertPayment (
	IN v_id_give int,
	IN v_fec_pago date,
	IN v_interests float,
	IN v_capital_shares float,
	IN v_lender float,
	IN v_assistant float,
	IN v_observation text
)
BEGIN
	INSERT INTO give VALUES(null,v_id_give,v_fec_pago,v_interests,v_capital_shares,v_lender,v_assistant,v_observation);
	SELECT @@identity AS id,'not' AS error, 'Prestamo registrado.' AS msj;
END //



DROP PROCEDURE IF EXISTS pReporte;
CREATE PROCEDURE pReporte (
    IN v_fecha date
)
BEGIN
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
END //


DROP PROCEDURE IF EXISTS pUpdateUser;
CREATE PROCEDURE pUpdateUser (
	IN v_id int,
	IN v_email varchar(100),
	IN v_pwdA varchar(100),
	IN v_pwdN varchar(100),
	IN v_pwdR varchar(100),
	IN v_src varchar(255)
)
BEGIN
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
END //