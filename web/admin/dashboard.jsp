<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="java.util.List,com.inmobiliaria.model.Propiedad,com.inmobiliaria.model.Contacto,com.inmobiliaria.model.Usuario,java.util.Collections,com.inmobiliaria.util.Html" %>
<%
    if (request.getAttribute("propiedades") == null) { response.sendRedirect(request.getContextPath() + "/admin/dashboard"); return; }
    request.setAttribute("adminTitle", "Panel general");
    request.setAttribute("adminSubtitle", "Resumen de las métricas del negocio.");
    request.setAttribute("adminActive", "/admin/dashboard");
    request.setAttribute("adminBootstrap", Boolean.TRUE);

    List<Propiedad> propiedades = (List<Propiedad>) request.getAttribute("propiedades");
    if (propiedades == null) {
        propiedades = Collections.emptyList();
    }
    List<Contacto> contactos = (List<Contacto>) request.getAttribute("contactos");
    if (contactos == null) {
        contactos = Collections.emptyList();
    }
    List<Usuario> usuarios = (List<Usuario>) request.getAttribute("usuarios");
    if (usuarios == null) {
        usuarios = Collections.emptyList();
    }
    long disponibles = propiedades.stream()
            .filter(propiedad -> "DISPONIBLE".equals(propiedad.getEstado()))
            .count();
    boolean propiedadesDisponibles = request.getAttribute("errorBaseDatos") == null;
%>
<jsp:include page="/WEB-INF/components/admin-shell-start.jsp" />

<section class="row g-3" aria-label="Métricas del negocio">
    <div class="col-12 col-md-6 col-xl-3">
    <article class="card admin-card h-100">
        <strong><%= propiedadesDisponibles ? String.valueOf(propiedades.size()) : "No disponible" %></strong>
        <span>Propiedades registradas</span>
    </article>
    </div>
    <div class="col-12 col-md-6 col-xl-3">
    <article class="card admin-card h-100">
        <strong><%= propiedadesDisponibles ? String.valueOf(disponibles) : "No disponible" %></strong>
        <span>Propiedades disponibles</span>
    </article>
    </div>
    <div class="col-12 col-md-6 col-xl-3">
    <article class="card admin-card h-100">
        <strong><%= request.getAttribute("errorContactos") == null ? String.valueOf(contactos.size()) : "No disponible" %></strong>
        <span>Contactos recibidos</span>
    </article>
    </div>
    <div class="col-12 col-md-6 col-xl-3">
    <article class="card admin-card h-100">
        <strong><%= request.getAttribute("errorUsuarios") == null ? String.valueOf(usuarios.size()) : "No disponible" %></strong>
        <span>Usuarios del sistema</span>
    </article>
    </div>
</section>

<jsp:include page="/WEB-INF/components/admin-shell-end.jsp" />
