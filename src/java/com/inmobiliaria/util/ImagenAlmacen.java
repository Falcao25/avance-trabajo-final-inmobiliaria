package com.inmobiliaria.util;

import jakarta.servlet.http.Part;
import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.Iterator;
import java.util.Locale;
import java.util.UUID;
import javax.imageio.ImageIO;
import javax.imageio.ImageReader;
import javax.imageio.stream.ImageInputStream;

/** Guarda las imágenes fuera del despliegue para conservarlas al publicar de nuevo. */
public final class ImagenAlmacen {
    public static final String RUTA = "/img/propiedades/subidas/";
    private ImagenAlmacen() { }

    public static Path directorio() {
        return Path.of(System.getProperty("catalina.base", System.getProperty("user.home")),
                "inmobiliaria", "imagenes").toAbsolutePath().normalize();
    }

    public static String validar(Part archivo) throws IOException {
        if (archivo.getSize() > 5 * 1024 * 1024) {
            throw new IllegalArgumentException("La imagen debe pesar como máximo 5 MB.");
        }
        try (InputStream entrada = archivo.getInputStream();
             ImageInputStream imagen = ImageIO.createImageInputStream(entrada)) {
            Iterator<ImageReader> lectores = ImageIO.getImageReaders(imagen);
            if (!lectores.hasNext()) throw new IllegalArgumentException("Selecciona una imagen JPG, PNG o GIF válida.");
            ImageReader lector = lectores.next();
            try {
                String formato = lector.getFormatName().toLowerCase(Locale.ROOT);
                if (!formato.equals("jpeg") && !formato.equals("png") && !formato.equals("gif")) {
                    throw new IllegalArgumentException("Selecciona una imagen JPG, PNG o GIF válida.");
                }
                lector.setInput(imagen);
                if (lector.getWidth(0) <= 0 || lector.getHeight(0) <= 0
                        || (long) lector.getWidth(0) * lector.getHeight(0) > 40_000_000) {
                    throw new IllegalArgumentException("La imagen es demasiado grande. Máximo 40 megapíxeles.");
                }
                lector.read(0);
                return formato.equals("jpeg") ? "jpg" : formato;
            } finally {
                lector.dispose();
            }
        }
    }

    public static String guardar(Part archivo) throws IOException {
        String extension = validar(archivo);
        Files.createDirectories(directorio());
        Path destino = directorio().resolve(UUID.randomUUID() + "." + extension);
        try (InputStream entrada = archivo.getInputStream()) {
            Files.copy(entrada, destino);
        } catch (IOException e) {
            Files.deleteIfExists(destino);
            throw e;
        }
        return RUTA + destino.getFileName();
    }

    public static void eliminar(String ruta) throws IOException {
        if (ruta != null && ruta.startsWith(RUTA)) {
            Path archivo = directorio().resolve(ruta.substring(RUTA.length())).normalize();
            if (archivo.getParent().equals(directorio())) Files.deleteIfExists(archivo);
        }
    }
}
