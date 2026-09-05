<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="java.util.List,com.inmobiliaria.model.Propiedad,com.inmobiliaria.model.MockData" %>
<%
    List<Propiedad> propiedades = (List<Propiedad>) request.getAttribute("propiedades");
    if (propiedades == null) {
        propiedades = MockData.obtenerPropiedades();
    }
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Inmobiliaria Aurora | Propiedades</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/styles.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/layout.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/home.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/propiedades.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/responsive.css">
</head>
<body>
<jsp:include page="/WEB-INF/components/header.jsp" />

<main class="page-main">
    <section class="section">
        <div class="container property-page">
            <div class="section-title">
                <span class="eyebrow">Catálogo</span>
                <h1>Propiedades disponibles</h1>
                <p>Filtra por operación, tipo, ubicación, rango de precio y habitaciones para encontrar la opción ideal.</p>
            </div>

            <div class="content-panel">
                <form class="filters-panel" action="${pageContext.request.contextPath}/propiedades" method="get" data-filters-form>
                    <div class="form-field">
                        <label for="q">Buscador</label>
                        <input id="q" name="q" type="text" placeholder="Casa moderna, Miraflores...">
                    </div>
                    <div class="form-field">
                        <label for="operacion">Operación</label>
                        <select id="operacion" name="operacion">
                            <option value="todas">Todas</option>
                            <option value="venta">Venta</option>
                            <option value="alquiler">Alquiler</option>
                        </select>
                    </div>
                    <div class="form-field">
                        <label for="tipo">Tipo</label>
                        <select id="tipo" name="tipo">
                            <option value="todos">Todos</option>
                            <option value="casa">Casa</option>
                            <option value="departamento">Departamento</option>
                            <option value="terreno">Terreno</option>
                        </select>
                    </div>
                    <div class="form-field">
                        <label for="ubicacion">Ubicación</label>
                        <input id="ubicacion" name="ubicacion" type="text" placeholder="Lima">
                    </div>
                    <div class="form-field">
                        <label for="precio">Precio</label>
                        <select id="precio" name="precio">
                            <option value="">Todos</option>
                            <option value="0-150000">Hasta 150k</option>
                            <option value="150000-250000">150k - 250k</option>
                            <option value="250000-400000">250k - 400k</option>
                            <option value="400000+">400k+</option>
                        </select>
                    </div>
                    <div class="form-field">
                        <label for="habitaciones">Habitaciones</label>
                        <select id="habitaciones" name="habitaciones">
                            <option value="cualquiera">Cualquiera</option>
                            <option value="1">1+</option>
                            <option value="2">2+</option>
                            <option value="3">3+</option>
                            <option value="4">4+</option>
                        </select>
                    </div>
                    <button class="btn btn-primary" type="submit">Aplicar</button>
                </form>
            </div>

            <div class="property-toolbar">
                <p class="muted">Mostrando <strong><%= propiedades.size() %></strong> propiedades mock.</p>
                <a class="btn btn-secondary" href="${pageContext.request.contextPath}/detalle-propiedad?id=1">Ver ejemplo de detalle</a>
            </div>

            <div class="cards-grid">
                <%
                    for (Propiedad propiedad : propiedades) {
                %>
                <article class="card property-card" data-property-card
                         data-title="<%= propiedad.getTitulo() %>"
                         data-operation="<%= propiedad.getTipoOperacion().toLowerCase() %>"
                         data-type="<%= propiedad.getTipo().toLowerCase() %>"
                         data-location="<%= propiedad.getUbicacion() %>"
                         data-price="<%= propiedad.getPrecio() %>"
                         data-bedrooms="<%= propiedad.getHabitaciones() %>">
                    <div class="property-image" style="background-image: url('<%= request.getContextPath() + propiedad.getImagenPrincipal() %>');"></div>
                    <div class="property-body">
                        <span class="property-badge"><%= propiedad.getTipoOperacion() %> · <%= propiedad.getTipo() %></span>
                        <h3><%= propiedad.getTitulo() %></h3>
                        <p class="muted"><%= propiedad.getUbicacion() %></p>
                        <div class="property-meta">
                            <span>$ <%= propiedad.getPrecio() %></span>
                            <span><%= propiedad.getArea() %> m2</span>
                            <span><%= propiedad.getBanos() %> baños</span>
                        </div>
                        <a class="btn btn-secondary" href="${pageContext.request.contextPath}/detalle-propiedad?id=<%= propiedad.getId() %>">Ver detalle</a>
                    </div>
                </article>
                <% } %>
            </div>
        </div>
    </section>
</main>

<jsp:include page="/WEB-INF/components/footer.jsp" />
