package com.inmobiliaria.controller;

import com.inmobiliaria.util.ImagenAlmacen;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;

@WebServlet(urlPatterns = "/img/propiedades/subidas/*")
public class ImagenPropiedadServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String nombre = request.getPathInfo();
        if (nombre == null || !nombre.matches("/[a-f0-9-]{36}\\.(jpg|png|gif)")) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }
        Path archivo = ImagenAlmacen.directorio().resolve(nombre.substring(1));
        if (!Files.isRegularFile(archivo)) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }
        response.setContentType(nombre.endsWith(".jpg") ? "image/jpeg"
                : nombre.endsWith(".png") ? "image/png" : "image/gif");
        response.setHeader("X-Content-Type-Options", "nosniff");
        response.setHeader("Cache-Control", "public, max-age=86400");
        response.setContentLengthLong(Files.size(archivo));
        Files.copy(archivo, response.getOutputStream());
    }
}
