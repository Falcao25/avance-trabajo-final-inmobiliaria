<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="com.inmobiliaria.model.Propiedad,com.inmobiliaria.model.MockData" %>
<%
    Propiedad propiedad = (Propiedad) request.getAttribute("propiedad");
    if (propiedad == null) {
        String idParam = request.getParameter("id");
        int id = 1;
        try {
            id = Integer.parseInt(idParam);
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
    <title>Inmobiliaria Aurora | Detalle</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/styles.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/layout.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/propiedades.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/responsive.css">
</head>
<body>
<jsp:include page="/WEB-INF/components/header.jsp" />
<jsp:include page="/WEB-INF/components/navbar.jsp" />

<main class="page-main">
    <section class="section">
        <div class="container detail-layout">
            <div>
                <div class="gallery-main" style="background-image: url('<%= request.getContextPath() + propiedad.getImagenPrincipal() %>');"></div>
                <div class="gallery-thumbs">
                    <% for (String imagen : propiedad.getImagenes()) { %>
                    <div style="background-image: url('<%= request.getContextPath() + imagen %>');"></div>
                    <% } %>
                </div>
            </div>
            <div class="card detail-card">
                <span class="property-badge"><%= propiedad.getTipoOperacion() %> · <%= propiedad.getTipo() %></span>
                <h1><%= propiedad.getTitulo() %></h1>
                <p class="detail-price">$ <%= propiedad.getPrecio() %></p>
                <p class="muted"><%= propiedad.getUbicacion() %></p>

                <div class="detail-meta">
                    <div class="meta-box">
                        <span>Área</span>
                        <strong><%= propiedad.getArea() %> m2</strong>
                    </div>
                    <div class="meta-box">
                        <span>Habitaciones</span>
                        <strong><%= propiedad.getHabitaciones() %></strong>
                    </div>
                    <div class="meta-box">
                        <span>Baños</span>
                        <strong><%= propiedad.getBanos() %></strong>
                    </div>
                    <div class="meta-box">
                        <span>Operación</span>
                        <strong><%= propiedad.getTipoOperacion() %></strong>
                    </div>
                </div>

                <h3>Descripción</h3>
                <p><%= propiedad.getDescripcion() %></p>

                <h3>Características</h3>
                <ul class="feature-list">
                    <% for (String caracteristica : propiedad.getCaracteristicas()) { %>
                    <li><%= caracteristica %></li>
                    <% } %>
                </ul>

                <div class="home-highlight">
                    <a class="btn btn-primary" href="${pageContext.request.contextPath}/contacto">Contactar</a>
                    <a class="btn btn-secondary" href="${pageContext.request.contextPath}/propiedades">Volver al catálogo</a>
                </div>
            </div>
        </div>
    </section>
</main>

<jsp:include page="/WEB-INF/components/footer.jsp" />
