<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Inmobiliaria Aurora | Nosotros</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/styles.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/layout.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/home.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/responsive.css">
</head>
<body>
<jsp:include page="/WEB-INF/components/header.jsp" />

<main class="page-main">
    <section class="section">
        <div class="container">
            <div class="section-title">
                <span class="eyebrow">Nosotros</span>
                <h1>Una inmobiliaria enfocada en experiencia, confianza y acompañamiento</h1>
            </div>
            <div class="feature-grid">
                <div class="feature-card">
                    <h3>Quiénes somos</h3>
                    <p>Inmobiliaria Aurora es una propuesta web moderna para administrar propiedades, clientes y procesos comerciales.</p>
                </div>
                <div class="feature-card">
                    <h3>Misión</h3>
                    <p>Conectar personas con propiedades ideales mediante una experiencia clara, confiable y visualmente ordenada.</p>
                </div>
                <div class="feature-card">
                    <h3>Visión</h3>
                    <p>Ser una referencia local en servicios inmobiliarios digitales con atención cercana y soluciones simples.</p>
                </div>
            </div>

            <div class="section" style="padding-bottom: 0;">
                <div class="section-title">
                    <span class="eyebrow">Valores</span>
                    <h2>Principios que guían nuestro trabajo</h2>
                </div>
                <div class="benefits">
                    <div class="benefit-card">
                        <h3>Transparencia</h3>
                        <p>Información clara en cada paso del proceso.</p>
                    </div>
                    <div class="benefit-card">
                        <h3>Servicio</h3>
                        <p>Acompañamiento cercano para compradores, vendedores y arrendatarios.</p>
                    </div>
                    <div class="benefit-card">
                        <h3>Innovación</h3>
                        <p>Herramientas web sencillas para administrar el negocio inmobiliario.</p>
                    </div>
                </div>
            </div>
        </div>
    </section>
</main>

<jsp:include page="/WEB-INF/components/footer.jsp" />
