# Inmobiliaria Aurora

Aplicación con catálogo público y panel administrativo. El listado, registro y
edición de propiedades utilizan Jakarta Faces (JSF), CDI y Bootstrap.
El dashboard presenta métricas.

Inicio, catálogo, detalles, contactos, usuarios y métricas consultan MySQL mediante
los DAO. El login valida cuentas activas de la tabla `usuarios` y los mensajes del
formulario de contacto se guardan en `contactos`. No se utilizan datos de ejemplo.

## Entorno

NetBeans con Ant y JDK 21, Tomcat 11 y MySQL.
Jakarta Faces 4.1.1, Weld 6.0.3.Final, Connector/J y Bootstrap 5.3.8 incluidos.

## Configuración JDBC

El esquema está en `database/inmobiliaria.sql`.
Copiar `config/database.example.properties` a `config/database.local.properties`
y completar las credenciales únicamente en el archivo local ignorado por Git.

Se admite `-Dinmobiliaria.config=RUTA_AL_ARCHIVO`, `INMOBILIARIA_CONFIG`
o `conf/inmobiliaria.properties` dentro de CATALINA_BASE.
Las variables `INMOBILIARIA_DB_USER` y `INMOBILIARIA_DB_PASSWORD` permiten suministrar
las credenciales mediante el entorno. No publicar valores reales.

## Construcción y ejecución

Registrar JDK 21 y Tomcat 11 en NetBeans y ejecutar Clean and Build / Run.
Desde consola con Ant y las propiedades de NetBeans configurados:

```powershell
ant clean dist
```

Verificar las dependencias:

```powershell
./tools/restore-dependencies.ps1 -VerifyOnly
```

Restaurar solamente las dependencias ausentes o incorrectas:

```powershell
./tools/restore-dependencies.ps1 -JavaHome 'RUTA_AL_JDK_21'
```

`tools/dependencies.properties` fija versiones y SHA-256. `PrepareWeld.java`
prepara Weld para Tomcat 11 y es utilizado por el restaurador.

## Acceso

Inicio: `/avance-proyecto-final-inmobiliaria/index.jsp`.
Catálogo: `/avance-proyecto-final-inmobiliaria/propiedades`.
Acceso administrativo: `/avance-proyecto-final-inmobiliaria/login`.
Las rutas `/admin` requieren la sesión administrativa.
