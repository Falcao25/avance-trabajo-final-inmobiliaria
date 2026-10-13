package com.inmobiliaria.controller;

import com.inmobiliaria.dao.ContactoDAO;
import java.sql.SQLException;
import java.nio.charset.StandardCharsets;

import com.inmobiliaria.model.Contacto;
import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.time.LocalDateTime;

@WebServlet(urlPatterns = {"/contacto"})
public class ContactoServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        var session = request.getSession(false);
        if (session != null) {
            request.setAttribute("mensajeExito", session.getAttribute("mensajeContacto"));
            session.removeAttribute("mensajeContacto");
        }
        RequestDispatcher dispatcher = request.getRequestDispatcher("/contacto.jsp");
        dispatcher.forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        Contacto contacto = new Contacto();
        contacto.setNombre(valor(request.getParameter("nombre")));
        contacto.setCorreo(valor(request.getParameter("correo")));
        contacto.setTelefono(valor(request.getParameter("telefono")));
        contacto.setMensaje(valor(request.getParameter("mensaje")));
        contacto.setFecha(LocalDateTime.now());

        request.setAttribute("contacto", contacto);
        boolean valido = !contacto.getNombre().isBlank() && contacto.getNombre().codePointCount(0, contacto.getNombre().length()) <= 120
                && contacto.getCorreo().matches("[^\\s@]+@[^\\s@]+\\.[^\\s@]+") && contacto.getCorreo().length() <= 160
                && contacto.getTelefono().length() <= 30 && !contacto.getMensaje().isBlank()
                && contacto.getMensaje().getBytes(StandardCharsets.UTF_8).length <= 65535;
        if (!valido) {
            request.setAttribute("errorContacto", "Completa nombre, correo válido y mensaje, respetando las longitudes permitidas.");
        } else {
            try {
                if (new ContactoDAO().guardar(contacto) <= 0) throw new SQLException("No se obtuvo el ID del contacto.");
                request.getSession(true).setAttribute("mensajeContacto", "Gracias por escribirnos. Tu mensaje fue guardado correctamente.");
                response.sendRedirect(request.getContextPath() + "/contacto");
                return;
            } catch (SQLException | ExceptionInInitializerError | NoClassDefFoundError e) {
                getServletContext().log("No se pudo guardar el contacto en MySQL", e);
                request.setAttribute("errorContacto", "No se pudo guardar el mensaje. Conservamos tus datos para que puedas intentarlo nuevamente.");
            }
        }
        RequestDispatcher dispatcher = request.getRequestDispatcher("/contacto.jsp");
        dispatcher.forward(request, response);
    }

    private String valor(String texto) { return texto == null ? "" : texto.trim(); }
}
