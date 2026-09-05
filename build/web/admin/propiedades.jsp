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
    <title>Inmobiliaria Aurora | Admin Propiedades</title>
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
                <h1>Listado de propiedades</h1>
            </div>
            <div class="home-highlight">
                <a class="btn btn-primary" href="${pageContext.request.contextPath}/admin/nueva-propiedad">Nueva propiedad</a>
                <a class="btn btn-secondary" href="${pageContext.request.contextPath}/admin/dashboard">Volver al dashboard</a>
            </div>
            <div class="table-wrap content-panel" style="margin-top: 1.25rem;">
                <table class="data-table">
                    <thead>
                    <tr>
                        <th>ID</th>
                        <th>Titulo</th>
                        <th>Operacion</th>
                        <th>Tipo</th>
                        <th>Precio</th>
                        <th>Acciones</th>
                    </tr>
                    </thead>
                    <tbody>
                    <% for (Propiedad propiedad : propiedades) { %>
                    <tr>
                        <td><%= propiedad.getId() %></td>
                        <td><%= propiedad.getTitulo() %></td>
                        <td><span class="status-pill"><%= propiedad.getTipoOperacion() %></span></td>
                        <td><%= propiedad.getTipo() %></td>
                        <td>$ <%= propiedad.getPrecio() %></td>
                        <td>
                            <div class="action-group">
                                <a class="btn btn-secondary" href="${pageContext.request.contextPath}/admin/editar-propiedad?id=<%= propiedad.getId() %>">Editar</a>
                                <form action="${pageContext.request.contextPath}/admin/propiedades" method="post" style="display:inline;">
                                    <input type="hidden" name="accion" value="eliminar">
                                    <input type="hidden" name="id" value="<%= propiedad.getId() %>">
                                    <button class="btn btn-primary" type="submit">Eliminar</button>
                                </form>
                            </div>
                        </td>
                    </tr>
                    <% } %>
                    </tbody>
                </table>
            </div>
        </div>
    </section>
</main>

<jsp:include page="/WEB-INF/components/footer.jsp" />
