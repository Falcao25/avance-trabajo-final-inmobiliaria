package com.inmobiliaria.config;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public final class Conexion {
    private static final DatabaseSettings SETTINGS = DatabaseSettings.load();
    private static final String HOST = SETTINGS.getHost();
    private static final String PORT = SETTINGS.getPort();
    // La instancia principal conserva su base; la JVM de pruebas selecciona una base aislada.
    private static final String DATABASE = System.getProperty("inmobiliaria.database", SETTINGS.getDatabase());
    private static final String USER = SETTINGS.getUser();
    private static final String PASSWORD = SETTINGS.getPassword();
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
        boolean pruebas = Boolean.getBoolean("inmobiliaria.test");
        if (pruebas && !"inmobiliaria_apf2_test".equals(DATABASE)) {
            throw new SQLException("El perfil de pruebas requiere la base aislada autorizada.");
        }
        Connection conexion = DriverManager.getConnection(URL, USER, PASSWORD);
        if (pruebas && !"inmobiliaria_apf2_test".equals(conexion.getCatalog())) {
            conexion.close();
            throw new SQLException("La conexión de pruebas no apunta a la base aislada autorizada.");
        }
        return conexion;
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
                    
                }
            }
        }
    }
}
