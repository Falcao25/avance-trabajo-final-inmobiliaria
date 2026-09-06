<header class="site-header">
    <div class="container header-bar">
        <a class="brand" href="${pageContext.request.contextPath}/index.jsp">
            <img class="brand-logo" src="${pageContext.request.contextPath}/img/logo/logo.svg" alt="Inmobiliaria Aurora">
            <span class="brand-text">
                <strong>Inmobiliaria Aurora</strong>
                <small>Viviendas, terrenos y alquileres</small>
            </span>
        </a>
        <jsp:include page="/WEB-INF/components/navbar.jsp" />
        <div class="header-actions">
            <a class="header-link" >Contacto</a>
            <!-- <a class="header-link header-link-primary" href="${pageContext.request.contextPath}/login">Ingresar</a> -->
        </div>
    </div>
</header>
