# APF2 - Fase 4: integracion, navegacion y validacion final

> Nota de entrega: la configuracion JDBC se externalizo despues de esta validacion.
> Los JSON/TSV mencionados son informes locales ignorados por Git. Las capturas PNG
> academicas se conservan; revisar APF2-PREPARACION-REPOSITORIO.md antes de publicar.

Validacion realizada el 12 de octubre de 2026, zona America/Lima.
Documento tecnico; no constituye el informe academico completo.

## Estado de Git y alcance

Se trabajo exclusivamente en `apf2-jsf`. Al comenzar existian cambios locales y
archivos nuevos de las fases 1 a 3: se conservaron sin reset, checkout destructivo,
commit o push. La construccion regenera los artefactos de `build/` ya versionados.
El contenido previo de `nbproject/private/private.xml` conserva el SHA-256
`E359E27E94C58B9603B850668BD999985C65C6975672A553F4917A429FEBF572`.

Se mantienen NetBeans/Ant, JDK 21, Tomcat 11.0.25, Mojarra 4.1.1, Weld 6.0.3.Final,
Bootstrap 5.3.8, JDBC y MySQL. No se introdujeron dependencias, esquemas o funciones
nuevas. Las JSP, los Servlets y sus rutas coexisten con JSF.

## Arquitectura final

```text
Navegador
  -> LoginServlet -> HttpSession.usuarioLogueado
  -> AdminSessionFilter (/admin y /admin/*, REQUEST/FORWARD)
       -> FacesServlet (*.xhtml)
            -> Facelets + componentes JSF + Expression Language
                 -> Beans CDI @Named / @ViewScoped, Serializable
                      -> PropiedadDAO -> Conexion JDBC -> MySQL
       -> AdminServlet -> DAO -> JSP existentes
```

- `PruebaJsfBean` / `prueba-jsf.xhtml` comprueban CDI, lectura/escritura EL y accion.
- `PropiedadListaBean` carga por DAO al entrar y al actualizar; sus getters no
  consultan JDBC. Usa `h:dataTable`, contador y estados vacio/error separados.
- `PropiedadFormularioBean` inicia una propiedad o carga su ID; mantiene el modelo
  en postbacks, valida y delega en guardar/actualizar del DAO.
- `PropiedadValidacion` comparte reglas entre JSF y los Servlets/JSP.
- El DAO reutilizado mantiene PreparedStatement y try-with-resources.
- `faces-config.xml` configura locale y documenta navegacion implicita; los beans
  son CDI, sin ManagedBean antiguo o APIs javax.faces.

La plataforma efectiva se comprobo con Ant y con ambas instancias Tomcat. El
descriptor Servlet 6.0 se mantiene compatible con Tomcat 11; no se cambio de servidor
ni se afirmo que Tomcat implementa por si solo todo Jakarta EE Web Profile.

## Flujo administrativo comprobado

```text
/login (POST) -> /admin/dashboard (JSP via Servlet)
  -> /admin/propiedades-jsf.xhtml
  -> /admin/propiedad-formulario.xhtml
  -> guardar -> faces-redirect -> listado + FacesMessage Flash
  -> Editar con f:param id -> formulario?id=ID_EXISTENTE
  -> actualizar -> faces-redirect -> listado + FacesMessage Flash
  -> /logout -> /login
```

`tools/test-phase4-navigation.mjs` usa Chrome real con CDP para pulsar los enlaces
y botones; no sustituye este flujo por peticiones directas. Se comprobaron:

- Login exitoso hacia dashboard y enlace al listado JSF.
- Boton de registro, edicion del inmueble recien creado y retorno al listado.
- Confirmacion unica despues del registro y persistencia de mensaje tras edicion.
- Cancelar / Volver al listado en escritorio y movil.
- Retroceso desde formulario al listado.
- Retroceso despues de guardar: carga los valores ya persistidos.
- ID inexistente: mensaje controlado sin un formulario operativo.
- Logout y retroceso posterior: no vuelve a habilitar acceso administrativo.
- Los 12 enlaces detectados en esas pantallas, excluyendo logout durante la
  comprobacion intermedia, respondieron por GET sin errores 404.

El detalle de los enlaces y 21 verificaciones esta en
`docs/evidencias/fase4/navegacion-final.json`. Esta comprobacion no equivale a un
crawler exhaustivo de todos los enlaces posibles del sitio publico.

## Incidencias comprobadas y correcciones

