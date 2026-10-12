# APF2 - Fase 3: registro y edicion de propiedades mediante JSF

> Nota de entrega: JDBC ya no contiene credenciales literales. La configuracion
> actual y preparacion segura estan en APF2-PREPARACION-REPOSITORIO.md. Los hashes,
> fixtures y reportes JSON/TSV de esta fase son evidencia local no versionada.

## Alcance autorizado y preservacion

Implementacion realizada en `apf2-jsf`, sin commits ni push. Al comenzar habia
cambios locales de las fases anteriores y artefactos de NetBeans: se conservaron.
El contenido de `nbproject/private/private.xml` mantiene su SHA-256
`E359E27E94C58B9603B850668BD999985C65C6975672A553F4917A429FEBF572`.

El usuario autorizo explicitamente crear `inmobiliaria_apf2_test`, reproducir las
tablas y relaciones con el esquema existente y crear/editar/eliminar registros
identificables de pruebas dentro de esa base. La base se conserva al finalizar.

La estructura y todos los datos de `inmobiliaria` permanecieron intactos. Se
compararon hashes SHA-256 del SHOW CREATE TABLE y de todas las columnas/filas,
ordenadas por ID, para usuarios, clientes, propiedades y contactos. Evidencias:

- `docs/evidencias/fase3-principal-antes.tsv`.
- `docs/evidencias/fase3-principal-despues.tsv`.

Ambos archivos son identicos: usuarios 2, clientes 3, propiedades 9 y contactos 3.
No contienen credenciales ni datos personales en claro, solo nombres, conteos y
hashes. Los marcadores de pruebas nunca se insertaron en la base principal.

## Revision del modelo y esquema

Se reutilizan `Propiedad`, `PropiedadDAO.guardar()`, `buscarPorId()` y
`actualizar()`, con sus PreparedStatement y cierre de recursos. El DAO y el modelo
no se modificaron. Las validaciones y preparacion del formulario se revisaron
tambien en `AdminServlet`, `nueva-propiedad.jsp` y `editar-propiedad.jsp`.

| Campo del modelo | Almacenamiento y reglas compartidas |
| --- | --- |
| titulo | VARCHAR(180), obligatorio y no blanco como en APF1 |
| ubicacion | VARCHAR(160), obligatoria y no blanca como en APF1 |
| direccion | VARCHAR(220), opcional |
| imagenPrincipal | Columna imagen VARCHAR(255); vacia conserva el fallback del DAO |
| descripcion | TEXT NOT NULL: se normaliza null a cadena vacia; no se inventa una obligatoriedad de contenido; maximo 65535 bytes UTF-8 |
| tipo | CASA, DEPARTAMENTO, TERRENO, OFICINA, LOCAL |
| tipoOperacion | VENTA, ALQUILER |
| estado | DISPONIBLE, RESERVADA, VENDIDA, ALQUILADA |
| precio | BigDecimal / DECIMAL(12,2); cero permitido, no negativos segun APF1, maximo 9999999999.99 a escala de almacenamiento |
| area | double / DECIMAL(10,2); cero permitido, finita y no negativa, maximo 99999999.99 |
| habitaciones / banos | INT: enteros no negativos; opcionales vacios en JSP equivalen a cero |
| destacada | boolean / TINYINT(1), h:selectBooleanCheckbox |
| id | INT autogenerado; parametro de edicion entero positivo existente |

Precio y area se normalizan a dos decimales con HALF_UP, en consonancia con su
almacenamiento. No se rechazo por una regla nueva el uso de mas decimales.
Las longitudes VARCHAR se cuentan por caracteres Unicode; TEXT por bytes UTF-8.
No se incorporaron campos inexistentes, moneda nueva ni tablas de imagenes.

## Archivos creados y modificados

