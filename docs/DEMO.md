# IRIS Control Center demo walkthrough

This is the short, repeatable demonstration path for judges and reviewers. It is designed to show the product value in roughly three minutes without relying on hidden setup.

## Before recording or presenting

1. Start the application with `docker compose up --build`.
2. Wait for IRIS to become healthy and for the setup script to finish.
3. Run the smoke suite without placing a password in shell history:

   ```bash
   read -rsp "IRIS password: " IRIS_PASSWORD; echo
   IRIS_USER=_SYSTEM IRIS_PASSWORD="$IRIS_PASSWORD" ./scripts/smoke-test.sh
   unset IRIS_PASSWORD
   ```

   Do not record a demo until it passes. The smoke script always requires an explicit IRIS_PASSWORD; it has no default password.
4. Open `http://localhost:52773/iris-control-center/` and authenticate to IRIS if prompted.
5. Use only non-sensitive local test data. Never display real credentials, tokens, customer data, or private infrastructure details.

## Three-minute story

### 0:00–0:30 — The problem

Open IRIS Control Center and explain the goal in one sentence:

> IRIS Control Center turns the REST services registered in an IRIS instance into a searchable, task-focused API workspace.

Point out that the catalogue is discovered from IRIS rather than maintained as a separate hard-coded list.

### 0:30–1:10 — Discover

- Show the service count.
- Filter by a service name, namespace, or web-application path.
- Select a service.
- Show its web application, namespace, dispatch class, and required resource.

Value to emphasize: a developer can quickly answer “what REST APIs are actually available on this instance?” without manually assembling that inventory.

### 1:10–2:00 — Understand

- Allow Control Center to load the service's advertised OpenAPI definition.
- Show the API title/version and method counts.
- Filter the endpoint list.
- Expand the story around path/query parameters and endpoint descriptions.

Value to emphasize: discovery metadata and API documentation are brought together in one workflow.

### 2:00–2:40 — Safely exercise a GET

- Choose a known read-only GET endpoint.
- Fill any required path/query parameters.
- Run the request.
- Show HTTP status, elapsed time, response headers, and formatted JSON/text response.

Mention the deliberate safety boundary: the contest workbench executes GET only; mutating methods remain inspect-only. Requests are pinned to the selected local IRIS web application rather than accepting an arbitrary remote host.

### 2:40–3:00 — Close

Summarize the workflow:

**Discover → understand → exercise → diagnose.**

Then mention that the project is open source, containerized for repeatable installation, and includes smoke/static checks and explicit runtime-validation evidence.

## Final evidence package

The release browser suite deliberately captures only genuine IRIS states. For the currently validated release, use the `browser-evidence-35834262463` artifact from runtime acceptance run 75 as the authoritative source for images 1–4 below. Use the separate `release-validation-35834262463` artifact for the smoke-test proof. Both artifacts are retained by GitHub Actions until 2026-10-07; package the final submission evidence before that date.

1. `01-real-catalogue.png` — catalogue with discovered IRIS services visible.
2. `02-real-selected-service.png` — selected service with live IRIS metadata.
3. `03-real-openapi-explorer.png` — the first-party Control Center OpenAPI contract rendered by the explorer.
4. `04-real-safe-get.png` — successful first-party `/health` GET executed through the production request proxy, including status/timing/result.
5. `release-validation-35834262463` transcript — select or render the final section showing the clean smoke/release validation passing. Do not substitute an edited terminal result or fixture-backed screenshot.

Before publication, inspect every selected image for browser chrome, account names, cookies, authorization data, local/private infrastructure names, or any other information that should not become public. The automated repository guard does not inspect screenshot pixels.

If a fresh final validation supersedes run 75, use all browser images and the validation transcript from the same newer successful runtime run and update `RELEASE_EVIDENCE.md`; do not mix evidence from different release candidates unless the provenance is explicitly documented.

## Fresh public-checkout rehearsal

Once repository visibility has been changed by the owner, reproduce the judge path from a new directory rather than relying on the development checkout:

```bash
cd "$(mktemp -d)"
git clone https://github.com/mrtandmilo/iris-control-center.git
cd iris-control-center
docker compose up --build -d
docker compose ps
```

Wait for the IRIS service to become healthy, then run the smoke command from **Before recording or presenting** and follow the README installation path exactly. Record the public commit SHA and outcome in `RELEASE_EVIDENCE.md`. This is the final installation gate because it proves that a judge can start from the public repository alone.

## Screenshots for the submission

Use the five-item evidence package above. Do not recapture fixture-backed states merely to make the screenshots look cleaner. If a new live capture is required, run the full runtime acceptance workflow and take all release screenshots from that validated instance.

Avoid screenshots containing browser password dialogs, terminal command history with credentials, Authorization headers, cookies, or private system information.

## Demo acceptance gate

A polished recording is not evidence of correctness by itself. Before publishing or submitting a demo, complete every release-evidence item in `TESTING.md` and record the exact IRIS Community version used. If any runtime item remains unverified, describe it as a limitation rather than editing around it in the video.
