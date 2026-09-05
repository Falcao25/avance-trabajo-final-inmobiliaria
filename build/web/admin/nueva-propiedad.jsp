<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Inmobiliaria Aurora | Nueva Propiedad</title>
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
        <div class="container">
            <div class="card form-card">
                <div class="section-title">
                    <span class="eyebrow">Administración</span>
                    <h1>Crear propiedad</h1>
                </div>
                <% if (request.getAttribute("mensajeExito") != null) { %>
                <p class="status-pill"><%= request.getAttribute("mensajeExito") %></p>
                <% } %>
                <form class="form-grid" action="${pageContext.request.contextPath}/admin/nueva-propiedad" method="post">
                    <div class="form-field">
                        <label for="titulo">Título</label>
                        <input id="titulo" name="titulo" type="text" required>
                    </div>
                    <div class="form-field">
                        <label for="precio">Precio</label>
                        <input id="precio" name="precio" type="number" required>
                    </div>
                    <div class="form-field">
                        <label for="ubicacion">Ubicación</label>
                        <input id="ubicacion" name="ubicacion" type="text" required>
                    </div>
                    <div class="form-field">
                        <label for="tipoOperacion">Operación</label>
                        <select id="tipoOperacion" name="tipoOperacion">
                            <option>Venta</option>
                            <option>Alquiler</option>
                        </select>
                    </div>
                    <div class="form-field">
                        <label for="tipo">Tipo</label>
                        <select id="tipo" name="tipo">
                            <option>Casa</option>
                            <option>Departamento</option>
                            <option>Terreno</option>
                        </select>
                    </div>
                    <div class="form-field">
                        <label for="area">Area</label>
                        <input id="area" name="area" type="number" step="0.1">
                    </div>
                    <div class="form-field">
                        <label for="habitaciones">Habitaciones</label>
                        <input id="habitaciones" name="habitaciones" type="number">
                    </div>
                    <div class="form-field">
                        <label for="banos">Baños</label>
                        <input id="banos" name="banos" type="number">
                    </div>
                    <div class="form-field" style="grid-column: 1 / -1;">
                        <label for="descripcion">Descripcion</label>
                        <textarea id="descripcion" name="descripcion" rows="6"></textarea>
                    </div>
                    <div>
                        <button class="btn btn-primary" type="submit">Guardar</button>
                    </div>
                </form>
                <p class="form-note">Esta entrega solo deja lista la pantalla y el flujo visual. La persistencia real se conectara con MySQL despues.</p>
            </div>
        </div>
    </section>
</main>

<jsp:include page="/WEB-INF/components/footer.jsp" />
