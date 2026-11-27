// Phase 16 admin web QA. Headless Chromium via playwright core.
// Serves nothing, writes nothing to production. Captures console,
// page errors, failed requests, visible text and screenshots.
const { chromium } = require('playwright-core');
const fs = require('fs');
const path = require('path');

const OUT = path.join(__dirname, 'run5');
fs.mkdirSync(OUT, { recursive: true });
const BASE = 'http://127.0.0.1:8317/';
const EXE = '/home/hatch/.cache/ms-playwright/chromium-1248/chrome-linux64/chrome';

const log = [];
function note(kind, msg) {
  const line = `[${new Date().toISOString()}] ${kind}: ${msg}`;
  log.push(line);
  console.log(line);
}

(async () => {
  const browser = await chromium.launch({ executablePath: EXE, args: ['--no-sandbox'] });
  const context = await browser.newContext({ viewport: { width: 1280, height: 800 } });
  // CDN substitution, bytes are identical: the CI build itself
  // ships these exact files under build/web/canvaskit, but the
  // engine requests them from the public CDN, which the sandbox
  // cannot reach. Serve the bundled copies for those URLs only.
  // No app code and no Firebase traffic is touched.
  await context.route('https://www.gstatic.com/flutter-canvaskit/**', async (route) => {
    const url = route.request().url();
    const tail = url.split('/flutter-canvaskit/')[1].split('/').slice(1).join('/');
    const local = path.join(__dirname, 'web-build', 'canvaskit', tail);
    if (!fs.existsSync(local)) { note('cdnmap.miss', url); return route.abort(); }
    const ext = path.extname(local);
    const type = ext === '.wasm' ? 'application/wasm' : ext === '.js' ? 'text/javascript' : 'application/octet-stream';
    note('cdnmap.serve', url + ' -> ' + tail);
    return route.fulfill({ status: 200, contentType: type, body: fs.readFileSync(local) });
  });

  // Firebase JS SDK, same files and version as the CDN serves:
  // the npm firebase package at 11.9.1 is the source of the
  // gstatic files, and its own imports point at the same URLs.
  await context.route('https://www.gstatic.com/firebasejs/**', async (route) => {
    const url = route.request().url();
    const tail = url.split('/firebasejs/')[1].split('/').slice(1).join('/');
    const local = path.join(__dirname, 'node_modules', 'firebase', tail);
    if (!fs.existsSync(local)) { note('fbmap.miss', url); return route.abort(); }
    note('fbmap.serve', url + ' -> ' + tail);
    return route.fulfill({ status: 200, contentType: 'text/javascript', body: fs.readFileSync(local) });
  });

  // Fonts: same substitution idea. The engine fetches Roboto and
  // Noto woff2 files from the public font CDN, which the sandbox
  // cannot reach, so every glyph renders blank. Serve one local
  // Roboto latin file for every font request so Latin UI text
  // becomes visible. Weight differences are lost, text is not.
  await context.route('https://fonts.gstatic.com/**', async (route) => {
    note('fontmap.serve', route.request().url().slice(0, 110));
    return route.fulfill({ status: 200, contentType: 'font/woff2', body: fs.readFileSync(path.join(__dirname, 'node_modules', '@fontsource', 'roboto', 'files', 'roboto-latin-400-normal.woff2')) });
  });
  const page = await context.newPage();
  page.on('console', (m) => note('console.' + m.type(), m.text().slice(0, 500)));
  page.on('pageerror', (e) => note('pageerror', String(e).slice(0, 500)));
  page.on('requestfailed', (r) => note('requestfailed', r.url() + ' :: ' + (r.failure() || {}).errorText));
  page.on('response', (r) => {
    if (r.status() >= 400) note('http.' + r.status(), r.url());
  });

  // ADM001: app boot on desktop viewport
  await page.goto(BASE, { waitUntil: 'load', timeout: 60000 });
  await page.waitForTimeout(15000);
  const bodyText1 = (await page.evaluate(() => document.body.innerText)).slice(0, 3000);
  fs.writeFileSync(path.join(OUT, 'desktop-body-text.txt'), bodyText1);
  await page.screenshot({ path: path.join(OUT, '01-desktop-load.png'), fullPage: true });
  note('state', 'desktop title=' + (await page.title()) + ' url=' + page.url());
  note('state', 'flutter canvas present=' + (await page.evaluate(() => !!document.querySelector('canvas'))));

  // ADM002: reload persistence of the same screen
  await page.reload({ waitUntil: 'load', timeout: 60000 });
  await page.waitForTimeout(12000);
  const bodyText2 = (await page.evaluate(() => document.body.innerText)).slice(0, 3000);
  fs.writeFileSync(path.join(OUT, 'desktop-body-text-after-reload.txt'), bodyText2);
  await page.screenshot({ path: path.join(OUT, '02-desktop-after-reload.png'), fullPage: true });
  note('state', 'after reload same text=' + (bodyText1 === bodyText2));

  // ADM003: sign in form presence check (auth boundary probe, no input typed)
  const probes = await page.evaluate(() => {
    const text = document.body.innerText || '';
    const inputs = Array.from(document.querySelectorAll('input')).map((i) => i.type + ':' + (i.placeholder || i.name || ''));
    return {
      hasSignInText: /sign in/i.test(text),
      hasSetupText: /setup|Firebase/i.test(text),
      hasDeniedText: /not an admin|denied/i.test(text),
      inputCount: inputs.length,
      inputs,
      textLen: text.length,
    };
  });
  fs.writeFileSync(path.join(OUT, 'auth-boundary-probe.json'), JSON.stringify(probes, null, 2));
  note('probe', JSON.stringify(probes));

  // ADM004: narrow viewport 390px, same CDN mapping on its own context
  const mobCtx = await browser.newContext({ viewport: { width: 390, height: 844 } });
  await mobCtx.route('https://www.gstatic.com/flutter-canvaskit/**', async (route) => {
    const url = route.request().url();
    const tail = url.split('/flutter-canvaskit/')[1].split('/').slice(1).join('/');
    const local = path.join(__dirname, 'web-build', 'canvaskit', tail);
    if (!fs.existsSync(local)) { note('cdnmap.miss', url); return route.abort(); }
    const ext = path.extname(local);
    const type = ext === '.wasm' ? 'application/wasm' : ext === '.js' ? 'text/javascript' : 'application/octet-stream';
    note('cdnmap.serve', url + ' -> ' + tail);
    return route.fulfill({ status: 200, contentType: type, body: fs.readFileSync(local) });
  });

  // Firebase JS SDK, same files and version as the CDN serves:
  // the npm firebase package at 11.9.1 is the source of the
  // gstatic files, and its own imports point at the same URLs.
  await mobCtx.route('https://www.gstatic.com/firebasejs/**', async (route) => {
    const url = route.request().url();
    const tail = url.split('/firebasejs/')[1].split('/').slice(1).join('/');
    const local = path.join(__dirname, 'node_modules', 'firebase', tail);
    if (!fs.existsSync(local)) { note('fbmap.miss', url); return route.abort(); }
    note('fbmap.serve', url + ' -> ' + tail);
    return route.fulfill({ status: 200, contentType: 'text/javascript', body: fs.readFileSync(local) });
  });

  // Fonts: same substitution idea. The engine fetches Roboto and
  // Noto woff2 files from the public font CDN, which the sandbox
  // cannot reach, so every glyph renders blank. Serve one local
  // Roboto latin file for every font request so Latin UI text
  // becomes visible. Weight differences are lost, text is not.
  await mobCtx.route('https://fonts.gstatic.com/**', async (route) => {
    note('fontmap.serve', route.request().url().slice(0, 110));
    return route.fulfill({ status: 200, contentType: 'font/woff2', body: fs.readFileSync(path.join(__dirname, 'node_modules', '@fontsource', 'roboto', 'files', 'roboto-latin-400-normal.woff2')) });
  });
  const mob = await mobCtx.newPage();
  mob.on('pageerror', (e) => note('mobile.pageerror', String(e).slice(0, 300)));
  mob.on('console', (m) => { if (m.type() === 'error') note('mobile.console.error', m.text().slice(0, 300)); });
  await mob.goto(BASE, { waitUntil: 'load', timeout: 60000 });
  await mob.waitForTimeout(12000);
  const mobText = (await mob.evaluate(() => document.body.innerText)).slice(0, 2000);
  fs.writeFileSync(path.join(OUT, 'mobile-body-text.txt'), mobText);
  await mob.screenshot({ path: path.join(OUT, '03-mobile-390px.png'), fullPage: true });
  note('state', 'mobile horizontal overflow=' + (await mob.evaluate(() => document.documentElement.scrollWidth > 390)));

  fs.writeFileSync(path.join(OUT, 'browser-log.txt'), log.join('\n') + '\n');
  await browser.close();
  console.log('DONE run1');
})().catch((e) => { console.error('SCRIPT FAILED: ' + e); process.exit(1); });
