<header class="navbar navbar-expand-lg border-bottom py-3">
    <div class="container">
        <a class="navbar-brand d-flex align-items-center gap-3" href="${pageContext.request.contextPath}/index.jsp">
            <img src="${pageContext.request.contextPath}/img/logo/logo.svg" width="42" height="42" alt="Inmobiliaria Aurora">
            <span class="d-flex flex-column fs-6">
                <strong class="fs-6">Inmobiliaria Aurora</strong>
                <small class="text-body-secondary">Viviendas, terrenos y alquileres</small>
            </span>
        </a>
        <button class="navbar-toggler" type="button" aria-label="Abrir menú" aria-expanded="false"
                aria-controls="menuInicio" data-menu-toggle data-bootstrap-menu>
            <span class="navbar-toggler-icon"></span>
        </button>
        <nav id="menuInicio" class="collapse navbar-collapse" aria-label="Navegación principal" data-nav-menu>
            <ul class="navbar-nav mx-auto gap-lg-3">
                <li class="nav-item"><a class="nav-link active" aria-current="page" href="${pageContext.request.contextPath}/index.jsp">Inicio</a></li>
                <li class="nav-item"><a class="nav-link" href="${pageContext.request.contextPath}/propiedades">Propiedades</a></li>
                <li class="nav-item"><a class="nav-link" href="${pageContext.request.contextPath}/nosotros.jsp">Nosotros</a></li>
                <li class="nav-item"><a class="nav-link" href="${pageContext.request.contextPath}/contacto">Contacto</a></li>
            </ul>
            <a class="btn btn-secondary" href="tel:+51987654321">+51 987 654 321</a>
        </nav>
    </div>
</header>
