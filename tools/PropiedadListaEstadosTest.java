import com.inmobiliaria.bean.PropiedadListaBean;
import jakarta.faces.application.FacesMessage;
import jakarta.faces.context.FacesContext;
import jakarta.faces.context.FacesContextWrapper;
import java.io.ByteArrayOutputStream;
import java.io.ObjectOutputStream;
import java.lang.reflect.Proxy;
import java.sql.*;
import java.util.*;
import java.util.logging.Level;
import java.util.logging.Logger;

/** Prueba aislada en otra JVM: no detiene MySQL ni modifica datos o credenciales. */
public class PropiedadListaEstadosTest {
    private static int consultas;
    private static boolean fallo;

    private static class Contexto extends FacesContextWrapper {
        final List<FacesMessage> mensajes = new ArrayList<>();
        Contexto() { super(null); setCurrentInstance(this); }
        @Override public void addMessage(String id, FacesMessage mensaje) { mensajes.add(mensaje); }
        @Override public FacesContext getWrapped() { throw new UnsupportedOperationException(); }
        @Override public void release() { setCurrentInstance(null); }
    }

    private static Object vacio(Class<?> api) {
        return Proxy.newProxyInstance(api.getClassLoader(), new Class<?>[]{api}, (proxy, method, args) -> {
            if (method.getName().equals("prepareStatement")) {
                consultas++;
                if (fallo) throw new SQLException("Detalle SQL interno que no debe mostrarse");
                return vacio(PreparedStatement.class);
            }
            if (method.getName().equals("executeQuery")) return vacio(ResultSet.class);
            if (method.getReturnType() == boolean.class) return false;
            return null;
        });
    }

    private static void comprobar(boolean cumple, String mensaje) {
        if (!cumple) throw new AssertionError(mensaje);
        System.out.println("OK: " + mensaje);
    }

    public static void main(String[] args) throws Exception {
        // La sustitucion afecta solo a DriverManager de esta JVM de prueba.
        Class.forName("com.mysql.cj.jdbc.Driver");
        for (Driver driver : DriverManager.drivers().toList()) DriverManager.deregisterDriver(driver);
        DriverManager.registerDriver(new Driver() {
            public boolean acceptsURL(String url) { return url.startsWith("jdbc:mysql:"); }
            public Connection connect(String url, Properties info) { return acceptsURL(url) ? (Connection) vacio(Connection.class) : null; }
            public DriverPropertyInfo[] getPropertyInfo(String url, Properties info) { return new DriverPropertyInfo[0]; }
            public int getMajorVersion() { return 1; }
            public int getMinorVersion() { return 0; }
            public boolean jdbcCompliant() { return false; }
            public Logger getParentLogger() { return Logger.getGlobal(); }
        });
        Logger.getLogger(PropiedadListaBean.class.getName()).setLevel(Level.OFF);
        Contexto contexto = new Contexto();
        try {
            PropiedadListaBean bean = new PropiedadListaBean();
            bean.inicializar();
            comprobar(bean.isVacio() && !bean.isErrorCarga() && contexto.mensajes.isEmpty(), "Consulta sin filas produce estado vacio sin error");
            bean.getPropiedades(); bean.getCantidad(); bean.isVacio();
            comprobar(consultas == 1, "Getters no repiten consultas al DAO");
            fallo = true;
            bean.recargar();
            comprobar(bean.isErrorCarga() && !bean.isVacio() && bean.getCantidad() == 0, "Fallo JDBC no se presenta como inventario vacio");
            comprobar(contexto.mensajes.size() == 1 && contexto.mensajes.get(0).getSeverity() == FacesMessage.SEVERITY_ERROR, "Fallo JDBC genera FacesMessage de error");
            comprobar(!contexto.mensajes.get(0).getDetail().contains("SQL interno"), "Mensaje al usuario no expone detalles SQL");
            fallo = false;
            contexto.mensajes.clear();
            bean.recargar();
            comprobar(bean.isVacio() && !bean.isErrorCarga(), "Actualizar permite recuperarse del fallo");
            try (ObjectOutputStream salida = new ObjectOutputStream(new ByteArrayOutputStream())) { salida.writeObject(bean); }
            comprobar(true, "Bean de alcance de vista puede serializarse sin conexiones o DAO");
        } finally { contexto.release(); }
    }
}
