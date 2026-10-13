<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="com.inmobiliaria.util.Html,java.util.List,java.util.Collections,com.inmobiliaria.model.Propiedad" %>
<%!
    private String atributoSeguro(String valor) {
        return valor == null ? "" : valor.replace("&", "&amp;")
                .replace("<", "&lt;").replace(">", "&gt;")
                .replace("\"", "&quot;").replace("'", "&#39;");
    }
%>
<%
    List<Propiedad> propiedades = (List<Propiedad>) request.getAttribute("propiedades");
    if (propiedades == null) {
        propiedades = Collections.emptyList();
    }
    String fuenteDatos = (String) request.getAttribute("fuenteDatos");
    if (fuenteDatos == null) {
        fuenteDatos = "sin cargar";
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
                        <input id="q" name="q" type="text" value="<%= atributoSeguro(request.getParameter("q")) %>" placeholder="Casa moderna, Miraflores...">
                    </div>
                    <div class="form-field">
                        <label for="operacion">Operación</label>
                        <select id="operacion" name="operacion">
                            <option value="todas" ${param.operacion eq 'todas' ? 'selected' : ''}>Todas</option>
                            <option value="venta" ${param.operacion eq 'venta' ? 'selected' : ''}>Venta</option>
                            <option value="alquiler" ${param.operacion eq 'alquiler' ? 'selected' : ''}>Alquiler</option>
                        </select>
                    </div>
                    <div class="form-field">
                        <label for="tipo">Tipo</label>
                        <select id="tipo" name="tipo">
                            <option value="todos" ${param.tipo eq 'todos' ? 'selected' : ''}>Todos</option>
                            <option value="casa" ${param.tipo eq 'casa' ? 'selected' : ''}>Casa</option>
                            <option value="departamento" ${param.tipo eq 'departamento' ? 'selected' : ''}>Departamento</option>
                            <option value="terreno" ${param.tipo eq 'terreno' ? 'selected' : ''}>Terreno</option>
                        </select>
                    </div>
                    <div class="form-field">
                        <label for="ubicacion">Ubicación</label>
                        <input id="ubicacion" name="ubicacion" type="text" value="<%= atributoSeguro(request.getParameter("ubicacion")) %>" placeholder="Lima">
                    </div>
                    <div class="form-field">
                        <label for="precio">Precio</label>
                        <select id="precio" name="precio">
                            <option value="" ${param.precio eq '' ? 'selected' : ''}>Todos</option>
                            <option value="0-150000" ${param.precio eq '0-150000' ? 'selected' : ''}>Hasta 150k</option>
                            <option value="150000-250000" ${param.precio eq '150000-250000' ? 'selected' : ''}>150k - 250k</option>
                            <option value="250000-400000" ${param.precio eq '250000-400000' ? 'selected' : ''}>250k - 400k</option>
                            <option value="400000+" ${param.precio eq '400000+' ? 'selected' : ''}>400k+</option>
                        </select>
                    </div>
                    <div class="form-field">
                        <label for="habitaciones">Habitaciones</label>
                        <select id="habitaciones" name="habitaciones">
                            <option value="cualquiera" ${param.habitaciones eq 'cualquiera' ? 'selected' : ''}>Cualquiera</option>
                            <option value="1" ${param.habitaciones eq '1' ? 'selected' : ''}>1+</option>
                            <option value="2" ${param.habitaciones eq '2' ? 'selected' : ''}>2+</option>
                            <option value="3" ${param.habitaciones eq '3' ? 'selected' : ''}>3+</option>
                            <option value="4" ${param.habitaciones eq '4' ? 'selected' : ''}>4+</option>
                        </select>
                    </div>
                    <button class="btn btn-primary" type="submit">Aplicar</button>
                </form>
            </div>

            <div class="property-toolbar">
                <p class="muted">Mostrando <strong><%= propiedades.size() %></strong> propiedades de <strong><%= fuenteDatos %></strong>.</p>

            </div>

            <% if (request.getAttribute("errorBaseDatos") != null) { %>
            <div class="database-notice"><%= request.getAttribute("errorBaseDatos") %></div>
            <% } %>

            <% if (propiedades.isEmpty() && request.getAttribute("errorBaseDatos") == null) { %>
            <p class="database-notice" role="status">No se encontraron propiedades con los filtros seleccionados.</p>
            <% } %>

            <div class="cards-grid">
                <%
                    for (Propiedad propiedad : propiedades) {
                %>
                <article class="card property-card" data-property-card
                         data-title="<%= Html.escapar(propiedad.getTitulo()) %>"
                         data-operation="<%= Html.escapar(propiedad.getTipoOperacion().toLowerCase()) %>"
                         data-type="<%= Html.escapar(propiedad.getTipo().toLowerCase()) %>"
                         data-location="<%= Html.escapar(propiedad.getUbicacion()) %>"
                         data-price="<%= Html.escapar(propiedad.getPrecio()) %>"
                         data-bedrooms="<%= Html.escapar(propiedad.getHabitaciones()) %>">
                    <div class="property-image" style="background-image: url('<%= Html.escapar(request.getContextPath() + propiedad.getImagenPrincipal()) %>');"></div>
                    <div class="property-body">
                        <span class="property-badge"><%= Html.escapar(propiedad.getTipoOperacion()) %> · <%= Html.escapar(propiedad.getTipo()) %></span>
                        <h3><%= Html.escapar(propiedad.getTitulo()) %></h3>
                        <p class="muted"><%= Html.escapar(propiedad.getUbicacion()) %></p>
                        <div class="property-meta">
                            <span>$ <%= Html.escapar(propiedad.getPrecio()) %></span>
                            <span><%= Html.escapar(propiedad.getArea()) %> m2</span>
                            <span><%= Html.escapar(propiedad.getBanos()) %> baños</span>
                        </div>
                        <a class="btn btn-secondary" href="${pageContext.request.contextPath}/detalle-propiedad?id=<%= Html.escapar(propiedad.getId()) %>">Ver detalle</a>
                    </div>
                </article>
                <% } %>
            </div>
        </div>
    </section>
</main>

<jsp:include page="/WEB-INF/components/footer.jsp" />
