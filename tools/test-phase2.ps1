param(
    [string]$BaseUrl = 'http://localhost:8080/avance-proyecto-final-inmobiliaria',
    [string]$JavaHome = $env:JAVA_HOME
)
$ErrorActionPreference = 'Stop'
$BaseUrl = $BaseUrl.TrimEnd('/')
$projectRoot = Split-Path -Parent $PSScriptRoot
if (-not $JavaHome) { throw 'Indica -JavaHome con la instalacion de JDK 21.' }
$java = Join-Path $JavaHome 'bin/java.exe'
$snapshot = @(& $java -cp "$projectRoot/build/web/WEB-INF/classes;$projectRoot/web/WEB-INF/lib/*" (Join-Path $PSScriptRoot 'PropiedadDaoSnapshot.java'))
if ($LASTEXITCODE -ne 0) { throw 'No se pudo consultar PropiedadDAO con JDK.' }
$session = New-Object Microsoft.PowerShell.Commands.WebRequestSession
$passed = 0
function Assert-Result([bool]$Condition, [string]$Description) {
    if (-not $Condition) { throw "FALLO: $Description" }
    $script:passed++
    Write-Output "OK: $Description"
}
function Get-Page([string]$Route) { Invoke-WebRequest -UseBasicParsing -Uri "$BaseUrl$Route" -WebSession $session -TimeoutSec 20 }
function Text-Cell([string]$Html) { [Net.WebUtility]::HtmlDecode(([regex]::Replace($Html, '<[^>]+>', '')).Trim()) }
function Check-Rows([string]$Html) {
    $table = [regex]::Match($Html, '<table[^>]*id="tablaPropiedades"[\s\S]*?</table>').Value
    $tbody = [regex]::Match($table, '<tbody[^>]*>([\s\S]*?)</tbody>').Groups[1].Value
    $rows = [regex]::Matches($tbody, '<tr[^>]*>([\s\S]*?)</tr>')
    Assert-Result ($rows.Count -eq $snapshot.Count) 'Cantidad de filas HTML coincide con PropiedadDAO.listar()'
    for ($rowIndex = 0; $rowIndex -lt $rows.Count; $rowIndex++) {
        $expected = $snapshot[$rowIndex].Split("`t")
        $cells = [regex]::Matches($rows[$rowIndex].Groups[1].Value, '<td[^>]*>([\s\S]*?)</td>')
        if ($cells.Count -ne 8) { throw 'La tabla no tiene siete columnas de datos y una de acciones.' }
        for ($column = 0; $column -lt 7; $column++) {
            $actual = Text-Cell $cells[$column].Groups[1].Value
            if ($column -eq 5) {
                $price = [decimal]::Parse($actual, [Globalization.NumberStyles]::Number, [Globalization.CultureInfo]::InvariantCulture)
                $expectedPrice = [decimal]::Parse($expected[$column], [Globalization.CultureInfo]::InvariantCulture)
                if ($price -ne $expectedPrice) { throw "Precio diferente en fila $rowIndex" }
            } else {
                $expectedText = $expected[$column]
                if ($column -ne 0) { $expectedText = [Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($expectedText)) }
                if ($actual -cne $expectedText) { throw "Columna $column diferente en fila $rowIndex" }
            }
        }
    }
    Assert-Result ($rows.Count -gt 0) 'Siete columnas de cada registro y orden DESC coinciden con MySQL via DAO'
}

