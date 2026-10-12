import com.inmobiliaria.bean.PropiedadFormularioBean;
import com.inmobiliaria.config.Conexion;
import com.inmobiliaria.model.Propiedad;
import com.inmobiliaria.validation.PropiedadValidacion;
import jakarta.faces.application.FacesMessage;
import jakarta.faces.context.*;
import java.math.BigDecimal;
import java.sql.*;
import java.util.*;
import java.util.logging.*;

/** Pruebas de reglas y fallo de persistencia en una JVM aislada, sin escrituras. */
public class PropiedadFormularioTest {
    private static int comprobaciones;
    private static void verificar(boolean cumple, String mensaje) {
        if (!cumple) throw new AssertionError(mensaje);
        comprobaciones++;
        System.out.println("OK: " + mensaje);
    }
    private static class Contexto extends FacesContextWrapper {
        List<FacesMessage> mensajes = new ArrayList<>();
        boolean invalido;
        Contexto() { super(null); setCurrentInstance(this); }
        public void addMessage(String id, FacesMessage message) { mensajes.add(message); }
        public void validationFailed() { invalido = true; }
        public ExternalContext getExternalContext() {
            return new ExternalContextWrapper(null) {
                public Map<String, String> getRequestParameterMap() { return Map.of(); }
            };
        }
        public void release() { setCurrentInstance(null); }
    }
    public static void main(String[] args) throws Exception {
        if (args.length > 0 && args[0].equals("guard")) {
            try (var cn = Conexion.getConnection()) { throw new AssertionError("El perfil TEST permitio la base principal"); }
            catch (SQLException expected) { verificar(expected.getMessage().contains("base aislada"), "Guardia TEST rechaza la base principal antes de conectar"); }
            return;
        }
        PropiedadFormularioBean bean = new PropiedadFormularioBean();
        bean.inicializar();
        Propiedad p = bean.getPropiedad();
        p.setTitulo("APF2_TEST_REGLAS"); p.setUbicacion("Pruebas aisladas"); p.setPrecio(BigDecimal.ZERO);
        verificar(PropiedadValidacion.validar(p).isEmpty(), "Precio y area cero siguen permitidos como en APF1");
        p.setTitulo("😀".repeat(180));
        verificar(PropiedadValidacion.validar(p).isEmpty(), "VARCHAR cuenta caracteres Unicode segun el esquema");
        p.setDescripcion("😀".repeat(16384));
        verificar(!PropiedadValidacion.validar(p).isEmpty(), "TEXT rechaza mas de 65535 bytes UTF-8");
        p.setDescripcion(""); p.setTitulo("APF2_TEST_REGLAS"); p.setPrecio(new BigDecimal("12.345"));
        PropiedadValidacion.normalizar(p);
        verificar(p.getPrecio().equals(new BigDecimal("12.35")), "Decimales se normalizan a escala MySQL sin exigir precision nueva");
        for (String id : List.of("0", "-1", "abc", "2147483648")) {
            try { PropiedadValidacion.idPositivo(id); throw new AssertionError("ID invalido aceptado"); }
            catch (IllegalArgumentException expected) { verificar(true, "ID invalido rechazado: " + id); }
        }
        Class.forName("com.mysql.cj.jdbc.Driver");
        for (Driver driver : DriverManager.drivers().toList()) DriverManager.deregisterDriver(driver);
        DriverManager.registerDriver(new Driver() {
            public boolean acceptsURL(String url) { return url.startsWith("jdbc:mysql:"); }
            public Connection connect(String url, Properties info) throws SQLException { throw new SQLException("Detalle interno sensible de prueba"); }
            public DriverPropertyInfo[] getPropertyInfo(String url, Properties info) { return new DriverPropertyInfo[0]; }
            public int getMajorVersion() { return 1; }
            public int getMinorVersion() { return 0; }
            public boolean jdbcCompliant() { return false; }
            public Logger getParentLogger() { return Logger.getGlobal(); }
        });
        Logger.getLogger(PropiedadFormularioBean.class.getName()).setLevel(Level.OFF);
        Contexto contexto = new Contexto();
        try {
            bean.preparar();
            verificar(bean.guardar() == null && contexto.invalido, "Fallo JDBC permanece en el formulario sin navegar");
            verificar(bean.getPropiedad().getTitulo().equals("APF2_TEST_REGLAS") && bean.getPropiedad().getPrecio().equals(new BigDecimal("12.35")), "Fallo JDBC conserva los valores del modelo");
            verificar(contexto.mensajes.size() == 1 && !contexto.mensajes.get(0).getSummary().contains("sensible"), "Mensaje de fallo no expone informacion interna");
        } finally { contexto.release(); }
        System.out.println("Comprobaciones aisladas: " + comprobaciones);
    }
}
