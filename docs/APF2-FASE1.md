# APF2 - Fase 1: preparacion de JSF y CDI

> Nota de entrega: esta fase describe su validacion historica. La configuracion
> JDBC actual es externa; consultar APF2-PREPARACION-REPOSITORIO.md. Los resultados
> generados y configuraciones privadas se conservan solo localmente.

## Alcance

Implementado en la rama `apf2-jsf`, creada desde `main` en el commit `18ca4c4`.
El cambio local previo en `nbproject/private/private.xml` se conserva byte por byte.
No se modificaron los Servlets, las JSP fuente, los modelos, los DAO, `Conexion.java`
ni el script SQL. No se implemento CRUD JSF ni se hicieron commits o pushes.

## Plataforma y bibliotecas

La construccion limpia y el servidor se ejecutaron con Oracle JDK 21.0.2.
El Java predeterminado de la consola de este equipo es 25; se selecciono JDK 21
explicitamente para las validaciones. `build.xml` comprueba Java 21 antes de compilar.

Tomcat 11.0.25 aporta Servlet 6.1, JSP 4.0, EL 6.0 y Jakarta Annotation.
Las bibliotecas de aplicacion estan en `web/WEB-INF/lib`:

| Archivo | Uso |
| --- | --- |
| `jakarta.faces-4.1.1.jar` | API e implementacion Mojarra de Jakarta Faces 4.1 |
| `weld-servlet-shaded-6.0.3.Final-tomcat11.jar` | Weld Servlet con CDI API y CDI EL API 4.1.0, Jakarta Inject y dependencias internas |
| `mysql-connector-j-26.7.0.jar` | Mismo Connector/J usado anteriormente, ahora dentro del proyecto |

El JAR sombreado original de Weld incluye copias de Servlet, EL y Annotation.
`tools/restore-dependencies.ps1` elimina exclusivamente los prefijos
`jakarta/servlet/`, `jakarta/el/`, `jakarta/annotation/` y los correspondientes
metadatos Maven, conservando las implementaciones y APIs CDI. Esta variante recibe
el sufijo `-tomcat11`. Las APIs eliminadas son proporcionadas por Tomcat.
No se eliminaron avisos de licencia. No se empaqueta la API completa Jakarta EE.

`tools/dependencies.properties` fija las URLs y SHA-256 tanto de los originales
como de los archivos finales. La restauracion verifica ambos hashes antes de
reemplazar una biblioteca. La construccion Ant verifica los hashes finales.
La prueba `-Force` descargo los tres originales y reprodujo los hashes fijados.
Connector/J coincide tambien con el hash de la biblioteca local anterior.

```powershell
./tools/restore-dependencies.ps1 -VerifyOnly # Verificacion sin red
./tools/restore-dependencies.ps1             # Restaura solo si falta o no coincide
./tools/restore-dependencies.ps1 -Force      # Descarga y reproduce las tres bibliotecas
```

NetBeans sigue usando Ant. `project.properties` contiene rutas relativas y
`project.xml` declara las tres bibliotecas. No se edito `nbproject/build-impl.xml`:
las bibliotecas tambien se copian desde `web/WEB-INF/lib` mediante la tarea existente
que copia el directorio web. Si NetBeans regenera el script, sus declaraciones de
bibliotecas siguen siendo validas.

## Configuracion web

- `web.xml`: se conserva el descriptor Servlet 6.0, admitido por Tomcat 11, la
  bienvenida `index.jsp` y la sesion de 30 minutos. Se registra el listener Weld
  antes de Faces y `jakarta.faces.webapp.FacesServlet`, con `load-on-startup=1`
  y mapeo `*.xhtml`. Las rutas Servlet existentes permanecen sin extension.
- `beans.xml`: CDI 4.1, con `bean-discovery-mode="annotated"`.
- `faces-config.xml`: Faces 4.1 y locale predeterminado `es`. No usa la antigua
  configuracion `managed-bean`; el bean se registra por CDI. El postback de prueba
  permanece en la misma vista y no requiere reglas de navegacion explicitas.
- Se conserva `j2ee.platform=10-web`, metadato existente del proyecto NetBeans 20.
  El servidor efectivo y las bibliotecas Faces/CDI son los indicados arriba; este
  metadato no convierte Tomcat en una implementacion completa de Web Profile.

Los esquemas oficiales `beans_4_1.xsd` y `web-facesconfig_4_1.xsd` respondieron HTTP
200. El despliegue y renderizado comprobaron que los descriptores son aceptados.

## Vista y bean de prueba

`src/java/com/inmobiliaria/bean/PruebaJsfBean.java` usa
`@Named("pruebaJsfBean")` y `@RequestScoped`. El alcance dura una peticion, suficiente
para esta prueba sin estado entre pantallas. No guarda conexiones ni accede a MySQL.

`web/prueba-jsf.xhtml` utiliza los namespaces `jakarta.faces.html` y
`jakarta.faces.core`, y demuestra:

- Lectura EL: `#{pruebaJsfBean.tecnologia}` y `#{pruebaJsfBean.saludo}`.
- Escritura EL: `#{pruebaJsfBean.nombre}` en `h:inputText`.
- Invocacion EL: `#{pruebaJsfBean.saludar}` desde `h:commandButton`.
- Validacion de un campo obligatorio y de su longitud.
- Postback JSF con `jakarta.faces.ViewState`.

