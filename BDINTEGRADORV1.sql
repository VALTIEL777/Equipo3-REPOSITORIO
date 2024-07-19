CREATE TABLE ROL(
Id_Rol SERIAL,
Rol VARCHAR(13) NOT NULL,
PRIMARY KEY(Id_Rol)
);

INSERT INTO ROL(Rol)
VALUES('Invitado'),
('Administrador');

CREATE TABLE USUARIOS(
Id_Usuario SERIAL,
Nom_Usuario VARCHAR(40) NOT NULL,
password VARCHAR NOT NULL,
Id_Rol INT NOT NULL,
PRIMARY KEY(Id_Usuario),
FOREIGN KEY(Id_Rol) REFERENCES ROL(Id_Rol)
);

CREATE EXTENSION pgcrypto;

INSERT INTO USUARIOS(Nom_Usuario,password,Id_Rol)
VALUES('Elian777',PGP_SYM_ENCRYPT('Lirio777','AES_KEY'),2),
('Carlos012',PGP_SYM_ENCRYPT('Lirio012','AES_KEY'),1),
('Antoine444',PGP_SYM_ENCRYPT('Lirio444','AES_KEY'),2),
('Rodolfo555',PGP_SYM_ENCRYPT('Lirio555','AES_KEY'),1);



CREATE TABLE EMPLEADOS(
Id_Empleado SERIAL,
Nombre VARCHAR(25) NOT NULL,
ApellidoP VARCHAR(20) NOT NULL,
ApellidoM VARCHAR(20) NULL,
Fecha_nac DATE NOT NULL,
Correo VARCHAR(30) UNIQUE NOT NULL,
Telefono VARCHAR(10)NOT NULL,
Nss Varchar(11) UNIQUE NOT NULL,
Id_Usuario INT NOT NULL,
PRIMARY KEY(Id_Empleado),
FOREIGN KEY(Id_Usuario) REFERENCES USUARIOS(Id_Usuario)
);

INSERT INTO EMPLEADOS(Nombre,ApellidoP,ApellidoM,Fecha_nac,Correo,Telefono,Nss,Id_Usuario)
VALUES('Elian','Medina','Cobos','2004-06-04','elianmedinacobos@gmail.com','2712100209','12345678910',1),
('Nestor Antoine','García','Sánchez','2004-08-11','Antoine2004@gmail.com','2731442610','09876543211',3);



CREATE TABLE VENTAS(
Folio SERIAL NOT NULL,
TOTAL DECIMAL(10,5) NOT NULL,
FechaVenta DATE NOT NULL,
Id_Empleado INT NOT NULL,
PRIMARY KEY(Folio),
FOREIGN KEY(Id_Empleado) REFERENCES EMPLEADOS(Id_Empleado)
);

INSERT INTO VENTAS(TOTAL,FechaVenta,Id_Empleado)
VALUES(100.5,'2024-07-10',1),
(64.4,'2024-07-12',2);


CREATE TABLE CATEGORIAS(
Id_Categoria SERIAL ,
Nom_Categoria VARCHAR(25) NOT NULL,
PRIMARY KEY(Id_Categoria)
);

INSERT INTO CATEGORIAS(Nom_Categoria)
VALUES('Canasta Básica'),
('Dulcería'),
('Limpieza');

CREATE TABLE PRODUCTOS(
Id_Producto SERIAL NOT NULL,
Nom_Prod VARCHAR(25) NOT NULL,
Precio_Venta DECIMAL(10,5) NOT NULL,
Precio_Comp DECIMAL(10,5) NOT NULL,
Desc_Prod VARCHAR(25) NOT NULL,
Existencia INT NOT NULL,
Id_Categoria INT NOT NULL,
PRIMARY KEY(Id_Producto),
FOREIGN KEY(Id_Categoria) REFERENCES CATEGORIAS(Id_Categoria)
);

INSERT INTO PRODUCTOS(Nom_Prod,Precio_Venta,Precio_Comp,Desc_Prod,Existencia,Id_Categoria)
VALUES('Leche',15.5,10.0,'LALA 1Litro',25,1),
('Chetos',10.0,6.0,'Chetos Bolita',15,2),
('Clorox',12.0,8.0,'Cloro 1Litro',10,3);


