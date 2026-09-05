<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Inmobiliaria Aurora | Login</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/styles.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/layout.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/propiedades.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/responsive.css">
</head>
<body>
<jsp:include page="/WEB-INF/components/header.jsp" />

<main class="page-main">
    <section class="section">
        <div class="container" style="max-width: 560px;">
            <div class="card form-card">
                <div class="section-title">
                    <span class="eyebrow">Administración</span>
                    <h1>Iniciar sesión</h1>
                    <p>Acceso demo para la primera versión. Usa <strong>admin@inmobiliaria.com</strong> y <strong>admin123</strong>.</p>
                </div>
                <% if (request.getAttribute("errorLogin") != null) { %>
                <p class="status-pill" style="background: rgba(220, 38, 38, 0.1); color: #b91c1c;"><%= request.getAttribute("errorLogin") %></p>
                <% } %>
                <form class="form-grid" action="${pageContext.request.contextPath}/login" method="post" data-login-form>
                    <div class="form-field" style="grid-column: 1 / -1;">
                        <label for="usuario">Usuario</label>
                        <input id="usuario" name="usuario" type="email" required>
                    </div>
                    <div class="form-field" style="grid-column: 1 / -1;">
                        <label for="password">Contraseña</label>
                        <input id="password" name="password" type="password" required data-login-password>
                    </div>
                    <div class="action-group" style="grid-column: 1 / -1;">
                        <button class="btn btn-secondary" type="button" data-toggle-password>Mostrar</button>
                        <button class="btn btn-primary" type="submit">Entrar</button>
                    </div>
                </form>
            </div>
        </div>
    </section>
</main>

<jsp:include page="/WEB-INF/components/footer.jsp" />
