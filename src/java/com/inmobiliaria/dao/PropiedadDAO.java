package com.inmobiliaria.dao;

import com.inmobiliaria.config.Conexion;
import com.inmobiliaria.model.Propiedad;
import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

public class PropiedadDAO {

    public List<Propiedad> listar() throws SQLException {
        List<Propiedad> propiedades = new ArrayList<>();
        String sql = "SELECT * FROM propiedades ORDER BY id DESC";

        try (Connection cn = Conexion.getConnection();
             PreparedStatement ps = cn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                propiedades.add(mapear(rs));
            }
        }
        return propiedades;
    }

    public Propiedad buscarPorId(int id) throws SQLException {
        String sql = "SELECT * FROM propiedades WHERE id = ?";
        try (Connection cn = Conexion.getConnection();
             PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? mapear(rs) : null;
            }
        }
    }

    public int guardar(Propiedad propiedad) throws SQLException {
        String sql = """
                INSERT INTO propiedades
                    (titulo, descripcion, tipo_propiedad, tipo_operacion, precio, ubicacion, direccion,
                     habitaciones, banios, area, imagen, estado, destacada)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
                """;
        try (Connection cn = Conexion.getConnection();
             PreparedStatement ps = cn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            completarParametros(ps, propiedad);
            ps.executeUpdate();
            try (ResultSet rs = ps.getGeneratedKeys()) {
                return rs.next() ? rs.getInt(1) : 0;
            }
        }
    }

    public boolean actualizar(Propiedad propiedad) throws SQLException {
        String sql = """
                UPDATE propiedades
                SET titulo = ?, descripcion = ?, tipo_propiedad = ?, tipo_operacion = ?, precio = ?,
                    ubicacion = ?, direccion = ?, habitaciones = ?, banios = ?, area = ?, imagen = ?,
                    estado = ?, destacada = ?
                WHERE id = ?
                """;
        try (Connection cn = Conexion.getConnection();
             PreparedStatement ps = cn.prepareStatement(sql)) {
            completarParametros(ps, propiedad);
            ps.setInt(14, propiedad.getId());
            return ps.executeUpdate() > 0;
        }
    }

    public boolean eliminar(int id) throws SQLException {
        String sql = "DELETE FROM propiedades WHERE id = ?";
        try (Connection cn = Conexion.getConnection();
             PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        }
    }

    private Propiedad mapear(ResultSet rs) throws SQLException {
        Propiedad propiedad = new Propiedad();
        propiedad.setId(rs.getInt("id"));
        propiedad.setTitulo(rs.getString("titulo"));
        propiedad.setDescripcion(rs.getString("descripcion"));
        propiedad.setTipo(rs.getString("tipo_propiedad"));
        propiedad.setTipoOperacion(rs.getString("tipo_operacion"));
        propiedad.setPrecio(rs.getBigDecimal("precio"));
        propiedad.setUbicacion(rs.getString("ubicacion"));
        propiedad.setDireccion(rs.getString("direccion"));
        propiedad.setHabitaciones(rs.getInt("habitaciones"));
        propiedad.setBanos(rs.getInt("banios"));
        propiedad.setArea(rs.getDouble("area"));
        propiedad.setImagenPrincipal(rs.getString("imagen"));
        propiedad.setEstado(rs.getString("estado"));
        propiedad.setDestacada(rs.getBoolean("destacada"));
        Timestamp fecha = rs.getTimestamp("fecha_publicacion");
        if (fecha != null) {
            propiedad.setFechaPublicacion(fecha.toLocalDateTime());
        }
        return propiedad;
    }

    private void completarParametros(PreparedStatement ps, Propiedad propiedad) throws SQLException {
        ps.setString(1, propiedad.getTitulo());
        ps.setString(2, propiedad.getDescripcion());
        ps.setString(3, propiedad.getTipo());
        ps.setString(4, propiedad.getTipoOperacion());
        ps.setBigDecimal(5, propiedad.getPrecio() != null ? propiedad.getPrecio() : BigDecimal.ZERO);
        ps.setString(6, propiedad.getUbicacion());
        ps.setString(7, propiedad.getDireccion());
        ps.setInt(8, propiedad.getHabitaciones());
        ps.setInt(9, propiedad.getBanos());
        ps.setDouble(10, propiedad.getArea());
        ps.setString(11, propiedad.getImagenPrincipal());
        ps.setString(12, propiedad.getEstado() == null ? "DISPONIBLE" : propiedad.getEstado());
        ps.setBoolean(13, propiedad.isDestacada());
    }
}
