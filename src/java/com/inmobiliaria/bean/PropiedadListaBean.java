package com.inmobiliaria.bean;

import com.inmobiliaria.dao.PropiedadDAO;
import com.inmobiliaria.model.Propiedad;
import jakarta.annotation.PostConstruct;
import jakarta.faces.application.FacesMessage;
import jakarta.faces.context.FacesContext;
import jakarta.faces.view.ViewScoped;
import jakarta.inject.Named;
import java.io.Serializable;
import java.sql.SQLException;
import java.util.Collections;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

/** Listado de solo lectura. El DAO abre y cierra su conexion en cada consulta. */
@Named("propiedadListaBean")
@ViewScoped
public class PropiedadListaBean implements Serializable {

    private static final long serialVersionUID = 1L;
    private static final Logger LOGGER = Logger.getLogger(PropiedadListaBean.class.getName());
    private List<Propiedad> propiedades = Collections.emptyList();
    private boolean errorCarga;

    @PostConstruct
    public void inicializar() {
        cargar();
    }

    public void recargar() {
        cargar();
    }

    private void cargar() {
        try {
            // DAO local: no se serializan conexiones ni objetos de persistencia.
            propiedades = new PropiedadDAO().listar();
            errorCarga = false;
        } catch (SQLException | ExceptionInInitializerError | NoClassDefFoundError e) {
            propiedades = Collections.emptyList();
            errorCarga = true;
            LOGGER.log(Level.SEVERE, "No se pudo cargar el listado administrativo de propiedades", e);
            FacesContext.getCurrentInstance().addMessage(null, new FacesMessage(
                    FacesMessage.SEVERITY_ERROR,
                    "No se pudo cargar el listado de propiedades.",
                    "La fuente de datos no esta disponible. Intenta actualizar en unos momentos."));
        }
    }

    public List<Propiedad> getPropiedades() {
        return propiedades;
    }

    public int getCantidad() {
        return propiedades.size();
    }

    public boolean isErrorCarga() {
        return errorCarga;
    }

    public boolean isVacio() {
        return !errorCarga && propiedades.isEmpty();
    }
}