| Incidencia observada | Correccion minima | Verificacion final |
| --- | --- | --- |
| Confirmacion repetida dos veces al regresar al listado | El FacesMessage de exito utiliza detalle vacio, en vez de null que repetia el resumen | Chrome encontro una sola ocurrencia tras registro |
| En modo edicion se destacaba Registrar propiedad en el menu | Clases active condicionadas al modo: Inventario activo al editar, Registro al crear | Chrome confirmo Inventario de propiedades como item activo |
| Comentario de faces-config seguia describiendo solo Fase 1 | Se documentan outcomes y faces-redirect ya existentes | Revision del descriptor; no cambia su funcionamiento |

No se realizo un rediseno. Se conservaron paleta, Bootstrap, distribucion y
componentes. Las pruebas a 1440 y 390 px no comprobaron desbordamiento horizontal
de la pagina; la tabla movil se desplaza dentro de table-responsive.

Archivos de aplicacion modificados en esta fase: `PropiedadFormularioBean.java`,
`propiedad-formulario.xhtml` y el comentario de `faces-config.xml`.
Se agregaron el test de navegador, este documento y las evidencias persistentes;
se actualizo el README. No se cambiaron credenciales ni reglas DAO.

## Construccion, despliegue y pruebas ejecutadas

Se detuvieron ambas instancias para liberar los JARs antes de limpiar. Se ejecuto
`clean dist` con Ant 1.10.14 y Oracle JDK 21.0.2: **BUILD SUCCESSFUL**. Se generaron
las clases y el WAR, y se reiniciaron los despliegues expandidos build/web con
Tomcat 11.0.25. Los logs de cada instancia confirmaron Weld y Mojarra; no mostraron
nuevas excepciones o errores graves en la ejecucion final.

| Suite o comprobacion | Resultado final ejecutado |
| --- | --- |
| tools/test-phase1.ps1 | 31 comprobaciones aprobadas: XHTML, CDI/EL, postback, validacion y rutas anteriores |
| tools/test-phase2.ps1 | 29 aprobadas: tabla/DAO, nueve registros principales, Bootstrap, sesiones y JSP |
| tools/test-phase3.ps1 | 51 aprobadas: formatos, limites, campos, sesiones, ID, INSERT/UPDATE TEST, redireccion, Flash y auditoria principal |
| tools/test-phase3-jsp.ps1 | 7 aprobadas: altas/edicion JSP reales en TEST, errores, conservacion y compatibilidad JSF |
| PropiedadListaEstadosTest | 7 aprobadas en JVM aislada: vacio, fallo, mensajes, recuperacion, getters y serializacion |
| PropiedadFormularioTest | 11 aprobadas en JVM aislada: reglas, precision, ID y datos conservados ante fallo JDBC |
| PropiedadFormularioTest guard | 1 aprobada: perfil TEST rechaza configurar la base principal antes de conectar |
| test-phase4-navigation.mjs | 21 aprobadas en Chrome; 12 enlaces GET y flujo completo con retroceso |
| SHA-256 dependencias | Mojarra, Weld preparado, Connector/J, Bootstrap y licencia coinciden con manifiesto |
| Estructura del WAR | Descriptores, beans, formulario, tabla y filtro presentes; tres bibliotecas Java |
| Captura 01 | Ventana real de NetBeans con web.xml, obtenida y revisada |

En total: **158 comprobaciones de suites aprobadas**, ademas de compilacion,
despliegue, inspeccion del WAR, hashes y captura. Se informan las ejecuciones
finales: la primera pasada de navegador detecto la confirmacion duplicada y no
se considero aprobada; se corrigio y se repitio el flujo completo.

Las pruebas de estados de fallo en harness no desconectaron MySQL ni alteraron
la aplicacion desplegada. El navegador comprobo layouts y controles en Chrome
headless; las capturas fueron inspeccionadas visualmente, sin afirmar una sesion
manual de pruebas en todos los navegadores/dispositivos.

## Datos principales e aislamiento

| Instancia | Puerto | Base | Operaciones de esta fase |
| --- | --- | --- | --- |
| Principal | 8080 | inmobiliaria | Solo lectura DAO y cambios de sesion HTTP |
| Pruebas | 8081 | inmobiliaria_apf2_test | Registro/edicion de marcadores autorizados APF2_TEST_* |

