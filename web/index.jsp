<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="java.util.List,com.inmobiliaria.model.Propiedad,com.inmobiliaria.model.MockData" %>
<% request.setAttribute("publicBootstrap", Boolean.TRUE); %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Inmobiliaria Aurora | Inicio</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/bootstrap/bootstrap.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/styles.css">
</head>
<body>
<jsp:include page="/WEB-INF/components/header-bootstrap.jsp" />

<main class="pb-5">
    <section class="py-5">
        <div class="container">
        <div class="row g-4 align-items-center">
            <div class="col-12 col-lg-6 col-xl-7">
                <span class="badge bg-secondary-subtle text-dark align-self-start">Inmobiliaria moderna en Lima</span>
                <h1 class="display-3 fw-medium">Encuentra la propiedad ideal para vivir, invertir o alquilar.</h1>
                <p>Explora casas, departamentos y terrenos con una experiencia clara, rápida y profesional. Esta primera versión trabaja con datos mock para validar la estructura del proyecto.</p>
                <div class="gap-3 mb-4 d-flex flex-wrap">
                    <a class="btn btn-primary" href="${pageContext.request.contextPath}/propiedades">Ver propiedades</a>
                    <a class="btn btn-secondary" href="${pageContext.request.contextPath}/contacto">Hablar con un asesor</a>
                </div>
                <div class="row g-3">
                    <div class="col-12 col-sm-4"><div class="card-body card h-100">
                        <strong class="fs-4 text-body-emphasis">120+</strong>
                        <span>Propiedades gestionadas</span>
                    </div></div>
                    <div class="col-12 col-sm-4"><div class="card-body card h-100">
                        <strong class="fs-4 text-body-emphasis">18</strong>
                        <span>Distritos cubiertos</span>
                    </div></div>
                    <div class="col-12 col-sm-4"><div class="card-body card h-100">
                        <strong class="fs-4 text-body-emphasis">24/7</strong>
                        <span>Atención comercial</span>
                    </div></div>
                </div>
            </div>
            <div class="col-12 col-lg-6 col-xl-5">
                <div class="card p-3">
                    <img class="img-fluid rounded" src="${pageContext.request.contextPath}/img/propiedades/propiedad-casa.png" alt="Casa destacada de Inmobiliaria Aurora">
                </div>
            </div>
        </div>
        </div>
    </section>

    <section class="py-5">
        <div class="container">
            <div class="d-flex flex-column gap-2 mb-4">
                <span class="badge bg-secondary-subtle text-dark align-self-start">Buscador</span>
                <h2 class="display-6 fw-medium">Encuentra propiedades por operación, tipo, ubicación y presupuesto</h2>
            </div>
            <div class="card card-body">
                <form class="row g-3 align-items-end" action="${pageContext.request.contextPath}/propiedades" method="get">
                    <div class="d-flex flex-column gap-2 col-12 col-md-4 col-lg-5">
                        <label for="q">Buscar</label>
                        <input class="form-control" id="q" name="q" type="text" placeholder="Casa en Surco">
                    </div>
                    <div class="d-flex flex-column gap-2 col-12 col-md-4 col-lg-3">
                        <label for="operacion">Operación</label>
                        <select class="form-select" id="operacion" name="operacion">
                            <option value="todas">Todas</option>
                            <option value="venta">Venta</option>
                            <option value="alquiler">Alquiler</option>
                        </select>
                    </div>
                    <div class="d-flex flex-column gap-2 col-12 col-md-4 col-lg-2">
                        <label for="tipo">Tipo</label>
                        <select class="form-select" id="tipo" name="tipo">
                            <option value="todos">Todos</option>
                            <option value="casa">Casa</option>
                            <option value="departamento">Departamento</option>
                            <option value="terreno">Terreno</option>
                        </select>
                    </div>
                    <div class="col-12 col-lg-2 d-grid">
                        <button class="btn btn-primary" type="submit">Buscar</button>
                    </div>
                </form>
            </div>
        </div>
    </section>

    <section class="py-5">
        <div class="container">
            <div class="d-flex flex-column gap-2 mb-4">
                <span class="badge bg-secondary-subtle text-dark align-self-start">Destacadas</span>
                <h2 class="display-6 fw-medium">Propiedades recomendadas</h2>
            </div>
            <div class="row g-4">
                <%
                    List<Propiedad> destacadas = MockData.obtenerDestacadas();
                    for (Propiedad propiedad : destacadas) {
                %>
                <div class="col-12 col-md-6 col-lg-4"><article class="card overflow-hidden h-100">
                    <div class="ratio ratio-16x9"><img class="w-100 h-100 object-fit-cover" src="<%= request.getContextPath() + propiedad.getImagenPrincipal() %>" alt="Propiedad recomendada"></div>
                    <div class="card-body d-flex flex-column">
                        <span class="badge bg-secondary-subtle text-dark align-self-start"><%= propiedad.getTipoOperacion() %> · <%= propiedad.getTipo() %></span>
                        <h3 class="fs-4 fw-semibold"><%= propiedad.getTitulo() %></h3>
                        <p class="text-body-secondary"><%= propiedad.getUbicacion() %></p>
                        <div class="d-flex flex-wrap gap-3 my-3 text-body-secondary">
                            <span>$ <%= propiedad.getPrecio() %></span>
                            <span><%= propiedad.getArea() %> m2</span>
                            <span><%= propiedad.getHabitaciones() %> habs.</span>
                        </div>
                        <a class="btn btn-secondary align-self-start mt-auto" href="${pageContext.request.contextPath}/detalle-propiedad?id=<%= propiedad.getId() %>">Ver detalle</a>
                    </div>
                </article></div>
                <% } %>
            </div>
        </div>
    </section>

    <section class="py-5">
        <div class="container">
            <div class="d-flex flex-column gap-2 mb-4">
                <span class="badge bg-secondary-subtle text-dark align-self-start">Tipos de propiedad</span>
                <h2 class="display-6 fw-medium">Opciones pensadas para cada necesidad</h2>
            </div>
            <div class="row g-3">
                <div class="col-12 col-md-4"><div class="card-body card h-100">
                    <h3 class="fs-4 fw-semibold">Casas</h3>
                    <p>Espacios amplios, jardines y ambientes listos para familias o proyectos a medida.</p>
                </div></div>
                <div class="col-12 col-md-4"><div class="card-body card h-100">
                    <h3 class="fs-4 fw-semibold">Departamentos</h3>
                    <p>Ubicaciones urbanas estratégicas para vivir con comodidad o generar renta mensual.</p>
                </div></div>
                <div class="col-12 col-md-4"><div class="card-body card h-100">
                    <h3 class="fs-4 fw-semibold">Terrenos</h3>
                    <p>Lotes urbanos y campestres con potencial para construir, desarrollar o invertir.</p>
                </div></div>
            </div>
        </div>
    </section>

    <section class="py-5">
        <div class="container">
            <div class="d-flex flex-column gap-2 mb-4">
                <span class="badge bg-secondary-subtle text-dark align-self-start">Beneficios</span>
                <h2 class="display-6 fw-medium">Una experiencia simple y profesional</h2>
            </div>
            <div class="row g-3">
                <div class="col-12 col-md-4"><div class="card-body card h-100">
                    <h3 class="fs-4 fw-semibold">Asesoría clara</h3>
                    <p>Te guiamos con información ordenada para comparar opciones sin perder tiempo.</p>
                </div></div>
                <div class="col-12 col-md-4"><div class="card-body card h-100">
                    <h3 class="fs-4 fw-semibold">Publicación rápida</h3>
                    <p>La estructura queda lista para administrar propiedades desde un backend simple en Java Web.</p>
                </div></div>
                <div class="col-12 col-md-4"><div class="card-body card h-100">
                    <h3 class="fs-4 fw-semibold">Diseño responsive</h3>
                    <p>La interfaz se adapta a escritorio y móvil con la rejilla y los componentes de Bootstrap.</p>
                </div></div>
            </div>
        </div>
    </section>

    <section class="py-5">
        <div class="container">
            <div class="card card-body d-flex flex-column flex-lg-row justify-content-between align-items-lg-center gap-3">
                <div>
                    <span class="badge bg-secondary-subtle text-dark align-self-start">Contacto</span>
                    <h2 class="display-6 fw-medium">Agenda una visita o pide una cotización</h2>
                    <p class="text-body-secondary">Usa el formulario de contacto para recibir seguimiento del equipo comercial.</p>
                </div>
                <a class="btn btn-primary" href="${pageContext.request.contextPath}/contacto">Ir a contacto</a>
            </div>
        </div>
    </section>
</main>

<jsp:include page="/WEB-INF/components/footer-bootstrap.jsp" />
