param([string]$JavaHome = $env:JAVA_HOME,
      [string]$BaseUrl = 'http://localhost:8081/avance-proyecto-final-inmobiliaria')
$ErrorActionPreference='Stop'
$root=Split-Path -Parent $PSScriptRoot
$java=Join-Path $JavaHome 'bin/java.exe'
$driverClasspath=(Join-Path $root 'build/web/WEB-INF/classes')+';'+(Join-Path $root 'web/WEB-INF/lib/mysql-connector-j-26.7.0.jar')
$databaseTool=Join-Path $PSScriptRoot 'Phase3Database.java'
$uri=[Uri]$BaseUrl
if($uri.Host -notin @('localhost','127.0.0.1') -or $uri.Port -ne 8081) {throw 'Las pruebas de escritura solo admiten la instancia TEST local en 8081.'}
$listener=Get-NetTCPConnection -State Listen -LocalPort 8081 | Select-Object -First 1
$process=Get-CimInstance Win32_Process -Filter ('ProcessId='+$listener.OwningProcess)
if($process.CommandLine -notmatch '-Dinmobiliaria\.database=inmobiliaria_apf2_test\b' -or $process.CommandLine -notmatch '-Dinmobiliaria\.test=true\b') {
    throw 'Se rechazo la escritura: la JVM del puerto TEST no declara la base aislada y su guardia.'
}
$script:passed=0
function Check([bool]$value,[string]$description) {
    if(-not $value) {throw ('FALLO: '+$description)}
    $script:passed++; Write-Host ('OK: '+$description)
}
function Db([string]$operation,[string]$marker='') {
    $arguments=@('-cp',$driverClasspath,$databaseTool,$operation)
    if($marker) {$arguments+=$marker}
    $result=@(& $java @arguments)
    if($LASTEXITCODE -ne 0) {throw ('Fallo al verificar TEST: '+$operation)}
    return $result
}
$before=@(Db 'audit')
$baseline=[int](Db 'count')[0]
$session=New-Object Microsoft.PowerShell.Commands.WebRequestSession
$route='/admin/propiedad-formulario.xhtml'
function Page([string]$path=$route) {Invoke-WebRequest -UseBasicParsing -Uri ($BaseUrl+$path) -WebSession $session -TimeoutSec 20}
function Body {
    return @{'propiedad'='propiedad';'propiedad:titulo'=$script:marker;'propiedad:precio'='123456.78';
        'propiedad:ubicacion'='Entorno aislado APF2';'propiedad:direccion'='Direccion TEST';'propiedad:tipo'='CASA';
        'propiedad:operacion'='VENTA';'propiedad:estado'='DISPONIBLE';'propiedad:area'='100.25';
        'propiedad:habitaciones'='3';'propiedad:banos'='2';'propiedad:imagen'='';
        'propiedad:descripcion'='Registro JSF de prueba autorizado';'propiedad:guardar'='Registrar propiedad'}
}
function Submit($page,$body,[string]$path=$route) {
    $state=[regex]::Match($page.Content,'name="jakarta.faces.ViewState"[^>]*value="([^"]+)"').Groups[1].Value
    if(-not $state) {throw 'Falta ViewState. No se envia la escritura.'}
    $body['jakarta.faces.ViewState']=[Net.WebUtility]::HtmlDecode($state)
    return Invoke-WebRequest -UseBasicParsing -Uri ($BaseUrl+$path) -Method Post -Body $body -WebSession $session -TimeoutSec 20
}
$script:marker='APF2_TEST_001_'+[Guid]::NewGuid().ToString('N').Substring(0,8)
foreach($path in @($route,($route+'?id=1'))) {
    $denied=Page $path
    Check ($denied.BaseResponse.ResponseUri.AbsolutePath.EndsWith('/login')) ('Sin sesion: '+$path)
}
$denied=Invoke-WebRequest -UseBasicParsing -Uri ($BaseUrl+$route) -Method Post -Body (Body) -WebSession $session -TimeoutSec 20
Check ($denied.BaseResponse.ResponseUri.AbsolutePath.EndsWith('/login') -and [int](Db 'count')[0] -eq $baseline) 'POST sin sesion no escribe en TEST'
$login=Invoke-WebRequest -UseBasicParsing -Uri ($BaseUrl+'/login') -Method Post -Body @{usuario='admin@inmobiliaria.com';password='admin123'} -WebSession $session -TimeoutSec 20
$new=Page
Check ($new.StatusCode -eq 200 -and $new.Content.Contains('id="propiedad"')) 'Formulario de registro XHTML renderizado'
foreach($case in @(
    @('titulo','','El título es obligatorio'), @('precio','','El precio es obligatorio'),
    @('ubicacion','','La ubicación es obligatoria'), @('area','','El área es obligatoria'),
    @('precio','abc','El precio debe ser un número válido'), @('area','abc','El área debe ser un número válido'),
    @('habitaciones','1.5','Las habitaciones deben ser un número entero válido'),
    @('precio','-1','El precio debe estar entre'), @('area','NaN','El área debe ser un número finito'),
    @('precio','10000000000','El precio debe estar entre'), @('area','100000000','El área debe ser un número finito'),
    @('titulo',('A'*181),'180 caracteres'), @('ubicacion',('U'*161),'160 caracteres'),
    @('direccion',('D'*221),'220 caracteres'), @('imagen',('I'*256),'255 caracteres')
)) {
    $page=Page; $body=Body; $body['propiedad:'+$case[0]]=$case[1]; $response=Submit $page $body
    Check ($response.Content.Contains($case[2]) -and $response.Content.Contains('id="propiedad"')) ('Validacion: '+$case[0]+' / '+$case[2])
    if($case[0] -ne 'titulo') {Check ($response.Content.Contains($script:marker)) 'Los datos introducidos se conservan tras el error'}
}
foreach($field in @('tipo','operacion','estado')) {
    $page=Page; $body=Body; $body['propiedad:'+$field]='NO_PERMITIDO'; $response=Submit $page $body
    Check ($response.Content.Contains('text-danger') -and $response.Content.Contains('id="propiedad"')) ('Select rechaza valor ajeno al ENUM: '+$field)
}
Check ([int](Db 'count')[0] -eq $baseline) 'Ninguna validacion fallida inserto registros'
foreach($invalidId in @('abc','0','-1','','2147483647')) {
    $missing=Page ($route+'?id='+$invalidId)
    Check ($missing.Content -notmatch '<form[^>]*id="propiedad"' -and $missing.Content.Contains('alert-danger')) ('ID invalido o inexistente no habilita formulario: '+$invalidId)
}
$created=Submit (Page) (Body)
Check ($created.BaseResponse.ResponseUri.AbsolutePath.EndsWith('/admin/propiedades-jsf.xhtml') -and $created.Content.Contains('Propiedad registrada correctamente.')) 'Registro redirige al listado y conserva mensaje Flash'
$record=@(Db 'marker' $script:marker)
Check ($record.Count -eq 1) 'INSERT confirmado por SELECT directo en inmobiliaria_apf2_test'
$columns=$record[0].Split("`t"); $testId=[int]$columns[0]
Check ($columns[1] -eq $script:marker -and $columns[2] -eq '123456.78' -and $columns[3] -eq 'DISPONIBLE') 'Titulo, precio y estado persistidos coinciden con el formulario'
Check ($created.Content.Contains('propiedad-formulario.xhtml?id='+$testId)) 'Listado contiene enlace JSF de edicion con ID real'
$edit=Page ($route+'?id='+$testId)
Check ($edit.Content.Contains('Editar propiedad') -and $edit.Content.Contains($script:marker) -and $edit.Content.Contains('123456.78')) 'Edicion carga valores reales del DAO'
$body=Body; $body['propiedad:titulo']=$script:marker+'_EDITADA'; $body['propiedad:precio']='234567.89'; $body['propiedad:estado']='RESERVADA'; $body['propiedad:descripcion']='Edicion JSF confirmada en TEST'
# El parametro URL y un input ID inventado no sustituyen el ID mantenido en el estado de vista.
$body['propiedad:id']='2147483647'
$updated=Submit $edit $body ($route+'?id=2147483647')
Check ($updated.BaseResponse.ResponseUri.AbsolutePath.EndsWith('/admin/propiedades-jsf.xhtml') -and $updated.Content.Contains('Propiedad actualizada correctamente.')) 'Edicion redirige y conserva confirmacion'
$record=@(Db 'marker' $script:marker); $columns=$record[0].Split("`t")
Check ($record.Count -eq 1 -and [int]$columns[0] -eq $testId -and $columns[2] -eq '234567.89' -and $columns[3] -eq 'RESERVADA' -and $columns[4] -eq 'Edicion JSF confirmada en TEST') 'UPDATE real conserva ID autorizado e ignora manipulacion de ID'
Check ([int](Db 'count')[0] -eq ($baseline+1)) 'Edicion no crea duplicados'
$null=Page '/logout'; $denied=Page ($route+'?id='+$testId)
Check ($denied.BaseResponse.ResponseUri.AbsolutePath.EndsWith('/login')) 'Logout revoca acceso al formulario de edicion'
$after=@(Db 'audit')
Check (($before -join "`n") -ceq ($after -join "`n")) 'Todas las tablas y registros principales mantienen sus hashes'
$report=@{base='inmobiliaria_apf2_test';puerto=8081;id=$testId;marcador=$script:marker;comprobaciones=$script:passed;principalIntacta=$true}
$report | ConvertTo-Json | Set-Content -LiteralPath (Join-Path $root 'dist/phase3-test-result.json') -Encoding UTF8
Write-Output "Fase 3: $script:passed comprobaciones aprobadas; registro TEST $testId ($script:marker). Se conserva la base de pruebas."
