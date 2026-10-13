param(
    [switch]$VerifyOnly,
    [switch]$Force,
    [string[]]$Dependency,
    [string]$JavaHome = $env:JAVA_HOME
)

$ErrorActionPreference = 'Stop'
if ($VerifyOnly -and $Force) { throw 'Usa VerifyOnly o Force, no ambos.' }
$projectRoot = Split-Path -Parent $PSScriptRoot
$lock = @{}
Get-Content -LiteralPath (Join-Path $PSScriptRoot 'dependencies.properties') | ForEach-Object {
    if ($_ -match '^([^#=]+)=(.*)$') { $lock[$matches[1].Trim()] = $matches[2].Trim() }
}
$libraryDir = Join-Path $projectRoot 'web/WEB-INF/lib'
if (-not $VerifyOnly) { New-Item -ItemType Directory -Force -Path $libraryDir | Out-Null }

$ids = $lock['dependencies.ids'].Split(',')
if ($Dependency) {
    foreach ($id in $Dependency) {
        if ($id -notin $ids) { throw "Dependencia desconocida: $id" }
    }
    $ids = $Dependency
}
foreach ($id in $ids) {
    $assetDir = $libraryDir
    if ($lock.ContainsKey("$id.directory")) { $assetDir = Join-Path $projectRoot $lock["$id.directory"] }
    if (-not $VerifyOnly) { New-Item -ItemType Directory -Force -Path $assetDir | Out-Null }
    $destination = Join-Path $assetDir $lock["$id.file"]
    $valid = (Test-Path -LiteralPath $destination) -and
        ((Get-FileHash -LiteralPath $destination -Algorithm SHA256).Hash -eq $lock["$id.sha256"])
    if ($VerifyOnly) {
        if (-not $valid) { throw "Falta una biblioteca o su SHA-256 es incorrecto: $destination" }
    } elseif ($Force -or -not $valid) {
        $download = [System.IO.Path]::GetTempFileName()
        try {
            try {
                Invoke-WebRequest -UseBasicParsing -Uri $lock["$id.url"] -OutFile $download -TimeoutSec 20
            } catch {
                if (-not (Get-Command curl.exe -ErrorAction SilentlyContinue)) { throw }
                # Mantiene la validacion TLS; tolera solo que el servicio de revocacion este sin conexion.
                & curl.exe --ssl-revoke-best-effort --silent --show-error --fail --location --max-time 30 --output $download $lock["$id.url"]
                if ($LASTEXITCODE -ne 0) { throw "No se pudo descargar el artefacto: $id" }
            }
            if ((Get-FileHash -LiteralPath $download -Algorithm SHA256).Hash -ne $lock["$id.upstream.sha256"]) {
                throw "SHA-256 del artefacto original incorrecto: $id"
            }
            if ($id -eq 'weld') {
                # El shaded original incluye APIs que ya proporciona Tomcat 11.
                # Conservamos CDI/Weld y retiramos Servlet, EL y Annotation duplicadas.
                # Java escribe cabeceras y descriptores compatibles con el lector ZIP de NetBeans.
                $java = if ($JavaHome) { Join-Path $JavaHome 'bin/java.exe' } else { 'java.exe' }
                $prepared = [System.IO.Path]::GetTempFileName()
                try {
                    & $java (Join-Path $PSScriptRoot 'PrepareWeld.java') $download $prepared
                    if ($LASTEXITCODE -ne 0) { throw 'No se pudo preparar Weld con JDK 21. Indica -JavaHome.' }
                    Copy-Item -LiteralPath $prepared -Destination $download -Force
                } finally { Remove-Item -LiteralPath $prepared -ErrorAction SilentlyContinue }
            }
            if ((Get-FileHash -LiteralPath $download -Algorithm SHA256).Hash -ne $lock["$id.sha256"]) {
                throw "SHA-256 de la biblioteca preparada incorrecto: $id"
            }
            Copy-Item -LiteralPath $download -Destination $destination -Force
        } finally { Remove-Item -LiteralPath $download -ErrorAction SilentlyContinue }
    }
    Write-Output "OK SHA-256: $($lock["$id.file"])"
}
