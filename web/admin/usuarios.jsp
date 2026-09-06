<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="java.util.List,com.inmobiliaria.model.Usuario,com.inmobiliaria.model.MockData" %>
<%
    request.setAttribute("adminTitle", "Usuarios del sistema");
    request.setAttribute("adminSubtitle", "Listado interno de cuentas con acceso al panel.");
    request.setAttribute("adminActive", "/admin/usuarios");

    List<Usuario> usuarios = (List<Usuario>) request.getAttribute("usuarios");
    if (usuarios == null) {
        usuarios = MockData.obtenerUsuarios();
    }
%>
<jsp:include page="/WEB-INF/components/admin-shell-start.jsp" />

<section class="admin-panel">
    <div class="admin-panel-header">
        <div>
            <span class="admin-pill">Seguridad</span>
            <h2>Usuarios del sistema</h2>
            <p>Vista rápida para revisar quién tiene acceso al entorno de administración.</p>
        </div>
        <a class="admin-btn admin-btn-secondary" href="${pageContext.request.contextPath}/admin/dashboard">Volver al panel</a>
    </div>

    <div class="admin-table-wrap">
        <table class="admin-table">
            <thead>
            <tr>
                <th>Nombre</th>
                <th>Correo</th>
                <th>Rol</th>
                <th>Activo</th>
            </tr>
            </thead>
            <tbody>
            <% for (Usuario usuario : usuarios) { %>
            <tr>
                <td><%= usuario.getNombre() %></td>
                <td><%= usuario.getCorreo() %></td>
                <td><%= usuario.getRol() %></td>
                <td><span class="admin-status"><%= usuario.isActivo() ? "Si" : "No" %></span></td>
            </tr>
            <% } %>
            </tbody>
        </table>
    </div>
</section>

<jsp:include page="/WEB-INF/components/admin-shell-end.jsp" />
