<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="java.util.List,com.inmobiliaria.model.Contacto,java.util.Collections,com.inmobiliaria.util.Html" %>
<%
    if (request.getAttribute("contactos") == null) { response.sendRedirect(request.getContextPath() + "/admin/clientes"); return; }
    request.setAttribute("adminTitle", "Contactos recibidos");
    request.setAttribute("adminSubtitle", "Mensajes y consultas llegadas desde el formulario del sitio.");
    request.setAttribute("adminActive", "/admin/clientes");

    List<Contacto> contactos = (List<Contacto>) request.getAttribute("contactos");
    if (contactos == null) {
        contactos = Collections.emptyList();
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

    <% if (request.getAttribute("errorContactos") != null) { %>
    <p class="admin-error"><%= Html.escapar(request.getAttribute("errorContactos")) %></p>
    <% } else if (contactos.isEmpty()) { %>
    <p class="admin-note">No hay registros disponibles.</p>
    <% } %>
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
            <% for (Contacto contacto : contactos) { %>
            <tr>
                <td><%= Html.escapar(contacto.getNombre()) %></td>
                <td><%= Html.escapar(contacto.getCorreo()) %></td>
                <td><%= Html.escapar(contacto.getTelefono()) %></td>
                <td><%= Html.escapar(contacto.getMensaje()) %></td>
            </tr>
            <% } %>
            </tbody>
        </table>
    </div>
</section>

<jsp:include page="/WEB-INF/components/admin-shell-end.jsp" />
