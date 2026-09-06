<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
    String adminTitle = (String) request.getAttribute("adminTitle");
    if (adminTitle == null || adminTitle.isBlank()) {
        adminTitle = "Panel de administracion";
    }
    String adminSubtitle = (String) request.getAttribute("adminSubtitle");
    if (adminSubtitle == null || adminSubtitle.isBlank()) {
        adminSubtitle = "Gestion interna de propiedades, contactos y usuarios.";
    }
    String adminActive = (String) request.getAttribute("adminActive");
    if (adminActive == null || adminActive.isBlank()) {
        adminActive = request.getServletPath();
    }
    String contextPath = request.getContextPath();
    String dashboardClass = ("/admin".equals(adminActive) || "/admin/dashboard".equals(adminActive)) ? "is-active" : "";
    String propiedadesClass = (adminActive != null && (adminActive.startsWith("/admin/propiedades") || adminActive.startsWith("/admin/nueva-propiedad") || adminActive.startsWith("/admin/editar-propiedad"))) ? "is-active" : "";
    String clientesClass = (adminActive != null && adminActive.startsWith("/admin/clientes")) ? "is-active" : "";
    String usuariosClass = (adminActive != null && adminActive.startsWith("/admin/usuarios")) ? "is-active" : "";
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Inmobiliaria Aurora | <%= adminTitle %></title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin.css">
</head>
<body class="admin-body">
<div class="admin-shell">
    <aside class="admin-sidebar">
        <a class="admin-brand" href="<%= contextPath %>/admin">
            <img class="admin-brand-logo" src="${pageContext.request.contextPath}/img/logo/logo.svg" alt="Inmobiliaria Aurora">
            <span class="admin-brand-text">
                <strong>Inmobiliaria Aurora</strong>
                <small>Centro de administracion</small>
            </span>
        </a>
        <p class="admin-sidebar-note">Espacio privado para dar de alta propiedades, revisar contactos y gestionar usuarios.</p>

        <nav class="admin-nav" aria-label="Navegacion de administracion">
            <a class="<%= dashboardClass %>" href="<%= contextPath %>/admin/dashboard">Panel general</a>
            <a class="<%= propiedadesClass %>" href="<%= contextPath %>/admin/propiedades">Propiedades</a>
            <a class="<%= clientesClass %>" href="<%= contextPath %>/admin/clientes">Contactos</a>
            <a class="<%= usuariosClass %>" href="<%= contextPath %>/admin/usuarios">Usuarios</a>
        </nav>

        <div class="admin-sidebar-actions">
            <a class="admin-btn admin-btn-ghost" href="<%= contextPath %>/index.jsp">Volver al sitio</a>
            <a class="admin-btn admin-btn-secondary" href="<%= contextPath %>/login">Cerrar sesion</a>
        </div>
    </aside>

    <div class="admin-main">
        <header class="admin-topbar">
            <div class="admin-topbar-copy">
                <span class="admin-pill">Panel interno</span>
                <h1><%= adminTitle %></h1>
                <p><%= adminSubtitle %></p>
            </div>
            <div class="admin-topbar-meta">
                <span class="admin-badge">Registro de propiedades</span>
                <span class="admin-muted">Acceso administrativo separado del sitio publico</span>
            </div>
        </header>

        <main class="admin-content">
