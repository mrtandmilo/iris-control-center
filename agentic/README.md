# IRIS Control Center — Agentic Interoperability Edition

**Development candidate — NOT submitted and NOT runtime-validated.**

This isolated extension to the prize-winning IRIS Control Center adds a real **InterSystems IRIS interoperability Production** (Business Service → Business Process → Business Operation) and a native **IRIS AI Hub %AI.Agent** that classifies synthetic integration incidents. The original `main` branch and its validated management-console release remain unchanged.

## Why this matters

When an integration fails, an operator must decide whether to retry, investigate, or isolate the incident. The agent proposes `RETRY`, `REVIEW`, or `QUARANTINE`; deterministic policy checks the proposal; an interoperability Business Operation writes an audit record. **No actual retry, quarantine, or production configuration change is performed.** Every recommendation requires human approval.

## Contest compliance

The official [contest](https://openexchange.intersystems.com/contest/49) and [announcement](https://community.intersystems.com/post/intersystems-programming-contest-ai-agents-interoperability-workflows) require a fully functional, original, open-source application using **IRIS AI Hub Community build 154** in a real interoperability workflow, plus English installation instructions and a demonstration or detailed description. Submission closes **8 November 2026, 23:59 EST (9 November, 04:59 GMT)**. Voting continues to 15 November EST. **No official entry has been submitted.**

## Installation: AI Hub EAP build 154

1. Download the appropriate `iris-community-2026.3.0AI.154.0-docker.tar.gz` (ARM64 equivalent for Apple Silicon) from the [InterSystems EAP portal](https://evaluation.intersystems.com/Eval/early-access/AIHub). The portal may require personal sign-in and terms acceptance; this project does not automate that. **Do not redistribute this EAP image or any image built on top of it.**
2. Load and retag the image:

   ```bash
   docker image load -i /path/to/iris-community-2026.3.0AI.154.0-docker.tar.gz
   docker images
   docker tag <loaded-image-name> iris-community:2026.3.0AI.154.0
   ```

3. From the repository root, choose a non-default local password and the **free synthetic fixture mode**:

   ```bash
   export IRIS_PASSWORD="$(openssl rand -hex 24)"
   export AGENTIC_MODE=fixture
   docker compose -f agentic/docker-compose.yml up --build -d
   ```

   On Windows PowerShell, set `$env:IRIS_PASSWORD` and `$env:AGENTIC_MODE = 'fixture'` before running Compose. Do not commit passwords.

4. For a real AI Hub decision, **explicitly opt in** to paid-provider calls using your own API key:

   ```bash
   export AGENTIC_MODE=live
   export OPENAI_API_KEY="<your-own-key>"
   docker compose -f agentic/docker-compose.yml up --build -d
   ```

   The provider is OpenAI, model `gpt-5-nano`. API calls may incur costs. No credits or keys are included. Judges may use their own keys. Fixture mode is **not** a replay of real AI output.

5. Check health and send an incident (the API uses IRIS password authentication):

   ```bash
   curl -u "_SYSTEM:${IRIS_PASSWORD}" http://localhost:52773/iris-control-center/agentic/health
   curl -u "_SYSTEM:${IRIS_PASSWORD}" -H 'Content-Type: application/json' \
     -d '{"incident_id":"DEMO-001","source_system":"Orders","error_code":"HTTP_503","summary":"Temporary upstream outage","retry_count":0}' \
     http://localhost:52773/iris-control-center/agentic/incident
   curl -u "_SYSTEM:${IRIS_PASSWORD}" http://localhost:52773/iris-control-center/agentic/audit
   ```

6. Run three scenarios through the Production from an IRIS terminal:

   ```bash
   docker compose -f agentic/docker-compose.yml exec iris iris session IRIS -U USER
   # In the terminal:
   # do ##class(IRISControlCenter.Agentic.Demo).Run()
   ```

The demo sends a temporary HTTP 503, a measurement-data integrity incident, and a timeout after three retries. Production auto-start is configured in `iris.script`.

## Actual message path

```text
Authenticated POST /incident
  → IncidentIngress  [Ens.BusinessService]
  → IncidentTriage   [Ens.BusinessProcess]
      → DecisionAgent  [%AI.Agent, live only; fixture otherwise]
      → DecisionPolicy [deterministic safety boundary]
  → IncidentLedger   [Ens.BusinessOperation]
      → ^ICCAgenticAudit append-only record
  → Authenticated JSON response and GET /audit
```

The live path invokes `%AI.Agent.%Init()`, `CreateSession()` and `Chat()`. Agent output is parsed as JSON and checked against the allowlist. Invalid output, provider failure or missing credentials fail closed to `REVIEW`. `DATA_INTEGRITY` and `AUTH_FAILURE` force quarantine review. Retry recommendations are restricted to `TIMEOUT`, `HTTP_503`, and `CONNECTION_RESET` with fewer than two previous retries. All recommendations are advisory; `approval_required=true` always.

Security boundaries: no permissive CORS, authenticated REST application, bounded input fields, no raw provider exceptions in API responses, and no sensitive incident summaries or credentials in the audit ledger. **Use synthetic data only.**

## Human approval workflow

After the agent's decision has been recorded, an authenticated operator can review it without executing any remediation:

```bash
curl -u "_SYSTEM:${IRIS_PASSWORD}" -H 'Content-Type: application/json' \
  -d '{"audit_id":1,"action":"approve"}' \
  http://localhost:52773/iris-control-center/agentic/review
```

Use `"reject"` instead to decline. A second review returns HTTP 409. Review events are stored separately in `^ICCAgenticReview` so the original decision remains unchanged; `GET /audit` includes the review when present. **Approval is an auditable acknowledgement, not authorisation to execute a production change.**

## Tests and evidence

```bash
node --test agentic/tests/contract.test.mjs
```

These are **static wiring/contract tests only**. They do not compile ObjectScript or prove the AI Hub runtime works.

**Not yet verified:** ObjectScript compilation on build 154, Production auto-start, message dispatch, live LLM response parsing, audit persistence, REST authentication, and the three-case end-to-end demo. There is no video, deployed demo, Open Exchange listing or submission receipt.

## Required next gates

1. Obtain the EAP build-154 image through authorised access.
2. Run Docker Compose and correct any build-specific API issues.
3. Exercise fixture scenarios, malformed output, no-key fallback, auth failures, and audit persistence; capture evidence.
4. Test one low-cost live AI Hub call only after an API key and spending approval exist.
5. Prepare a narrated 90–180 second demonstration and Open Exchange listing.
6. Obtain explicit approval before the official submission.

MIT licensed under the repository root `LICENSE`.
