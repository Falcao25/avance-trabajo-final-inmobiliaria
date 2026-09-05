package com.inmobiliaria.controller;

import com.inmobiliaria.model.MockData;
import com.inmobiliaria.model.Propiedad;
import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

@WebServlet(urlPatterns = {"/propiedades", "/detalle-propiedad"})
public class PropiedadServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String servletPath = request.getServletPath();
        if ("/detalle-propiedad".equals(servletPath)) {
            mostrarDetalle(request, response);
        } else {
            mostrarListado(request, response);
        }
    }

    private void mostrarListado(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        List<Propiedad> propiedades = filtrarPropiedades(request);
        request.setAttribute("propiedades", propiedades);
        RequestDispatcher dispatcher = request.getRequestDispatcher("/propiedades.jsp");
        dispatcher.forward(request, response);
    }

    private void mostrarDetalle(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        int id = parseInt(request.getParameter("id"), 1);
        request.setAttribute("propiedad", MockData.obtenerPropiedadPorId(id));
        RequestDispatcher dispatcher = request.getRequestDispatcher("/detalle-propiedad.jsp");
        dispatcher.forward(request, response);
    }

    private List<Propiedad> filtrarPropiedades(HttpServletRequest request) {
        String q = valor(request.getParameter("q"));
        String operacion = valor(request.getParameter("operacion"));
        String tipo = valor(request.getParameter("tipo"));
        String ubicacion = valor(request.getParameter("ubicacion"));
        String precio = valor(request.getParameter("precio"));
        String habitaciones = valor(request.getParameter("habitaciones"));

        List<Propiedad> filtradas = new ArrayList<>();
        for (Propiedad propiedad : MockData.obtenerPropiedades()) {
            if (!q.isEmpty() && !propiedad.getTitulo().toLowerCase().contains(q) && !propiedad.getUbicacion().toLowerCase().contains(q)) {
                continue;
            }
            if (!operacion.isEmpty() && !"todas".equals(operacion) && !propiedad.getTipoOperacion().toLowerCase().equals(operacion)) {
                continue;
            }
            if (!tipo.isEmpty() && !"todos".equals(tipo) && !propiedad.getTipo().toLowerCase().equals(tipo)) {
                continue;
            }
            if (!ubicacion.isEmpty() && !propiedad.getUbicacion().toLowerCase().contains(ubicacion)) {
                continue;
            }
            if (!precio.isEmpty()) {
                double valorPrecio = propiedad.getPrecio().doubleValue();
                if (!coincidePrecio(precio, valorPrecio)) {
                    continue;
                }
            }
            if (!habitaciones.isEmpty() && !"cualquiera".equals(habitaciones)) {
                if (propiedad.getHabitaciones() < parseInt(habitaciones, 0)) {
                    continue;
                }
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
