# avance-trabajo-final-inmobiliaria

## Base de datos

1. Crear la base de datos ejecutando `database/inmobiliaria.sql` en MySQL Workbench.
2. Configurar usuario y contrasena en `src/java/com/inmobiliaria/config/Conexion.java`.
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
