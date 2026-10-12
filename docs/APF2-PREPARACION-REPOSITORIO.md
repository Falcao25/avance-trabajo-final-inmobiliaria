# APF2 - Auditoria y preparacion del repositorio

Preparacion realizada el 12 de octubre de 2026 en `apf2-jsf`.
El staging esta preparado para revision; no se ejecutaron commits, push, merges
ni reescrituras del historial. `main` mantiene su referencia `18ca4c4` y HEAD
continua en `89d333f`. La Fase 1 ya forma parte de ese historial: no se duplicara.

## Hallazgos y ajustes

- La conexion JDBC tenia una credencial real literal en el codigo y en clases
  generadas rastreadas. Se externalizo, preservando sus valores locales actuales.
- `nbproject/private/private.xml` y `private.properties` estaban rastreados; se
  retiraron del indice sin borrar los archivos locales.
- `build/` estaba rastreado con clases, copias JSP y bibliotecas; se retiro del
  indice. Las fuentes originales y dependencias de `web/WEB-INF/lib` permanecen.
- `database/inmobiliaria.sql` incluia semillas con nombres, emails, documentos y
  claves de ejemplo. El archivo publico contiene solo DDL y relaciones. La copia
  completa anterior se conserva en `database/local/inmobiliaria-seed.local.sql`,
  ignorada. No se ejecuto SQL para esta separacion ni se tocaron registros reales.
- JSON/TSV de pruebas, perfiles Tomcat/Chrome, logs, WAR, clases y temporales se
  excluyen. Las capturas PNG academicas 01 a 04 y el apoyo movil se mantienen:
  muestran configuracion sin secretos y registros TEST identificables, no una
  exportacion de las propiedades principales.
- Se agrego `.gitattributes` para conservar bytes de JAR, CSS Bootstrap, licencia
  y PNG. Es necesario para que los SHA-256 fijados sobrevivan a checkout Windows.

El retiro afecta **60 archivos rastreados**: 58 de build y 2 de configuracion
privada. `git rm --cached` prepara sus eliminaciones del repositorio, no del disco.
La compilacion reconstruyo build y las configuraciones privadas siguen presentes.
El hash del private.xml previo se conserva.

## Configuracion JDBC externa

`DatabaseSettings.java` carga un archivo indicado por `inmobiliaria.config` o
`INMOBILIARIA_CONFIG`; por defecto busca `config/database.local.properties` en el
directorio de trabajo y, si no existe, `conf/inmobiliaria.properties` dentro de
CATALINA_BASE. Tambien admite `INMOBILIARIA_DB_USER` y `INMOBILIARIA_DB_PASSWORD`.
No imprime valores sensibles en sus excepciones.

Se entrega `config/database.example.properties` con placeholders. Copiarlo a la
version local ignorada y completar sus valores, o configurar el entorno. El archivo
local no se incluye en el WAR. Para NetBeans/Tomcat que se ejecuta desde otro
directorio, usar el archivo conf del servidor o la opcion JVM de archivo explicito.

La conexion y sus operaciones permanecen iguales, incluida la guardia TEST.
HOST, PORT, usuario y password efectivos no se cambiaron. El script de arranque
TEST recibe solo la ruta del archivo ignorado; no coloca el password en argumentos
de procesos. El helper SQL usa el mismo cargador y no analiza secretos del Java.
Los comandos del helper requieren el proyecto previamente compilado:

```powershell
& "$env:JAVA_HOME/bin/java.exe" -cp 'build/web/WEB-INF/classes;web/WEB-INF/lib/mysql-connector-j-26.7.0.jar' tools/Phase3Database.java audit
```

El primer archivo local generado tenia un formato de propiedades incorrecto; se
corrigio, se reiniciaron las instancias y se repitieron las regresiones completas.
La validacion final corresponde al formato correcto.

## Archivos publicables y exclusiones

