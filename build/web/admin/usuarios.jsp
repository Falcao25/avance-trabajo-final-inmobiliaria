<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="java.util.List,com.inmobiliaria.model.Usuario,com.inmobiliaria.model.MockData" %>
<%
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
    <title>Inmobiliaria Aurora | Usuarios</title>
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
            <div class="section-title">
                <span class="eyebrow">Administración</span>
                <h1>Usuarios del sistema</h1>
            </div>
            <div class="table-wrap content-panel">
                <table class="data-table">
                    <thead>
                    <tr>
                        <th>Nombre</th>
                        <th>Correo</th>
                        <th>Rol</th>
                        <th>Activo</th>
                    </tr>
                    </thead>
                    <tbody>
                    <% for (Usuario usuario : usuarios) { %>
                    <tr>
                        <td><%= usuario.getNombre() %></td>
                        <td><%= usuario.getCorreo() %></td>
                        <td><%= usuario.getRol() %></td>
                        <td><span class="status-pill"><%= usuario.isActivo() ? "Si" : "No" %></span></td>
                    </tr>
                    <% } %>
                    </tbody>
                </table>
            </div>
        </div>
    </section>
</main>

<jsp:include page="/WEB-INF/components/footer.jsp" />
