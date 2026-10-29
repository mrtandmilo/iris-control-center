import test from 'node:test';
import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import { spawnSync } from 'node:child_process';

const script = new URL('./preflight-fixture.sh', import.meta.url).pathname;

test('preflight rejects live mode before invoking Docker', () => {
  const result = spawnSync('bash', [script], {
    encoding: 'utf8', env: { ...process.env, AGENTIC_MODE: 'live', IRIS_PASSWORD: 'test-local' },
  });
  assert.equal(result.status, 2);
  assert.match(result.stderr, /live calls need separate approval/);
});

test('preflight never prints the password and refuses defaults', () => {
  const result = spawnSync('bash', [script], {
    encoding: 'utf8', env: { ...process.env, AGENTIC_MODE: 'fixture', IRIS_PASSWORD: 'SYS' },
  });
  assert.equal(result.status, 3);
  assert.doesNotMatch(result.stderr, /password: SYS/);
});

test('preflight does not download or push EAP images', () => {
  const source = readFileSync(script, 'utf8');
  assert.match(source, /docker image inspect/);
  assert.doesNotMatch(source, /docker (pull|push|run)|curl|wget/);
  assert.match(source, /config --quiet/);
});
