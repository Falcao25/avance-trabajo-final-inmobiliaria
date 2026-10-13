package com.inmobiliaria.dao;

import com.inmobiliaria.config.Conexion;
import com.inmobiliaria.model.Contacto;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

public class ContactoDAO {
    public List<Contacto> listar() throws SQLException {
        List<Contacto> contactos = new ArrayList<>();
        String sql = "SELECT id, nombre, correo, telefono, mensaje, fecha_contacto, estado FROM contactos ORDER BY fecha_contacto DESC, id DESC";
        try (var cn = Conexion.getConnection(); var ps = cn.prepareStatement(sql); var rs = ps.executeQuery()) {
            while (rs.next()) {
                Contacto contacto = new Contacto();
                contacto.setId(rs.getInt("id"));
                contacto.setNombre(rs.getString("nombre"));
                contacto.setCorreo(rs.getString("correo"));
                contacto.setTelefono(rs.getString("telefono"));
                contacto.setMensaje(rs.getString("mensaje"));
                var fecha = rs.getTimestamp("fecha_contacto");
                contacto.setFecha(fecha == null ? null : fecha.toLocalDateTime());
                contacto.setEstado(rs.getString("estado"));
                contactos.add(contacto);
            }
        }
        return contactos;
    }

    public int guardar(Contacto contacto) throws SQLException {
        String sql = "INSERT INTO contactos (nombre, correo, telefono, mensaje) VALUES (?, ?, ?, ?)";
        try (var cn = Conexion.getConnection(); var ps = cn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, contacto.getNombre());
            ps.setString(2, contacto.getCorreo());
            ps.setString(3, contacto.getTelefono());
            ps.setString(4, contacto.getMensaje());
            ps.executeUpdate();
            try (var keys = ps.getGeneratedKeys()) { return keys.next() ? keys.getInt(1) : 0; }
        }
    }
}