CREATE TABLE DETALLE_DE_VENTA(
Id_Det_Venta SERIAL NOT NULL,
Cantidad INT NOT NULL,
Folio INT NOT NULL,
Id_Producto INT NOT NULL,
PRIMARY KEY (Id_Det_Venta),
FOREIGN KEY(Folio) REFERENCES VENTAS (Folio),
FOREIGN KEY(Id_Producto) REFERENCES PRODUCTOS(Id_Producto)
);

INSERT INTO DETALLE_DE_VENTA(Cantidad,Folio,Id_Producto)
VALUES(2,1,1),
(1,2,2);



/*_____________________________________________________INDICES___________________________________________________*/
CREATE INDEX idx_IdUsuario ON USUARIOS(Id_Usuario);
CREATE INDEX idx_IdEmpleado ON EMPLEADOS(Id_Empleado);
CREATE INDEX idx_Folio ON VENTAS(Folio);
CREATE INDEX idx_IdProducto ON PRODUCTOS(Id_Producto);
CREATE INDEX idx_IdCategoria ON CATEGORIAS(Id_Categoria);
CREATE INDEX idx_Id_log ON bitacora_usuarios(Id_log);
/*________________________________________________________________________________________________________________*/

/*_____________________________________________________VISTAS______________________________________________________*/
CREATE VIEW TV_REGISTROS_EMPLEADOS AS
SELECT COUNT(*)
FROM EMPLEADOS;
SELECT *FROM TV_REGISTROS_EMPLEADOS;

CREATE VIEW TV_CATEGORIA_PRODUCTOS AS
SELECT pr.Nom_Prod,pr.Precio_Venta,pr.Precio_Comp,pr.Existencia,ca.Nom_Categoria
FROM PRODUCTOS pr INNER JOIN CATEGORIAS ca
ON ca.Id_Categoria = pr.Id_Categoria;
SELECT *FROM TV_CATEGORIA_PRODUCTOS;

CREATE VIEW TV_USUARIO_ROL_EMPLEADO AS
SELECT e.Id_Empleado,e.Nombre,e.ApellidoP,e.Correo,u.Nom_Usuario,u.Id_Usuario,r.Rol
FROM ROL r INNER JOIN USUARIOS u
ON r.Id_Rol = u.Id_Rol
INNER JOIN EMPLEADOS e
ON u.Id_Usuario = e.Id_Usuario;
SELECT *FROM TV_USUARIO_ROL_EMPLEADO;

CREATE VIEW TV_VENTAS_DE_EMPLEADOS AS
SELECT e.Nombre,e.ApellidoP,e.Correo,v.Folio,v.FechaVenta,dtv.Id_Det_Venta
FROM EMPLEADOS e INNER JOIN VENTAS v
ON e.Id_Empleado = v.Id_Empleado
INNER JOIN DETALLE_DE_VENTA dtv
ON v.Folio = dtv.Folio;
SELECT *FROM TV_VENTAS_DE_EMPLEADOS;

CREATE VIEW TV_ORDEN_ASC_USUARIOS_EMPLEADOS AS
SELECT u.Id_Usuario,u.Nom_Usuario,e.Nombre,e.ApellidoP,e.ApellidoM
FROM USUARIOS u INNER JOIN EMPLEADOS e
ON u.Id_Usuario = e.Id_Empleado;
SELECT *FROM TV_ORDEN_ASC_USUARIOS_EMPLEADOS;

/*________________________________________________________________________________________________________________*/
/*______________________________________________TRANSACCIONES_____________________________________________________________________*/
BEGIN;
INSERT INTO USUARIOS(Nom_Usuario,password,Id_Rol)
VALUES('Andy',PGP_SYM_ENCRYPT('Mar7N','AES_KEY'),2),
('Andy',PGP_SYM_ENCRYPT('Mar7N','AES_KEY'),2);
COMMIT;

