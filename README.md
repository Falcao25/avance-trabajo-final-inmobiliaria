# avance-trabajo-final-inmobiliaria

## Base de datos

1. Crear la base de datos ejecutando `database/inmobiliaria.sql` en MySQL Workbench.
2. Copiar `config/database.example.properties` a `config/database.local.properties` y configurar alli las credenciales locales. Este archivo se ignora en Git.
3. MySQL Connector/J esta incluido en `web/WEB-INF/lib`, con una referencia relativa en NetBeans.
4. Ejecutar el proyecto desde NetBeans.
5. Abrir `http://localhost:8080/avance-proyecto-final-inmobiliaria/propiedades`.

## APF2 - Fase 1: JSF y CDI

La arquitectura conserva NetBeans con Ant, los Servlets, las JSP, los modelos y los DAO.
La vista de prueba esta disponible en:

http://localhost:8080/avance-proyecto-final-inmobiliaria/prueba-jsf.xhtml

Usa JDK 21, Tomcat 11, Mojarra 4.1.1 y Weld 6.0.3.Final (CDI 4.1).
Las tres bibliotecas estan incluidas en el proyecto. Para verificar sus SHA-256:

```powershell
./tools/restore-dependencies.ps1 -VerifyOnly
```

Para restaurarlas desde versiones fijas de Maven Central:

```powershell
./tools/restore-dependencies.ps1
```

Para ejecutar las pruebas HTTP sobre el despliegue local:

```powershell
./tools/test-phase1.ps1
```

La configuracion, la construccion Ant y los resultados comprobados se describen en
[docs/APF2-FASE1.md](docs/APF2-FASE1.md).

## APF2 - Fase 2: inventario administrativo JSF

Iniciar sesion con el login existente y abrir **Inventario de propiedades (JSF)**
desde el menu del dashboard:

http://localhost:8080/avance-proyecto-final-inmobiliaria/admin/propiedades-jsf.xhtml

La vista usa Bootstrap 5.3.8 local, `h:dataTable`, un bean CDI `@ViewScoped` y
`PropiedadDAO.listar()` para consultar MySQL. No implementa escrituras JSF.
El acceso a `/admin` y `/admin/*`, incluidas las JSP directas, requiere la sesion
creada por el login existente.

```powershell
./tools/test-phase2.ps1 -JavaHome 'RUTA_DE_TU_JDK_21'
```

[Arquitectura, pruebas y evidencias para los capitulos 3, 4 y 5](docs/APF2-FASE2.md).

## APF2 - Fase 3: registro y edicion JSF

Formulario compartido, con sesion administrativa:

- Registro: `/admin/propiedad-formulario.xhtml`.
- Edicion: `/admin/propiedad-formulario.xhtml?id=ID_EXISTENTE`.

La aplicacion principal conserva el puerto **8080** y la base `inmobiliaria`.
La instancia aislada de pruebas utiliza **8081** y `inmobiliaria_apf2_test`.
Las pruebas de escritura se ejecutan exclusivamente en la segunda instancia.

URL de registro para pruebas:
http://localhost:8081/avance-proyecto-final-inmobiliaria/admin/propiedad-formulario.xhtml

La base aislada se conserva. No se modificaron las nueve propiedades originales.
Las reglas se comparten entre JSF y los Servlets/JSP existentes.

[Implementacion, preparacion del perfil TEST, pruebas y evidencias del capitulo 4](docs/APF2-FASE3.md).

## APF2 - Fase 4: integracion y validacion final

El flujo Login -> Dashboard -> Listado JSF -> Registro -> Listado -> Edicion ->
Listado -> Logout se verifico en Chrome, incluidos retroceso, cancelacion,
mensajes y acceso restringido. Las escrituras se limitaron a la instancia TEST.

[Resultados finales, arquitectura y correspondencia con capitulos 2 a 5](docs/APF2-FASE4.md).

Las capturas obligatorias 01 a 04 estan conservadas en `docs/evidencias/fase4/`.
La captura 05 de GitHub queda pendiente de autorizar commits y publicacion.

Prueba adicional de navegador (solo TEST en puerto 8081):

```powershell
node --experimental-websocket tools/test-phase4-navigation.mjs 'RUTA_AL_CHROME/chrome.exe'
```

## Configuracion privada y entrega

`database/inmobiliaria.sql` contiene solamente el esquema y las relaciones, sin
registros personales o semillas. La aplicacion APF1 y su login demo se conservan.

JDBC lee configuracion externa, en este orden: archivo indicado por
`-Dinmobiliaria.config` o `INMOBILIARIA_CONFIG`; `config/database.local.properties`
desde el directorio de trabajo; o `conf/inmobiliaria.properties` de CATALINA_BASE.
`INMOBILIARIA_DB_USER` y `INMOBILIARIA_DB_PASSWORD` permiten sustituir las credenciales
por variables de entorno. Nunca agregar valores reales al ejemplo publico.

Para ejecutar desde NetBeans/Tomcat con otro directorio de trabajo, copiar el
archivo local a `conf/inmobiliaria.properties` del servidor o configurar
`-Dinmobiliaria.config` en las opciones JVM de Tomcat. El script TEST pasa la ruta
del archivo ignorado y conserva la guardia para `inmobiliaria_apf2_test`.

Registrar JDK 21 y Tomcat 11 en NetBeans para generar `nbproject/private/` localmente.
En consola, configurar las rutas locales de Tomcat y la biblioteca CopyLibs de
NetBeans cuando Ant lo requiera. Los fuentes, archivos Ant/JSF y dependencias
relativas estan incluidos; build, dist, configuraciones privadas y resultados de
pruebas no se versionan.

Antes de publicar, revisar [el plan exacto de commits y la auditoria](docs/APF2-PREPARACION-REPOSITORIO.md).
