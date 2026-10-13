package com.inmobiliaria.util;

/** Escapa datos de la base antes de mostrarlos en las vistas JSP. */
public final class Html {
    private Html() { }
    public static String escapar(Object valor) {
        return valor == null ? "" : valor.toString().replace("&", "&amp;")
                .replace("<", "&lt;").replace(">", "&gt;")
                .replace("\"", "&quot;").replace("'", "&#39;");
    }
}
