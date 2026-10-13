# Diagnostico de dependencias APF2

Verificado el 12 de octubre de 2026 en el proyecto local, con NetBeans 20.

## Causa comprobada

`web/WEB-INF/lib/weld-servlet-shaded-6.0.3.Final-tomcat11.jar` proporciona
`jakarta/inject/Named.class` (422 bytes) y
`jakarta/enterprise/context/RequestScoped.class` (676 bytes).

El JAR anterior coincidia con el manifiesto, pero tenia metadatos ZIP invalidos.
Con el lector `org.netbeans.modules.java.source.parsing.FastJar` de la instalacion
real de NetBeans se reprodujo exactamente:

```
java.util.zip.ZipException: invalid entry size (expected 2534277128 but got 422 bytes)
```

La validacion completa tambien detecto CRC/tamano incorrecto en `META-INF/`
y `only DEFLATED entries can have EXT descriptor` al recorrer el ZIP.
Por tanto, la coincidencia del hash antiguo no garantizaba un JAR valido.
El artefacto original de Maven Central pasa las comprobaciones; el problema
estaba en el ZIP adaptado por el script mediante `ZipArchiveMode.Update` de .NET.

| Artefacto | SHA-256 |
| --- | --- |
| Original Weld 6.0.3.Final, sin cambios | `714ea1da6555fec310584b0e3938176a5eb6821feac8252c8f4c633c56f28cce` |
| Adaptado anterior, invalido aunque fijado | `22b61d6b2ae0b9d64ea3e9b91d723b7371a1aac492ddd47f5c3684430604a48b` |
| Adaptado corregido con JDK 21 | `99f586f15663cb369a5fbbb7ff5759ea729490ff6957657b5d3604c1e390bc74` |

## Correccion

Se descargo exclusivamente Weld desde la URL fijada:
`https://repo.maven.apache.org/maven2/org/jboss/weld/servlet/weld-servlet-shaded/6.0.3.Final/weld-servlet-shaded-6.0.3.Final.jar`.
Se verifico el SHA-256 original antes de prepararlo.

`tools/PrepareWeld.java` reconstruye las cabeceras ZIP con JDK 21, conservando
el orden y las fechas locales de las entradas. Aplica las mismas exclusiones
existentes de Servlet, EL y Annotation, suministradas por Tomcat 11.
Las 2.397 entradas conservadas tienen contenido identico al original;
las 246 exclusiones coinciden exactamente con el filtro anterior.

Se actualizo solo el hash final de Weld en `tools/dependencies.properties`;
la URL, version y hash original permanecen fijados.
`restore-dependencies.ps1` usa el preparador Java y permite seleccionar
una dependencia. El hash final se verifica antes de reemplazar el archivo.
Faces, MySQL y Bootstrap conservaron sus hashes originales.

Comando de restauracion utilizado:

```powershell
./tools/restore-dependencies.ps1 -Dependency weld -JavaHome 'C:\Program Files\Java\jdk-21'
./tools/restore-dependencies.ps1 -VerifyOnly
```

## Verificaciones

- Se revisaron los 39 JAR del classpath: tres del proyecto y 36 de Tomcat 11.
  Todos pasan lectura completa con `ZipFile`, tamanos, CRC y `ZipInputStream`
  despues de la correccion. Las rutas configuradas existen.
- No hay clases duplicadas entre esos JAR (excluyendo los descriptores
  `module-info.class` y las variantes bajo `META-INF/versions/`).
- Los imports de `PruebaJsfBean.java` ya son correctos:
  `jakarta.inject.Named` y `jakarta.enterprise.context.RequestScoped`.
  No se cambio el contenido del bean.
- El lector real `FastJar` de NetBeans lee ambas anotaciones del JAR corregido:
  `Named.class bytes=422` y `RequestScoped.class bytes=676`.
- NetBeans reindexo Weld y el bean. Se actualizo solo la fecha del fuente para
  solicitar su relectura; desaparecio el archivo de errores
  `index/s310/errors/1/com/inmobiliaria/bean/PruebaJsfBean.java.err` y se regenero
  `PruebaJsfBean.sig`. No fue necesario borrar caches ni reiniciar el IDE.

## Compilacion limpia

JDK Oracle 21.0.2 (`C:\Program Files\Java\jdk-21`) y Ant 1.10.14, incluido en
NetBeans. Se utilizaron las propiedades privadas existentes del proyecto:

```powershell
& 'C:\Program Files\Java\jdk-21\bin\java.exe' -jar 'C:\Program Files\NetBeans-20\netbeans\extide\ant\lib\ant-launcher.jar' clean dist
```

Resultado: **BUILD SUCCESSFUL**, 20 fuentes compilados y WAR generado en
`dist/avance-proyecto-final-inmobiliaria.war`. Las comprobaciones SHA-256 del
target `-pre-compile` tambien pasaron.

No se ejecutaron despliegues, pruebas con acceso a bases de datos, cambios de
credenciales, commits ni push. Se conservaron los cambios previos del usuario
en el bean y los archivos generados de NetBeans.
