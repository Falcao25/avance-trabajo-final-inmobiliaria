param([Parameter(Mandatory=$true)][string]$JavaHome)
$ErrorActionPreference='Stop'
$listener=Get-NetTCPConnection -State Listen -LocalPort 8081 | Select-Object -First 1
$process=Get-CimInstance Win32_Process -Filter ('ProcessId='+$listener.OwningProcess)
if($process.CommandLine -notmatch '-Dinmobiliaria.database=inmobiliaria_apf2_test\b' -or $process.CommandLine -notmatch '-Dinmobiliaria.test=true\b') {throw 'La JVM TEST no esta aislada.'}
$root=Split-Path -Parent $PSScriptRoot
$java=Join-Path $JavaHome 'bin/java.exe'
$classpath=(Join-Path $root 'build/web/WEB-INF/classes')+';'+(Join-Path $root 'web/WEB-INF/lib/mysql-connector-j-26.7.0.jar')
function Db([string]$mode,[string]$prefix='') {
    $arguments=@('-cp',$classpath,(Join-Path $PSScriptRoot 'Phase3Database.java'),$mode)
    if($prefix) {$arguments+=$prefix}
    $result=@(& $java @arguments)
    if($LASTEXITCODE -ne 0) {throw 'Fallo en comprobacion SQL de TEST.'}
    return $result
}
$script:passed=0
function Check([bool]$value,[string]$message) {if(-not $value) {throw $message}; $script:passed++; Write-Host ('OK: '+$message)}
$before=@(Db 'audit'); $count=[int](Db 'count')[0]
$base='http://localhost:8081/avance-proyecto-final-inmobiliaria'
$session=New-Object Microsoft.PowerShell.Commands.WebRequestSession
$null=Invoke-WebRequest -UseBasicParsing -Uri ($base+'/login') -Method Post -Body @{usuario='admin@inmobiliaria.com';password='admin123'} -WebSession $session
$prefix='APF2_TEST_JSP_'+[Guid]::NewGuid().ToString('N').Substring(0,8)
$body=@{titulo=$prefix;ubicacion='TEST APF1';tipo='Casa';tipoOperacion='Venta';estado='DISPONIBLE';precio='1000.00';area='80';habitaciones='';banos='';descripcion='';imagen='';direccion=''}
$invalid=$body.Clone(); $invalid.precio='-1'
$response=Invoke-WebRequest -UseBasicParsing -Uri ($base+'/admin/nueva-propiedad') -Method Post -Body $invalid -WebSession $session
Check ($response.Content.Contains($prefix) -and [int](Db 'count')[0] -eq $count) 'Validacion JSP rechaza precio negativo y conserva texto sin escribir'
$response=Invoke-WebRequest -UseBasicParsing -Uri ($base+'/admin/nueva-propiedad') -Method Post -Body $body -WebSession $session
$record=@(Db 'marker' $prefix)
Check ($response.BaseResponse.ResponseUri.AbsolutePath.EndsWith('/admin/propiedades') -and $record.Count -eq 1) 'Registro JSP anterior sigue funcionando en TEST'
$id=[int]$record[0].Split("`t")[0]
$body.id=$id; $body.precio='invalid'
$response=Invoke-WebRequest -UseBasicParsing -Uri ($base+'/admin/editar-propiedad') -Method Post -Body $body -WebSession $session
Check ($response.Content.Contains($prefix) -and $response.Content.Contains('name="id" value="'+$id+'"')) 'Error de edicion JSP conserva la propiedad y el ID'
$body.precio='2000.00'; $body.estado='RESERVADA'
$response=Invoke-WebRequest -UseBasicParsing -Uri ($base+'/admin/editar-propiedad') -Method Post -Body $body -WebSession $session
$record=@(Db 'marker' $prefix); $fields=$record[0].Split("`t")
Check ($fields[2] -eq '2000.00' -and $fields[3] -eq 'RESERVADA') 'Edicion JSP anterior persiste en la base aislada'
$response=Invoke-WebRequest -UseBasicParsing -Uri ($base+'/admin/propiedad-formulario.xhtml?id='+$id) -WebSession $session
Check ($response.Content.Contains($prefix) -and $response.Content.Contains('2000.00')) 'JSF carga tambien una propiedad registrada mediante JSP'
Check ([int](Db 'count')[0] -eq ($count+1)) 'Errores y edicion JSP no agregan duplicados'
$after=@(Db 'audit')
Check (($before -join "`n") -ceq ($after -join "`n")) 'Regresion de escritura JSP no modifica datos principales'
Write-Output "Regresion JSP: $script:passed comprobaciones; registro TEST conservado: $id / $prefix"
