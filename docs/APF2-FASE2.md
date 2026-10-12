# APF2 - Fase 2: listado dinamico de propiedades

> Nota de entrega: las credenciales actuales se cargan desde configuracion externa.
> Los informes JSON/TSV y perfiles de pruebas referidos aqui son archivos locales
> ignorados; las capturas academicas PNG permanecen publicables.

## Alcance y estado Git

Trabajo realizado exclusivamente en `apf2-jsf`, desde el commit local `89d333f`.
Al iniciar, el directorio de trabajo no tenia cambios pendientes. Se conservaron
los archivos de la Fase 1 y el contenido local previo de `private.xml`: su SHA-256
continua siendo `E359E27E94C58B9603B850668BD999985C65C6975672A553F4917A429FEBF572`.
No se hicieron commits ni push.

Se conserva NetBeans con Ant, JDK 21, Tomcat 11.0.25, Mojarra 4.1.1 y Weld
6.0.3.Final. No se agregaron bibliotecas Java. No se modificaron `Propiedad.java`,
`PropiedadDAO.java`, `Conexion.java`, las credenciales, el esquema o los registros.
No se implementaron alta, edicion o eliminacion JSF.

## Arquitectura

```text
LoginServlet -> HttpSession.usuarioLogueado
                         |
Navegador -> AdminSessionFilter -> FacesServlet (*.xhtml)
                                      |
                         propiedades-jsf.xhtml (EL y h:dataTable)
                                      |
                         PropiedadListaBean (@Named, @ViewScoped)
                                      |
                         PropiedadDAO.listar() -> Conexion -> MySQL
```

La ruta nueva es:

http://localhost:8080/avance-proyecto-final-inmobiliaria/admin/propiedades-jsf.xhtml

Sin sesion redirige a `/login`. Despues del login existente, el menu compartido del
dashboard ofrece **Inventario de propiedades (JSF)**. Las rutas JSP y Servlet
anteriores permanecen disponibles para usuarios autenticados.

## Archivos creados y modificados

| Archivo | Funcion |
| --- | --- |
| `src/java/com/inmobiliaria/bean/PropiedadListaBean.java` | Bean CDI serializable, consulta inicial, recarga, cantidad y estados de carga |
| `src/java/com/inmobiliaria/filter/AdminSessionFilter.java` | Proteccion comun de rutas administrativas en REQUEST y FORWARD |
| `web/admin/propiedades-jsf.xhtml` | Vista administrativa con tabla de siete columnas, resumen, navegacion y mensajes |
| `web/resources/css/propiedades-jsf.css` | Paleta oscura y acento verde coherentes con el dashboard existente |
| `web/resources/bootstrap/bootstrap.min.css`, `LICENSE` | Bootstrap 5.3.8 local y licencia MIT |
| `web/WEB-INF/components/admin-shell-start.jsp` | Enlace al listado JSF y correccion del enlace de cierre de sesion a `/logout` |
| `tools/dependencies.properties`, `restore-dependencies.ps1` | Version, origen y SHA-256 de Bootstrap y su licencia; restauracion verificada |
| `build.xml` | Comprueba tambien el hash del CSS Bootstrap antes de compilar |
| `tools/PropiedadDaoSnapshot.java` | Invoca el DAO real y exporta siete campos para contrastar la tabla |
| `tools/test-phase2.ps1` | Comprobaciones HTTP, autenticacion, navegacion y comparacion de todas las filas |
| `tools/PropiedadListaEstadosTest.java` | Estados vacio, fallo, recuperacion y serializacion en JVM aislada |
| `tools/capture-phase2.mjs` | Capturas reales y comprobaciones de ancho con Chrome headless, sin paquetes npm |
| `README.md`, este documento | Instrucciones, resultados y correspondencia con la plantilla |

`build/` ya estaba versionado: sus copias generadas reflejan la nueva construccion.
Las fuentes existentes solo recibieron la adicion del enlace administrativo y la
correccion del logout. Los descriptores Faces/CDI de la Fase 1 permanecen iguales.