foreach ($route in @('/admin', '/admin/propiedades-jsf.xhtml', '/admin/dashboard.jsp', '/admin/propiedades.jsp', '/admin/nueva-propiedad.jsp', '/admin/editar-propiedad.jsp?id=1', '/admin/clientes.jsp', '/admin/usuarios.jsp')) {
    $denied = Get-Page $route
    Assert-Result ($denied.BaseResponse.ResponseUri.AbsolutePath.EndsWith('/login')) "Sin sesion se redirige: $route"
}
$deniedPost = Invoke-WebRequest -UseBasicParsing -Uri "$BaseUrl/admin/propiedades-jsf.xhtml" -Method Post -Body @{} -WebSession $session -TimeoutSec 20
Assert-Result ($deniedPost.BaseResponse.ResponseUri.AbsolutePath.EndsWith('/login')) 'Postback sin sesion no accede a JSF'
$login = Invoke-WebRequest -UseBasicParsing -Uri "$BaseUrl/login" -Method Post -Body @{usuario='admin@inmobiliaria.com'; password='admin123'} -WebSession $session -TimeoutSec 20
Assert-Result ($login.Content.Contains('/admin/propiedades-jsf.xhtml')) 'Dashboard tiene enlace al inventario JSF'
Assert-Result ($login.Content.Contains('/logout')) 'Encabezado administrativo enlaza al logout real'
$view = Get-Page '/admin/propiedades-jsf.xhtml'
Assert-Result ($view.StatusCode -eq 200) 'Vista administrativa XHTML responde HTTP 200 con sesion'
Assert-Result ($view.Content -notmatch '#\{|<h:') 'EL y componentes JSF se procesan a HTML'
Assert-Result ($view.Content.Contains('id="tablaPropiedades"')) 'h:dataTable renderiza la tabla'
Assert-Result ($view.Content -match ('id="cantidad"[^>]*>\s*' + $snapshot.Count + '\s*<')) 'Contador EL coincide con DAO'
Assert-Result ($view.Content -notmatch 'No se pudo cargar|No hay propiedades registradas|MockData') 'Datos reales no se confunden con vacio o fallo'
Check-Rows $view.Content
$cssMatch = [regex]::Match($view.Content, 'href="([^"]*bootstrap.min.css[^"]*)"').Groups[1].Value
$resourceUri = [Uri]::new([Uri]($BaseUrl + '/'), [Net.WebUtility]::HtmlDecode($cssMatch))
$css = Invoke-WebRequest -UseBasicParsing -Uri $resourceUri.AbsoluteUri -WebSession $session -TimeoutSec 20
Assert-Result ($css.StatusCode -eq 200 -and $css.Content -match 'Bootstrap\s+v5\.3\.8') 'Bootstrap local 5.3.8 se sirve mediante recursos JSF'
Assert-Result ($view.Content.Contains('table-responsive')) 'Tabla contiene contenedor responsivo Bootstrap'
$state = [regex]::Match($view.Content, 'name="jakarta.faces.ViewState"[^>]*value="([^"]+)"').Groups[1].Value
$postback = Invoke-WebRequest -UseBasicParsing -Uri "$BaseUrl/admin/propiedades-jsf.xhtml" -Method Post -Body @{'listado'='listado'; 'listado:actualizar'='Actualizar listado'; 'jakarta.faces.ViewState'=[Net.WebUtility]::HtmlDecode($state)} -WebSession $session -TimeoutSec 20
Assert-Result ($postback.StatusCode -eq 200 -and $postback.Content.Contains('id="tablaPropiedades"')) 'Actualizar listado ejecuta postback con bean ViewScoped'
Check-Rows $postback.Content
foreach ($route in @('/admin/dashboard.jsp', '/admin/propiedades.jsp', '/admin/nueva-propiedad.jsp', '/admin/clientes.jsp', '/admin/usuarios.jsp')) {
    $page = Get-Page $route
    Assert-Result ($page.StatusCode -eq 200 -and -not $page.BaseResponse.ResponseUri.AbsolutePath.EndsWith('/login')) "JSP anterior sigue disponible con sesion: $route"
}
$null = Get-Page '/logout'
$denied = Get-Page '/admin/propiedades-jsf.xhtml'
Assert-Result ($denied.BaseResponse.ResponseUri.AbsolutePath.EndsWith('/login')) 'Logout revoca acceso a la nueva vista'
Write-Output "Pruebas Fase 2 aprobadas: $passed; registros contrastados: $($snapshot.Count). Solo SELECT y estado HTTP."
