<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="com.inmobiliaria.model.Propiedad" %>
<%
    request.setAttribute("adminTitle", "Editar propiedad");
    request.setAttribute("adminSubtitle", "Ajusta los datos de una propiedad sin salir del panel interno.");
    request.setAttribute("adminActive", "/admin/editar-propiedad");
    Propiedad propiedad = (Propiedad) request.getAttribute("propiedad");
%>
<jsp:include page="/WEB-INF/components/admin-shell-start.jsp" />

<section class="admin-panel">
    <div class="admin-panel-header">
        <div>
            <span class="admin-pill">Edición</span>
            <h2>Editar propiedad</h2>
            <p>Actualiza los datos que se muestran en el catálogo público.</p>
        </div>
        <div class="admin-actions">
            <a class="admin-btn admin-btn-secondary" href="${pageContext.request.contextPath}/admin/propiedades">Volver al listado</a>
            <a class="admin-btn admin-btn-ghost" href="${pageContext.request.contextPath}/admin/dashboard">Panel general</a>
        </div>
    </div>

    <% if (request.getAttribute("errorBaseDatos") != null) { %>
    <p class="admin-error"><%= request.getAttribute("errorBaseDatos") %></p>
    <% } %>

    <% if (propiedad != null) { %>
    <form class="admin-form" action="${pageContext.request.contextPath}/admin/editar-propiedad" method="post">
        <input type="hidden" name="id" value="<%= propiedad.getId() %>">
        <div class="admin-field"><label for="titulo">Título</label><input id="titulo" name="titulo" type="text" value="<%= propiedad.getTitulo() %>" required></div>
        <div class="admin-field"><label for="precio">Precio</label><input id="precio" name="precio" type="number" step="0.01" value="<%= propiedad.getPrecio() %>" required></div>
        <div class="admin-field"><label for="ubicacion">Ubicación</label><input id="ubicacion" name="ubicacion" type="text" value="<%= propiedad.getUbicacion() %>" required></div>
        <div class="admin-field"><label for="direccion">Dirección</label><input id="direccion" name="direccion" type="text" value="<%= propiedad.getDireccion() == null ? "" : propiedad.getDireccion() %>"></div>
        <div class="admin-field"><label for="tipoOperacion">Operación</label>
            <select id="tipoOperacion" name="tipoOperacion"><option value="VENTA" <%= "VENTA".equals(propiedad.getTipoOperacion()) ? "selected" : "" %>>Venta</option><option value="ALQUILER" <%= "ALQUILER".equals(propiedad.getTipoOperacion()) ? "selected" : "" %>>Alquiler</option></select>
        </div>
        <div class="admin-field"><label for="tipo">Tipo</label>
            <select id="tipo" name="tipo"><option value="CASA" <%= "CASA".equals(propiedad.getTipo()) ? "selected" : "" %>>Casa</option><option value="DEPARTAMENTO" <%= "DEPARTAMENTO".equals(propiedad.getTipo()) ? "selected" : "" %>>Departamento</option><option value="TERRENO" <%= "TERRENO".equals(propiedad.getTipo()) ? "selected" : "" %>>Terreno</option><option value="OFICINA" <%= "OFICINA".equals(propiedad.getTipo()) ? "selected" : "" %>>Oficina</option><option value="LOCAL" <%= "LOCAL".equals(propiedad.getTipo()) ? "selected" : "" %>>Local</option></select>
        </div>
        <div class="admin-field"><label for="area">Área</label><input id="area" name="area" type="number" step="0.01" min="0" value="<%= propiedad.getArea() %>" required></div>
        <div class="admin-field"><label for="habitaciones">Habitaciones</label><input id="habitaciones" name="habitaciones" type="number" min="0" value="<%= propiedad.getHabitaciones() %>"></div>
        <div class="admin-field"><label for="banos">Baños</label><input id="banos" name="banos" type="number" min="0" value="<%= propiedad.getBanos() %>"></div>
        <div class="admin-field"><label for="imagen">Imagen principal</label><input id="imagen" name="imagen" type="text" value="<%= propiedad.getImagenPrincipal() == null ? "" : propiedad.getImagenPrincipal() %>"></div>
        <div class="admin-field"><label for="estado">Estado</label>
            <select id="estado" name="estado"><option value="DISPONIBLE" <%= "DISPONIBLE".equals(propiedad.getEstado()) ? "selected" : "" %>>Disponible</option><option value="RESERVADA" <%= "RESERVADA".equals(propiedad.getEstado()) ? "selected" : "" %>>Reservada</option><option value="VENDIDA" <%= "VENDIDA".equals(propiedad.getEstado()) ? "selected" : "" %>>Vendida</option><option value="ALQUILADA" <%= "ALQUILADA".equals(propiedad.getEstado()) ? "selected" : "" %>>Alquilada</option></select>
        </div>
        <label class="admin-check"><input name="destacada" type="checkbox" <%= propiedad.isDestacada() ? "checked" : "" %>> Mostrar como destacada</label>
        <div class="admin-field" style="grid-column: 1 / -1;"><label for="descripcion">Descripción</label><textarea id="descripcion" name="descripcion" rows="6"><%= propiedad.getDescripcion() %></textarea></div>
        <div class="admin-form-actions" style="grid-column: 1 / -1;"><button class="admin-btn admin-btn-primary" type="submit">Actualizar propiedad</button><a class="admin-btn admin-btn-secondary" href="${pageContext.request.contextPath}/admin/propiedades">Cancelar</a></div>
    </form>
    <% } else { %>
    <p class="admin-error">No se encontró la propiedad solicitada.</p>
    <% } %>
</section>

<jsp:include page="/WEB-INF/components/admin-shell-end.jsp" />
