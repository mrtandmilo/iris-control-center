import { access, readFile, readdir } from 'node:fs/promises';
import { dirname, join, normalize, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

const root = resolve(dirname(fileURLToPath(import.meta.url)), '..');
const markdownFiles = ['README.md'];

async function collect(dir) {
  for (const entry of await readdir(dir, { withFileTypes: true })) {
    const path = join(dir, entry.name);
    if (entry.isDirectory()) await collect(path);
    else if (entry.isFile() && entry.name.endsWith('.md')) markdownFiles.push(path.slice(root.length + 1));
  }
}

await collect(join(root, 'docs'));

const failures = [];
const linkPattern = /!?(?:\[[^\]]*\])\(([^)\s]+)(?:\s+["'][^"']*["'])?\)/g;

for (const relativeFile of markdownFiles) {
  const source = await readFile(join(root, relativeFile), 'utf8');
  for (const match of source.matchAll(linkPattern)) {
    const raw = match[1].replace(/^<|>$/g, '');
    if (/^(?:https?:|mailto:|tel:|data:)/i.test(raw) || raw.startsWith('#')) continue;

    let decoded;
    try {
      decoded = decodeURIComponent(raw.split('#', 1)[0].split('?', 1)[0]);
    } catch {
      failures.push(`${relativeFile}: invalid URL encoding in ${raw}`);
      continue;
    }
    if (!decoded) continue;

    const target = normalize(join(dirname(join(root, relativeFile)), decoded));
    if (!target.startsWith(`${root}/`) && target !== root) {
      failures.push(`${relativeFile}: link escapes repository: ${raw}`);
      continue;
    }
    try {
      await access(target);
    } catch {
      failures.push(`${relativeFile}: missing local link target: ${raw}`);
    }
  }
}

if (failures.length) {
  console.error('Markdown link validation failed:');
  for (const failure of failures) console.error(`- ${failure}`);
  process.exit(1);
}

console.log(`Markdown link validation passed for ${markdownFiles.length} files.`);
