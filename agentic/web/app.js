'use strict';
const API = '/iris-control-center/agentic';
const $ = id => document.getElementById(id);
const samples = {
  transient: { incident_id: 'WEB-503', source_system: 'Orders', error_code: 'HTTP_503', summary: 'Synthetic upstream service unavailable', retry_count: 0 },
  integrity: { incident_id: 'WEB-INTEGRITY', source_system: 'Quality', error_code: 'DATA_INTEGRITY', summary: 'Synthetic measurement metadata conflict', retry_count: 0 },
  limit: { incident_id: 'WEB-LIMIT', source_system: 'Billing', error_code: 'TIMEOUT', summary: 'Synthetic timeout after repeated attempts', retry_count: 3 }
};
async function api(path, options = {}) {
  const response = await fetch(API + path, { credentials: 'same-origin', cache: 'no-store', ...options });
  const body = await response.json();
  if (!response.ok) throw new Error(body.error || 'HTTP ' + response.status);
  return body;
}
function setStatus(text) { $('status').textContent = text; }
function element(tag, className, text) {
  const node = document.createElement(tag);
  if (className) node.className = className;
  if (text !== undefined) node.textContent = String(text);
  return node;
}
async function submit(name) {
  setStatus('Processing ' + name + ' through IRIS Production…');
  const data = await api('/incident', {
    method: 'POST', headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(samples[name])
  });
  $('result').textContent = JSON.stringify(data, null, 2);
  setStatus(data.decision + ' · ' + data.route + ' · source=' + data.source + ' · audit #' + data.audit_id);
  await refreshAudit();
}
async function refreshAudit() {
  const entries = await api('/audit?limit=20');
  const root = $('audit');
  root.replaceChildren();
  if (!entries.length) { root.append(element('p', '', 'No audit records yet.')); return; }
  for (const item of entries) {
    const card = element('article', 'audit-card');
    const top = element('div', 'top');
    top.append(element('strong', '', '#' + item.audit_id + ' · ' + item.incident_id));
    top.append(element('small', '', item.source));
    card.append(top);
    card.append(element('div', 'route', item.decision + ' → ' + item.route));
    card.append(element('p', '', item.reason));
    if (item.review) {
      card.append(element('div', 'review', item.review.action + ' by ' + item.review.reviewed_by));
    } else {
      for (const action of ['approve', 'reject']) {
        const button = element('button', '', action === 'approve' ? 'Approve' : 'Reject');
        button.type = 'button';
        button.addEventListener('click', () => review(item.audit_id, action));
        card.append(button);
      }
    }
    root.append(card);
  }
}
async function review(id, action) {
  if (!window.confirm('Record ' + action + ' for audit #' + id + '? This does not execute remediation.')) return;
  try {
    await api('/review', {
      method: 'POST', headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ audit_id: id, action })
    });
    setStatus('Review recorded for audit #' + id);
    await refreshAudit();
  } catch (error) { setStatus('Review failed: ' + error.message); }
}
async function initialize() {
  try {
    const health = await api('/health');
    $('mode').textContent = health.mode === 'live' ? 'LIVE AI HUB · provider calls possible' : 'FIXTURE · SYNTHETIC, NO AI';
    await refreshAudit();
  } catch (error) { setStatus('Connection failed: ' + error.message); }
}
document.querySelectorAll('[data-case]').forEach(button => button.addEventListener('click', async () => {
  button.disabled = true;
  try { await submit(button.dataset.case); }
  catch (error) { setStatus('Incident failed: ' + error.message); }
  finally { button.disabled = false; }
}));
$('run-all').addEventListener('click', async event => {
  event.currentTarget.disabled = true;
  try { for (const name of Object.keys(samples)) await submit(name); }
  catch (error) { setStatus('Scenario failed: ' + error.message); }
  finally { event.currentTarget.disabled = false; }
});
$('refresh').addEventListener('click', () => refreshAudit().catch(error => setStatus(error.message)));
initialize();
