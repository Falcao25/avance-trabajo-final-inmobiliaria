package com.inmobiliaria.config;

import java.sql.Connection;

public final class TestConexion {

    private TestConexion() {
    }

    public static void main(String[] args) {
        try (Connection ignored = Conexion.getConnection()) {
            System.out.println("Conexion exitosa a MySQL");
        } catch (Exception e) {
            System.err.println("No fue posible conectar a MySQL: " + e.getMessage());
        }
    }
}
