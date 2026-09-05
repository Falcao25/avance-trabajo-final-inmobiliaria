<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="com.inmobiliaria.model.Propiedad,com.inmobiliaria.model.MockData" %>
<%
    Propiedad propiedad = (Propiedad) request.getAttribute("propiedad");
    if (propiedad == null) {
        int id = 1;
        try {
            id = Integer.parseInt(String.valueOf(request.getParameter("id")));
        } catch (Exception ignored) {
        }
        propiedad = MockData.obtenerPropiedadPorId(id);
    }
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Inmobiliaria Aurora | Editar Propiedad</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/styles.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/layout.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/propiedades.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/responsive.css">
</head>
<body>
<jsp:include page="/WEB-INF/components/header.jsp" />

<main class="page-main">
    <section class="section">
        <div class="container">
            <div class="card form-card">
                <div class="section-title">
                    <span class="eyebrow">Administración</span>
                    <h1>Editar propiedad</h1>
                </div>
                <% if (request.getAttribute("mensajeExito") != null) { %>
                <p class="status-pill"><%= request.getAttribute("mensajeExito") %></p>
                <% } %>
                <form class="form-grid" action="${pageContext.request.contextPath}/admin/editar-propiedad" method="post">
                    <input type="hidden" name="id" value="<%= propiedad.getId() %>">
                    <div class="form-field">
                        <label for="titulo">Título</label>
                        <input id="titulo" name="titulo" type="text" value="<%= propiedad.getTitulo() %>">
                    </div>
                    <div class="form-field">
                        <label for="precio">Precio</label>
                        <input id="precio" name="precio" type="number" value="<%= propiedad.getPrecio() %>">
                    </div>
                    <div class="form-field">
                        <label for="ubicacion">Ubicación</label>
                        <input id="ubicacion" name="ubicacion" type="text" value="<%= propiedad.getUbicacion() %>">
                    </div>
                    <div class="form-field">
                        <label for="tipoOperacion">Operación</label>
                        <input id="tipoOperacion" name="tipoOperacion" type="text" value="<%= propiedad.getTipoOperacion() %>">
                    </div>
                    <div class="form-field">
                        <label for="tipo">Tipo</label>
                        <input id="tipo" name="tipo" type="text" value="<%= propiedad.getTipo() %>">
                    </div>
                    <div class="form-field">
                        <label for="area">Area</label>
                        <input id="area" name="area" type="number" step="0.1" value="<%= propiedad.getArea() %>">
                    </div>
                    <div class="form-field">
                        <label for="habitaciones">Habitaciones</label>
                        <input id="habitaciones" name="habitaciones" type="number" value="<%= propiedad.getHabitaciones() %>">
                    </div>
                    <div class="form-field">
                        <label for="banos">Baños</label>
                        <input id="banos" name="banos" type="number" value="<%= propiedad.getBanos() %>">
                    </div>
                    <div class="form-field" style="grid-column: 1 / -1;">
                        <label for="descripcion">Descripcion</label>
                        <textarea id="descripcion" name="descripcion" rows="6"><%= propiedad.getDescripcion() %></textarea>
                    </div>
                    <div>
                        <button class="btn btn-primary" type="submit">Actualizar</button>
                    </div>
                </form>
            </div>
        </div>
    </section>
</main>

<jsp:include page="/WEB-INF/components/footer.jsp" />