## Bean, tabla y datos

`@Named("propiedadListaBean")` expone el bean a EL. `jakarta.faces.view.ViewScoped`
conserva el estado durante los postbacks de la misma vista. El bean implementa
`Serializable` con `serialVersionUID`; no almacena DAO, conexiones ni sentencias.

`@PostConstruct` carga la lista una sola vez. El boton **Actualizar listado** usa
`h:form` y `h:commandButton` para ejecutar `recargar()`, que vuelve a consultar el
DAO. Los getters no ejecutan SQL. No se usa `MockData` en este flujo.

La consulta reutilizada sin cambios es:

```sql
SELECT * FROM propiedades ORDER BY id DESC
```

| Columna | EL con atributo real de Propiedad |
| --- | --- |
| ID | `#{propiedad.id}` |
| Titulo | `#{propiedad.titulo}` |
| Tipo de inmueble | `#{propiedad.tipo}` |
| Operacion | `#{propiedad.tipoOperacion}` |
| Ubicacion | `#{propiedad.ubicacion}` |
| Precio | `#{propiedad.precio}` |
| Estado | `#{propiedad.estado}` |

El precio se formatea con `f:convertNumber`, dos decimales y separadores `en_US`,
con el mismo simbolo `$` empleado por el catalogo existente. No se agrego una
propiedad de moneda. Los valores se emiten mediante `h:outputText`, con escape HTML.

Una consulta correcta sin filas produce **No hay propiedades registradas**, con
cantidad cero. Un fallo SQL o de carga del driver produce un `FacesMessage`
generico, oculta la tabla y muestra **Informacion no disponible** en el contador.
Nunca se presentan fallos de conexion como inventario vacio. Los detalles tecnicos
se registran en el servidor; no se incluyen en los mensajes de la vista.

## Seguridad y compatibilidad con APF1

El filtro cubre `/admin` y `/admin/*`, incluidas peticiones directas a las JSP y
los forwards de los Servlets. Utiliza `getSession(false)` y la misma cadena
`usuarioLogueado` creada por `LoginServlet`; no crea sesiones para visitantes.
Las respuestas administrativas incluyen `Cache-Control: no-store`.

Se corrigio la vulnerabilidad de acceso directo a las JSP sin sesion detectada
en la auditoria. No se sustituyo el login demo ni se introdujo un sistema nuevo
de roles: la autorizacion corresponde al acceso administrativo actual, que solo
autentica la cuenta demo existente. Una futura autenticacion real requerira
integrar usuarios y roles de MySQL en otra fase.

Bootstrap se carga solo en la vista nueva mediante `h:outputStylesheet`; no altera
el CSS de las JSP. No se incluye JavaScript Bootstrap porque esta pantalla no usa
componentes que lo requieran. El archivo local coincide con el SRI SHA-384 publicado
en la documentacion oficial y tiene su SHA-256 fijado en el manifiesto.

## Validaciones ejecutadas el 12 de octubre de 2026

| Validacion | Resultado |
| --- | --- |
| Construccion limpia Ant 1.10.14 con Oracle JDK 21.0.2 | BUILD SUCCESSFUL |
| Despliegue expandido `build/web` en Tomcat 11.0.25 | Mojarra y Weld inicializados; sin errores nuevos en el log de ejecucion |
| Pruebas HTTP de Fase 2 | 29 comprobaciones aprobadas |
| Regresion de Fase 1 | 31 comprobaciones aprobadas |
| Pruebas aisladas del bean | 7 comprobaciones aprobadas |
| Comparacion tabla / DAO real | 9 registros, siete campos por fila, orden DESC, antes y despues de actualizar |
| Chrome a 1440 px | 9 filas, Bootstrap aplicado, documento de 1440 px sin desbordamiento |
| Chrome a 390 px | 9 filas, documento de 390 px; solo el contenedor de tabla tiene desplazamiento horizontal |
| Evidencia de procesamiento JSF | Entrada `Evidencia APF2` procesada y saludo obtenido mediante EL |
| Cambios en MySQL | Ninguna escritura; solo consultas del DAO |