| Archivo | Cambio |
| --- | --- |
| `src/java/com/inmobiliaria/bean/PropiedadFormularioBean.java` | Bean CDI serializable, nuevo/edicion, carga por ID, validacion, guardado y mensajes |
| `web/admin/propiedad-formulario.xhtml` | Facelet compartida, Bootstrap y enlaces bidireccionales |
| `src/java/com/inmobiliaria/validation/PropiedadValidacion.java` | Reglas, normalizacion e interpretacion de parametros compartidas |
| `src/java/com/inmobiliaria/controller/AdminServlet.java` | Delega a reglas compartidas; conserva propiedad e ID al fallar la edicion JSP |
| `web/admin/propiedades-jsf.xhtml` | Enlace de registro, columna Editar con f:param y estilo para confirmaciones |
| `src/java/com/inmobiliaria/bean/PropiedadListaBean.java` | Restituye un import jakarta.inject.Named que faltaba en el estado encontrado |
| `src/java/com/inmobiliaria/config/Conexion.java` | Seleccion de base por propiedad de JVM, con principal como default; guardia de perfil TEST |
| `tools/Phase3Database.java` | Crea solo esquema TEST, audita principal en solo lectura y consulta registros TEST |
| `tools/start-test-tomcat.ps1` | Segunda instancia Tomcat aislada con puerto, CATALINA_BASE y propiedades propias |
| `tools/test-phase3.ps1` | Validaciones, registro/edicion real, ID, sesiones, Flash y hashes de principal |
| `tools/test-phase3-jsp.ps1` | Regresion funcional de escrituras JSP exclusivamente en TEST |
| `tools/PropiedadFormularioTest.java` | Reglas, fallo JDBC y guardia de aislamiento en JVM separada |
| `tools/test-phase2.ps1` | Mantiene contraste de las siete columnas de datos y admite la nueva columna de acciones |
| `tools/capture-phase2.mjs` | Reutiliza CDP para capturas opcionales de Fase 3, sin nuevas dependencias npm |
| `README.md`, este documento y los TSV de auditoria | Instrucciones y evidencias |

Se conservaron las vistas JSP, el filtro administrativo, las dependencias Java,
Bootstrap 5.3.8 y los descriptores JSF/CDI previamente validados. `build/` contiene
artefactos regenerados; no corresponde a eliminacion de componentes fuente.

## Ciclo del formulario y seguridad

El bean usa `@Named("propiedadFormularioBean")`, `jakarta.faces.view.ViewScoped`
y `Serializable`. No almacena conexiones ni DAO. `@PostConstruct` inicia una
propiedad nueva con CASA, VENTA y DISPONIBLE. `f:viewParam` obtiene el parametro
ID y `f:viewAction`, con `onPostback=false`, carga la propiedad solo al entrar.

Si el ID no es positivo, excede INT o no existe, se muestra un mensaje seguro y
no se renderiza un formulario operativo. No se recurre a mocks ni a otro inmueble.
Los postbacks conservan el modelo y los valores locales de componentes invalidos;
no vuelven a cargar los datos originales encima del formulario.

`guardar()` valida antes de llamar al DAO. En modo edicion restaura el ID cargado
en el estado de vista; no lo toma de un input oculto o del parametro POST.
Se probo que un parametro URL e input ID manipulados no cambian el registro que
se esta editando. Si el UPDATE no afecta una fila, comunica que ya no existe.

Despues del exito retorna `/admin/propiedades-jsf?faces-redirect=true` y conserva
el FacesMessage mediante Flash. Un error de validacion o JDBC retorna a la misma
vista, mantiene los datos y no expone SQL, credenciales ni trazas. Los detalles
tecnicos quedan solo en el logger del servidor.

El filtro de Fase 2 cubre GET y POST administrativos en ambas instancias, incluida
la vista de formulario. La autorizacion sigue siendo la sesion del login existente.
No se cambio el sistema de autenticacion ni se implemento eliminacion JSF.

## Aislamiento de las escrituras

| Instancia | Puerto HTTP | Base | Utilizacion durante la validacion |
| --- | --- | --- | --- |
| Principal | 8080 | inmobiliaria | GET, login/session y regresion de lectura; ninguna escritura de propiedades |
| TEST | 8081 | inmobiliaria_apf2_test | Registro y edicion autorizados de fixtures APF2_TEST_* |

`Conexion` mantiene sin cambios HOST, PORT, USER y PASSWORD. La base se selecciona
por `System.getProperty("inmobiliaria.database", "inmobiliaria")`.
El perfil TEST se inicia con:

```text
-Dinmobiliaria.database=inmobiliaria_apf2_test
-Dinmobiliaria.test=true
```

La segunda propiedad exige la base autorizada antes de conectar y vuelve a
comprobar el catalogo de la conexion obtenida. La guardia se probo con TEST=true
y database=inmobiliaria: rechazo antes de abrir una conexion.

Los scripts de escritura solo admiten localhost:8081 y comprueban que la JVM
propietaria de ese puerto declara ambas propiedades. Los helpers SQL de pruebas
usan un nombre TEST constante y SELECT DATABASE() antes de operaciones sobre sus
tablas. La preparacion usa una conexion al servidor sin catalogo para CREATE
DATABASE y ejecuta solo CREATE TABLE del esquema, despues de elegir TEST.
No ejecuta las semillas INSERT del script ni copia los datos principales.

`CATALINA_BASE` TEST esta en `dist/tomcat-apf2-test`; sus puertos HTTP/shutdown son
8081/8006 y su descriptor apunta a `build/web`. Se dejan las dos instancias
operativas y la base TEST no se elimina. Los usuarios de la tabla TEST estan
vacios: el login demo actual funciona igual por ser un login fijo del APF1.

