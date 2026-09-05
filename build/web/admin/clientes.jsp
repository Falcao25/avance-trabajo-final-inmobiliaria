<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="java.util.List,com.inmobiliaria.model.Cliente,com.inmobiliaria.model.MockData" %>
<%
    List<Cliente> clientes = (List<Cliente>) request.getAttribute("clientes");
    if (clientes == null) {
        clientes = MockData.obtenerClientes();
    }
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Inmobiliaria Aurora | Clientes</title>
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
                <h1>Contactos recibidos</h1>
            </div>
            <div class="table-wrap content-panel">
                <table class="data-table">
                    <thead>
                    <tr>
                        <th>Nombre</th>
                        <th>Correo</th>
                        <th>Telefono</th>
                        <th>Mensaje</th>
                    </tr>
                    </thead>
                    <tbody>
                    <% for (Cliente cliente : clientes) { %>
                    <tr>
                        <td><%= cliente.getNombre() %></td>
                        <td><%= cliente.getCorreo() %></td>
                        <td><%= cliente.getTelefono() %></td>
                        <td><%= cliente.getMensaje() %></td>
                    </tr>
                    <% } %>
                    </tbody>
                </table>
            </div>
        </div>
    </section>
</main>

<jsp:include page="/WEB-INF/components/footer.jsp" />