BEGIN;
INSERT INTO EMPLEADOS(Nombre,ApellidoP,ApellidoM,Fecha_nac,Correo,Telefono,Nss,Id_Usuario)
VALUES('Andrea','Molina','Sánchez','2005-06-13','AndyRomol@gmail.com','2712134433','56788990871',5),
('Mery','Torres','Canseco','2004-01-07','Jane777@gmail.com','2731447656','98975667893',6);
COMMIT;
ROLLBACK;

BEGIN;
UPDATE USUARIOS
SET password=(PGP_SYM_ENCRYPT('SkyBlue8','AES_KEY'))
WHERE Id_Usuario=5;
COMMIT;
/*___________________________________________BITACORA_USUARIOS______________________________________________________*/

CREATE TABLE bitacora_USUARIOS(
IdUsuario INT,
timestamp_ TIMESTAMP WITH TIME ZONE default NOW(),
nombre_disparador text,
tipo_disparador text,
nivel_disparador text,
comando text,
descripcion text
);


CREATE OR REPLACE FUNCTION grabar_operaciones_usuarios() RETURNS TRIGGER AS $$
	DECLARE
	BEGIN
		INSERT INTO bitacora_USUARIOS (
					IdUsuario,
					nombre_disparador,
					tipo_disparador,
					nivel_disparador,
					comando,
					descripcion)
			VALUES (
					NEW.Id_Usuario,
					TG_NAME,
					TG_WHEN,
					TG_LEVEL,
					TG_OP,
					current_query()
				   );
				   
		RETURN NULL;
	END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER grabar_operaciones_usuarios AFTER INSERT OR UPDATE OR DELETE
	ON USUARIOS FOR EACH ROW
	EXECUTE PROCEDURE grabar_operaciones_usuarios();
	
SELECT *FROM bitacora_USUARIOS;
/*________________________________________________________________________________________________________________*/

/*___________________________________________BITACORA_EMPLEADOS______________________________________________________*/

CREATE TABLE bitacora_EMPLEADOS(
IdEmpleado INT,
timestamp_ TIMESTAMP WITH TIME ZONE default NOW(),
nombre_disparador text,
tipo_disparador text,
nivel_disparador text,
comando text,
descripcion text
);


CREATE OR REPLACE FUNCTION grabar_operaciones_empleados() RETURNS TRIGGER AS $$
	DECLARE
	BEGIN
		INSERT INTO bitacora_EMPLEADOS (
					IdEmpleado,
					nombre_disparador,
					tipo_disparador,
					nivel_disparador,
					comando,
					descripcion)
			VALUES (
					NEW.Id_Empleado,
					TG_NAME,
					TG_WHEN,
					TG_LEVEL,
					TG_OP,
					current_query()
				   );
				   
		RETURN NULL;
	END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER grabar_operaciones_empleados AFTER INSERT OR UPDATE OR DELETE
	ON EMPLEADOS FOR EACH ROW
	EXECUTE PROCEDURE grabar_operaciones_empleados();
	
SELECT *FROM bitacora_EMPLEADOS;
/*________________________________________________________________________________________________________________*/

/*___________________________________________BITACORA_PRODUCTOS______________________________________________________*/

CREATE TABLE bitacora_PRODUCTOS(
IdProducto INT,
timestamp_ TIMESTAMP WITH TIME ZONE default NOW(),
nombre_disparador text,
tipo_disparador text,
nivel_disparador text,
comando text,
descripcion text
);


CREATE OR REPLACE FUNCTION grabar_operaciones_productos() RETURNS TRIGGER AS $$
	DECLARE
	BEGIN
		INSERT INTO bitacora_PRODUCTOS (
					IdProducto,
					nombre_disparador,
					tipo_disparador,
					nivel_disparador,
					comando,
					descripcion)
			VALUES (
					NEW.Id_Producto,
					TG_NAME,
					TG_WHEN,
					TG_LEVEL,
					TG_OP,
					current_query()
				   );
				   
		RETURN NULL;
	END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER grabar_operaciones_productos AFTER INSERT OR UPDATE OR DELETE
	ON PRODUCTOS FOR EACH ROW
	EXECUTE PROCEDURE grabar_operaciones_productos();
	
SELECT *FROM bitacora_PRODUCTOS;
/*________________________________________________________________________________________________________________*/

