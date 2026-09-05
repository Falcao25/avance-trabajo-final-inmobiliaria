package com.inmobiliaria.model;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

public final class MockData {

    private MockData() {
    }

    public static List<Propiedad> obtenerPropiedades() {
        List<Propiedad> propiedades = new ArrayList<>();
        propiedades.add(new Propiedad(1, "Casa moderna en Surco", new BigDecimal("245000"), "Santiago de Surco, Lima",
                "Venta", "Casa", 180, 4, 3, "Casa de tres niveles con terraza, cocina abierta y cochera doble.",
                "/img/propiedades/propiedad-casa.png",
                List.of("/img/propiedades/propiedad-casa.png", "/img/propiedades/propiedad-departamento.png", "/img/propiedades/propiedad-terreno.png"),
                List.of("Terraza panorámica", "Cochera doble", "Cocina abierta", "Acabados premium")));
        propiedades.add(new Propiedad(2, "Departamento luminoso en Miraflores", new BigDecimal("1250"), "Miraflores, Lima",
                "Alquiler", "Departamento", 92, 3, 2, "Departamento amoblado cerca al malecón y comercios.",
                "/img/propiedades/propiedad-departamento.png",
                List.of("/img/propiedades/propiedad-departamento.png", "/img/propiedades/propiedad-terreno.png", "/img/propiedades/propiedad-casa.png"),
                List.of("Balcón", "Lavandería", "Seguridad 24/7", "Vista exterior")));
        propiedades.add(new Propiedad(3, "Terreno urbano en La Molina", new BigDecimal("98000"), "La Molina, Lima",
                "Venta", "Terreno", 300, 0, 0, "Terreno plano ideal para proyecto residencial o inversión.",
                "/img/propiedades/propiedad-terreno.png",
                List.of("/img/propiedades/propiedad-terreno.png", "/img/propiedades/propiedad-casa.png", "/img/propiedades/propiedad-departamento.png"),
                List.of("Servicios completos", "Zonificación urbana", "Frente amplio", "Acceso principal")));
        propiedades.add(new Propiedad(4, "Casa familiar en San Borja", new BigDecimal("315000"), "San Borja, Lima",
                "Venta", "Casa", 210, 5, 4, "Espacios amplios, jardín interior y sala de estudio independiente.",
                "/img/propiedades/propiedad-casa.png",
                List.of("/img/propiedades/propiedad-casa.png", "/img/propiedades/propiedad-departamento.png", "/img/propiedades/propiedad-terreno.png"),
                List.of("Jardín interior", "Estudio", "Sala de TV", "Cocina equipada")));
        propiedades.add(new Propiedad(5, "Departamento ejecutivo en San Isidro", new BigDecimal("1800"), "San Isidro, Lima",
                "Alquiler", "Departamento", 108, 3, 2, "Ideal para ejecutivos, cerca a oficinas y parques.",
                "/img/propiedades/propiedad-departamento.png",
                List.of("/img/propiedades/propiedad-departamento.png", "/img/propiedades/propiedad-casa.png", "/img/propiedades/propiedad-terreno.png"),
                List.of("Lobby elegante", "Co-working", "Ascensor", "Pet friendly")));
        propiedades.add(new Propiedad(6, "Terreno campestre en Cieneguilla", new BigDecimal("74000"), "Cieneguilla, Lima",
                "Venta", "Terreno", 520, 0, 0, "Oportunidad para casa de campo o proyecto recreativo.",
                "/img/propiedades/propiedad-terreno.png",
                List.of("/img/propiedades/propiedad-terreno.png", "/img/propiedades/propiedad-casa.png", "/img/propiedades/propiedad-departamento.png"),
                List.of("Vista natural", "Buen acceso", "Alto potencial", "Documentación en regla")));
        return propiedades;
    }

    public static List<Propiedad> obtenerDestacadas() {
        List<Propiedad> propiedades = obtenerPropiedades();
        return propiedades.subList(0, Math.min(3, propiedades.size()));
    }

    public static Propiedad obtenerPropiedadPorId(int id) {
        return obtenerPropiedades().stream()
                .filter(propiedad -> propiedad.getId() == id)
                .findFirst()
                .orElseGet(() -> obtenerPropiedades().get(0));
    }

    public static List<Usuario> obtenerUsuarios() {
        return List.of(
                new Usuario(1, "Administrador", "admin@inmobiliaria.com", "admin123", "ADMIN", true),
                new Usuario(2, "Carlos Ramos", "carlos@inmobiliaria.com", "carlos123", "ASESOR", true),
                new Usuario(3, "Laura Peña", "laura@inmobiliaria.com", "laura123", "ASESOR", false));
    }

    public static List<Cliente> obtenerClientes() {
        return List.of(
                new Cliente(1, "María Torres", "maria@mail.com", "999 111 222", "Solicita visita para casa en Surco", LocalDateTime.now().minusDays(1)),
                new Cliente(2, "Juan Castillo", "juan@mail.com", "999 333 444", "Pide información de alquiler en Miraflores", LocalDateTime.now().minusHours(8)),
                new Cliente(3, "Sofía León", "sofia@mail.com", "999 555 666", "Quiere agendar llamada por terreno", LocalDateTime.now().minusHours(2)));
    }
}
