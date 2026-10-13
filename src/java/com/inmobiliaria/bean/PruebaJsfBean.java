package com.inmobiliaria.bean;

import jakarta.inject.Named;
import jakarta.enterprise.context.RequestScoped;

/** Prueba de integracion de Faces y CDI sin acceso a la base de datos. */
@Named("pruebaJsfBean")
@RequestScoped
public class PruebaJsfBean {

    private String nombre = "UTP";
    private String saludo = "Vista XHTML conectada correctamente con un bean CDI.";

    public String getTecnologia() {
        return "Jakarta Faces 4.1 + CDI 4.1";
    }

    public String getNombre() {
        return nombre;
    }

    public void setNombre(String nombre) {
        this.nombre = nombre;
    }

    public String getSaludo() {
        return saludo;
    }

    public String saludar() {
        saludo = "Hola, " + nombre.trim() + ". Expression Language ejecuto la accion del bean CDI.";
        return null;
    }
}
