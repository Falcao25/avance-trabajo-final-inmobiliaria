<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="java.util.List,com.inmobiliaria.model.Propiedad,com.inmobiliaria.model.Cliente,com.inmobiliaria.model.Usuario,com.inmobiliaria.model.MockData" %>
<%
    request.setAttribute("adminTitle", "Panel general");
    request.setAttribute("adminSubtitle", "Resumen del negocio y formulario rápido para registrar propiedades.");
    request.setAttribute("adminActive", "/admin/dashboard");

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
<jsp:include page="/WEB-INF/components/admin-shell-start.jsp" />

<section class="admin-grid">
    <article class="admin-card">
        <strong><%= propiedades.size() %></strong>
        <span>Propiedades activas</span>
    </article>
    <article class="admin-card">
        <strong><%= clientes.size() %></strong>
        <span>Contactos recibidos</span>
    </article>
    <article class="admin-card">
        <strong><%= usuarios.size() %></strong>
        <span>Usuarios del sistema</span>
    </article>
    <article class="admin-card">
        <strong>MySQL</strong>
        <span>Propiedades conectadas a la base de datos</span>
    </article>
</section>

<section class="admin-split">
    <article class="admin-panel">
        <div class="admin-panel-header">
            <div>
                <span class="admin-pill">Alta de propiedades</span>
                <h2>Registrar propiedad</h2>
                <p>Este formulario vive dentro del panel privado, separado del sitio público.</p>
            </div>
        </div>

        <% if (request.getAttribute("mensajeExito") != null) { %>
        <p class="admin-badge"><%= request.getAttribute("mensajeExito") %></p>
        <% } %>
        <% if (request.getAttribute("errorBaseDatos") != null) { %>
        <p class="admin-error"><%= request.getAttribute("errorBaseDatos") %></p>
        <% } %>

        <form class="admin-form" action="${pageContext.request.contextPath}/admin/dashboard" method="post">
            <div class="admin-field">
                <label for="titulo">Título</label>
                <input id="titulo" name="titulo" type="text" required>
            </div>
            <div class="admin-field">
                <label for="precio">Precio</label>
                <input id="precio" name="precio" type="number" required>
            </div>
            <div class="admin-field">
                <label for="ubicacion">Ubicación</label>
                <input id="ubicacion" name="ubicacion" type="text" required>
            </div>
            <div class="admin-field">
                <label for="tipoOperacion">Operación</label>
                <select id="tipoOperacion" name="tipoOperacion">
                    <option>Venta</option>
                    <option>Alquiler</option>
                </select>
            </div>
            <div class="admin-field">
                <label for="tipo">Tipo</label>
                <select id="tipo" name="tipo">
                    <option>Casa</option>
                    <option>Departamento</option>
                    <option>Terreno</option>
                </select>
            </div>
            <div class="admin-field">
                <label for="area">Area</label>
                <input id="area" name="area" type="number" step="0.01" min="0" required>
            </div>
            <div class="admin-field">
                <label for="habitaciones">Habitaciones</label>
                <input id="habitaciones" name="habitaciones" type="number">
            </div>
            <div class="admin-field">
                <label for="banos">Baños</label>
                <input id="banos" name="banos" type="number">
            </div>
            <div class="admin-field" style="grid-column: 1 / -1;">
                <label for="descripcion">Descripción</label>
                <textarea id="descripcion" name="descripcion" rows="6"></textarea>
            </div>
            <div class="admin-form-actions" style="grid-column: 1 / -1;">
                <button class="admin-btn admin-btn-primary" type="submit">Guardar propiedad</button>
                <a class="admin-btn admin-btn-secondary" href="${pageContext.request.contextPath}/admin/nueva-propiedad">Abrir formulario completo</a>
            </div>
        </form>
    </article>

    <aside class="admin-panel admin-stack">
        <div class="admin-panel-header">
            <div>
                <span class="admin-pill">Atajos</span>
                <h3>Acciones rápidas</h3>
                <p>Lo más usado para operar el panel sin salir de esta pantalla.</p>
            </div>
        </div>
        <a class="admin-btn admin-btn-ghost" href="${pageContext.request.contextPath}/admin/propiedades">Ver listado de propiedades</a>
        <a class="admin-btn admin-btn-ghost" href="${pageContext.request.contextPath}/admin/clientes">Revisar contactos</a>
        <a class="admin-btn admin-btn-ghost" href="${pageContext.request.contextPath}/admin/usuarios">Administrar usuarios</a>

        <div class="admin-panel-header" style="margin-top: 0.5rem;">
            <div>
                <span class="admin-pill">Resumen</span>
                <h3>Últimas propiedades</h3>
            </div>
        </div>
        <div class="admin-table-wrap">
            <table class="admin-table">
                <thead>
                <tr>
                    <th>Título</th>
                    <th>Tipo</th>
                    <th>Precio</th>
                </tr>
                </thead>
                <tbody>
                <% for (int i = 0; i < Math.min(propiedades.size(), 4); i++) {
                    Propiedad propiedad = propiedades.get(i);
                %>
                <tr>
                    <td><%= propiedad.getTitulo() %></td>
                    <td><span class="admin-status"><%= propiedad.getTipoOperacion() %></span></td>
                    <td>$ <%= propiedad.getPrecio() %></td>
                </tr>
                <% } %>
                </tbody>
            </table>
        </div>
    </aside>
</section>

<section class="admin-panel">
    <div class="admin-panel-header">
        <div>
            <span class="admin-pill">Inventario</span>
            <h2>Propiedades registradas</h2>
            <p>Vista rápida de las publicaciones ya cargadas.</p>
        </div>
        <a class="admin-btn admin-btn-secondary" href="${pageContext.request.contextPath}/admin/propiedades">Ir al listado completo</a>
    </div>
    <div class="admin-table-wrap">
        <table class="admin-table">
            <thead>
            <tr>
                <th>ID</th>
                <th>Título</th>
                <th>Operación</th>
                <th>Tipo</th>
                <th>Precio</th>
            </tr>
            </thead>
            <tbody>
            <% for (int i = 0; i < Math.min(propiedades.size(), 6); i++) {
                Propiedad propiedad = propiedades.get(i);
            %>
            <tr>
                <td><%= propiedad.getId() %></td>
                <td><%= propiedad.getTitulo() %></td>
                <td><span class="admin-status"><%= propiedad.getTipoOperacion() %></span></td>
                <td><%= propiedad.getTipo() %></td>
                <td>$ <%= propiedad.getPrecio() %></td>
            </tr>
            <% } %>
            </tbody>
        </table>
    </div>
</section>

<jsp:include page="/WEB-INF/components/admin-shell-end.jsp" />
