package com.inmobiliaria.controller;

import com.inmobiliaria.model.MockData;
import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet(urlPatterns = {
    "/admin/dashboard",
    "/admin/propiedades",
    "/admin/nueva-propiedad",
    "/admin/editar-propiedad",
    "/admin/clientes",
    "/admin/usuarios"
})
public class AdminServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        if (requiereLogin(request, response)) {
            return;
        }

        String path = request.getServletPath();
        switch (path) {
            case "/admin/dashboard" -> {
                request.setAttribute("propiedades", MockData.obtenerPropiedades());
                request.setAttribute("clientes", MockData.obtenerClientes());
                request.setAttribute("usuarios", MockData.obtenerUsuarios());
                forward(request, response, "/admin/dashboard.jsp");
            }
            case "/admin/propiedades" -> {
                request.setAttribute("propiedades", MockData.obtenerPropiedades());
                forward(request, response, "/admin/propiedades.jsp");
            }
            case "/admin/nueva-propiedad" -> forward(request, response, "/admin/nueva-propiedad.jsp");
            case "/admin/editar-propiedad" -> {
                int id = parseInt(request.getParameter("id"), 1);
                request.setAttribute("propiedad", MockData.obtenerPropiedadPorId(id));
                forward(request, response, "/admin/editar-propiedad.jsp");
            }
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
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        if (requiereLogin(request, response)) {
            return;
        }

        String path = request.getServletPath();
        request.setAttribute("mensajeExito", "Accion recibida en modo demo. La integracion con MySQL se activara despues.");

        switch (path) {
            case "/admin/nueva-propiedad" -> forward(request, response, "/admin/nueva-propiedad.jsp");
            case "/admin/editar-propiedad" -> {
                int id = parseInt(request.getParameter("id"), 1);
                request.setAttribute("propiedad", MockData.obtenerPropiedadPorId(id));
                forward(request, response, "/admin/editar-propiedad.jsp");
            }
            case "/admin/propiedades" -> {
                request.setAttribute("propiedades", MockData.obtenerPropiedades());
                forward(request, response, "/admin/propiedades.jsp");
            }
            default -> response.sendRedirect(request.getContextPath() + "/admin/dashboard");
        }
    }

    private boolean requiereLogin(HttpServletRequest request, HttpServletResponse response) throws IOException {
        HttpSession session = request.getSession(false);
        if (session != null && session.getAttribute("usuarioLogueado") != null) {
            return false;
        }
        response.sendRedirect(request.getContextPath() + "/login");
        return true;
    }

    private void forward(HttpServletRequest request, HttpServletResponse response, String destino) throws ServletException, IOException {
        RequestDispatcher dispatcher = request.getRequestDispatcher(destino);
        dispatcher.forward(request, response);
    }

    private int parseInt(String texto, int valorDefecto) {
        try {
            return Integer.parseInt(texto);
        } catch (Exception e) {
            return valorDefecto;
        }
    }
}
