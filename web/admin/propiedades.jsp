<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="java.util.List,com.inmobiliaria.model.Propiedad,java.util.Collections,com.inmobiliaria.util.Html" %>
<%
    if (request.getAttribute("propiedades") == null) { response.sendRedirect(request.getContextPath() + "/admin/propiedades"); return; }
    request.setAttribute("adminTitle", "Listado de propiedades");
    request.setAttribute("adminSubtitle", "Inventario completo para revisar, editar o eliminar propiedades.");
    request.setAttribute("adminActive", "/admin/propiedades");

    List<Propiedad> propiedades = (List<Propiedad>) request.getAttribute("propiedades");
    if (propiedades == null) {
        propiedades = Collections.emptyList();
    }
%>
<jsp:include page="/WEB-INF/components/admin-shell-start.jsp" />

<section class="admin-panel">
    <div class="admin-panel-header">
        <div>
            <span class="admin-pill">Gestión</span>
            <h2>Listado de propiedades</h2>
            <p>Desde aquí se administra todo el inventario que se publica en el sitio.</p>
        </div>
        <div class="admin-actions">
            <a class="admin-btn admin-btn-primary" href="${pageContext.request.contextPath}/admin/nueva-propiedad">Nueva propiedad</a>
            <a class="admin-btn admin-btn-secondary" href="${pageContext.request.contextPath}/admin/dashboard">Volver al panel</a>
        </div>
    </div>

    <% if (request.getAttribute("mensajeExito") != null) { %>
    <p class="admin-badge"><%= request.getAttribute("mensajeExito") %></p>
    <% } %>
    <% if (request.getAttribute("errorBaseDatos") != null) { %>
    <p class="admin-error"><%= request.getAttribute("errorBaseDatos") %></p>
    <% } %>
    <% if (request.getAttribute("fuenteDatos") != null) { %>
    <p class="admin-note">Fuente de datos: <%= request.getAttribute("fuenteDatos") %></p>
    <% } %>

    <% if (request.getAttribute("errorBaseDatos") != null) { %>
    <p class="admin-error"><%= Html.escapar(request.getAttribute("errorBaseDatos")) %></p>
    <% } else if (propiedades.isEmpty()) { %>
    <p class="admin-note">No hay registros disponibles.</p>
    <% } %>
    <div class="admin-table-wrap">
        <table class="admin-table">
            <thead>
            <tr>
                <th>ID</th>
                <th>Título</th>
                <th>Operación</th>
                <th>Tipo</th>
                <th>Precio</th>
                <th>Acciones</th>
            </tr>
            </thead>
            <tbody>
            <% for (Propiedad propiedad : propiedades) { %>
            <tr>
                <td><%= Html.escapar(propiedad.getId()) %></td>
                <td><%= Html.escapar(propiedad.getTitulo()) %></td>
                <td><span class="admin-status"><%= Html.escapar(propiedad.getTipoOperacion()) %></span></td>
                <td><%= Html.escapar(propiedad.getTipo()) %></td>
                <td>$ <%= Html.escapar(propiedad.getPrecio()) %></td>
                <td>
                    <div class="admin-actions">
                        <a class="admin-btn admin-btn-secondary" href="${pageContext.request.contextPath}/admin/editar-propiedad?id=<%= Html.escapar(propiedad.getId()) %>">Editar</a>
                        <form action="${pageContext.request.contextPath}/admin/propiedades" method="post" style="display:inline;">
                            <input type="hidden" name="accion" value="eliminar">
                            <input type="hidden" name="id" value="<%= Html.escapar(propiedad.getId()) %>">
                            <button class="admin-btn admin-btn-ghost" type="submit">Eliminar</button>
                        </form>
                    </div>
                </td>
            </tr>
            <% } %>
            </tbody>
        </table>
    </div>
</section>

<jsp:include page="/WEB-INF/components/admin-shell-end.jsp" />