| Publicables | Motivo |
| --- | --- |
| src/java, JSP/XHTML, CSS, JS e imagenes de la aplicacion | Funcionalidad APF1 y APF2 |
| web/WEB-INF/web.xml, beans.xml, faces-config.xml | Configuracion JSF/CDI |
| build.xml y nbproject fuera de private | Construccion Ant y proyecto NetBeans |
| web/WEB-INF/lib y recursos Bootstrap/LICENSE | Dependencias fijadas y reproducibles |
| config/database.example.properties | Plantilla sin credenciales reales |
| database/inmobiliaria.sql | Esquema sin INSERT ni registros |
| tools/*.java, *.ps1, *.mjs y manifiesto de dependencias | Codigo de preparacion/pruebas, no sus resultados |
| README, docs/APF2-*.md y docs/plan-commits.json | Documentacion y propuesta de commits |
| docs/evidencias/fase4/*.png | Capturas academicas revisadas |

| Excluidos | Motivo |
| --- | --- |
| build, dist, *.class, *.war | Compilados, paquetes y perfiles generados |
| nbproject/private | Identidad local de servidor, rutas personales y preferencias |
| config/database.local.properties, .env y variantes locales | Credenciales o configuracion de maquina |
| database/local | Copia SQL anterior con semillas; ningun dato se publica |
| *.log, *.tmp, *.bak, *.hprof | Logs, temporales y volcados |
| docs/evidencias/**/*.json y **/*.tsv | Resultados, fixtures y fingerprints de pruebas |
| node_modules | Dependencias instaladas localmente; los scripts actuales no requieren paquetes npm |

No se excluyen globalmente los JAR: los tres JAR de aplicacion son necesarios y
ya estan fijados por SHA-256. No se eliminan los scripts que permiten reproducir
las pruebas. Las referencias a JSON/TSV en informes de fases describen evidencias
locales, no archivos que se entreguen en Git.

## Riesgos pendientes antes de publicar

**El snapshot preparado esta saneado; el historial no esta libre de secretos.**
La credencial real anterior aparece en commits `18ca4c4`, `18a82eb`, `d8b3695` y
`c0ad984`. Retirar archivos y el literal del indice no elimina esos objetos ni
las lineas antiguas que aparecen en los diffs. El historial tambien conserva los
artefactos privados y semillas previamente rastreados.

Antes de publicar se debe revocar/rotar esa credencial y revisar con el propietario
si hace falta un tratamiento del historial, especialmente si esos commits ya se
compartieron. No se cambio la credencial de MySQL, no se alteraron usuarios ni se
reescribio `main`: esas acciones requieren una autorizacion independiente.

El login demo y MockData del APF1 conservan claves publicas de demostracion por
compatibilidad. No se clasifican como secretos privados, pero son un riesgo real
si se despliega el sistema como servicio publico con esa autenticacion. El perfil
academico no se presenta como autenticacion segura de produccion.

Las opciones JDBC de TLS corresponden al entorno local ya validado. Esta entrega
de codigo no equivale a aprobar su exposicion como servicio publico.

## Plan exacto de commits (propuesta)

`docs/plan-commits.json` enumera, archivo por archivo, los seis grupos y los 60
retiros del indice. No hay commits ejecutados en esta preparacion.

1. **chore(security): externalizar JDBC y excluir archivos privados y generados**
   Configuracion externa y plantilla, schema sin datos, helper/arranque TEST y
   exclusiones; retirar build/private solo del repositorio.
2. **chore(web): consolidar configuracion JSF y Bootstrap reproducible**
   Ant, descripcion Faces, manifiesto/restauracion Bootstrap y reglas de bytes.
3. **feat(jsf): integrar listado inmobiliario y proteccion administrativa**
   Bean de lista, filtro, tabla, navegacion de dashboard y estilos administrativos.
4. **feat(jsf): agregar formularios y validaciones compartidas**
   Bean y formulario nuevo/edicion, reglas compartidas y integracion con Servlet.
5. **test(apf2): documentar pruebas reproducibles con aislamiento MySQL**
   Fuentes de las suites, contraste DAO y automatizacion Chrome.
6. **docs(apf2): consolidar fases, evidencias y auditoria de publicacion**
   README, documentos de fases, capturas academicas y plan exacto.

El staging actual representa el resultado completo. Despues de la autorizacion
habra que seleccionar grupos en ese orden: no ejecutar un commit unico con todo
el staging por accidente. El listado final incluye enlaces al formulario del grupo
siguiente; la secuencia se valida/publica como conjunto, no se certifican estados
intermedios como entregas terminadas.

## Verificaciones despues de los ajustes

- Compilacion limpia local con JDK 21 y Ant: BUILD SUCCESSFUL.
- Exportacion del indice a dist/staged-review, sin private ni archivo de
  credenciales: BUILD SUCCESSFUL. Se pasaron rutas locales del servidor y CopyLibs
  como propiedades Ant, no dentro de archivos publicados.
- Regresiones 1/2/3 y JSP: 31, 29, 51 y 7 comprobaciones aprobadas.
- Pruebas aisladas del listado/formulario y guardia: 7, 11 y 1 aprobadas.
- Navegacion Chrome con configuracion externa: 21 aprobadas, incluido retroceso.
- Total de suites repetidas: 158 comprobaciones; escrituras exclusivamente en
  inmobiliaria_apf2_test. Las cuatro tablas principales mantienen sus hashes.
- Escaneo del indice: no contiene la credencial MySQL real detectada, archivos
  privados, resultados de pruebas o rutas personales en textos publicados.
- Las claves demo se identifican como datos publicos APF1; no se confunden con
  la credencial privada retirada.
- Dependencias y estructura del proyecto se conservan; los artefactos compilados
  se mantienen locales y se reconstruyen a partir de las fuentes.
- Rama actual apf2-jsf; main y HEAD conservan sus referencias, sin commits/push.

Ejemplo de compilacion desde el snapshot exportado sin configuracion privada,
usando instalaciones locales que cada equipo debe proporcionar:

```powershell
$copyLibsPath = Join-Path $env:NETBEANS_HOME 'java/ant/extra/org-netbeans-modules-java-j2seproject-copylibstask.jar'
ant "-Dj2ee.server.home=$env:CATALINA_HOME" "-Dlibs.CopyLibs.classpath=$copyLibsPath" clean dist
```

Estado final: staging y plan revisables, sin operaciones de publicacion. Se
espera autorizacion expresa; el riesgo del secreto historico sigue pendiente.
