import fs from 'node:fs';

const html = fs.readFileSync('web/index.html', 'utf8');
const js = fs.readFileSync('web/app.js', 'utf8');

const staticIds = new Set([...html.matchAll(/\bid=["']([^"']+)["']/g)].map(match => match[1]));
// app.js intentionally renders parts of the detail pane (including #endpoints)
// at runtime. Include literal ids created by its HTML templates so the check
// distinguishes a genuine dangling reference from a dynamically rendered node.
const dynamicIds = new Set([...js.matchAll(/\bid=\\?["']([^\\"']+)\\?["']/g)].map(match => match[1]));
const availableIds = new Set([...staticIds, ...dynamicIds]);
const referencedIds = new Set([...js.matchAll(/\bel\(['"]([^'"]+)['"]\)/g)].map(match => match[1]));

const missing = [...referencedIds].filter(id => !availableIds.has(id));
if (missing.length) {
  console.error(`app.js references missing HTML element id(s): ${missing.join(', ')}`);
  process.exit(1);
}

for (const required of ['services', 'filter', 'refresh', 'count', 'detail']) {
  if (!staticIds.has(required)) {
    console.error(`Required UI element #${required} is missing from web/index.html`);
    process.exit(1);
  }
}

const requiredFragments = [
  ["const API='/iris-control-center/api'", 'Browser API base no longer targets the installed Control Center API application.'],
  ["credentials:'same-origin'", 'Browser requests no longer explicitly preserve the authenticated same-origin session.'],
  ["method==='get'", 'Explorer no longer restricts executable operations to GET.'],
  ["new URLSearchParams()", 'Explorer no longer uses URLSearchParams for query construction.'],
  ["style!=='form'", 'Explorer no longer rejects unsupported OpenAPI query serialization styles.'],
  ["/\\{[^}]+\\}/.test(path)", 'Explorer no longer blocks unresolved path parameters.'],
  ["!path.startsWith('/')", 'Explorer no longer rejects non-relative OpenAPI paths.'],
  ["ev.target.disabled=true", 'Explorer no longer suppresses duplicate execution while a request is in flight.'],
  ["body.slice(0,12000)", 'Explorer response rendering no longer enforces the browser output cap.']
];

for (const [fragment, message] of requiredFragments) {
  if (!js.includes(fragment)) {
    console.error(message);
    process.exit(1);
  }
}

console.log(`UI integrity OK: ${referencedIds.size} referenced element IDs resolve; explorer safety invariants are present.`);
