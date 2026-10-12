import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.security.MessageDigest;
import java.sql.*;
import java.util.*;
import com.inmobiliaria.config.DatabaseSettings;

/** Operaciones limitadas: auditar principal (SELECT), crear esquema TEST y consultar TEST. */
public class Phase3Database {
    private static final String TEST = "inmobiliaria_apf2_test";
    private static Connection conectar(String database) throws Exception {
        DatabaseSettings config = DatabaseSettings.load();
        return DriverManager.getConnection("jdbc:mysql://" + config.getHost() + ":" + config.getPort() + "/" + database
                + "?useSSL=false&serverTimezone=UTC&allowPublicKeyRetrieval=true", config.getUser(), config.getPassword());
    }
    private static void verificarTest(Connection cn) throws SQLException {
        try (var st = cn.createStatement(); var rs = st.executeQuery("SELECT DATABASE()")) {
            if (!rs.next() || !TEST.equals(rs.getString(1))) throw new SQLException("Se rechazo una operacion fuera de la base TEST.");
        }
    }
    private static void hashTexto(MessageDigest digest, String texto) {
        byte[] bytes = texto == null ? new byte[0] : texto.getBytes(StandardCharsets.UTF_8);
        digest.update((texto == null ? "NULL:" : bytes.length + ":").getBytes(StandardCharsets.UTF_8));
        digest.update(bytes);
    }
    public static void main(String[] args) throws Exception {
        if (args.length == 0) throw new IllegalArgumentException("Usa prepare, audit, marker o count.");
        if (args[0].equals("prepare")) {
            try (Connection cn = conectar("")) {
                try (var st = cn.createStatement()) {
                    st.executeUpdate("CREATE DATABASE IF NOT EXISTS inmobiliaria_apf2_test CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci");
                }
                cn.setCatalog(TEST);
                String schema = Files.readString(Path.of("database/inmobiliaria.sql"));
                for (String statement : schema.split(";")) {
                    if (!statement.trim().startsWith("CREATE TABLE IF NOT EXISTS")) continue;
                    verificarTest(cn);
                    try (var st = cn.createStatement()) { st.executeUpdate(statement); }
                }
                verificarTest(cn);
                System.out.println("OK esquema y relaciones creados en " + TEST + "; sin copiar registros principales.");
            }
        } else if (args[0].equals("audit")) {
            try (Connection cn = conectar("inmobiliaria")) {
                cn.setReadOnly(true);
                for (String table : List.of("usuarios", "clientes", "propiedades", "contactos")) {
                    MessageDigest digest = MessageDigest.getInstance("SHA-256");
                    try (var st = cn.createStatement(); var rs = st.executeQuery("SHOW CREATE TABLE " + table)) {
                        rs.next(); hashTexto(digest, rs.getString(2));
                    }
                    int count = 0;
                    try (var st = cn.createStatement(); var rs = st.executeQuery("SELECT * FROM " + table + " ORDER BY id")) {
                        while (rs.next()) {
                            count++;
                            for (int column = 1; column <= rs.getMetaData().getColumnCount(); column++) hashTexto(digest, rs.getString(column));
                        }
                    }
                    System.out.println(table + "\t" + count + "\t" + HexFormat.of().formatHex(digest.digest()));
                }
            }
        } else {
            try (Connection cn = conectar(TEST)) {
                verificarTest(cn);
                cn.setReadOnly(true);
                if (args[0].equals("count")) {
                    try (var st = cn.createStatement(); var rs = st.executeQuery("SELECT COUNT(*) FROM propiedades")) { rs.next(); System.out.println(rs.getInt(1)); }
                } else if (args[0].equals("marker") && args.length == 2 && args[1].startsWith("APF2_TEST_")) {
                    try (var ps = cn.prepareStatement("SELECT id, titulo, precio, estado, descripcion FROM propiedades WHERE titulo LIKE ? ORDER BY id")) {
                        ps.setString(1, args[1] + "%");
                        try (var rs = ps.executeQuery()) {
                            while (rs.next()) System.out.println(rs.getInt(1) + "\t" + rs.getString(2) + "\t" + rs.getBigDecimal(3).toPlainString() + "\t" + rs.getString(4) + "\t" + rs.getString(5));
                        }
                    }
                } else throw new IllegalArgumentException("Operacion no permitida.");
            }
        }
    }
}
