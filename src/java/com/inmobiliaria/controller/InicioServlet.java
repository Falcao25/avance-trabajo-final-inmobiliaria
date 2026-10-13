package com.inmobiliaria.controller;

import com.inmobiliaria.dao.PropiedadDAO;
import com.inmobiliaria.model.Propiedad;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.SQLException;
import java.util.Collections;

@WebServlet("/inicio")
public class InicioServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        try {
            var propiedades = new PropiedadDAO().listar();
            var destacadas = propiedades.stream().filter(Propiedad::isDestacada).limit(3).toList();
            request.setAttribute("destacadas", destacadas);
            request.setAttribute("portada", !destacadas.isEmpty() ? destacadas.get(0) : propiedades.isEmpty() ? null : propiedades.get(0));
            request.setAttribute("cantidadPropiedades", propiedades.size());
            request.setAttribute("cantidadUbicaciones", propiedades.stream().map(Propiedad::getUbicacion)
                    .filter(u -> u != null && !u.isBlank()).map(String::trim).distinct().count());
            request.setAttribute("cantidadDisponibles", propiedades.stream().filter(p -> "DISPONIBLE".equals(p.getEstado())).count());
        } catch (SQLException | ExceptionInInitializerError | NoClassDefFoundError e) {
            getServletContext().log("No se pudieron cargar las propiedades de Inicio", e);
            request.setAttribute("destacadas", Collections.emptyList());
            request.setAttribute("errorBaseDatos", "No se pudieron cargar las propiedades. Intenta nuevamente en unos momentos.");
        }
        request.getRequestDispatcher("/WEB-INF/views/inicio.jsp").forward(request, response);
    }
}
