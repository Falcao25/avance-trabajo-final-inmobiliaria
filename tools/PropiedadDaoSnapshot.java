import com.inmobiliaria.dao.PropiedadDAO;
import java.nio.charset.StandardCharsets;
import java.util.Base64;

/** Evidencia de solo lectura: invoca exactamente el DAO que utiliza el bean JSF. */
public class PropiedadDaoSnapshot {
    private static String texto(String value) {
        return Base64.getEncoder().encodeToString(value.getBytes(StandardCharsets.UTF_8));
    }

    public static void main(String[] args) throws Exception {
        for (var propiedad : new PropiedadDAO().listar()) {
            System.out.println(propiedad.getId() + "\t" + texto(propiedad.getTitulo()) + "\t"
                    + texto(propiedad.getTipo()) + "\t" + texto(propiedad.getTipoOperacion()) + "\t"
                    + texto(propiedad.getUbicacion()) + "\t" + propiedad.getPrecio().toPlainString()
                    + "\t" + texto(propiedad.getEstado()));
        }
    }
}
