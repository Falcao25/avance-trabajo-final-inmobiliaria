package com.inmobiliaria.controller;

import com.inmobiliaria.dao.UsuarioDAO;
import java.sql.SQLException;

import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet(urlPatterns = {"/login", "/logout"})
public class LoginServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        if ("/logout".equals(request.getServletPath())) {
            HttpSession session = request.getSession(false);
            if (session != null) {
                session.invalidate();
            }
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        RequestDispatcher dispatcher = request.getRequestDispatcher("/login.jsp");
        dispatcher.forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String usuario = valor(request.getParameter("usuario"));
        String password = request.getParameter("password");
        try {
            if (!usuario.isBlank() && password != null && !password.isEmpty()) {
                var cuenta = new UsuarioDAO().autenticar(usuario, password);
                if (cuenta != null) {
                    HttpSession session = request.getSession(true);
                    request.changeSessionId();
                    session.setAttribute("usuarioLogueado", cuenta.getCorreo());
                    response.sendRedirect(request.getContextPath() + "/admin/dashboard");
                    return;
                }
            }
            request.setAttribute("errorLogin", "Usuario o contraseña incorrectos, o cuenta inactiva.");
        } catch (SQLException | ExceptionInInitializerError | NoClassDefFoundError e) {
            getServletContext().log("No se pudo comprobar el acceso en MySQL", e);
            request.setAttribute("errorLogin", "No se pudo iniciar sesión. Intenta nuevamente en unos momentos.");
        }
        RequestDispatcher dispatcher = request.getRequestDispatcher("/login.jsp");
        dispatcher.forward(request, response);
    }

    private String valor(String texto) {
        return texto == null ? "" : texto.trim();
    }
}
