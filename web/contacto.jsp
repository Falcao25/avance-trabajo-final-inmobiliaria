<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Inmobiliaria Aurora | Contacto</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/styles.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/layout.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/propiedades.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/responsive.css">
</head>
<body>
<jsp:include page="/WEB-INF/components/header.jsp" />

<main class="page-main">
    <section class="section">
        <div class="container detail-layout">
            <div class="card form-card">
                <div class="section-title">
                    <span class="eyebrow">Contacto</span>
                    <h1>Escríbenos y te ayudamos a encontrar tu próxima propiedad</h1>
                </div>
                <% if (request.getAttribute("mensajeExito") != null) { %>
                <p class="status-pill"><%= request.getAttribute("mensajeExito") %></p>
                <% } %>
                <form class="form-grid" action="${pageContext.request.contextPath}/contacto" method="post">
                    <div class="form-field">
                        <label for="nombre">Nombre</label>
                        <input id="nombre" name="nombre" type="text" required>
                    </div>
                    <div class="form-field">
                        <label for="correo">Correo</label>
                        <input id="correo" name="correo" type="email" required>
                    </div>
                    <div class="form-field">
                        <label for="telefono">Teléfono</label>
                        <input id="telefono" name="telefono" type="tel" required>
                    </div>
                    <div class="form-field" style="grid-column: 1 / -1;">
                        <label for="mensaje">Mensaje</label>
                        <textarea id="mensaje" name="mensaje" rows="6" required></textarea>
                    </div>
                    <div>
                        <button class="btn btn-primary" type="submit">Enviar mensaje</button>
                    </div>
                </form>
            </div>
            <aside class="card form-card">
                <h2>Información comercial</h2>
                <p class="muted">Horarios de atención, teléfonos y correo de soporte comercial.</p>
                <div class="detail-meta">
                    <div class="meta-box">
                        <span>Teléfono</span>
                        <strong>+51 987 654 321</strong>
                    </div>
                    <div class="meta-box">
                        <span>Correo</span>
                        <strong>ventas@inmobiliaria.com</strong>
                    </div>
                    <div class="meta-box">
                        <span>Horario</span>
                        <strong>Lun - Sáb / 9:00 a 18:00</strong>
                    </div>
                    <div class="meta-box">
                        <span>Ubicación</span>
                        <strong>Lima, Perú</strong>
                    </div>
                </div>
            </aside>
        </div>
    </section>
</main>

<jsp:include page="/WEB-INF/components/footer.jsp" />
