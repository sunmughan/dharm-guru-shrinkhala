// Phase 16 admin web QA. Headless Chromium via playwright core.
// Serves nothing, writes nothing to production. Captures console,
// page errors, failed requests, visible text and screenshots.
const { chromium } = require('playwright-core');
const fs = require('fs');
const path = require('path');

const OUT = path.join(__dirname, 'run7');
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

  // Each step reloads fresh so coordinates never go stale
  // after a validation error shifts the layout down.
  async function fresh() {
    await page.goto(BASE, { waitUntil: 'load', timeout: 60000 });
    await page.waitForTimeout(12000);
  }

  // ADM006r: valid email plus short password
  await fresh();
  await page.mouse.click(640, 165);
  await page.keyboard.type('qa.probe@example.com');
  await page.mouse.click(640, 230);
  await page.keyboard.type('abc');
  await page.mouse.click(640, 273);
  await page.waitForTimeout(2500);
  await page.screenshot({ path: path.join(OUT, '06r-short-password.png') });
  note('ADM006r', 'submitted valid email plus 3 char password');

  // ADM007r: valid shape probe, real Auth attempt
  await fresh();
  await page.mouse.click(640, 165);
  await page.keyboard.type('qa.probe@example.com');
  await page.mouse.click(640, 230);
  await page.keyboard.type('QaProbe123');
  await page.mouse.click(640, 273);
  await page.waitForTimeout(8000);
  await page.screenshot({ path: path.join(OUT, '07r-auth-attempt.png') });
  note('ADM007r', 'submitted probe sign in, waited 8s for Auth error');

  // ADM008r: Create account mode switch
  await fresh();
  await page.mouse.click(1215, 370);
  await page.waitForTimeout(2500);
  await page.screenshot({ path: path.join(OUT, '08r-create-account-mode.png') });
  note('ADM008r', 'tapped Create account link');

  // ADM009r: Forgot password mode switch
  await fresh();
  await page.mouse.click(75, 370);
  await page.waitForTimeout(2500);
  await page.screenshot({ path: path.join(OUT, '09r-forgot-password-mode.png') });
  note('ADM009r', 'tapped Forgot password link');

  // ADM010r: Continue with Google
  await fresh();
  await page.mouse.click(640, 325);
  await page.waitForTimeout(8000);
  await page.screenshot({ path: path.join(OUT, '10r-google-signin.png') });
  note('ADM010r', 'tapped Continue with Google');

  fs.writeFileSync(path.join(OUT, 'browser-log.txt'), log.join('\n') + '\n');
  await browser.close();
  console.log('DONE run7');
})().catch((e) => { console.error('SCRIPT FAILED: ' + e); process.exit(1); });
