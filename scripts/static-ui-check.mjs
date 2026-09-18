import fs from 'node:fs';

const html = fs.readFileSync('web/index.html', 'utf8');
const js = fs.readFileSync('web/app.js', 'utf8');

const ids = new Set([...html.matchAll(/\bid=["']([^"']+)["']/g)].map(match => match[1]));
const referencedIds = new Set([...js.matchAll(/\bel\(['"]([^'"]+)['"]\)/g)].map(match => match[1]));

const missing = [...referencedIds].filter(id => !ids.has(id));
if (missing.length) {
  console.error(`app.js references missing HTML element id(s): ${missing.join(', ')}`);
  process.exit(1);
}

for (const required of ['services', 'filter', 'refresh', 'count', 'detail']) {
  if (!ids.has(required)) {
    console.error(`Required UI element #${required} is missing from web/index.html`);
    process.exit(1);
  }
}

if (!js.includes("const API='/iris-control-center/api'")) {
  console.error('Browser API base no longer targets the installed Control Center API application.');
  process.exit(1);
}

if (!js.includes("credentials:'same-origin'")) {
  console.error('Browser requests no longer explicitly preserve the authenticated same-origin session.');
  process.exit(1);
}

console.log(`UI integrity OK: ${referencedIds.size} referenced element IDs are present.`);