## URLs locales comprobadas

Con sesion autorizada:

- Principal, registro: http://localhost:8080/avance-proyecto-final-inmobiliaria/admin/propiedad-formulario.xhtml
- Principal, carga de edicion verificada solo por GET: http://localhost:8080/avance-proyecto-final-inmobiliaria/admin/propiedad-formulario.xhtml?id=9
- TEST, registro y validacion de escrituras: http://localhost:8081/avance-proyecto-final-inmobiliaria/admin/propiedad-formulario.xhtml
- TEST, edicion del fixture JSF conservado: http://localhost:8081/avance-proyecto-final-inmobiliaria/admin/propiedad-formulario.xhtml?id=1
- TEST, listado: http://localhost:8081/avance-proyecto-final-inmobiliaria/admin/propiedades-jsf.xhtml

Los IDs son locales a cada base; el ID 1 de TEST es un fixture y el ID 1 principal
es una propiedad original distinta. Para continuar pruebas usar siempre 8081.

## Resultados ejecutados el 12 de octubre de 2026

| Prueba | Resultado |
| --- | --- |
| Compilacion limpia, Ant 1.10.14 y Oracle JDK 21.0.2 | BUILD SUCCESSFUL |
| Tomcat 11.0.25 principal y TEST | Mojarra/Weld y formularios operativos; sin errores nuevos en logs de ejecucion |
| Suite Fase 3 | 51 comprobaciones aprobadas |
| Regresion funcional de registro y edicion JSP en TEST | 7 comprobaciones aprobadas |
| Reglas/fallo de persistencia, JVM aislada | 11 comprobaciones aprobadas |
| Guardia TEST contra configuracion de base principal | Aprobada, sin conectar |
| Regresion HTTP de Fase 2 | 29 comprobaciones aprobadas, 9 registros principales contrastados |
| Regresion HTTP de Fase 1 | 31 comprobaciones aprobadas |
| Formulario principal, nuevo y edicion de ID 9 | HTTP 200 por lectura, sin guardar |
| Capturas Chrome headless, escritorio/movil | Renderizado inspeccionado; formularios sin desbordamiento horizontal |
| Integridad principal antes/despues | Las cuatro tablas conservaron hashes de estructura y todos sus datos |

La suite cubre obligatorios, conversion decimal/double/entero, valores negativos,
NaN, capacidad DECIMAL, longitudes y ENUM. Verifica que no se inserte una fila
durante errores, que se mantenga el titulo introducido, ID incorrecto/inexistente,
POST sin sesion, insert/update reales, carga de edicion, mensajes Flash,
redireccion y revocacion tras logout.

Se conservan estos registros autorizados en TEST:

| ID | Marcador y estado final |
| --- | --- |
| 1 | APF2_TEST_001_c9a0950b_EDITADA; precio 234567.89, RESERVADA, descripcion de edicion confirmada |
| 2 | APF2_TEST_JSP_7be2a807; precio 2000.00, RESERVADA; regresion de JSP |

Las lecturas de verificacion usan consultas directas a TEST; la UI usa el DAO real.
No se introdujeron datos simulados en la aplicacion. El fallo JDBC se simula solo
en un harness fuera de Tomcat para verificar retencion y mensajes sin interrumpir
MySQL. No se afirma haber desconectado el servidor real para esa prueba.

## Reproduccion de las pruebas

Con JDK 21 y el Tomcat local configurados; antes de una nueva limpieza detener
ambas instancias para liberar los JARs compartidos. `dist/` contiene perfiles,
logs y capturas regenerables, pero la base MySQL TEST persiste independiente.

```powershell
ant clean dist
# Solo esquema aislado; conserva la base si ya existe, no la elimina:
& "$env:JAVA_HOME/bin/java.exe" -cp 'build/web/WEB-INF/classes;web/WEB-INF/lib/mysql-connector-j-26.7.0.jar' tools/Phase3Database.java prepare
./tools/start-test-tomcat.ps1 -TomcatHome $env:CATALINA_HOME -JavaHome $env:JAVA_HOME
./tools/test-phase3.ps1 -JavaHome $env:JAVA_HOME
./tools/test-phase3-jsp.ps1 -JavaHome $env:JAVA_HOME
./tools/test-phase2.ps1 -JavaHome $env:JAVA_HOME # instancia principal, solo lectura
./tools/test-phase1.ps1

New-Item -ItemType Directory -Force dist/testclasses | Out-Null
$testClasspath = 'build/web/WEB-INF/classes;web/WEB-INF/lib/*;' + $env:CATALINA_HOME + '/lib/*'
& "$env:JAVA_HOME/bin/javac.exe" -encoding UTF-8 -proc:none -cp $testClasspath -d dist/testclasses tools/PropiedadFormularioTest.java
& "$env:JAVA_HOME/bin/java.exe" -cp ('dist/testclasses;' + $testClasspath) PropiedadFormularioTest
& "$env:JAVA_HOME/bin/java.exe" '-Dinmobiliaria.test=true' '-Dinmobiliaria.database=inmobiliaria' -cp ('dist/testclasses;' + $testClasspath) PropiedadFormularioTest guard

node --experimental-websocket tools/capture-phase2.mjs 'RUTA_AL_CHROME/chrome.exe' http://localhost:8081/avance-proyecto-final-inmobiliaria fase3
```

