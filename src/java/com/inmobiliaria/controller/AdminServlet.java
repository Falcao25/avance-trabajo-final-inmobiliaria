package com.inmobiliaria.controller;

import com.inmobiliaria.dao.PropiedadDAO;
import com.inmobiliaria.model.MockData;
import com.inmobiliaria.model.Propiedad;
import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.math.BigDecimal;
import java.sql.SQLException;
import java.util.Collections;

@WebServlet(urlPatterns = {
    "/admin", "/admin/dashboard", "/admin/propiedades", "/admin/nueva-propiedad",
    "/admin/editar-propiedad", "/admin/clientes", "/admin/usuarios"
})
public class AdminServlet extends HttpServlet {

    private final PropiedadDAO propiedadDAO = new PropiedadDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (requiereLogin(request, response)) return;

        switch (request.getServletPath()) {
            case "/admin" -> response.sendRedirect(request.getContextPath() + "/admin/dashboard");
            case "/admin/dashboard" -> mostrarDashboard(request, response);
            case "/admin/propiedades" -> mostrarPropiedades(request, response);
            case "/admin/nueva-propiedad" -> forward(request, response, "/admin/nueva-propiedad.jsp");
            case "/admin/editar-propiedad" -> mostrarEdicion(request, response);
            case "/admin/clientes" -> {
                request.setAttribute("clientes", MockData.obtenerClientes());
                forward(request, response, "/admin/clientes.jsp");
            }
            case "/admin/usuarios" -> {
                request.setAttribute("usuarios", MockData.obtenerUsuarios());
                forward(request, response, "/admin/usuarios.jsp");
            }
            default -> response.sendRedirect(request.getContextPath() + "/admin/dashboard");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (requiereLogin(request, response)) return;
        request.setCharacterEncoding("UTF-8");

        switch (request.getServletPath()) {
            case "/admin/dashboard", "/admin/nueva-propiedad" -> guardarPropiedad(request, response);
            case "/admin/editar-propiedad" -> actualizarPropiedad(request, response);
            case "/admin/propiedades" -> eliminarPropiedad(request, response);
            default -> response.sendRedirect(request.getContextPath() + "/admin/dashboard");
        }
    }

