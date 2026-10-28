import test from 'node:test';
import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';

const read = path => readFileSync(new URL(path, import.meta.url), 'utf8');
const production = read('../src/IRISControlCenter/Agentic/Production.cls');
const agent = read('../src/IRISControlCenter/Agentic/DecisionAgent.cls');
const policy = read('../src/IRISControlCenter/Agentic/DecisionPolicy.cls');
const process = read('../src/IRISControlCenter/Agentic/TriageProcess.cls');
const operation = read('../src/IRISControlCenter/Agentic/AuditOperation.cls');
const service = read('../src/IRISControlCenter/Agentic/IncidentService.cls');
const rest = read('../src/IRISControlCenter/Agentic/REST.cls');
const review = read('../src/IRISControlCenter/Agentic/Review.cls');
const installer = read('../src/IRISControlCenter/Agentic/Installer.cls');
const dockerfile = read('../Dockerfile');
const compose = read('../docker-compose.yml');

test('production contains a real Business Service, Process, and Operation', () => {
  assert.match(production, /ClassName="IRISControlCenter\.Agentic\.IncidentService"/);
  assert.match(production, /ClassName="IRISControlCenter\.Agentic\.TriageProcess"/);
  assert.match(production, /ClassName="IRISControlCenter\.Agentic\.AuditOperation"/);
  assert.match(service, /Extends Ens\.BusinessService/);
  assert.match(process, /Extends Ens\.BusinessProcess/);
  assert.match(operation, /Extends Ens\.BusinessOperation/);
  assert.match(service, /SendRequestSync\("IncidentTriage"/);
  assert.match(process, /SendRequestSync\("IncidentLedger"/);
  assert.match(operation, /MessageType="IRISControlCenter\.Agentic\.AuditRequest"/);
});
test('native AI Hub agent is used in live mode; fixture is identified', () => {
  assert.match(agent, /Extends %AI\.Agent/);
  assert.match(agent, /agent\.%Init\(\)/);
  assert.match(agent, /agent\.CreateSession\(\)/);
  assert.match(agent, /agent\.Chat\(/);
  assert.match(agent, /mode="fixture"/);
  assert.match(agent, /"source":"fixture"/);
  assert.match(agent, /"source":"fallback"/);
});
test('policy refuses unsafe retries and requires approval', () => {
  assert.match(policy, /DATA_INTEGRITY/);
  assert.match(policy, /AUTH_FAILURE/);
  assert.match(policy, /pIncident\.RetryCount'<2/);
  assert.match(policy, /"approval_required",1,"boolean"/);
  assert.match(process, /No side effects other than the audit ledger/);
});
test('REST authenticates and routes through the actual Production', () => {
  assert.match(rest, /Method="POST" Call="Incident"/);
  assert.match(rest, /CreateBusinessService\("IncidentIngress"/);
  assert.match(rest, /service\.ProcessInput\(request,\.answer\)/);
  assert.match(installer, /app\.AutheEnabled = 32/);
  assert.doesNotMatch(rest, /HandleCorsRequest = 1/);
});
test('Docker uses required EAP build 154 and no default password', () => {
  assert.match(dockerfile, /2026\.3\.0AI\.154\.0/);
  assert.match(compose, /2026\.3\.0AI\.154\.0/);
  assert.match(compose, /IRIS_PASSWORD:\s*\$\{IRIS_PASSWORD:\?/);
  assert.doesNotMatch(compose, /docker push|registry\.example/);
});

test('human review is authenticated, one-time, and never executes remediation', () => {
  assert.match(rest, /Method="POST" Call="Review"/);
  assert.match(rest, /ClassMethod Review\(\)/);
  assert.match(review, /Lock \+\^ICCAgenticReview/);
  assert.match(review, /already_reviewed/);
  assert.match(review, /reviewed_by/);
  assert.doesNotMatch(review, /SendRequestSync|SendRequestAsync|HttpRequest/);
});

test('dashboard serves only local assets and uses safe DOM rendering', () => {
  const ui = read('../src/IRISControlCenter/Agentic/UI.cls');
  const js = read('../web/app.js');
  const html = read('../web/index.html');
  assert.match(ui, /Extends %CSP\.REST/);
  assert.match(ui, /agentic\/web/);
  assert.match(js, /textContent/);
  assert.match(js, /replaceChildren\(\)/);
  assert.doesNotMatch(js, /innerHTML|document\.write\(/);
  assert.match(html, /Agentic Incident Triage/);
  assert.match(installer, /agentic-ui/);
});


test('ObjectScript status macros and TRY/CATCH exits use valid syntax', () => {
  // Bare $$OK/$$ISERR are routine calls, not the required status macros.
  for (const [name, source] of [['REST', rest], ['Installer', installer], ['DecisionAgent', agent]]) {
    assert.doesNotMatch(source, /(?<!\$)\$\$(?:OK|ISERR|ThrowStatus)\b/, name);
  }
  assert.match(rest, /Return \$\$\$OK/);
  assert.match(rest, /Quit \$\$\$OK/);
  assert.match(installer, /If \$\$\$ISERR\(sc\) \$\$\$ThrowStatus\(sc\)/);
  assert.match(agent, /If \$\$\$ISERR\(sc\) Return fallback/);
  assert.match(agent, /Return parsed/);
  assert.match(agent, /Catch ex \{\s*\/\/ Never expose[\s\S]*?Return fallback/);
});


test('fixture dashboard port is bound to loopback, not exposed to LAN', () => {
  assert.match(compose, /127\.0\.0\.1:52773:52773/);
  assert.doesNotMatch(compose, /-\s*["']52773:52773["']/);
});
