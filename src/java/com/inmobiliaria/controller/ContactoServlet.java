package com.inmobiliaria.controller;

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
        RequestDispatcher dispatcher = request.getRequestDispatcher("/contacto.jsp");
        dispatcher.forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        Contacto contacto = new Contacto();
        contacto.setNombre(request.getParameter("nombre"));
        contacto.setCorreo(request.getParameter("correo"));
        contacto.setTelefono(request.getParameter("telefono"));
        contacto.setMensaje(request.getParameter("mensaje"));
        contacto.setFecha(LocalDateTime.now());

        request.setAttribute("contacto", contacto);
        request.setAttribute("mensajeExito", "Gracias por escribirnos. Tu mensaje fue recibido en modo demo.");
        RequestDispatcher dispatcher = request.getRequestDispatcher("/contacto.jsp");
        dispatcher.forward(request, response);
    }
}
