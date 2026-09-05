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
import java.io.IOException;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

@WebServlet(urlPatterns = {"/propiedades", "/detalle-propiedad"})
public class PropiedadServlet extends HttpServlet {

    private final PropiedadDAO propiedadDAO = new PropiedadDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if ("/detalle-propiedad".equals(request.getServletPath())) {
            mostrarDetalle(request, response);
        } else {
            mostrarListado(request, response);
        }
    }

    private void mostrarListado(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        List<Propiedad> propiedades;
        try {
            propiedades = propiedadDAO.listar();
            request.setAttribute("fuenteDatos", "MySQL");
        } catch (SQLException e) {
            getServletContext().log("No fue posible leer propiedades desde MySQL", e);
            propiedades = MockData.obtenerPropiedades();
            request.setAttribute("fuenteDatos", "Mock de respaldo");
            request.setAttribute("errorBaseDatos",
                    "No se pudo conectar a MySQL. Se muestran datos mock de respaldo.");
        }

        request.setAttribute("propiedades", filtrarPropiedades(request, propiedades));
        RequestDispatcher dispatcher = request.getRequestDispatcher("/propiedades.jsp");
        dispatcher.forward(request, response);
    }

    private void mostrarDetalle(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        int id = parseInt(request.getParameter("id"), 1);
        Propiedad propiedad;
        try {
            propiedad = propiedadDAO.buscarPorId(id);
            if (propiedad == null) {
                propiedad = MockData.obtenerPropiedadPorId(id);
                request.setAttribute("fuenteDatos", "Mock de respaldo");
            } else {
                request.setAttribute("fuenteDatos", "MySQL");
            }
        } catch (SQLException e) {
            getServletContext().log("No fue posible leer el detalle desde MySQL", e);
            propiedad = MockData.obtenerPropiedadPorId(id);
            request.setAttribute("fuenteDatos", "Mock de respaldo");
            request.setAttribute("errorBaseDatos",
                    "No se pudo conectar a MySQL. Se muestra un detalle mock de respaldo.");
        }

        request.setAttribute("propiedad", propiedad);
        RequestDispatcher dispatcher = request.getRequestDispatcher("/detalle-propiedad.jsp");
        dispatcher.forward(request, response);
    }

    private List<Propiedad> filtrarPropiedades(HttpServletRequest request, List<Propiedad> propiedades) {
        String q = valor(request.getParameter("q"));
        String operacion = valor(request.getParameter("operacion"));
        String tipo = valor(request.getParameter("tipo"));
        String ubicacion = valor(request.getParameter("ubicacion"));
        String precio = valor(request.getParameter("precio"));
        String habitaciones = valor(request.getParameter("habitaciones"));

        List<Propiedad> filtradas = new ArrayList<>();
        for (Propiedad propiedad : propiedades) {
            if (!q.isEmpty() && !propiedad.getTitulo().toLowerCase().contains(q)
                    && !propiedad.getUbicacion().toLowerCase().contains(q)) {
                continue;
            }
            if (!operacion.isEmpty() && !"todas".equals(operacion)
                    && !propiedad.getTipoOperacion().toLowerCase().equals(operacion)) {
                continue;
            }
            if (!tipo.isEmpty() && !"todos".equals(tipo)
                    && !propiedad.getTipo().toLowerCase().equals(tipo)) {
                continue;
            }
            if (!ubicacion.isEmpty() && !propiedad.getUbicacion().toLowerCase().contains(ubicacion)) {
                continue;
            }
            if (!precio.isEmpty() && !coincidePrecio(precio, propiedad.getPrecio().doubleValue())) {
                continue;
            }
            if (!habitaciones.isEmpty() && !"cualquiera".equals(habitaciones)
                    && propiedad.getHabitaciones() < parseInt(habitaciones, 0)) {
                continue;
            }
            filtradas.add(propiedad);
        }
        return filtradas;
    }

    private boolean coincidePrecio(String rango, double precio) {
        return switch (rango) {
            case "0-150000" -> precio <= 150000;
            case "150000-250000" -> precio > 150000 && precio <= 250000;
            case "250000-400000" -> precio > 250000 && precio <= 400000;
            case "400000+" -> precio > 400000;
            default -> true;
        };
    }

    private String valor(String texto) {
        return texto == null ? "" : texto.trim().toLowerCase();
    }

    private int parseInt(String texto, int valorDefecto) {
        try {
            return Integer.parseInt(texto);
        } catch (Exception e) {
            return valorDefecto;
        }
    }
}
