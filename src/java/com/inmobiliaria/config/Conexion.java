package com.inmobiliaria.config;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public final class Conexion {

    // Valores de desarrollo. Cambiar USER y PASSWORD para el entorno local.
    private static final String HOST = "localhost";
    private static final String PORT = "3306";
    private static final String DATABASE = "inmobiliaria";
    private static final String USER = "root";
    private static final String PASSWORD = "Carlos345.";
    private static final String URL = "jdbc:mysql://" + HOST + ":" + PORT + "/" + DATABASE
            + "?useSSL=false&serverTimezone=UTC&allowPublicKeyRetrieval=true";

    private Conexion() {
    }
    static {
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
            } catch (ClassNotFoundException e) {
            throw new ExceptionInInitializerError(
                    "No se encontró MySQL Connector/J: " + e.getMessage()
            );
        }
    }

    public static Connection getConnection() throws SQLException {
        return DriverManager.getConnection(URL, USER, PASSWORD);
    }

    public static Connection conectar() throws SQLException {
        return getConnection();
    }

    public static void cerrar(AutoCloseable... recursos) {
        for (AutoCloseable recurso : recursos) {
            if (recurso != null) {
                try {
                    recurso.close();
                } catch (Exception ignored) {
                    // Se ignora el error al cerrar para no ocultar la excepción original.
                }
            }
        }
    }
}