Las pruebas aisladas usan un controlador JDBC de prueba que devuelve una consulta
sin filas o lanza `SQLException`, exclusivamente en otra JVM. No se vacio una tabla,
no se detuvo MySQL y no se modifico el codigo de conexion. Se comprobaron el mensaje
seguro, la distincion de estados, la recuperacion, getters sin consultas repetidas
y la serializacion. Estos escenarios de vacio/fallo no se probaron desconectando
la base real ni mediante capturas de esos estados en el despliegue.

Comandos reproducibles, con JDK 21 configurado:

```powershell
ant clean dist
./tools/restore-dependencies.ps1 -VerifyOnly
./tools/test-phase2.ps1 -JavaHome $env:JAVA_HOME
./tools/test-phase1.ps1

New-Item -ItemType Directory -Force dist/testclasses | Out-Null
$testClasspath = 'build/web/WEB-INF/classes;web/WEB-INF/lib/*;' + $env:CATALINA_HOME + '/lib/*'
& "$env:JAVA_HOME/bin/javac.exe" -proc:none -cp $testClasspath -d dist/testclasses tools/PropiedadListaEstadosTest.java
& "$env:JAVA_HOME/bin/java.exe" -cp ('dist/testclasses;' + $testClasspath) PropiedadListaEstadosTest

node --experimental-websocket tools/capture-phase2.mjs 'RUTA_AL_CHROME/chrome.exe'
```

En este equipo se detuvo Tomcat antes de `clean` para evitar el bloqueo de JARs
observado en la Fase 1 y se reinicio con JDK 21 en segundo plano. El servidor quedo
operativo en 8080, con su descriptor local original apuntando a `build/web`.

La descarga inicial de Bootstrap encontro problemas de acceso a la comprobacion
de revocacion de certificados de Windows. Se completo con `curl.exe
--ssl-revoke-best-effort`, que mantiene la validacion TLS, y se contrasto con el SRI
oficial. Los primeros intentos de los tests requirieron corregir dos verificaciones
HTML demasiado estrictas y compilar el harness JDBC para compartir el cargador de
clases. Los resultados anteriores corresponden a las ejecuciones finales aprobadas.

## Correspondencia exacta con la plantilla del profesor

### CAPITULO 3: DISENO DE INTERFACES CON FRAMEWORKS FRONTEND (BOOTSTRAP)

**3.1 Estilos Responsivos.** `web/resources/bootstrap/bootstrap.min.css`,
`web/resources/css/propiedades-jsf.css` y `web/admin/propiedades-jsf.xhtml`:
Bootstrap 5.3.8 local, columnas adaptables, espaciados y `table-responsive`.
Capturas reales de escritorio y movil respaldan el comportamiento.

**3.2 Componentes UI Utilizados.** Navegacion administrativa con `nav/nav-pills`,
tarjetas `card`, boton estilizado dentro de `h:form`, insignias de estado y alertas
JSF con clases Bootstrap. La navegacion es una barra lateral, no el componente
colapsable `navbar`. Las alertas son inline; no se implementaron alertas flotantes
ni se debe afirmar que existen. El formulario de procesamiento de la Fase 1
conserva sus estilos propios.

**CAPTURA OBLIGATORIA 02.** Abrir el listado autorizado en el navegador. Mostrar el
encabezado Aurora, menu, tarjeta con cantidad, boton y tabla Bootstrap. La captura
real disponible es `dist/evidencias-fase2/escritorio.png`; `movil.png` sirve como
evidencia adicional de responsividad. Para una captura manual, incluir la barra
de direcciones y usar la URL administrativa indicada arriba.

### CAPITULO 4: IMPLEMENTACION DE VISTAS FACELETS (XHTML), MANAGED BEANS Y EL

**4.1 Vistas XHTML.** La Fase 2 aporta `propiedades-jsf.xhtml`, `h:form`,
`h:commandButton`, `h:messages`, `h:outputText` y `h:dataTable`. La vista
`web/prueba-jsf.xhtml` de la Fase 1 aporta tambien `h:inputText` y validacion.

