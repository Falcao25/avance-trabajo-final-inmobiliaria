param([Parameter(Mandatory=$true)][string]$TomcatHome,
      [Parameter(Mandatory=$true)][string]$JavaHome)
$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$testBase = Join-Path $root 'dist/tomcat-apf2-test'
if (Get-NetTCPConnection -State Listen -LocalPort 8081 -ErrorAction SilentlyContinue) {
    throw 'El puerto 8081 ya esta ocupado. Verifica el perfil existente antes de iniciar otra instancia.'
}
foreach ($directory in @('conf','conf/Catalina/localhost','logs','temp','webapps','work')) {
    New-Item -ItemType Directory -Force -Path (Join-Path $testBase $directory) | Out-Null
}
Get-ChildItem -LiteralPath (Join-Path $TomcatHome 'conf') -File | ForEach-Object {
    Copy-Item -LiteralPath $_.FullName -Destination (Join-Path $testBase 'conf')
}
[xml]$server = Get-Content -LiteralPath (Join-Path $testBase 'conf/server.xml')
$server.Server.port = '8006'
foreach ($connector in $server.Server.Service.Connector) {
    if ($connector.port -eq '8080') { $connector.port = '8081'; $connector.redirectPort = '8444' }
}
$server.Save((Join-Path $testBase 'conf/server.xml'))
$descriptor = [xml]'<Context />'
$descriptor.DocumentElement.SetAttribute('docBase', (Join-Path $root 'build/web').Replace('\','/'))
$descriptor.Save((Join-Path $testBase 'conf/Catalina/localhost/avance-proyecto-final-inmobiliaria.xml'))
$env:JAVA_HOME = $JavaHome
$env:JRE_HOME = $JavaHome
$env:CATALINA_HOME = $TomcatHome
$env:CATALINA_BASE = $testBase
$localConfig = Join-Path $root 'config/database.local.properties'
if (-not (Test-Path -LiteralPath $localConfig)) { throw 'Configura config/database.local.properties antes de iniciar TEST.' }
$env:CATALINA_OPTS = '-Dinmobiliaria.database=inmobiliaria_apf2_test -Dinmobiliaria.test=true "-Dinmobiliaria.config=' + $localConfig + '"'
$launcher = Start-Process -FilePath $env:ComSpec -ArgumentList ('/c "' + (Join-Path $TomcatHome 'bin/catalina.bat') + '" run') -WindowStyle Hidden -PassThru `
    -RedirectStandardOutput (Join-Path $testBase 'logs/stdout.log') -RedirectStandardError (Join-Path $testBase 'logs/stderr.log')
Write-Output "Tomcat TEST iniciado: puerto 8081; base inmobiliaria_apf2_test; launcher $($launcher.Id)."
