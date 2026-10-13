import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.zip.ZipEntry;
import java.util.zip.ZipFile;
import java.util.zip.ZipOutputStream;

/** Prepara el shaded fijado sin las APIs que proporciona Tomcat 11. */
public class PrepareWeld {
    public static void main(String[] args) throws IOException {
        if (Runtime.version().feature() != 21) {
            throw new IllegalStateException("La preparacion reproducible requiere JDK 21.");
        }
        try (ZipFile source = new ZipFile(args[0]);
             ZipOutputStream target = new ZipOutputStream(Files.newOutputStream(Path.of(args[1])))) {
            var entries = source.entries();
            while (entries.hasMoreElements()) {
                ZipEntry entry = entries.nextElement();
                if (entry.getName().matches("^(jakarta/(servlet|el|annotation)/|META-INF/maven/jakarta\\.(servlet|el|annotation)/).*")) {
                    continue;
                }
                // Reescribir cabeceras y descriptores, sin heredar metadatos ZIP inconsistentes.
                ZipEntry output = new ZipEntry(entry.getName());
                output.setTimeLocal(entry.getTimeLocal());
                target.putNextEntry(output);
                try (var input = source.getInputStream(entry)) {
                    input.transferTo(target);
                }
                target.closeEntry();
            }
        }
    }
}
