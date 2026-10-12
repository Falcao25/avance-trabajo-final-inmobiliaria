CREATE DATABASE IF NOT EXISTS inmobiliaria
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE inmobiliaria;

CREATE TABLE IF NOT EXISTS usuarios (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(80) NOT NULL,
    apellido VARCHAR(80) NOT NULL,
    correo VARCHAR(160) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    rol ENUM('ADMIN', 'ASESOR') NOT NULL DEFAULT 'ASESOR',
    estado TINYINT(1) NOT NULL DEFAULT 1,
    fecha_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS clientes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(80) NOT NULL,
    apellido VARCHAR(80) NOT NULL,
    correo VARCHAR(160) NOT NULL,
    telefono VARCHAR(30),
    documento VARCHAR(30),
    fecha_registro TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_clientes_correo (correo)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS propiedades (
    id INT AUTO_INCREMENT PRIMARY KEY,
    titulo VARCHAR(180) NOT NULL,
    descripcion TEXT NOT NULL,
    tipo_propiedad ENUM('CASA', 'DEPARTAMENTO', 'TERRENO', 'OFICINA', 'LOCAL') NOT NULL,
    tipo_operacion ENUM('VENTA', 'ALQUILER') NOT NULL,
    precio DECIMAL(12, 2) NOT NULL,
    ubicacion VARCHAR(160) NOT NULL,
    direccion VARCHAR(220),
    habitaciones INT NOT NULL DEFAULT 0,
    banios INT NOT NULL DEFAULT 0,
    area DECIMAL(10, 2) NOT NULL,
    imagen VARCHAR(255),
    estado ENUM('DISPONIBLE', 'RESERVADA', 'VENDIDA', 'ALQUILADA') NOT NULL DEFAULT 'DISPONIBLE',
    destacada TINYINT(1) NOT NULL DEFAULT 0,
    fecha_publicacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_propiedades_filtros (tipo_operacion, tipo_propiedad, estado)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS contactos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    propiedad_id INT NULL,
    cliente_id INT NULL,
    nombre VARCHAR(120) NOT NULL,
    correo VARCHAR(160) NOT NULL,
    telefono VARCHAR(30),
    mensaje TEXT NOT NULL,
    fecha_contacto TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    estado ENUM('NUEVO', 'CONTACTADO', 'CERRADO') NOT NULL DEFAULT 'NUEVO',
    CONSTRAINT fk_contactos_propiedad
        FOREIGN KEY (propiedad_id) REFERENCES propiedades (id)
        ON UPDATE CASCADE ON DELETE SET NULL,
    CONSTRAINT fk_contactos_cliente
        FOREIGN KEY (cliente_id) REFERENCES clientes (id)
        ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE=InnoDB;
