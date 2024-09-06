CREATE DATABASE IF NOT EXISTS my_db;
USE my_db;

CREATE TABLE materias (
	Numero int NOT NULL AUTO_INCREMENT,
	Titulo varchar(255),
	Programa varchar(4096),
	PRIMARY KEY (Numero)
);

INSERT INTO materias (Titulo, Programa) VALUES ('Expe 36', 'Se experimentará con subpartículas quanto-elementales.');
INSERT INTO materias (Titulo, Programa) VALUES ('Intro a la Lógica', 'Si Pablito tiene un clavito, ¿cuántos átomos tiene el siguiente reticulado?');

DROP TABLE correlativas;
CREATE TABLE correlativas (
	NumeroMateria int,
	NumeroCorrelativa int,
	PRIMARY KEY (NumeroMateria, NumeroCorrelativa),
	FOREIGN KEY (NumeroMateria) REFERENCES materias(Numero),
	FOREIGN KEY (NumeroCorrelativa) REFERENCES materias(Numero)
);

CREATE TABLE estudiantes (
	NumeroMatricula int NOT NULL AUTO_INCREMENT,
	Nombre varchar(255),
	Carrera varchar(255),
	PRIMARY KEY (NumeroMatricula)
);

INSERT INTO estudiantes (Nombre, Carrera) VALUES ('Carlos', 'Compu');
INSERT INTO estudiantes (Nombre, Carrera) VALUES ('Juan', 'Compu');

DROP TABLE estudiante_materia;
CREATE TABLE estudiante_materia (
	NumeroMatricula int,
	NumeroMateria int,
	Nota int CHECK (1 <= Nota AND Nota <= 10),
	PRIMARY KEY (NumeroMatricula, NumeroMateria),
	FOREIGN KEY (NumeroMatricula) REFERENCES estudiantes(NumeroMatricula),
	FOREIGN KEY (NumeroMateria) REFERENCES materias(Numero)
);

# CUIDADOOOOOOOOOOOOOOOO! NO OLVIDAR AGREGAR LAS RESTRICCIONES DE PRIMARY KEY. SI NO, PASA ESTO (un estudiante podrá tener varias notas en la misma materia):
SELECT * FROM materias;
SELECT * FROM estudiantes;
INSERT INTO estudiante_materia VALUES (1, 1, 5);
INSERT INTO estudiante_materia VALUES (1, 2, 4);
SELECT * FROM estudiante_materia;


CREATE TABLE ofertas (
	Codigo int NOT NULL AUTO_INCREMENT,
	Ano int,
	Semestre int CHECK (Semestre = 1 OR Semestre = 2),
	PRIMARY KEY (Codigo)
);

CREATE TABLE oferta_aula (
	CodigoOferta int,
	Aula varchar(255),
	PRIMARY KEY (CodigoOferta, Aula),
	FOREIGN KEY (CodigoOferta) REFERENCES ofertas(Codigo)
);

CREATE TABLE oferta_horario (
	CodigoOferta int,
	Horario int CHECK (0 <= Horario AND Horario <= 23),
	PRIMARY KEY (CodigoOferta, Horario),
	FOREIGN KEY (CodigoOferta) REFERENCES ofertas(Codigo)
);

CREATE TABLE profesores (
	Legajo int NOT NULL AUTO_INCREMENT,
	Nombre varchar(255) NOT NULL,
	Depto varchar(255),
	Cargo varchar(255) NOT NULL,
	PRIMARY KEY (Legajo)
);

CREATE TABLE oferta_profesor (
	CodigoOferta int,
	Legajo int,
	PRIMARY KEY (CodigoOferta, Legajo),
	FOREIGN KEY (CodigoOferta) REFERENCES ofertas(Codigo),
	FOREIGN KEY (Legajo) REFERENCES profesores(Legajo)
);