import fs from 'node:fs';

const rest = fs.readFileSync('src/IRISControlCenter/REST.cls', 'utf8');
const discovery = fs.readFileSync('src/IRISControlCenter/ServiceDiscovery.cls', 'utf8');

const checks = [
  [rest, 'Do request.SetHeader("Authorization",auth)', 'REST proxy no longer forwards inbound Authorization credentials.'],
  [rest, 'Do request.SetHeader("Cookie",cookie)', 'REST proxy no longer forwards the authenticated CSP session cookie.'],
  [rest, 'If found.enabled = 0', 'REST proxy no longer blocks execution for disabled IRIS web applications.'],
  [rest, "If '..IsSafeRelativePath(path)", 'REST proxy no longer validates requested relative paths.'],
  [rest, 'request.Server = "127.0.0.1"', 'REST proxy is no longer pinned to the local IRIS instance.'],
  [rest, "If request.HttpResponse.StatusCode '= 200", 'OpenAPI proxy no longer rejects unsuccessful upstream responses.'],
  [discovery, 'Do item.%Set("enabled",(service.enabled=1),"boolean")', 'Service discovery no longer normalizes enabled state to a JSON boolean.'],
  [discovery, '##class(%REST.API).GetAllWebRESTApps(.appList)', 'Service discovery no longer uses the native IRIS REST application catalogue.']
];

for (const [source, fragment, message] of checks) {
  if (!source.includes(fragment)) {
    console.error(message);
    process.exit(1);
  }
}

const routes = ['/health', '/services', '/openapi', '/request'];
for (const route of routes) {
  if (!rest.includes(`Url="${route}"`)) {
    console.error(`Required Control Center route ${route} is missing.`);
    process.exit(1);
  }
}

console.log(`ObjectScript contract OK: ${checks.length} runtime invariants and ${routes.length} required routes are present.`);