El GET muestra `Jakarta Faces 4.1 + CDI 4.1`. Al enviar el formulario con
`Prueba APF2`, aparece `Hola, Prueba APF2. Expression Language ejecuto la accion del bean CDI.`
Un GET nuevo reinicia el bean de peticion. La pagina reutiliza CSS existente;
esta fase no incorpora Bootstrap ni tablas de propiedades JSF.

URL comprobada:

http://localhost:8080/avance-proyecto-final-inmobiliaria/prueba-jsf.xhtml

## Construccion y despliegue

En NetBeans, seleccionar JDK 21, registrar Tomcat 11 y usar Clean and Build / Run.
Desde una consola con JDK 21 y Ant configurados:

```powershell
ant clean dist
```

La construccion necesita las propiedades locales de NetBeans para el servidor y
su biblioteca CopyLibs, o sus equivalentes pasados mediante `-D` en Ant.
No se trasladaron las rutas personales a nuevas dependencias de la aplicacion.

Validacion realizada el 12 de octubre de 2026:

1. El primer `clean dist` encontro un JAR bloqueado por Windows. Detener solamente
   el contexto mediante Manager no libero ese archivo.
2. Se detuvo Tomcat, se ejecuto `clean dist` con Ant 1.10.14 y JDK 21 y se obtuvo
   `BUILD SUCCESSFUL`: 15 fuentes Java compiladas y WAR generado.
3. Se inicio Tomcat con JDK 21 en segundo plano. Se uso el descriptor local ya
   existente que apunta a `build/web`; no fue necesario cambiarlo.
4. Los logs confirmaron inicio de Weld 6.0.3.Final y Mojarra 4.1.1 para el contexto.
   No se encontraron errores de inicializacion o excepciones en el log de esta
   ejecucion. Los avisos de ausencia de servicios transaccionales y Jandex son
   informativos y no impiden esta integracion.
5. Se inspecciono el WAR: tres bibliotecas, bean compilado, XHTML y los tres
   descriptores presentes; no contiene copias de APIs Servlet/EL/Annotation ni
   clases `javax.servlet`, `javax.faces`, `javax.enterprise` o `javax.inject`.

El despliegue validado es el directorio expandido `build/web`, equivalente al
contenido construido. No se afirma haber probado por separado una instalacion
del WAR mediante Tomcat Manager. El servidor quedo funcionando en el puerto 8080.
Los logs de esta ejecucion estan en `dist/tomcat-phase1.stdout.log` y
`dist/tomcat-phase1.stderr.log`, que no se versionan.

Este repositorio ya versiona archivos generados en `build/`: una construccion
limpia cambia esos binarios, sincroniza las copias JSP con sus fuentes y elimina
marcadores de compilacion automatica. No son modificaciones de las fuentes APF1.

## Pruebas HTTP

```powershell
./tools/test-phase1.ps1
# Otro contexto o puerto:
./tools/test-phase1.ps1 -BaseUrl 'http://localhost:8080/avance-proyecto-final-inmobiliaria'
```

Resultado: **31 comprobaciones aprobadas**.

| Grupo | Resultado |
| --- | --- |
| XHTML, lectura EL, HTML procesado, postback y validacion obligatoria | 6 aprobadas |
| Inicio, seis JSP publicas, Servlets publicos y recursos CSS/JS | 13 aprobadas |
| Catalogo con fuente MySQL, acceso Servlet sin sesion y login demo | 3 aprobadas |
| Siete rutas administrativas existentes, solo GET | 7 aprobadas |
| Logout y rechazo posterior del acceso administrativo | 2 aprobadas |

Las peticiones POST se limitaron al formulario JSF de prueba y al login demo,
que modifican exclusivamente estado HTTP. No se enviaron altas, ediciones,
eliminaciones o formularios de contacto, ni se ejecutaron escrituras SQL.
Las credenciales y el codigo de conexion MySQL permanecen sin cambios.

No se ejecuto una inspeccion visual manual en navegador ni pruebas completas del
CRUD. La autenticacion demo y el acceso directo a JSP administrativas detectados
en la auditoria siguen siendo aspectos pendientes de otras fases.

## Referencias de compatibilidad

- [Tomcat: especificaciones y Java soportados](https://tomcat.apache.org/whichversion.html)
- [Jakarta Faces 4.1: Java 17+, implementacion Mojarra](https://jakarta.ee/specifications/faces/4.1/)
- [Weld 6.0.3.Final en contenedores Servlet](https://docs.jboss.org/weld/reference/6.0.3.Final/en-US/html/environments.html)
- [POM oficial de Mojarra 4.1.1](https://repo.maven.apache.org/maven2/org/glassfish/jakarta.faces/4.1.1/jakarta.faces-4.1.1.pom)

La compatibilidad concreta JDK 21 / Tomcat 11 / Mojarra 4.1.1 / Weld 6.0.3.Final
se comprobo ademas con la construccion, arranque, EL y postback descritos arriba.

La fase finaliza aqui. El listado dinamico con `h:dataTable` requiere autorizacion
para la siguiente fase.
