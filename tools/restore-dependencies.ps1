param(
    [switch]$VerifyOnly,
    [switch]$Force
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
Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem

foreach ($id in $lock['dependencies.ids'].Split(',')) {
    $destination = Join-Path $libraryDir $lock["$id.file"]
    $valid = (Test-Path -LiteralPath $destination) -and
        ((Get-FileHash -LiteralPath $destination -Algorithm SHA256).Hash -eq $lock["$id.sha256"])
    if ($VerifyOnly) {
        if (-not $valid) { throw "Falta una biblioteca o su SHA-256 es incorrecto: $destination" }
    } elseif ($Force -or -not $valid) {
        $download = [System.IO.Path]::GetTempFileName()
        try {
            Invoke-WebRequest -UseBasicParsing -Uri $lock["$id.url"] -OutFile $download -TimeoutSec 60
            if ((Get-FileHash -LiteralPath $download -Algorithm SHA256).Hash -ne $lock["$id.upstream.sha256"]) {
                throw "SHA-256 del artefacto original incorrecto: $id"
            }
            if ($id -eq 'weld') {
                # El shaded original incluye APIs que ya proporciona Tomcat 11.
                # Conservamos CDI/Weld y retiramos Servlet, EL y Annotation duplicadas.
                $archive = [System.IO.Compression.ZipFile]::Open($download, [System.IO.Compression.ZipArchiveMode]::Update)
                try {
                    $excluded = @($archive.Entries | Where-Object {
                        $_.FullName -match '^jakarta/(servlet|el|annotation)/|^META-INF/maven/jakarta\.(servlet|el|annotation)/'
                    })
                    foreach ($entry in $excluded) { $entry.Delete() }
                } finally { $archive.Dispose() }
            }
            if ((Get-FileHash -LiteralPath $download -Algorithm SHA256).Hash -ne $lock["$id.sha256"]) {
                throw "SHA-256 de la biblioteca preparada incorrecto: $id"
            }
            Copy-Item -LiteralPath $download -Destination $destination -Force
        } finally { Remove-Item -LiteralPath $download -ErrorAction SilentlyContinue }
    }
    Write-Output "OK SHA-256: $($lock["$id.file"])"
}
