package com.inmobiliaria.dao;

import com.inmobiliaria.config.Conexion;
import com.inmobiliaria.model.Cliente;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

public class ClienteDAO {

    public List<Cliente> listar() throws SQLException {
        List<Cliente> clientes = new ArrayList<>();
        String sql = """
                SELECT id, nombre, apellido, correo, telefono, documento, fecha_registro
                FROM clientes
                ORDER BY fecha_registro DESC
                """;
        try (Connection cn = Conexion.conectar();
             PreparedStatement ps = cn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Cliente cliente = new Cliente();
                cliente.setId(rs.getInt("id"));
                cliente.setNombre(rs.getString("nombre"));
                cliente.setApellido(rs.getString("apellido"));
                cliente.setCorreo(rs.getString("correo"));
                cliente.setTelefono(rs.getString("telefono"));
                cliente.setDocumento(rs.getString("documento"));
                cliente.setFechaRegistro(rs.getTimestamp("fecha_registro").toLocalDateTime());
                clientes.add(cliente);
            }
        }
        return clientes;
    }

    public int guardar(Cliente cliente) throws SQLException {
        String sql = """
                INSERT INTO clientes (nombre, apellido, correo, telefono, documento, fecha_registro)
                VALUES (?, ?, ?, ?, ?, NOW())
                """;
        try (Connection cn = Conexion.conectar();
             PreparedStatement ps = cn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
                ps.setString(1, cliente.getNombre());
            ps.setString(2, cliente.getApellido());
            ps.setString(3, cliente.getCorreo());
            ps.setString(4, cliente.getTelefono());
            ps.setString(5, cliente.getDocumento());
            ps.executeUpdate();
            try (ResultSet rs = ps.getGeneratedKeys()) {
                return rs.next() ? rs.getInt(1) : 0;
            }
        }
    }
}
