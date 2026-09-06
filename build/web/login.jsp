<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Administración | Inmobiliaria Aurora</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/styles.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin.css">
</head>
<body class="admin-login-body">
<main class="admin-login">
    <div class="admin-login-card">
        <a class="admin-login-brand" href="${pageContext.request.contextPath}/index.jsp">
            <img src="${pageContext.request.contextPath}/img/logo/logo.svg" alt="Inmobiliaria Aurora">
            <span>Inmobiliaria Aurora</span>
        </a>
        <div class="admin-login-heading">
            <span class="admin-pill">Administración</span>
            <h1>Iniciar sesión</h1>
            <p>Acceso privado para registrar y gestionar propiedades.</p>
        </div>
        <% if (request.getAttribute("errorLogin") != null) { %>
        <p class="admin-error"><%= request.getAttribute("errorLogin") %></p>
        <% } %>
        <form class="admin-login-form" action="${pageContext.request.contextPath}/login" method="post" data-login-form>
            <div class="admin-field">
                <label for="usuario">Usuario</label>
                <input id="usuario" name="usuario" type="email" required>
            </div>
            <div class="admin-field">
                <label for="password">Contraseña</label>
                <input id="password" name="password" type="password" required data-login-password>
            </div>
            <div class="admin-login-actions">
                <button class="admin-btn admin-btn-secondary" type="button" data-toggle-password>Mostrar</button>
                <button class="admin-btn admin-btn-primary" type="submit">Entrar al panel</button>
            </div>
        </form>
        <a class="admin-login-back" href="${pageContext.request.contextPath}/index.jsp">Volver al sitio público</a>
    </div>
</main>
<script src="${pageContext.request.contextPath}/js/login.js"></script>
</body>
</html>