Se mantiene la guardia de Conexion y se verifica la JVM propietaria del puerto
8081 antes de escribir. Los tests no admiten que las escrituras apunten al servidor
principal. La base TEST y los fixtures permanecen disponibles al finalizar.

Los archivos `principal-antes.tsv` y `principal-despues.tsv` de esta carpeta de
evidencias tienen hashes identicos para la estructura y todas las columnas/filas:
usuarios 2, clientes 3, propiedades 9, contactos 3. No contienen datos sensibles
en claro. La base principal no fue modificada.

El flujo Chrome final creo el ID TEST 4, marcador APF2_TEST_F4_1791837390104, y
persistio precio 46000.00. Las regresiones finales conservaron ademas el ID TEST 5
APF2_TEST_001_ee1de429_EDITADA y el ID TEST 6 APF2_TEST_JSP_741faa63. El ID TEST 3
proviene del primer intento que detecto la incidencia de confirmacion. Todos
pertenecen exclusivamente a TEST; no se eliminaron la base ni fixtures anteriores.

## Rutas funcionales

Contexto principal: `http://localhost:8080/avance-proyecto-final-inmobiliaria`.
Contexto para pruebas de escritura: `http://localhost:8081/avance-proyecto-final-inmobiliaria`.

| Ruta relativa | Funcion |
| --- | --- |
| /login | Login existente |
| /admin/dashboard | Dashboard JSP protegido |
| /admin/propiedades-jsf.xhtml | Listado JSF y enlaces Registrar/Editar |
| /admin/propiedad-formulario.xhtml | Registro JSF |
| /admin/propiedad-formulario.xhtml?id=ID | Edicion de ID existente en la base correspondiente |
| /logout | Invalida sesion y redirige al login |
| /prueba-jsf.xhtml | Demostracion JSF/CDI/EL de Fase 1 |
| /admin/propiedades, /admin/nueva-propiedad, /admin/editar-propiedad?id=ID | Rutas anteriores Servlet/JSP conservadas |
| /, /index.jsp, /nosotros.jsp, /propiedades, /detalle-propiedad?id=1, /contacto | Rutas publicas comprobadas por regresion |

Los IDs 4, 5 y 6 anteriores son de TEST; no usar esos ejemplos para editar
propiedades principales. El login continua siendo el demo autorizado del APF1,
sin migracion de autenticacion a MySQL ni nuevos roles en esta fase.

## Estado de las cinco evidencias obligatorias

Todas las imagenes guardadas son capturas reales, sin composicion o simulacion.
Las evidencias se conservan fuera de dist para que una limpieza Ant no las borre.

| Captura | Estado y archivo | Procedencia |
| --- | --- | --- |
| 01: configuracion JSF en NetBeans | Lista: docs/evidencias/fase4/01-netbeans-webxml.png | Nueva captura real de la ventana NetBeans existente, con web.xml abierto; muestra listener Weld y FacesServlet *.xhtml |
| 02: interfaz Bootstrap | Lista: docs/evidencias/fase4/02-bootstrap.png | Reutilizada de escritorio.png Fase 3, modulo administrativo real |
| 03: formulario de registro JSF | Lista: docs/evidencias/fase4/03-registro-jsf.png | Reutilizada de registro.png Fase 3; formulario real con campos completados, no afirma persistencia de APF2_TEST_CAPTURA |
| 04: tabla h:dataTable con MySQL | Lista: docs/evidencias/fase4/04-tabla-mysql.png | Reutilizada de la tabla real Fase 3, con fixture TEST persistido |
| 05: historial de commits GitHub | Pendiente | Se preparara despues de autorizar commits y push; no se publico ni se fabrico una captura |

Las capturas reutilizadas representan la ejecucion original de Fase 3 con un
fixture en el listado, no el conteo actual de seis registros TEST despues de las
pruebas de Fase 4. El componente, columnas y estilos siguen vigentes. Las
correcciones finales de mensajes y resaltado de edicion no invalidan esas vistas
de registro/listado sin confirmaciones. Se conserva tambien
`responsivo-registro-fase3.png` como apoyo movil.

Para la captura 05, una vez publicada la rama autorizada, abrir el historial de
commits real de GitHub y capturar repositorio, rama, mensajes y fechas visibles.
La fase actual termina antes de esa publicacion.

## Correspondencia con la plantilla oficial

### CAPITULO 2: CONFIGURACION DE LA ARQUITECTURA JSF Y ENTORNO WEB