Cada ejecucion de la suite genera un marcador TEST nuevo. Solo crea y edita ese
registro: no limpia fixtures anteriores. Los IDs futuros pueden ser distintos.
El resultado actual esta en `dist/phase3-test-result.json` y los logs TEST en
`dist/tomcat-apf2-test/logs/`. Nunca ejecutar estas suites contra el puerto principal.

## Evidencias para el CAPITULO 4 oficial

### 4.1 Vistas XHTML (.xhtml)

`web/admin/propiedad-formulario.xhtml` incorpora `h:form`, `h:inputText`,
`h:inputTextarea`, `h:selectOneMenu`, `h:selectBooleanCheckbox`, `h:commandButton`,
`h:message` y `h:messages`. Bootstrap aplica columnas responsivas, controles,
tarjetas, botones y alertas. La misma vista tiene modos nuevos/edicion claros.

**CAPTURA OBLIGATORIA 03 prioritaria:** `dist/evidencias-fase3/registro.png`,
captura real del formulario en la instancia TEST con campos completados.
`registro-movil.png` demuestra su distribucion adaptable. La captura de registro
no supone que APF2_TEST_CAPTURA se haya insertado: el navegador lleno los campos
sin pulsar Guardar; las pruebas HTTP demuestran la persistencia de los fixtures.

`edicion.png` muestra el fixture ID 1 cargado realmente desde MySQL, con precio y
estado actualizados. `escritorio.png` y `movil.png` muestran el listado TEST.
Se inspeccionaron las imagenes obtenidas de Chrome headless; no se afirma haber
realizado una sesion manual interactiva en el navegador.

### 4.2 Managed Beans

`PropiedadFormularioBean.java` utiliza `@Named`, `@ViewScoped` y `Serializable`.
Este alcance conserva el formulario y su ID autorizado durante postbacks y evita
guardar borradores de inmuebles en toda la sesion. Se documenta por que es adecuado
aunque la plantilla ejemplifique RequestScoped/SessionScoped. No se utiliza el
antiguo ManagedBean ni bibliotecas javax.faces.

Para captura complementaria de codigo en NetBeans, mostrar las anotaciones,
`preparar()`, `guardar()` y llamadas a `buscarPorId/guardar/actualizar` junto con
el XHTML. Esa captura de editor queda por obtener manualmente; no se fabrico.

### 4.3 Expression Language (EL)

Ejemplos de enlace bidireccional reales:

```xhtml
<h:inputText value="#{propiedadFormularioBean.propiedad.titulo}" />
<h:inputText value="#{propiedadFormularioBean.propiedad.precio}" />
<h:selectOneMenu value="#{propiedadFormularioBean.propiedad.estado}" />
<h:commandButton action="#{propiedadFormularioBean.guardar}" />
```

Se verifico en HTTP el paso de campos al modelo, validaciones, almacenamiento y
carga de valores persistidos en modo edicion. Las capturas de nuevo/edicion y el
reporte de prueba complementan el fragmento de codigo, sin presentar capturas
simuladas como ejecucion real.

## Dificultades resueltas

- Se detecto y restituyo el import de Named faltante en el bean del listado antes
  de compilar; no se descartaron las otras modificaciones locales.
- Se adapto Conexion con una propiedad opcional y guardia TEST para evitar usar
  la base principal en escrituras; las credenciales no cambiaron.
- El descriptor XML de la segunda instancia requirio DocumentElement para asignar
  atributos a un nodo Context vacio en PowerShell.
- Windows PowerShell 5.1 interpretaba sin BOM los acentos del script de pruebas;
  se guardo ese script como UTF-8 con BOM. No era un fallo de renderizado JSF.
- Las opciones JVM -D con puntos se entrecomillan en PowerShell para que no se
  interpreten como partes de un nombre de clase.
- Se ajusto la regresion de tabla a ocho columnas: siete de datos y una de acciones.

La fase finaliza con registro y edicion JSF operativos y probados en aislamiento.
La siguiente fase requiere autorizacion posterior.
