package com.inmobiliaria.config;

import java.io.IOException;
import java.io.Reader;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.Properties;

/** Configuracion externa: ningun secreto se incorpora al codigo ni al WAR. */
public final class DatabaseSettings {
    private final Properties properties;
    private DatabaseSettings(Properties properties) { this.properties = properties; }

    public static DatabaseSettings load() {
        String explicit = System.getProperty("inmobiliaria.config", System.getenv("INMOBILIARIA_CONFIG"));
        Path file = explicit == null || explicit.isBlank() ? Path.of("config/database.local.properties") : Path.of(explicit);
        if (explicit == null && !Files.isRegularFile(file) && System.getProperty("catalina.base") != null) {
            file = Path.of(System.getProperty("catalina.base"), "conf", "inmobiliaria.properties");
        }
        Properties values = new Properties();
        if (Files.isRegularFile(file)) {
            try (Reader reader = Files.newBufferedReader(file, StandardCharsets.UTF_8)) { values.load(reader); }
            catch (IOException e) { throw new IllegalStateException("No se pudo leer la configuracion JDBC local."); }
        } else if (explicit != null && !explicit.isBlank()) {
            throw new IllegalStateException("No existe el archivo JDBC configurado. Revisa inmobiliaria.config.");
        }
        override(values, "db.user", "INMOBILIARIA_DB_USER");
        override(values, "db.password", "INMOBILIARIA_DB_PASSWORD");
        if (values.getProperty("db.user", "").isBlank() || values.getProperty("db.password") == null) {
            throw new IllegalStateException("Configura JDBC con database.local.properties o variables de entorno antes de ejecutar.");
        }
        return new DatabaseSettings(values);
    }

    private static void override(Properties properties, String key, String environment) {
        String value = System.getenv(environment);
        if (value != null) properties.setProperty(key, value);
    }
    public String getHost() { return properties.getProperty("db.host", "localhost"); }
    public String getPort() { return properties.getProperty("db.port", "3306"); }
    public String getDatabase() { return properties.getProperty("db.database", "inmobiliaria"); }
    public String getUser() { return properties.getProperty("db.user"); }
    public String getPassword() { return properties.getProperty("db.password"); }
}