**4.2 Managed Beans.** `PropiedadListaBean.java` usa `@Named` y `@ViewScoped` porque
la tabla y sus postbacks pertenecen a una misma vista. La plantilla menciona
`@RequestScoped` o `@SessionScoped`: `PruebaJsfBean.java` de la Fase 1 demuestra
`@RequestScoped`. No se usa `@ManagedBean`, retirado en Faces 4, ni un alcance de
sesion para guardar innecesariamente el inventario.

**4.3 Expression Language.** El listado enlaza `#{propiedadListaBean.propiedades}`,
`#{propiedadListaBean.cantidad}` y la accion `#{propiedadListaBean.recargar}`.
El enlace bidireccional se demuestra con `#{pruebaJsfBean.nombre}` en `h:inputText`
y `#{pruebaJsfBean.saludar}` en el formulario de procesamiento de la Fase 1.

**CAPTURA OBLIGATORIA 03.** La plantilla admite formulario de registro **o
procesamiento**. Usar `/prueba-jsf.xhtml`: escribir `Evidencia APF2`, pulsar
**Probar comunicacion** y mostrar tanto el input como el saludo procesado. Existe
la captura real `dist/evidencias-fase2/captura03-procesamiento-jsf.png`.
No presentarla como registro de propiedades: ese CRUD pertenece a la Fase 3.

**Captura de codigo complementaria.** En NetBeans mostrar en paralelo
`PropiedadListaBean.java` (`@Named`, `@ViewScoped`, `Serializable`, llamada a
`PropiedadDAO.listar()`) y el fragmento XHTML de `h:dataTable` con sus siete
expresiones. Esta captura de NetBeans queda por obtener manualmente; no se fabrico.

### CAPITULO 5: GESTION DE NAVEGACION Y TABLAS DINAMICAS (JDBC/DAO)

**5.1 Flujo de Navegacion JSF.** La navegacion es hibrida para conservar APF1:
`LoginServlet` redirige al dashboard existente; el menu JSP enlaza al nuevo XHTML;
la vista ofrece regreso al dashboard, gestion anterior y logout. `h:link` resuelve
el outcome `/admin/propiedades-jsf`. `FacesServlet` procesa `*.xhtml` y el filtro
protege la sesion. No se agregaron `navigation-rule` explicitas a `faces-config.xml`
ni se migro el login a JSF: no deben describirse como implementadas.

**5.2 Componente h:dataTable.** `propiedades-jsf.xhtml` enlaza el componente a
`PropiedadListaBean`, que llama al DAO del APF1. `PropiedadDAO` mapea columnas reales
de MySQL a `Propiedad` utilizando `Conexion`. Se contrastaron todas las filas y
campos de la tabla con la misma consulta DAO, sin datos simulados en la aplicacion.

**CAPTURA OBLIGATORIA 04.** Mostrar las siete columnas, cantidad y filas reales
(en esta validacion IDs 9 a 1) del listado. Puede utilizarse la captura de escritorio
real o una nueva captura manual centrada en la tabla. Agregar como pie de figura:
“Listado JSF mediante h:dataTable, respaldado por PropiedadListaBean y
PropiedadDAO.listar(); datos leidos desde MySQL”. Acompanar con el fragmento XHTML
para demostrar el origen JSF del HTML renderizado.

Las capturas fueron generadas con Chrome headless y revisadas visualmente como
imagenes; no se afirma una prueba manual interactiva en navegador. Estan bajo
`dist/`, ignorado por Git y regenerable: copiarlas a la entrega academica antes
de otra limpieza de construccion si se desean conservar.

## Limites de esta fase

No hay escrituras JSF, paginacion, busqueda JSF, autenticacion JDBC, roles nuevos,
alertas flotantes o reglas explicitas de navegacion. Se conservan las funciones
actuales APF1. La Fase 3 (registro y edicion) requiere autorizacion posterior.

Referencia de Bootstrap y SRI: https://getbootstrap.com/docs/5.3/getting-started/download/