    private void guardarPropiedad(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            Propiedad propiedad = leerPropiedad(request);
            int id = propiedadDAO.guardar(propiedad);
            if (id <= 0) throw new SQLException("MySQL no devolvio el ID creado.");
            guardarMensaje(request.getSession(), "Propiedad guardada correctamente en MySQL.");
            response.sendRedirect(request.getContextPath() + "/admin/propiedades");
        } catch (IllegalArgumentException e) {
            request.setAttribute("errorBaseDatos", e.getMessage());
            request.setAttribute("propiedad", propiedadDesdeFormulario(request));
            forward(request, response, "/admin/nueva-propiedad.jsp");
        } catch (SQLException e) {
            getServletContext().log("No fue posible guardar la propiedad en MySQL", e);
            request.setAttribute("errorBaseDatos", "No se pudo guardar la propiedad. Verifica la conexión y los datos.");
            request.setAttribute("propiedad", propiedadDesdeFormulario(request));
            forward(request, response, "/admin/nueva-propiedad.jsp");
        }
    }

    private void actualizarPropiedad(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            Propiedad propiedad = leerPropiedad(request);
            propiedad.setId(parseRequiredInt(request.getParameter("id"), "El ID de la propiedad no es válido."));
            if (!propiedadDAO.actualizar(propiedad)) throw new SQLException("Propiedad no encontrada.");
            guardarMensaje(request.getSession(), "Propiedad actualizada correctamente en MySQL.");
            response.sendRedirect(request.getContextPath() + "/admin/propiedades");
        } catch (IllegalArgumentException | SQLException e) {
            getServletContext().log("No fue posible actualizar la propiedad en MySQL", e);
            request.setAttribute("errorBaseDatos", "No se pudo actualizar la propiedad en MySQL.");
            forward(request, response, "/admin/editar-propiedad.jsp");
        }
    }

    private void eliminarPropiedad(HttpServletRequest request, HttpServletResponse response) throws IOException {
        if (!"eliminar".equals(request.getParameter("accion"))) {
            response.sendRedirect(request.getContextPath() + "/admin/propiedades");
            return;
        }
        try {
            propiedadDAO.eliminar(parseRequiredInt(request.getParameter("id"), "El ID no es válido."));
            guardarMensaje(request.getSession(), "Propiedad eliminada correctamente.");
        } catch (IllegalArgumentException | SQLException e) {
            getServletContext().log("No fue posible eliminar la propiedad", e);
            guardarMensaje(request.getSession(), "No se pudo eliminar la propiedad.");
        }
        response.sendRedirect(request.getContextPath() + "/admin/propiedades");
    }

    private void mostrarDashboard(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        cargarPropiedades(request);
        request.setAttribute("clientes", MockData.obtenerClientes());
        request.setAttribute("usuarios", MockData.obtenerUsuarios());
        forward(request, response, "/admin/dashboard.jsp");
    }

    private void mostrarPropiedades(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        cargarPropiedades(request);
        cargarMensaje(request);
        forward(request, response, "/admin/propiedades.jsp");
    }

    private void mostrarEdicion(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            int id = parseRequiredInt(request.getParameter("id"), "El ID no es válido.");
            Propiedad propiedad = propiedadDAO.buscarPorId(id);
            if (propiedad == null) {
                response.sendRedirect(request.getContextPath() + "/admin/propiedades");
                return;
            }
            request.setAttribute("propiedad", propiedad);
        } catch (IllegalArgumentException | SQLException e) {
            getServletContext().log("No fue posible cargar la propiedad para editar", e);
            request.setAttribute("errorBaseDatos", "No se pudo cargar la propiedad desde MySQL.");
        }
        forward(request, response, "/admin/editar-propiedad.jsp");
    }

    private void cargarPropiedades(HttpServletRequest request) {
        try {
            request.setAttribute("propiedades", propiedadDAO.listar());
            request.setAttribute("fuenteDatos", "MySQL");
        } catch (SQLException e) {
            getServletContext().log("No fue posible leer propiedades desde MySQL", e);
            request.setAttribute("propiedades", Collections.emptyList());
            request.setAttribute("fuenteDatos", "MySQL no disponible");
            request.setAttribute("errorBaseDatos", "No se pudo conectar a MySQL. El listado está vacío.");
        }
    }

    private Propiedad leerPropiedad(HttpServletRequest request) {
        Propiedad propiedad = new Propiedad();
        propiedad.setTitulo(requerido(request, "titulo", "El título es obligatorio."));
        propiedad.setDescripcion(valor(request.getParameter("descripcion")));
        propiedad.setUbicacion(requerido(request, "ubicacion", "La ubicación es obligatoria."));
        propiedad.setDireccion(valor(request.getParameter("direccion")));
        propiedad.setTipo(requerido(request, "tipo", "El tipo es obligatorio.").toUpperCase());
        propiedad.setTipoOperacion(requerido(request, "tipoOperacion", "La operación es obligatoria.").toUpperCase());
        propiedad.setPrecio(parseDecimal(request.getParameter("precio"), "El precio debe ser un número válido."));
        propiedad.setArea(parseDouble(request.getParameter("area"), "El área debe ser un número válido."));
        propiedad.setHabitaciones(parseNonNegativeInt(request.getParameter("habitaciones"), "Las habitaciones deben ser un número válido."));
        propiedad.setBanos(parseNonNegativeInt(request.getParameter("banos"), "Los baños deben ser un número válido."));
        propiedad.setImagenPrincipal(valor(request.getParameter("imagen")));
        String estado = valor(request.getParameter("estado"));
        propiedad.setEstado(estado.isEmpty() ? "DISPONIBLE" : estado.toUpperCase());
        propiedad.setDestacada(request.getParameter("destacada") != null);
        return propiedad;
    }

    private Propiedad propiedadDesdeFormulario(HttpServletRequest request) {
        try { return leerPropiedad(request); } catch (IllegalArgumentException e) { return new Propiedad(); }
    }

    private String requerido(HttpServletRequest request, String nombre, String mensaje) {
        String resultado = valor(request.getParameter(nombre));
        if (resultado.isEmpty()) throw new IllegalArgumentException(mensaje);
        return resultado;
    }

    private String valor(String texto) { return texto == null ? "" : texto.trim(); }

    private BigDecimal parseDecimal(String texto, String mensaje) {
        try {
            BigDecimal resultado = new BigDecimal(valor(texto));
            if (resultado.signum() < 0) throw new NumberFormatException();
            return resultado;
        } catch (NumberFormatException e) { throw new IllegalArgumentException(mensaje); }
    }

    private double parseDouble(String texto, String mensaje) {
        try {
            double resultado = Double.parseDouble(valor(texto));
            if (resultado < 0) throw new NumberFormatException();
            return resultado;
        } catch (NumberFormatException e) { throw new IllegalArgumentException(mensaje); }
    }

    private int parseNonNegativeInt(String texto, String mensaje) {
        if (valor(texto).isEmpty()) return 0;
        int resultado = parseRequiredInt(texto, mensaje);
        if (resultado < 0) throw new IllegalArgumentException(mensaje);
        return resultado;
    }

    private int parseRequiredInt(String texto, String mensaje) {
        try { return Integer.parseInt(valor(texto)); }
        catch (NumberFormatException e) { throw new IllegalArgumentException(mensaje); }
    }

    private void guardarMensaje(HttpSession session, String mensaje) { session.setAttribute("mensajeExito", mensaje); }

    private void cargarMensaje(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session != null) {
            request.setAttribute("mensajeExito", session.getAttribute("mensajeExito"));
            session.removeAttribute("mensajeExito");
        }
    }

    private boolean requiereLogin(HttpServletRequest request, HttpServletResponse response) throws IOException {
        HttpSession session = request.getSession(false);
        if (session != null && session.getAttribute("usuarioLogueado") != null) return false;
        response.sendRedirect(request.getContextPath() + "/login");
        return true;
    }

    private void forward(HttpServletRequest request, HttpServletResponse response, String destino)
            throws ServletException, IOException {
        RequestDispatcher dispatcher = request.getRequestDispatcher(destino);
        dispatcher.forward(request, response);
    }
}
