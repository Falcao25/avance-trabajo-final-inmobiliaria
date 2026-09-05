package com.inmobiliaria.dao;

import com.inmobiliaria.config.Conexion;
import com.inmobiliaria.model.Usuario;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class UsuarioDAO {

    public List<Usuario> listar() throws SQLException {
        List<Usuario> usuarios = new ArrayList<>();
        String sql = """
                SELECT id, nombre, correo, password, rol, activo
                FROM usuarios
                ORDER BY id DESC
                """;
        try (Connection cn = Conexion.conectar();
             PreparedStatement ps = cn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                usuarios.add(new Usuario(
                        rs.getInt("id"),
                        rs.getString("nombre"),
                        rs.getString("correo"),
                        rs.getString("password"),
                        rs.getString("rol"),
                        rs.getBoolean("activo")));
            }
        }
        return usuarios;
    }

    public Usuario autenticar(String correo, String password) throws SQLException {
        String sql = """
                SELECT id, nombre, correo, password, rol, activo
                FROM usuarios
                WHERE correo = ? AND password = ? AND activo = 1
                """;
        try (Connection cn = Conexion.conectar();
             PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setString(1, correo);
            ps.setString(2, password);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return new Usuario(
                            rs.getInt("id"),
                            rs.getString("nombre"),
                            rs.getString("correo"),
                            rs.getString("password"),
                            rs.getString("rol"),
                            rs.getBoolean("activo"));
                }
            }
        }
        return null;
    }
}
