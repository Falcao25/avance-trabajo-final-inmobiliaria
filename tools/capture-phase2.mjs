// Capturas reales con Chrome headless y CDP, sin paquetes npm ni cambios SQL.
import { spawn } from 'node:child_process';
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');
const fase3 = process.argv[4] === 'fase3';
const output = path.join(root, 'dist', fase3 ? 'evidencias-fase3' : 'evidencias-fase2');
const profile = path.join(output, `chrome-profile-${Date.now()}`);
fs.mkdirSync(profile, { recursive: true });
const chrome = process.argv[2];
if (!chrome) throw new Error('Indica la ruta del ejecutable Chrome como primer argumento.');
const baseUrl = process.argv[3] || 'http://localhost:8080/avance-proyecto-final-inmobiliaria';
const browser = spawn(chrome, ['--headless', '--disable-gpu', '--no-first-run', '--no-default-browser-check',
    '--remote-debugging-port=0', `--user-data-dir=${profile}`, 'about:blank'], { windowsHide: true, stdio: 'ignore' });
const delay = ms => new Promise(resolve => setTimeout(resolve, ms));
let socket;
try {
    const activePort = path.join(profile, 'DevToolsActivePort');
    for (let attempt = 0; !fs.existsSync(activePort) && attempt < 100; attempt++) await delay(100);
    const port = fs.readFileSync(activePort, 'utf8').split('\n')[0];
    const pages = await (await fetch(`http://127.0.0.1:${port}/json/list`)).json();
    socket = new WebSocket(pages.find(page => page.type === 'page').webSocketDebuggerUrl);
    await new Promise((resolve, reject) => { socket.onopen = resolve; socket.onerror = reject; });
    let sequence = 0;
    const waiting = new Map();
    socket.onmessage = event => {
        const message = JSON.parse(event.data);
        const pending = waiting.get(message.id);
        if (pending) { waiting.delete(message.id); message.error ? pending.reject(message.error) : pending.resolve(message.result); }
    };
    const send = (method, params = {}) => new Promise((resolve, reject) => {
        const id = ++sequence; waiting.set(id, { resolve, reject }); socket.send(JSON.stringify({ id, method, params }));
    });
    const evaluate = async expression => {
        const result = await send('Runtime.evaluate', { expression, awaitPromise: true, returnByValue: true });
        if (result.exceptionDetails) throw new Error(result.exceptionDetails.text);
        return result.result.value;
    };
    await send('Page.enable');
    await send('Page.navigate', { url: `${baseUrl}/login` });
    for (let attempt = 0; attempt < 100; attempt++) {
        if (await evaluate('document.readyState === "complete" && !!document.querySelector("[data-login-form]")')) break;
        await delay(100);
    }
    const status = await evaluate(`fetch(${JSON.stringify(baseUrl + '/login')}, { method: 'POST', headers: {'Content-Type':'application/x-www-form-urlencoded'}, body:'usuario=admin%40inmobiliaria.com&password=admin123' }).then(response => response.status)`);
    if (status !== 200) throw new Error('Login demo no respondio correctamente.');
    await send('Page.navigate', { url: `${baseUrl}/admin/propiedades-jsf.xhtml` });
    for (let attempt = 0; attempt < 100; attempt++) {
        if (await evaluate('document.readyState === "complete" && !!document.getElementById("tablaPropiedades")')) break;
        await delay(100);
    }
    for (const [name, width, height] of [['escritorio', 1440, 1100], ['movil', 390, 844]]) {
        await send('Emulation.setDeviceMetricsOverride', { width, height, deviceScaleFactor: 1, mobile: name === 'movil' });
        await delay(200);
        const layout = await evaluate(`({ filas: document.querySelectorAll('#tablaPropiedades tbody tr').length,
            ancho: innerWidth, anchoDocumento: document.documentElement.scrollWidth,
            tablaDesplazable: document.querySelector('.table-responsive').scrollWidth > document.querySelector('.table-responsive').clientWidth,
            bootstrap: getComputedStyle(document.documentElement).getPropertyValue('--bs-blue').trim() })`);
        if (layout.filas === 0 || layout.bootstrap !== '#0d6efd' || layout.anchoDocumento > layout.ancho + 1) {
            throw new Error(`Problema de renderizado ${name}: ${JSON.stringify(layout)}`);
        }
        const screenshot = await send('Page.captureScreenshot', { format: 'png', captureBeyondViewport: true });
        fs.writeFileSync(path.join(output, `${name}.png`), Buffer.from(screenshot.data, 'base64'));
        console.log(`OK navegador ${name}: ${JSON.stringify(layout)}`);
    }
    if (fase3) {
        const report = JSON.parse(fs.readFileSync(path.join(root, 'dist', 'phase3-test-result.json'), 'utf8').replace(/^\uFEFF/, ''));
        if (!baseUrl.startsWith('http://localhost:8081/') || report.base !== 'inmobiliaria_apf2_test') throw new Error('Las evidencias Fase 3 requieren la instancia aislada TEST.');
        await send('Emulation.setDeviceMetricsOverride', { width: 1440, height: 1100, deviceScaleFactor: 1, mobile: false });
        await send('Page.navigate', { url: `${baseUrl}/admin/propiedad-formulario.xhtml` });
        for (let attempt = 0; attempt < 100; attempt++) {
            if (await evaluate('document.readyState === "complete" && !!document.getElementById("propiedad:titulo")')) break;
            await delay(100);
        }
        await evaluate(`document.getElementById('propiedad:titulo').value='APF2_TEST_CAPTURA'; document.getElementById('propiedad:ubicacion').value='Entorno aislado de pruebas'; document.getElementById('propiedad:precio').value='123456.78'; document.getElementById('propiedad:area').value='100.25'; true`);
        for (const [name, width, height] of [['registro',1440,1100], ['registro-movil',390,844]]) {
            await send('Emulation.setDeviceMetricsOverride', { width, height, deviceScaleFactor: 1, mobile: name.endsWith('movil') });
            await delay(200);
            const overflow = await evaluate('document.documentElement.scrollWidth > innerWidth + 1');
            if (overflow) throw new Error('El formulario desborda el viewport: ' + name);
            const capture = await send('Page.captureScreenshot', { format:'png', captureBeyondViewport:true });
            fs.writeFileSync(path.join(output, name + '.png'), Buffer.from(capture.data,'base64'));
            console.log('OK captura real formulario: ' + name);
        }
        await send('Emulation.setDeviceMetricsOverride', { width:1440, height:1100, deviceScaleFactor:1, mobile:false });
        await send('Page.navigate', { url:`${baseUrl}/admin/propiedad-formulario.xhtml?id=${report.id}` });
        let loaded = false;
        for (let attempt = 0; attempt < 100; attempt++) {
            loaded = await evaluate(`!!document.getElementById('propiedad:titulo') && document.getElementById('propiedad:titulo').value.includes(${JSON.stringify(report.marcador)})`);
            if (loaded) break;
            await delay(100);
        }
        if (!loaded) throw new Error('La captura no confirma la carga del registro TEST persistido.');
        const capture = await send('Page.captureScreenshot', { format:'png', captureBeyondViewport:true });
        fs.writeFileSync(path.join(output, 'edicion.png'), Buffer.from(capture.data,'base64'));
        console.log('OK captura real edicion: registro TEST cargado desde MySQL');
    } else {
    // Captura 03 de la plantilla: procesamiento JSF de la Fase 1, sin CRUD.
    await send('Emulation.setDeviceMetricsOverride', { width: 1200, height: 800, deviceScaleFactor: 1, mobile: false });
    await send('Page.navigate', { url: `${baseUrl}/prueba-jsf.xhtml` });
    for (let attempt = 0; attempt < 100; attempt++) {
        if (await evaluate('document.readyState === "complete" && !!document.getElementById("prueba:nombre")')) break;
        await delay(100);
    }
    await evaluate(`document.getElementById('prueba:nombre').value='Evidencia APF2'; document.getElementById('prueba:saludar').click(); true`);
    let procesado = false;
    for (let attempt = 0; attempt < 100; attempt++) {
        procesado = await evaluate(`!!document.getElementById('saludo') && document.getElementById('saludo').textContent.includes('Hola, Evidencia APF2.')`);
        if (procesado) break;
        await delay(100);
    }
    if (!procesado) throw new Error('La captura de procesamiento no confirma la accion EL.');
    const formulario = await send('Page.captureScreenshot', { format: 'png', captureBeyondViewport: true });
    fs.writeFileSync(path.join(output, 'captura03-procesamiento-jsf.png'), Buffer.from(formulario.data, 'base64'));
    console.log('OK captura03: formulario JSF con entrada del usuario procesada por EL');
    }
    await send('Browser.close');
} finally {
    if (socket) socket.close();
    if (!browser.killed) browser.kill();
}
