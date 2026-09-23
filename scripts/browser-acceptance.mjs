import { chromium } from 'playwright';
import { mkdir } from 'node:fs/promises';

const base = process.env.BASE_URL || 'http://localhost:52773';
const user = process.env.IRIS_USER || '_SYSTEM';
const password = process.env.IRIS_PASSWORD;
const artifactDir = process.env.BROWSER_ARTIFACT_DIR;
if (!password) {
  console.error('IRIS_PASSWORD must be set for browser acceptance.');
  process.exit(2);
}
if (artifactDir) await mkdir(artifactDir, { recursive: true });

const authorization = `Basic ${Buffer.from(`${user}:${password}`).toString('base64')}`;
const browser = await chromium.launch({ headless: true });
const page = await browser.newPage({ viewport: { width: 1440, height: 1000 }, extraHTTPHeaders: { Authorization: authorization } });

function assert(condition, message) {
  if (!condition) throw new Error(message);
}

async function capture(name) {
  if (!artifactDir) return;
  await page.screenshot({ path: `${artifactDir}/${name}.png`, fullPage: true });
}

try {
  await page.goto(`${base}/iris-control-center/`, { waitUntil: 'networkidle' });
  await page.locator('.service').first().waitFor({ state: 'visible', timeout: 30_000 });

  assert(await page.locator('#filter').getAttribute('placeholder') === 'Filter services…', 'UTF-8 HTML text was corrupted during asset delivery.');

  const deliveredScript = await page.evaluate(async () => (await fetch('/iris-control-center/app.js')).text());
  assert(deliveredScript.includes('Loading API definition…'), 'UTF-8 JavaScript text was corrupted during asset delivery.');

  const apiCatalogue = await page.evaluate(async () => {
    const response = await fetch('/iris-control-center/api/services');
    if (!response.ok) throw new Error(`services API returned ${response.status}`);
    return response.json();
  });
  const apiCount = (apiCatalogue.services || []).length;
  const renderedCount = Number(await page.locator('#count').textContent());
  assert(apiCount > 0, 'Expected at least one discovered REST service.');
  assert(renderedCount === apiCount, `Catalogue count mismatch: UI=${renderedCount}, API=${apiCount}.`);
  await capture('01-real-catalogue');

  const first = page.locator('.service').first();
  const firstName = (await first.locator('strong').textContent()).trim();
  await page.locator('#filter').fill(firstName);
  assert(await page.locator('.service').count() >= 1, 'Catalogue filtering hid the matching service.');
  await page.locator('#filter').fill('__control_center_no_match__');
  await page.getByText('No matching services.').waitFor();
  await page.locator('#filter').fill('');

  const selectable = page.locator('.service').first();
  await selectable.focus();
  await page.keyboard.press('Enter');
  await page.locator('#detail h2').waitFor();
  assert(await selectable.getAttribute('aria-pressed') === 'true', 'Selected service did not expose aria-pressed=true.');
  assert(await page.locator('.meta .card').count() === 4, 'Expected all four service metadata cards.');
  await capture('02-real-selected-service');

  const beforeRefresh = Number(await page.locator('#count').textContent());
  await page.locator('#refresh').click();
  await page.waitForFunction(expected => Number(document.querySelector('#count')?.textContent) === expected && document.querySelectorAll('.service').length > 0, beforeRefresh);

  // The application advertises its own first-party OpenAPI contract through
  // normal IRIS service discovery. Use that deterministic real service for
  // release evidence, then execute its safe /health GET through the production
  // request proxy. Nothing in this evidence path is mocked.
  const controlCenterService = (apiCatalogue.services || []).find(service => service.name === '/iris-control-center/api');
  assert(controlCenterService, 'Control Center API was not returned by real IRIS service discovery.');
  assert(controlCenterService.swagger, 'Control Center API did not advertise its first-party OpenAPI contract.');
  await page.locator('#filter').fill(controlCenterService.name);
  const controlCenterCandidate = page.locator('.service').filter({ hasText: controlCenterService.name }).first();
  await controlCenterCandidate.click();
  await page.waitForFunction(() => {
    const host = document.querySelector('#endpoints');
    return host && !host.textContent.includes('Loading API definition…');
  }, null, { timeout: 30_000 });
  const explorerText = await page.locator('#endpoints').textContent();
  assert(!explorerText.includes('Could not load OpenAPI definition:'), `OpenAPI browser load failed: ${explorerText}`);
  assert(await page.locator('.api-summary').count() === 1, 'OpenAPI summary was not rendered.');
  await capture('03-real-openapi-explorer');

  const liveHealthEndpoint = page.locator('.endpoint').filter({ hasText: '/health' }).first();
  assert(await liveHealthEndpoint.locator('.run-get').count() === 1, 'Real /health GET did not expose execution control.');
  await liveHealthEndpoint.locator('.run-get').click();
  await liveHealthEndpoint.locator('.response').getByText(/200 OK/).waitFor({ timeout: 30_000 });
  const liveHealthResponse = await liveHealthEndpoint.locator('.response').textContent();
  assert(liveHealthResponse.includes('"status": "ok"'), 'Real /health response did not contain status=ok.');
  assert(liveHealthResponse.includes('IRIS Control Center'), 'Real /health response did not identify IRIS Control Center.');
  await capture('04-real-safe-get');

  await page.locator('#endpoint-filter').fill('__control_center_no_endpoint__');
  await page.getByText('No matching endpoints.').waitFor();
  await page.locator('#endpoint-filter').fill('');

  // Deterministically exercise parameter encoding and inspect-only handling for
  // mutating methods. Only this deeper UI-contract section is mocked; release
  // screenshots above all come from the live IRIS instance.
  const fixtureService = (apiCatalogue.services || []).find(service => service.enabled !== false && service.webApplication);
  assert(fixtureService, 'Expected an enabled service for interactive request UI acceptance.');
  const fixtureSpec = {
    openapi: '3.0.3',
    info: { title: 'Browser acceptance fixture', version: '1.0' },
    paths: {
      '/items/{id}': {
        get: {
          summary: 'Read item',
          parameters: [
            { name: 'id', in: 'path', required: true, schema: { type: 'string' } },
            { name: 'verbose', in: 'query', schema: { type: 'string' } }
          ]
        },
        post: { summary: 'Mutating operation remains inspect-only' }
      }
    }
  };
  let observedProxy = null;
  await page.route('**/iris-control-center/api/openapi?service=*', route => route.fulfill({
    status: 200,
    contentType: 'application/json',
    body: JSON.stringify(fixtureSpec)
  }));
  await page.route('**/iris-control-center/api/request?*', route => {
    observedProxy = new URL(route.request().url());
    return route.fulfill({
      status: 200,
      contentType: 'application/json',
      headers: { 'x-control-center-test': 'accepted' },
      body: JSON.stringify({ ok: true, source: 'browser-acceptance' })
    });
  });

  await page.evaluate(name => {
    const service = catalogue.find(item => item.name === name);
    service.swagger = '/browser-acceptance-openapi.json';
  }, fixtureService.name);
  await page.locator('#filter').fill(fixtureService.name);
  await page.locator('.service').filter({ hasText: fixtureService.name }).first().click();
  await page.locator('.api-summary').waitFor({ timeout: 30_000 });

  const getEndpoint = page.locator('.endpoint').filter({ hasText: 'GET' }).first();
  const postEndpoint = page.locator('.endpoint').filter({ hasText: 'POST' }).first();
  assert(await getEndpoint.locator('.run-get').count() === 1, 'GET operation should expose execution control.');
  assert(await postEndpoint.locator('.run-get').count() === 0, 'Mutating POST operation must remain inspect-only.');

  await getEndpoint.locator('[data-param="id"]').fill('A/B 42');
  await getEndpoint.locator('[data-param="verbose"]').fill('yes & more');
  await getEndpoint.locator('.run-get').click();
  await getEndpoint.locator('.response').getByText(/200 OK/).waitFor();
  const responseText = await getEndpoint.locator('.response').textContent();
  assert(responseText.includes('x-control-center-test: accepted'), 'Rendered response omitted response headers.');
  assert(responseText.includes('"ok": true'), 'Rendered response omitted formatted JSON body.');
  assert(observedProxy, 'Interactive GET did not call the request proxy.');
  assert(observedProxy.searchParams.get('service') === fixtureService.name, 'Proxy request used the wrong service.');
  assert(observedProxy.searchParams.get('path') === '/items/A%2FB%2042?verbose=yes+%26+more', `Unexpected encoded request path: ${observedProxy.searchParams.get('path')}`);

  console.log(`Browser acceptance passed: ${apiCount} services discovered; catalogue UX, real OpenAPI exploration, genuine safe-GET execution, response rendering, path/query encoding and mutating-method inspect-only behaviour verified.`);
} finally {
  await browser.close();
}
