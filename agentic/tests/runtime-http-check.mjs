/** Local-only, fixture-mode HTTP acceptance for IRIS AI Hub Community build 154.
 * Run: IRIS_PASSWORD=<local-secret> node agentic/tests/runtime-http-check.mjs
 * This harness must be executed against real IRIS before claiming a runtime PASS.
 */
import assert from 'node:assert/strict';
const base = new URL(process.env.IRIS_AGENTIC_URL || 'http://127.0.0.1:52773');
if (!['localhost','127.0.0.1','[::1]'].includes(base.hostname)) {
  throw new Error('Acceptance restricted to loopback; never target production');
}
if (!process.env.IRIS_PASSWORD || process.env.IRIS_PASSWORD.length < 8) {
  throw new Error('IRIS_PASSWORD must be set to a local non-default password');
}
const prefix='/iris-control-center/agentic';
const authorization='Basic '+Buffer.from('_SYSTEM:'+process.env.IRIS_PASSWORD).toString('base64');
async function call(path,{method='GET',body,auth=true}={}){
  const headers={Accept:'application/json'};
  if(auth)headers.Authorization=authorization;
  if(body!==undefined)headers['Content-Type']='application/json';
  const res=await fetch(new URL(prefix+path,base),{
    method,headers,body:body===undefined?undefined:JSON.stringify(body),
    signal:AbortSignal.timeout(15000),redirect:'manual'
  });
  const raw=await res.text();
  let data;try{data=JSON.parse(raw)}catch{data=null}
  return {status:res.status,data};
}
function latestId(entries){
  assert.ok(Array.isArray(entries),'audit must be JSON array');
  return Math.max(0,...entries.map(e=>Number(e.audit_id||0)));
}
const unauth=await call('/health',{auth:false});
assert.ok([401,403].includes(unauth.status),'unauthenticated health must be denied');
const health=await call('/health');
assert.equal(health.status,200);
assert.equal(health.data?.mode,'fixture','never run in live paid-provider mode');
const before=await call('/audit');
assert.equal(before.status,200);
let previousId=latestId(before.data);
for(const invalid of [
  {incident_id:'',source_system:'TEST',error_code:'HTTP_503'},
  {incident_id:'INVALID',source_system:'TEST',error_code:'TIMEOUT',retry_count:11},
  {incident_id:'INVALID',source_system:'TEST',error_code:'TIMEOUT',summary:'x'.repeat(601)}
]){
  const res=await call('/incident',{method:'POST',body:invalid});
  assert.equal(res.status,400,'invalid incident must be rejected');
}
const afterInvalid=await call('/audit');
assert.equal(latestId(afterInvalid.data),previousId,'invalid incidents must not mutate ledger');
const cases=[
  ['HTTP_503',0,'RETRY','RETRY_CANDIDATE'],
  ['DATA_INTEGRITY',0,'QUARANTINE','QUARANTINE_REVIEW'],
  ['TIMEOUT',3,'REVIEW','HUMAN_REVIEW'],
  ['UNKNOWN',0,'REVIEW','HUMAN_REVIEW']
];
let firstAuditId;
for(const [error_code,retry_count,decision,route] of cases){
  const res=await call('/incident',{method:'POST',body:{
    incident_id:'ACCEPT-'+error_code+'-'+retry_count,
    source_system:'SYNTHETIC',error_code,retry_count,
    summary:'Synthetic acceptance only; no personal or customer data'
  }});
  assert.equal(res.status,200);
  assert.equal(res.data?.decision,decision);
  assert.equal(res.data?.route,route);
  assert.equal(res.data?.source,'fixture');
  assert.equal(res.data?.approval_required,true);
  const id=Number(res.data?.audit_id);
  assert.ok(Number.isInteger(id)&&id>previousId,'audit ID must advance');
  previousId=id;
  firstAuditId??=id;
  process.stdout.write('PASS '+error_code+' '+decision+' audit='+id+'\n');
}
const review=await call('/review',{method:'POST',body:{audit_id:firstAuditId,action:'approve'}});
assert.equal(review.status,200);
assert.equal(review.data?.action,'APPROVE');
const repeat=await call('/review',{method:'POST',body:{audit_id:firstAuditId,action:'approve'}});
assert.equal(repeat.status,409,'second review must fail');
const audits=await call('/audit');
assert.equal(audits.status,200);
assert.equal(audits.data.find(e=>Number(e.audit_id)===firstAuditId)?.review?.action,'APPROVE');
process.stdout.write('PASS authenticated fixture HTTP, invalid-input guard, audit and one-time review\n');
