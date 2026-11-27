// Phase 16 admin web QA. Headless Chromium via playwright core.
// Serves nothing, writes nothing to production. Captures console,
// page errors, failed requests, visible text and screenshots.
const { chromium } = require('playwright-core');
const fs = require('fs');
const path = require('path');

const OUT = path.join(__dirname, 'run6');
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

  // ADM005: invalid email, client side validation, no network call
  await page.goto(BASE, { waitUntil: 'load', timeout: 60000 });
  await page.waitForTimeout(12000);
  await page.mouse.click(640, 165);
  await page.keyboard.type('notanemail');
  await page.mouse.click(640, 273);
  await page.waitForTimeout(2000);
  await page.screenshot({ path: path.join(OUT, '05-invalid-email.png') });
  note('ADM005', 'submitted invalid email, waiting for validation error');

  // ADM006: valid email plus short password
  await page.mouse.click(640, 165);
  await page.keyboard.press('Control+a');
  await page.keyboard.type('qa.probe@example.com');
  await page.mouse.click(640, 230);
  await page.keyboard.type('abc');
  await page.mouse.click(640, 273);
  await page.waitForTimeout(2000);
  await page.screenshot({ path: path.join(OUT, '06-short-password.png') });
  note('ADM006', 'submitted short password, waiting for validation error');

  // ADM007: valid shape probe, real Auth attempt against placeholder project
  await page.mouse.click(640, 230);
  await page.keyboard.press('Control+a');
  await page.keyboard.type('QaProbe123');
  await page.mouse.click(640, 273);
  await page.waitForTimeout(6000);
  await page.screenshot({ path: path.join(OUT, '07-auth-attempt.png') });
  note('ADM007', 'submitted probe sign in, waiting for Auth error text');

  // ADM008: Create account mode switch
  await page.mouse.click(1215, 370);
  await page.waitForTimeout(2000);
  await page.screenshot({ path: path.join(OUT, '08-create-account-mode.png') });
  note('ADM008', 'tapped Create account link');

  // ADM009: back to sign in, then Forgot password mode
  await page.mouse.click(640, 480);
  await page.waitForTimeout(1500);
  await page.mouse.click(75, 370);
  await page.waitForTimeout(2000);
  await page.screenshot({ path: path.join(OUT, '09-forgot-password-mode.png') });
  note('ADM009', 'tapped Forgot password link');

  // ADM010: back to sign in, then Continue with Google
  await page.mouse.click(640, 420);
  await page.waitForTimeout(1500);
  await page.mouse.click(640, 325);
  await page.waitForTimeout(6000);
  await page.screenshot({ path: path.join(OUT, '10-google-signin.png') });
  note('ADM010', 'tapped Continue with Google');

  fs.writeFileSync(path.join(OUT, 'browser-log.txt'), log.join('\n') + '\n');
  await browser.close();
  console.log('DONE run6');
})().catch((e) => { console.error('SCRIPT FAILED: ' + e); process.exit(1); });
