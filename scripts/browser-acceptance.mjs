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

  // Exercise selection through the keyboard rather than a synthetic click.
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

  // If the clean Community instance advertises an OpenAPI-enabled service,
  // verify the browser can select it and reach a terminal explorer state.
  const swaggerService = (apiCatalogue.services || []).find(service => service.swagger);
  if (swaggerService) {
    await page.locator('#filter').fill(swaggerService.name || '');
    const candidate = page.locator('.service').filter({ hasText: swaggerService.name }).first();
    await candidate.click();
    await page.waitForFunction(() => {
      const host = document.querySelector('#endpoints');
      return host && !host.textContent.includes('Loading API definition…');
    }, null, { timeout: 30_000 });
    const text = await page.locator('#endpoints').textContent();
    assert(!text.includes('Could not load OpenAPI definition:'), `OpenAPI browser load failed: ${text}`);
    assert(await page.locator('.api-summary').count() === 1, 'OpenAPI summary was not rendered.');
    await capture('03-real-openapi-explorer');
    await page.locator('#endpoint-filter').fill('__control_center_no_endpoint__');
    await page.getByText('No matching endpoints.').waitFor();
  } else {
    console.log('No OpenAPI-advertising service exists in the clean Community image; live explorer rendering remains covered by runtime contracts.');
  }

  // Deterministically exercise the interactive request UI without depending on
  // optional APIs in the stock Community image. Only browser network responses
  // are mocked here; production discovery/proxy behaviour is tested separately
  // by the runtime acceptance suite. Mock-backed states are deliberately not
  // captured as release screenshots so evidence cannot be mistaken for a live
  // IRIS response.
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

  // Discovery may not mark a stock service as Swagger-enabled. Patch only the
  // in-page catalogue flag so selection follows the same production UI path.
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

  console.log(`Browser acceptance passed: ${apiCount} services discovered; catalogue UX, OpenAPI exploration, path/query encoding, GET execution, response rendering and mutating-method inspect-only behaviour verified.`);
} finally {
  await browser.close();
}