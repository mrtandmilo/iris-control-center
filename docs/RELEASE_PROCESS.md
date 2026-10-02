# Demo recording and release evidence — maintainer guide

This guide covers recording preparation, evidence provenance and publication checks for maintainers. The reviewer walkthrough is in [DEMO.md](DEMO.md); runtime acceptance gates are in [TESTING.md](TESTING.md), and validation results are recorded in [RELEASE_EVIDENCE.md](RELEASE_EVIDENCE.md).

## Recording preparation

1. Start the application with `docker compose up --build`.
2. Wait for IRIS to become healthy and for the setup script to finish.
3. Run the smoke suite without placing a password in shell history:

   ```bash
   read -rsp "IRIS password: " IRIS_PASSWORD; echo
   IRIS_USER=_SYSTEM IRIS_PASSWORD="$IRIS_PASSWORD" ./scripts/smoke-test.sh
   unset IRIS_PASSWORD
   ```

   Do not record a demo until it passes. The smoke script always requires an explicit IRIS_PASSWORD; it has no default password.
4. Open `http://localhost:52773/iris-control-center/`. With the repository's default Compose configuration, authenticate with username `_SYSTEM` and password `SYS`. If `IRIS_PASSWORD` was overridden when Compose was started, use that password instead. The browser authentication prompt is expected.
5. Use only non-sensitive local test data. Never display real credentials, tokens, customer data, or private infrastructure details.

## 90-second recording script

Use this version when attention is limited or for a short public video.

**0:00–0:15 — Problem**

“IRIS Control Center gives developers one safe workspace to discover the REST services actually registered in an IRIS instance, understand their contracts and exercise read-only operations.”

**0:15–0:35 — Discover**

Show the live catalogue, filter it, select a service and point out its namespace, dispatch class, web-application path and required resource. Emphasize that this inventory comes from IRIS itself rather than a hard-coded list.

**0:35–0:55 — Understand**

Open the advertised OpenAPI contract. Show paths, methods and parameters together with the IRIS service metadata.

**0:55–1:15 — Exercise safely**

Run a known GET operation. Show validation, HTTP status, timing and the formatted response. Point out that POST/PUT/PATCH/DELETE remain inspect-only and that execution is constrained to discovered local IRIS applications.

**1:15–1:30 — Proof**

Close with: “The release is open source, starts with Docker Compose, and has been validated from an anonymous checkout against pinned IRIS Community 2026.1 with runtime, browser and security acceptance tests.”

**Judge takeaway:** **Discover → understand → exercise → diagnose**, with IRIS authentication and deliberately bounded execution throughout.

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

Reproduce the reviewer installation path from a new directory using the public repository rather than relying on the development checkout:

```bash
cd "$(mktemp -d)"
git clone https://github.com/mrtandmilo/iris-control-center.git
cd iris-control-center
docker compose up --build -d
docker compose ps
```

Wait for the IRIS service to become healthy, then run the smoke command from **Recording preparation** above and follow the README installation path exactly. Record the public commit SHA and outcome in `RELEASE_EVIDENCE.md`. This is the final installation gate because it proves that a judge can start from the public repository alone.

## Screenshots for the submission

Use the five-item evidence package above. Do not recapture fixture-backed states merely to make the screenshots look cleaner. If a new live capture is required, run the full runtime acceptance workflow and take all release screenshots from that validated instance.

Avoid screenshots containing browser password dialogs, terminal command history with credentials, Authorization headers, cookies, or private system information.

## Demo acceptance gate

A polished recording is not evidence of correctness by itself. Before publishing or submitting a demo, complete every release-evidence item in `TESTING.md` and record the exact IRIS Community version used. If any runtime item remains unverified, describe it as a limitation rather than editing around it in the video.