**2.1 Mapeo del Servidor Web y Despliegue.** Tomcat recibe HTTP, aplica el filtro
administrativo y resuelve *.xhtml a FacesServlet. El ciclo JSF procesa componentes,
conversion/validacion, actualizacion del modelo y acciones CDI; los beans delegan
en DAO/JDBC. Las JSP siguen atendidas mediante el flujo de Servlets anterior.
Evidencia: build Ant, logs de ambos despliegues y captura 01.

**2.2 web.xml y faces-config.xml.** `web/WEB-INF/web.xml` registra FacesServlet y
listener Weld; `faces-config.xml` es Faces 4.1, con locale es y navegacion implicita.
`beans.xml` activa descubrimiento CDI annotated. No se describen navigation-rule
explicitas que no existen. Captura obligatoria 01 lista.

### CAPITULO 3: DISENO DE INTERFACES CON FRAMEWORKS FRONTEND (BOOTSTRAP)

**3.1 Estilos Responsivos.** Bootstrap local 5.3.8 con licencia/hashes; CSS de Aurora,
columnas adaptables y table-responsive. Chrome comprobo 1440 y 390 px.
**3.2 Componentes UI.** Navegacion lateral nav/nav-pills, cards, botones, controles
de formulario, badges y alertas inline JSF. No se afirman navbar colapsable o
alertas flotantes; esos componentes especificos no se implementaron.
Captura obligatoria 02 lista, con apoyo movil reutilizado.

### CAPITULO 4: FACELETS, MANAGED BEANS Y EXPRESSION LANGUAGE

**4.1 Vistas XHTML.** Formulario compartido con h:form, h:inputText,
h:inputTextarea, h:selectOneMenu, h:selectBooleanCheckbox, h:commandButton y
h:message/h:messages. Captura obligatoria 03 lista.
**4.2 Managed Beans.** @Named y @ViewScoped serializable en listado/formulario;
@RequestScoped en la demostracion Fase 1. Se justifica el alcance de vista para
postbacks; no se usa ManagedBean antiguo.
**4.3 EL.** Enlaces bidireccionales propiedadFormularioBean.propiedad.*, acciones
guardar/recargar y filas del listado. Registro y edicion con SELECT de confirmacion
respaldan funcionamiento real. Una captura de codigo complementaria del bean y
la vista en NetBeans es opcional y no se presenta como ya generada.

### CAPITULO 5: NAVEGACION Y TABLAS DINAMICAS CON JDBC/DAO

**5.1 Navegacion.** Flujo hibrido login/dashboard Servlet-JSP y outcomes JSF,
parametros de ID, faces-redirect, Flash y logout existente. Los tests Chrome
respaldan los enlaces y retroceso.
**5.2 h:dataTable.** Conexion real por PropiedadListaBean -> PropiedadDAO ->
Conexion -> MySQL. Siete columnas de datos y acciones Editar; nueve registros
principales contrastados en solo lectura. Captura obligatoria 04 lista.

## Reproduccion y limites

Antes de clean detener ambas instancias; las escrituras se realizan solo con la
instancia TEST arrancada con sus propiedades y guardia. Ejecutar en este orden:

```powershell
ant clean dist
# Iniciar Tomcat principal y el perfil TEST con sus configuraciones.
./tools/start-test-tomcat.ps1 -TomcatHome $env:CATALINA_HOME -JavaHome $env:JAVA_HOME
./tools/test-phase1.ps1
./tools/test-phase2.ps1 -JavaHome $env:JAVA_HOME
node --experimental-websocket tools/test-phase4-navigation.mjs 'RUTA_AL_CHROME/chrome.exe'
./tools/test-phase3.ps1 -JavaHome $env:JAVA_HOME
./tools/test-phase3-jsp.ps1 -JavaHome $env:JAVA_HOME
```

Las suites que escriben se ejecutan secuencialmente para no interferir sus
conteos de TEST. Las JVM aisladas se compilan/ejecutan con los comandos documentados
en las fases anteriores. Los logs quedan bajo dist y pueden regenerarse.
Las pruebas usan el login demo existente: no certifican autenticacion de usuarios
reales contra MySQL ni constituyen una auditoria completa de seguridad.

Estado final: funciones JSF integradas, coexistencia JSP/Servlet validada,
principal intacta, evidencias 01 a 04 disponibles. Solo captura 05 pendiente de
publicacion posterior autorizada. No se redacto el informe academico completo.
