param(
    [string]$BaseUrl = 'http://localhost:8080/avance-proyecto-final-inmobiliaria'
)

$ErrorActionPreference = 'Stop'
$BaseUrl = $BaseUrl.TrimEnd('/')
$session = New-Object Microsoft.PowerShell.Commands.WebRequestSession
$passed = 0

function Assert-Result([bool]$Condition, [string]$Description) {
    if (-not $Condition) { throw "FALLO: $Description" }
    $script:passed++
    Write-Output "OK: $Description"
}

function Get-Page([string]$Route) {
    Invoke-WebRequest -UseBasicParsing -Uri "$BaseUrl$Route" -WebSession $session -TimeoutSec 20
}

function Get-ViewState([string]$Html) {
    $state = [regex]::Match($Html, 'name="jakarta.faces.ViewState"[^>]*value="([^"]+)"').Groups[1].Value
    if (-not $state) { throw 'La vista no contiene jakarta.faces.ViewState.' }
    [System.Net.WebUtility]::HtmlDecode($state)
}

# GET y postbacks del bean de prueba. No hay operaciones JDBC en este formulario.
$view = Get-Page '/prueba-jsf.xhtml'
Assert-Result ($view.StatusCode -eq 200) 'XHTML responde HTTP 200'
Assert-Result ($view.Content.Contains('Jakarta Faces 4.1 + CDI 4.1')) 'EL obtiene tecnologia desde el bean CDI'
Assert-Result ($view.Content.Contains('Vista XHTML conectada correctamente con un bean CDI.')) 'EL obtiene saludo inicial'
Assert-Result ($view.Content -notmatch '#\{|<h:') 'Facelets produce HTML, sin expresiones EL sin resolver'
$body = @{
    'prueba' = 'prueba'
    'prueba:nombre' = 'Prueba APF2'
    'prueba:saludar' = 'Probar comunicacion'
    'jakarta.faces.ViewState' = (Get-ViewState $view.Content)
}
$postback = Invoke-WebRequest -UseBasicParsing -Uri "$BaseUrl/prueba-jsf.xhtml" -Method Post -Body $body -WebSession $session -TimeoutSec 20
Assert-Result ($postback.StatusCode -eq 200 -and $postback.Content.Contains('Hola, Prueba APF2. Expression Language ejecuto la accion del bean CDI.')) 'Postback actualiza el modelo y ejecuta la accion CDI'
$body['prueba:nombre'] = ''
$body['jakarta.faces.ViewState'] = Get-ViewState $postback.Content
$invalid = Invoke-WebRequest -UseBasicParsing -Uri "$BaseUrl/prueba-jsf.xhtml" -Method Post -Body $body -WebSession $session -TimeoutSec 20
Assert-Result ($invalid.StatusCode -eq 200 -and $invalid.Content.Contains('Ingresa un nombre.')) 'JSF rechaza un nombre obligatorio vacio'

# JSP publicas y Servlets existentes. Todas estas peticiones son de lectura.
foreach ($route in @('/', '/index.jsp', '/nosotros.jsp', '/propiedades.jsp', '/detalle-propiedad.jsp?id=1', '/contacto.jsp', '/login.jsp', '/propiedades', '/detalle-propiedad?id=1', '/contacto', '/login', '/css/styles.css', '/js/propiedades.js')) {
    $page = Get-Page $route
    Assert-Result ($page.StatusCode -eq 200) "Ruta existente disponible: $route"
}
$catalog = Get-Page '/propiedades'
Assert-Result ($catalog.Content -match 'propiedades de <strong>MySQL' -and $catalog.Content -notmatch 'Mock de respaldo') 'Catalogo Servlet sigue consultando MySQL'
$privatePage = Get-Page '/admin/propiedades'
Assert-Result ($privatePage.BaseResponse.ResponseUri.AbsolutePath.EndsWith('/login')) 'Servlet administrativo sigue exigiendo sesion'

# Login demo ya existente; solo modifica la sesion HTTP, no los registros MySQL.
$login = Invoke-WebRequest -UseBasicParsing -Uri "$BaseUrl/login" -Method Post -Body @{usuario='admin@inmobiliaria.com'; password='admin123'} -WebSession $session -TimeoutSec 20
Assert-Result ($login.StatusCode -eq 200 -and $login.BaseResponse.ResponseUri.AbsolutePath.EndsWith('/admin/dashboard')) 'Login demo existente abre el dashboard'
foreach ($route in @('/admin', '/admin/dashboard', '/admin/propiedades', '/admin/nueva-propiedad', '/admin/editar-propiedad?id=1', '/admin/clientes', '/admin/usuarios')) {
    $page = Get-Page $route
    Assert-Result ($page.StatusCode -eq 200 -and -not $page.BaseResponse.ResponseUri.AbsolutePath.EndsWith('/login')) "Vista administrativa existente disponible: $route"
}
$logout = Get-Page '/logout'
Assert-Result ($logout.BaseResponse.ResponseUri.AbsolutePath.EndsWith('/login')) 'Ruta logout existente redirige al login'
$privatePage = Get-Page '/admin/propiedades'
Assert-Result ($privatePage.BaseResponse.ResponseUri.AbsolutePath.EndsWith('/login')) 'Logout invalida la sesion administrativa'
Write-Output "Pruebas aprobadas: $passed. No se enviaron altas, ediciones, eliminaciones ni contactos."
