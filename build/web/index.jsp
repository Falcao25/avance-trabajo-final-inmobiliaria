<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="java.util.List,com.inmobiliaria.model.Propiedad,com.inmobiliaria.model.MockData" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Inmobiliaria Aurora | Inicio</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/styles.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/layout.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/home.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/propiedades.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/responsive.css">
</head>
<body>
<jsp:include page="/WEB-INF/components/header.jsp" />
<jsp:include page="/WEB-INF/components/navbar.jsp" />

<main class="page-main">
    <section class="hero">
        <div class="container hero-grid">
            <div class="hero-copy">
                <span class="eyebrow">Inmobiliaria moderna en Lima</span>
                <h1>Encuentra la propiedad ideal para vivir, invertir o alquilar.</h1>
                <p>Explora casas, departamentos y terrenos con una experiencia clara, rápida y profesional. Esta primera versión trabaja con datos mock para validar la estructura del proyecto.</p>
                <div class="hero-actions">
                    <a class="btn btn-primary" href="${pageContext.request.contextPath}/propiedades">Ver propiedades</a>
                    <a class="btn btn-secondary" href="${pageContext.request.contextPath}/contacto">Hablar con un asesor</a>
                </div>
                <div class="hero-stats">
                    <div class="stat card">
                        <strong>120+</strong>
                        <span>Propiedades gestionadas</span>
                    </div>
                    <div class="stat card">
                        <strong>18</strong>
                        <span>Distritos cubiertos</span>
                    </div>
                    <div class="stat card">
                        <strong>24/7</strong>
                        <span>Atención comercial</span>
                    </div>
                </div>
            </div>
            <div class="hero-panel">
                <div class="hero-illustration"></div>
            </div>
        </div>
    </section>

    <section class="section">
        <div class="container">
            <div class="section-title">
                <span class="eyebrow">Buscador</span>
                <h2>Encuentra propiedades por operación, tipo, ubicación y presupuesto</h2>
            </div>
            <div class="search-panel">
                <form class="search-strip" action="${pageContext.request.contextPath}/propiedades" method="get">
                    <div class="form-field">
                        <label for="q">Buscar</label>
                        <input id="q" name="q" type="text" placeholder="Casa en Surco">
                    </div>
                    <div class="form-field">
                        <label for="operacion">Operación</label>
                        <select id="operacion" name="operacion">
                            <option value="todas">Todas</option>
                            <option value="venta">Venta</option>
                            <option value="alquiler">Alquiler</option>
                        </select>
                    </div>
                    <div class="form-field">
                        <label for="tipo">Tipo</label>
                        <select id="tipo" name="tipo">
                            <option value="todos">Todos</option>
                            <option value="casa">Casa</option>
                            <option value="departamento">Departamento</option>
                            <option value="terreno">Terreno</option>
                        </select>
                    </div>
                    <button class="btn btn-primary" type="submit">Buscar</button>
                </form>
            </div>
        </div>
    </section>

    <section class="section">
        <div class="container">
            <div class="section-title">
                <span class="eyebrow">Destacadas</span>
                <h2>Propiedades recomendadas</h2>
            </div>
            <div class="property-grid">
                <%
                    List<Propiedad> destacadas = MockData.obtenerDestacadas();
                    for (Propiedad propiedad : destacadas) {
                %>
                <article class="card property-card">
                    <div class="property-image" style="background-image: url('<%= request.getContextPath() + propiedad.getImagenPrincipal() %>');"></div>
                    <div class="property-body">
                        <span class="property-badge"><%= propiedad.getTipoOperacion() %> · <%= propiedad.getTipo() %></span>
                        <h3><%= propiedad.getTitulo() %></h3>
                        <p class="muted"><%= propiedad.getUbicacion() %></p>
                        <div class="property-meta">
                            <span>$ <%= propiedad.getPrecio() %></span>
                            <span><%= propiedad.getArea() %> m2</span>
                            <span><%= propiedad.getHabitaciones() %> habs.</span>
                        </div>
                        <a class="btn btn-secondary" href="${pageContext.request.contextPath}/detalle-propiedad?id=<%= propiedad.getId() %>">Ver detalle</a>
                    </div>
                </article>
                <% } %>
            </div>
        </div>
    </section>

    <section class="section">
        <div class="container">
            <div class="section-title">
                <span class="eyebrow">Tipos de propiedad</span>
                <h2>Opciones pensadas para cada necesidad</h2>
            </div>
            <div class="property-types">
                <div class="type-card">
                    <h3>Casas</h3>
                    <p>Espacios amplios, jardines y ambientes listos para familias o proyectos a medida.</p>
                </div>
                <div class="type-card">
                    <h3>Departamentos</h3>
                    <p>Ubicaciones urbanas estratégicas para vivir con comodidad o generar renta mensual.</p>
                </div>
                <div class="type-card">
                    <h3>Terrenos</h3>
                    <p>Lotes urbanos y campestres con potencial para construir, desarrollar o invertir.</p>
                </div>
            </div>
        </div>
    </section>

    <section class="section">
        <div class="container">
            <div class="section-title">
                <span class="eyebrow">Beneficios</span>
                <h2>Una experiencia simple y profesional</h2>
            </div>
            <div class="benefits">
                <div class="benefit-card">
                    <h3>Asesoría clara</h3>
                    <p>Te guiamos con información ordenada para comparar opciones sin perder tiempo.</p>
                </div>
                <div class="benefit-card">
                    <h3>Publicación rápida</h3>
                    <p>La estructura queda lista para administrar propiedades desde un backend simple en Java Web.</p>
                </div>
                <div class="benefit-card">
                    <h3>Diseño responsive</h3>
                    <p>La interfaz se adapta a escritorio y móvil usando Flexbox y CSS Grid.</p>
                </div>
            </div>
        </div>
    </section>

    <section class="section section-cta">
        <div class="container">
            <div class="cta-panel">
                <div>
                    <span class="eyebrow">Contacto</span>
                    <h2>Agenda una visita o pide una cotización</h2>
                    <p class="muted">Usa el formulario de contacto para recibir seguimiento del equipo comercial.</p>
                </div>
                <a class="btn btn-primary" href="${pageContext.request.contextPath}/contacto">Ir a contacto</a>
            </div>
        </div>
    </section>
</main>

<jsp:include page="/WEB-INF/components/footer.jsp" />
