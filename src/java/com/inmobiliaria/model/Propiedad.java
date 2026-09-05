package com.inmobiliaria.model;

import java.io.Serializable;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

public class Propiedad implements Serializable {

    private int id;
    private String titulo;
    private BigDecimal precio;
    private String ubicacion;
    private String tipoOperacion;
    private String tipo;
    private String direccion;
    private double area;
    private int habitaciones;
    private int banos;
    private String descripcion;
    private String imagenPrincipal;
    private String estado;
    private boolean destacada;
    private LocalDateTime fechaPublicacion;
    private final List<String> imagenes = new ArrayList<>();
    private final List<String> caracteristicas = new ArrayList<>();

    public Propiedad() {
    }

    public Propiedad(int id, String titulo, BigDecimal precio, String ubicacion, String tipoOperacion, String tipo,
            double area, int habitaciones, int banos, String descripcion, String imagenPrincipal,
            List<String> imagenes, List<String> caracteristicas) {
        this.id = id;
        this.titulo = titulo;
        this.precio = precio;
        this.ubicacion = ubicacion;
        this.tipoOperacion = tipoOperacion;
        this.tipo = tipo;
        this.area = area;
        this.habitaciones = habitaciones;
        this.banos = banos;
        this.descripcion = descripcion;
        this.imagenPrincipal = imagenPrincipal;
        if (imagenes != null) {
            this.imagenes.addAll(imagenes);
        }
        if (caracteristicas != null) {
            this.caracteristicas.addAll(caracteristicas);
        }
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getTitulo() {
        return titulo;
    }

    public void setTitulo(String titulo) {
        this.titulo = titulo;
    }

    public BigDecimal getPrecio() {
        return precio;
    }

    public void setPrecio(BigDecimal precio) {
        this.precio = precio;
    }

    public String getUbicacion() {
        return ubicacion;
    }

    public void setUbicacion(String ubicacion) {
        this.ubicacion = ubicacion;
    }

    public String getTipoOperacion() {
        return tipoOperacion;
    }

    public void setTipoOperacion(String tipoOperacion) {
        this.tipoOperacion = tipoOperacion;
    }

    public String getTipo() {
        return tipo;
    }

    public void setTipo(String tipo) {
        this.tipo = tipo;
    }

    public String getDireccion() {
        return direccion;
    }

    public void setDireccion(String direccion) {
        this.direccion = direccion;
    }

    public double getArea() {
        return area;
    }

    public void setArea(double area) {
        this.area = area;
    }

    public int getHabitaciones() {
        return habitaciones;
    }

    public void setHabitaciones(int habitaciones) {
        this.habitaciones = habitaciones;
    }

    public int getBanos() {
        return banos;
    }

    public void setBanos(int banos) {
        this.banos = banos;
    }

    public String getDescripcion() {
        return descripcion;
    }

    public void setDescripcion(String descripcion) {
        this.descripcion = descripcion;
    }

    public String getImagenPrincipal() {
        return imagenPrincipal;
    }

    public void setImagenPrincipal(String imagenPrincipal) {
        this.imagenPrincipal = imagenPrincipal;
    }

    public String getEstado() {
        return estado;
    }

    public void setEstado(String estado) {
        this.estado = estado;
    }

    public boolean isDestacada() {
        return destacada;
    }

    public void setDestacada(boolean destacada) {
        this.destacada = destacada;
    }

    public LocalDateTime getFechaPublicacion() {
        return fechaPublicacion;
    }

    public void setFechaPublicacion(LocalDateTime fechaPublicacion) {
        this.fechaPublicacion = fechaPublicacion;
    }

    public List<String> getImagenes() {
        return imagenes;
    }

    public List<String> getCaracteristicas() {
        return caracteristicas;
    }
}
