package com.inmobiliaria.validation;

import com.inmobiliaria.model.Propiedad;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;
import java.util.function.Function;

/** Reglas compartidas por Servlet/JSP y JSF, segun el esquema y reglas del APF1. */
public final class PropiedadValidacion {
    public static final List<String> TIPOS = List.of("CASA", "DEPARTAMENTO", "TERRENO", "OFICINA", "LOCAL");
    public static final List<String> OPERACIONES = List.of("VENTA", "ALQUILER");
    public static final List<String> ESTADOS = List.of("DISPONIBLE", "RESERVADA", "VENDIDA", "ALQUILADA");
    private PropiedadValidacion() { }

    public static String texto(String valor) { return valor == null ? "" : valor.trim(); }

    public static Propiedad desdeParametros(Function<String, String> parametro, boolean validarNumeros) {
        Propiedad p = new Propiedad();
        p.setTitulo(texto(parametro.apply("titulo")));
        p.setDescripcion(texto(parametro.apply("descripcion")));
        p.setUbicacion(texto(parametro.apply("ubicacion")));
        p.setDireccion(texto(parametro.apply("direccion")));
        p.setTipo(texto(parametro.apply("tipo")));
        p.setTipoOperacion(texto(parametro.apply("tipoOperacion")));
        p.setImagenPrincipal(texto(parametro.apply("imagen")));
        String estado = texto(parametro.apply("estado"));
        p.setEstado(estado.isEmpty() ? "DISPONIBLE" : estado);
        p.setDestacada(parametro.apply("destacada") != null);
        try { p.setPrecio(new BigDecimal(texto(parametro.apply("precio")))); }
        catch (NumberFormatException e) { if (validarNumeros) throw new IllegalArgumentException("El precio debe ser un número válido."); }
        try { p.setArea(Double.parseDouble(texto(parametro.apply("area")))); }
        catch (NumberFormatException e) { if (validarNumeros) throw new IllegalArgumentException("El área debe ser un número válido."); }
        p.setHabitaciones(cantidad(parametro.apply("habitaciones"), "Las habitaciones", validarNumeros));
        p.setBanos(cantidad(parametro.apply("banos"), "Los baños", validarNumeros));
        return p;
    }

    private static int cantidad(String valor, String campo, boolean validar) {
        if (texto(valor).isEmpty()) return 0;
        try { return Integer.parseInt(texto(valor)); }
        catch (NumberFormatException e) {
            if (validar) throw new IllegalArgumentException(campo + " deben ser un número entero válido.");
            return 0;
        }
    }

    public static List<String> validar(Propiedad p) {
        List<String> errores = new ArrayList<>();
        longitud(errores, p.getTitulo(), "El título", 180, true);
        longitud(errores, p.getUbicacion(), "La ubicación", 160, true);
        longitud(errores, p.getDireccion(), "La dirección", 220, false);
        longitud(errores, p.getImagenPrincipal(), "La ruta de imagen", 255, false);
        if (texto(p.getDescripcion()).getBytes(StandardCharsets.UTF_8).length > 65535) {
            errores.add("La descripción supera la capacidad del campo TEXT (65535 bytes UTF-8).");
        }
        permitido(errores, p.getTipo(), TIPOS, "El tipo de inmueble");
        permitido(errores, p.getTipoOperacion(), OPERACIONES, "La operación");
        permitido(errores, p.getEstado(), ESTADOS, "El estado");
        if (p.getPrecio() == null || p.getPrecio().signum() < 0
                || p.getPrecio().setScale(2, RoundingMode.HALF_UP).compareTo(new BigDecimal("9999999999.99")) > 0) {
            errores.add("El precio debe estar entre 0 y 9999999999.99.");
        }
        if (!Double.isFinite(p.getArea()) || p.getArea() < 0
                || BigDecimal.valueOf(p.getArea()).setScale(2, RoundingMode.HALF_UP).compareTo(new BigDecimal("99999999.99")) > 0) {
            errores.add("El área debe ser un número finito entre 0 y 99999999.99.");
        }
        if (p.getHabitaciones() < 0) errores.add("Las habitaciones no pueden ser negativas.");
        if (p.getBanos() < 0) errores.add("Los baños no pueden ser negativos.");
        return errores;
    }

    public static void normalizar(Propiedad p) {
        p.setTitulo(texto(p.getTitulo()));
        p.setUbicacion(texto(p.getUbicacion()));
        p.setDireccion(texto(p.getDireccion()));
        p.setDescripcion(texto(p.getDescripcion()));
        p.setImagenPrincipal(texto(p.getImagenPrincipal()));
        p.setTipo(texto(p.getTipo()).toUpperCase(Locale.ROOT));
        p.setTipoOperacion(texto(p.getTipoOperacion()).toUpperCase(Locale.ROOT));
        p.setEstado(texto(p.getEstado()).toUpperCase(Locale.ROOT));
        p.setPrecio(p.getPrecio().setScale(2, RoundingMode.HALF_UP));
        p.setArea(BigDecimal.valueOf(p.getArea()).setScale(2, RoundingMode.HALF_UP).doubleValue());
    }

    public static int idPositivo(String valor) {
        try {
            int id = Integer.parseInt(texto(valor));
            if (id <= 0) throw new NumberFormatException();
            return id;
        } catch (NumberFormatException e) { throw new IllegalArgumentException("El ID de la propiedad no es válido."); }
    }

    private static void longitud(List<String> errores, String valor, String campo, int maximo, boolean obligatorio) {
        String limpio = texto(valor);
        if (obligatorio && limpio.isEmpty()) errores.add(campo + " es obligatorio.");
        if (limpio.codePointCount(0, limpio.length()) > maximo) errores.add(campo + " admite hasta " + maximo + " caracteres.");
    }

    private static void permitido(List<String> errores, String valor, List<String> valores, String campo) {
        if (!valores.contains(texto(valor).toUpperCase(Locale.ROOT))) errores.add(campo + " no es válido.");
    }
}
