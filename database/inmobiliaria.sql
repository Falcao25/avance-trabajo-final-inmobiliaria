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

INSERT IGNORE INTO usuarios (id, nombre, apellido, correo, password, rol, estado) VALUES
    (1, 'Administrador', 'Aurora', 'admin@inmobiliaria.com', 'admin123', 'ADMIN', 1),
    (2, 'Carlos', 'Ramos', 'carlos@inmobiliaria.com', 'carlos123', 'ASESOR', 1);

INSERT IGNORE INTO clientes (id, nombre, apellido, correo, telefono, documento) VALUES
    (1, 'Maria', 'Torres', 'maria@mail.com', '999111222', 'DNI-70123456'),
    (2, 'Juan', 'Castillo', 'juan@mail.com', '999333444', 'DNI-70876543'),
    (3, 'Sofia', 'Leon', 'sofia@mail.com', '999555666', 'DNI-70987654');

INSERT IGNORE INTO propiedades
    (id, titulo, descripcion, tipo_propiedad, tipo_operacion, precio, ubicacion, direccion,
     habitaciones, banios, area, imagen, estado, destacada)
VALUES
    (1, 'Casa moderna en Surco', 'Casa de tres niveles con terraza, cocina abierta y cochera doble.',
     'CASA', 'VENTA', 245000.00, 'Santiago de Surco, Lima', 'Av. El Polo 245',
     4, 3, 180.00, '/img/propiedades/propiedad-casa.png', 'DISPONIBLE', 1),
    (2, 'Departamento luminoso en Miraflores', 'Departamento amoblado cerca al malecon y comercios.',
     'DEPARTAMENTO', 'ALQUILER', 1250.00, 'Miraflores, Lima', 'Calle Colon 318',
     3, 2, 92.00, '/img/propiedades/propiedad-departamento.png', 'DISPONIBLE', 1),
    (3, 'Terreno urbano en La Molina', 'Terreno plano ideal para proyecto residencial o inversion.',
     'TERRENO', 'VENTA', 98000.00, 'La Molina, Lima', 'Jr. Las Retamas 510',
     0, 0, 300.00, '/img/propiedades/propiedad-terreno.png', 'DISPONIBLE', 1),
    (4, 'Casa familiar en San Borja', 'Espacios amplios, jardin interior y sala de estudio independiente.',
     'CASA', 'VENTA', 315000.00, 'San Borja, Lima', 'Av. San Luis 1240',
     5, 4, 210.00, '/img/propiedades/propiedad-casa.png', 'RESERVADA', 0),
    (5, 'Oficina ejecutiva en San Isidro', 'Oficina lista para equipos profesionales, cerca de parques y servicios.',
     'OFICINA', 'ALQUILER', 1800.00, 'San Isidro, Lima', 'Calle Las Begonias 441',
     0, 1, 108.00, '/img/propiedades/propiedad-departamento.png', 'DISPONIBLE', 0),
    (6, 'Local comercial en Cieneguilla', 'Local con acceso principal y alto potencial para negocio de servicios.',
     'LOCAL', 'VENTA', 74000.00, 'Cieneguilla, Lima', 'Av. Nueva Toledo 880',
     0, 1, 520.00, '/img/propiedades/propiedad-terreno.png', 'DISPONIBLE', 0);

INSERT IGNORE INTO contactos
    (id, propiedad_id, cliente_id, nombre, correo, telefono, mensaje, estado)
VALUES
    (1, 1, 1, 'Maria Torres', 'maria@mail.com', '999111222', 'Solicita visita para la casa en Surco.', 'NUEVO'),
    (2, 2, 2, 'Juan Castillo', 'juan@mail.com', '999333444', 'Pide informacion de alquiler en Miraflores.', 'CONTACTADO'),
    (3, 3, 3, 'Sofia Leon', 'sofia@mail.com', '999555666', 'Quiere agendar llamada por el terreno.', 'NUEVO');
