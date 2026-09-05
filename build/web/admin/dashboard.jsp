<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="java.util.List,com.inmobiliaria.model.Propiedad,com.inmobiliaria.model.Cliente,com.inmobiliaria.model.Usuario,com.inmobiliaria.model.MockData" %>
<%
    List<Propiedad> propiedades = (List<Propiedad>) request.getAttribute("propiedades");
    if (propiedades == null) {
        propiedades = MockData.obtenerPropiedades();
    }
    List<Cliente> clientes = (List<Cliente>) request.getAttribute("clientes");
    if (clientes == null) {
        clientes = MockData.obtenerClientes();
    }
    List<Usuario> usuarios = (List<Usuario>) request.getAttribute("usuarios");
    if (usuarios == null) {
        usuarios = MockData.obtenerUsuarios();
    }
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Inmobiliaria Aurora | Dashboard</title>
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
            <div class="section-title">
                <span class="eyebrow">Administración</span>
                <h1>Dashboard</h1>
            </div>
            <div class="admin-grid">
                <div class="card admin-stat">
                    <strong><%= propiedades.size() %></strong>
                    <span>Propiedades</span>
                </div>
                <div class="card admin-stat">
                    <strong><%= clientes.size() %></strong>
                    <span>Contactos</span>
                </div>
                <div class="card admin-stat">
                    <strong><%= usuarios.size() %></strong>
                    <span>Usuarios</span>
                </div>
                <div class="card admin-stat">
                    <strong>Demo</strong>
                    <span>Estado de la primera entrega</span>
                </div>
            </div>
            <div class="home-highlight">
                <a class="btn btn-primary" href="${pageContext.request.contextPath}/admin/propiedades">Gestionar propiedades</a>
                <a class="btn btn-secondary" href="${pageContext.request.contextPath}/admin/clientes">Ver contactos</a>
            </div>
        </div>
    </section>
</main>

<jsp:include page="/WEB-INF/components/footer.jsp" />
