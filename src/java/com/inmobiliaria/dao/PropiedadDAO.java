package com.inmobiliaria.dao;

import com.inmobiliaria.config.Conexion;
import com.inmobiliaria.model.Propiedad;
import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

public class PropiedadDAO {

    public List<Propiedad> listar() throws SQLException {
        List<Propiedad> propiedades = new ArrayList<>();
        String sql = """
                SELECT id, titulo, precio, ubicacion, tipo_operacion, tipo, area, habitaciones, banos,
                       descripcion, imagen_principal
                FROM propiedades
                ORDER BY id DESC
                """;
        try (Connection cn = Conexion.conectar();
             PreparedStatement ps = cn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Propiedad propiedad = new Propiedad();
                propiedad.setId(rs.getInt("id"));
                propiedad.setTitulo(rs.getString("titulo"));
                propiedad.setPrecio(rs.getBigDecimal("precio"));
                propiedad.setUbicacion(rs.getString("ubicacion"));
                propiedad.setTipoOperacion(rs.getString("tipo_operacion"));
                propiedad.setTipo(rs.getString("tipo"));
                propiedad.setArea(rs.getDouble("area"));
                propiedad.setHabitaciones(rs.getInt("habitaciones"));
                propiedad.setBanos(rs.getInt("banos"));
                propiedad.setDescripcion(rs.getString("descripcion"));
                propiedad.setImagenPrincipal(rs.getString("imagen_principal"));
                propiedades.add(propiedad);
            }
        }
        return propiedades;
    }

    public Propiedad buscarPorId(int id) throws SQLException {
        String sql = """
                SELECT id, titulo, precio, ubicacion, tipo_operacion, tipo, area, habitaciones, banos,
                       descripcion, imagen_principal
                FROM propiedades
                WHERE id = ?
                """;
        try (Connection cn = Conexion.conectar();
             PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Propiedad propiedad = new Propiedad();
                    propiedad.setId(rs.getInt("id"));
                    propiedad.setTitulo(rs.getString("titulo"));
                    propiedad.setPrecio(rs.getBigDecimal("precio"));
                    propiedad.setUbicacion(rs.getString("ubicacion"));
                    propiedad.setTipoOperacion(rs.getString("tipo_operacion"));
                    propiedad.setTipo(rs.getString("tipo"));
                    propiedad.setArea(rs.getDouble("area"));
                    propiedad.setHabitaciones(rs.getInt("habitaciones"));
                    propiedad.setBanos(rs.getInt("banos"));
                    propiedad.setDescripcion(rs.getString("descripcion"));
                    propiedad.setImagenPrincipal(rs.getString("imagen_principal"));
                    return propiedad;
                }
            }
        }
        return null;
    }

    public int guardar(Propiedad propiedad) throws SQLException {
        String sql = """
                INSERT INTO propiedades (titulo, precio, ubicacion, tipo_operacion, tipo, area, habitaciones, banos, descripcion, imagen_principal)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
                """;
        try (Connection cn = Conexion.conectar();
             PreparedStatement ps = cn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, propiedad.getTitulo());
            ps.setBigDecimal(2, propiedad.getPrecio() != null ? propiedad.getPrecio() : BigDecimal.ZERO);
            ps.setString(3, propiedad.getUbicacion());
            ps.setString(4, propiedad.getTipoOperacion());
            ps.setString(5, propiedad.getTipo());
            ps.setDouble(6, propiedad.getArea());
            ps.setInt(7, propiedad.getHabitaciones());
            ps.setInt(8, propiedad.getBanos());
            ps.setString(9, propiedad.getDescripcion());
            ps.setString(10, propiedad.getImagenPrincipal());
            ps.executeUpdate();
            try (ResultSet rs = ps.getGeneratedKeys()) {
                return rs.next() ? rs.getInt(1) : 0;
            }
        }
    }

    public boolean actualizar(Propiedad propiedad) throws SQLException {
        String sql = """
                UPDATE propiedades
                SET titulo = ?, precio = ?, ubicacion = ?, tipo_operacion = ?, tipo = ?, area = ?, habitaciones = ?, banos = ?, descripcion = ?, imagen_principal = ?
                WHERE id = ?
                """;
        try (Connection cn = Conexion.conectar();
             PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setString(1, propiedad.getTitulo());
            ps.setBigDecimal(2, propiedad.getPrecio() != null ? propiedad.getPrecio() : BigDecimal.ZERO);
            ps.setString(3, propiedad.getUbicacion());
            ps.setString(4, propiedad.getTipoOperacion());
            ps.setString(5, propiedad.getTipo());
            ps.setDouble(6, propiedad.getArea());
            ps.setInt(7, propiedad.getHabitaciones());
            ps.setInt(8, propiedad.getBanos());
            ps.setString(9, propiedad.getDescripcion());
            ps.setString(10, propiedad.getImagenPrincipal());
            ps.setInt(11, propiedad.getId());
            return ps.executeUpdate() > 0;
        }
    }

    public boolean eliminar(int id) throws SQLException {
        String sql = "DELETE FROM propiedades WHERE id = ?";
        try (Connection cn = Conexion.conectar();
             PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        }
    }
}
