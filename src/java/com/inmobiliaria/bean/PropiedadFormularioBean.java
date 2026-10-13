package com.inmobiliaria.bean;

import com.inmobiliaria.dao.PropiedadDAO;
import com.inmobiliaria.model.Propiedad;
import com.inmobiliaria.validation.PropiedadValidacion;
import com.inmobiliaria.util.ImagenAlmacen;
import jakarta.annotation.PostConstruct;
import jakarta.faces.application.FacesMessage;
import jakarta.faces.context.FacesContext;
import jakarta.faces.component.UIComponent;
import jakarta.faces.validator.ValidatorException;
import jakarta.faces.view.ViewScoped;
import jakarta.inject.Named;
import jakarta.servlet.http.Part;
import java.io.IOException;
import java.io.Serializable;
import java.sql.SQLException;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

@Named("propiedadFormularioBean")
@ViewScoped
public class PropiedadFormularioBean implements Serializable {
    private static final long serialVersionUID = 1L;
    private static final Logger LOGGER = Logger.getLogger(PropiedadFormularioBean.class.getName());
    private Propiedad propiedad;
    private String id;
    private Integer idEdicion;
    private boolean edicion;
    private boolean habilitado;
    private transient Part imagenArchivo;

    @PostConstruct
    public void inicializar() {
        propiedad = new Propiedad();
        propiedad.setTipo("CASA");
        propiedad.setTipoOperacion("VENTA");
        propiedad.setEstado("DISPONIBLE");
    }

    /** viewAction inicial: no vuelve a cargar ni sustituye datos durante postbacks. */
    public void preparar() {
        edicion = FacesContext.getCurrentInstance().getExternalContext().getRequestParameterMap().containsKey("id");
        if (!edicion) { habilitado = true; return; }
        try {
            int solicitado = PropiedadValidacion.idPositivo(id);
            Propiedad encontrada = new PropiedadDAO().buscarPorId(solicitado);
            if (encontrada == null) {
                error("La propiedad solicitada no existe.");
                return;
            }
            propiedad = encontrada;
            idEdicion = solicitado;
            habilitado = true;
        } catch (IllegalArgumentException e) {
            error(e.getMessage());
        } catch (SQLException | ExceptionInInitializerError | NoClassDefFoundError e) {
            LOGGER.log(Level.SEVERE, "No se pudo cargar la propiedad para el formulario JSF", e);
            error("No se pudo cargar la propiedad. Intenta nuevamente en unos momentos.");
        }
    }

    public String guardar() {
        if (!habilitado) { error("El formulario no está disponible. Regresa al listado."); return null; }
        List<String> errores = PropiedadValidacion.validar(propiedad);
        if (!errores.isEmpty()) {
            errores.forEach(this::error);
            return null;
        }
        PropiedadValidacion.normalizar(propiedad);
        String imagenAnterior = propiedad.getImagenPrincipal();
        String imagenNueva = null;
        boolean guardada = false;
        try {
            if (imagenArchivo != null && imagenArchivo.getSize() > 0) {
                imagenNueva = ImagenAlmacen.guardar(imagenArchivo);
                propiedad.setImagenPrincipal(imagenNueva);
            }
            PropiedadDAO dao = new PropiedadDAO();
            if (edicion) {
                // El ID guardado en el estado de vista no depende de un input o parametro POST.
                propiedad.setId(idEdicion);
                if (!dao.actualizar(propiedad)) {
                    habilitado = false;
                    error("La propiedad ya no existe. No se realizaron cambios.");
                    return null;
                }
            } else {
                propiedad.setId(0);
                int creado = dao.guardar(propiedad);
                if (creado <= 0) throw new SQLException("No se obtuvo la clave generada.");
                propiedad.setId(creado);
            }
            guardada = true;
            FacesContext contexto = FacesContext.getCurrentInstance();
            contexto.addMessage(null, new FacesMessage(FacesMessage.SEVERITY_INFO,
                    edicion ? "Propiedad actualizada correctamente." : "Propiedad registrada correctamente.", ""));
            contexto.getExternalContext().getFlash().setKeepMessages(true);
            return "/admin/propiedades-jsf?faces-redirect=true";
        } catch (IOException | IllegalArgumentException e) {
            LOGGER.log(Level.WARNING, "No se pudo subir la imagen de la propiedad", e);
            error(e instanceof IllegalArgumentException ? e.getMessage()
                    : "No se pudo subir la imagen. Selecciónala nuevamente e intenta guardar.");
            return null;
        } catch (SQLException | ExceptionInInitializerError | NoClassDefFoundError e) {
            LOGGER.log(Level.SEVERE, "No se pudo guardar la propiedad desde JSF", e);
            error("No se pudo guardar la propiedad. Conservamos los datos para que puedas intentarlo nuevamente.");
            return null;
        } finally {
            imagenArchivo = null;
            if (!guardada && imagenNueva != null) {
                propiedad.setImagenPrincipal(imagenAnterior);
                try {
                    ImagenAlmacen.eliminar(imagenNueva);
                } catch (IOException e) {
                    LOGGER.log(Level.WARNING, "No se pudo eliminar una imagen sin propiedad", e);
                }
            }
        }
    }

    public void validarImagen(FacesContext contexto, UIComponent componente, Object valor) {
        if (!(valor instanceof Part archivo) || archivo.getSize() == 0) return;
        try {
            ImagenAlmacen.validar(archivo);
        } catch (IOException | IllegalArgumentException e) {
            throw new ValidatorException(new FacesMessage(FacesMessage.SEVERITY_ERROR,
                    e instanceof IllegalArgumentException ? e.getMessage()
                            : "No se pudo leer la imagen. Selecciona un archivo JPG, PNG o GIF válido.", null));
        }
    }

    private void error(String mensaje) {
        FacesContext contexto = FacesContext.getCurrentInstance();
        contexto.addMessage(null, new FacesMessage(FacesMessage.SEVERITY_ERROR, mensaje, null));
        contexto.validationFailed();
    }

    public Propiedad getPropiedad() { return propiedad; }
    public Part getImagenArchivo() { return imagenArchivo; }
    public void setImagenArchivo(Part imagenArchivo) { this.imagenArchivo = imagenArchivo; }
    public String getId() { return id; }
    public void setId(String id) { this.id = id; }
    public boolean isEdicion() { return edicion; }
    public boolean isHabilitado() { return habilitado; }
    public List<String> getTipos() { return PropiedadValidacion.TIPOS; }
    public List<String> getOperaciones() { return PropiedadValidacion.OPERACIONES; }
    public List<String> getEstados() { return PropiedadValidacion.ESTADOS; }
}
