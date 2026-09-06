<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="java.util.List,com.inmobiliaria.model.Cliente,com.inmobiliaria.model.MockData" %>
<%
    request.setAttribute("adminTitle", "Contactos recibidos");
    request.setAttribute("adminSubtitle", "Mensajes y consultas llegadas desde el formulario del sitio.");
    request.setAttribute("adminActive", "/admin/clientes");

    List<Cliente> clientes = (List<Cliente>) request.getAttribute("clientes");
    if (clientes == null) {
        clientes = MockData.obtenerClientes();
    }
%>
<jsp:include page="/WEB-INF/components/admin-shell-start.jsp" />

<section class="admin-panel">
    <div class="admin-panel-header">
        <div>
            <span class="admin-pill">Soporte</span>
            <h2>Contactos recibidos</h2>
            <p>Las consultas quedan separadas del front principal dentro del panel administrativo.</p>
        </div>
        <a class="admin-btn admin-btn-secondary" href="${pageContext.request.contextPath}/admin/dashboard">Volver al panel</a>
    </div>

    <div class="admin-table-wrap">
        <table class="admin-table">
            <thead>
            <tr>
                <th>Nombre</th>
                <th>Correo</th>
                <th>Teléfono</th>
                <th>Mensaje</th>
            </tr>
            </thead>
            <tbody>
            <% for (Cliente cliente : clientes) { %>
            <tr>
                <td><%= cliente.getNombre() %></td>
                <td><%= cliente.getCorreo() %></td>
                <td><%= cliente.getTelefono() %></td>
                <td><%= cliente.getMensaje() %></td>
            </tr>
            <% } %>
            </tbody>
        </table>
    </div>
</section>

<jsp:include page="/WEB-INF/components/admin-shell-end.jsp" />
