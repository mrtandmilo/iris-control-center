import { chromium } from 'playwright';

const base = process.env.BASE_URL || 'http://localhost:52773';
const user = process.env.IRIS_USER || '_SYSTEM';
const password = process.env.IRIS_PASSWORD;
if (!password) {
  console.error('IRIS_PASSWORD must be set for browser acceptance.');
  process.exit(2);
}

const authorization = `Basic ${Buffer.from(`${user}:${password}`).toString('base64')}`;
const browser = await chromium.launch({ headless: true });
const page = await browser.newPage({ extraHTTPHeaders: { Authorization: authorization } });

function assert(condition, message) {
  if (!condition) throw new Error(message);
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
    await page.locator('#endpoint-filter').fill('__control_center_no_endpoint__');
    await page.getByText('No matching endpoints.').waitFor();
  } else {
    console.log('No OpenAPI-advertising service exists in the clean Community image; explorer rendering remains covered by static/runtime contracts.');
  }

  console.log(`Browser acceptance passed: ${apiCount} services discovered; keyboard selection, filtering, metadata and refresh verified${swaggerService ? '; OpenAPI explorer verified' : ''}.`);
} finally {
  await browser.close();
}
