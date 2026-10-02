# IRIS Control Center demo walkthrough

Explore how IRIS Control Center brings REST service discovery, API documentation and read-only requests into one workspace. The video gives a 90-second overview; the walkthrough below takes roughly three minutes in a running instance.

## Watch the demo

[Watch the 90-second IRIS Control Center demo on YouTube](https://youtu.be/8UxUOaP0gDo) — **Discover → understand → exercise → diagnose.**

This captioned screenshot walkthrough uses genuine IRIS Community 2026.1 runtime evidence captured on 23 September 2026. It shows REST service discovery, service metadata, OpenAPI exploration and a successful `/health` GET. The video is unlisted and viewable by anyone with the link. At the time of recording, Windows PowerShell execution was unverified. It has since passed on Windows Server 2022 in Windows PowerShell 5.1 and PowerShell 7 against a disposable Linux-hosted IRIS container; Windows Docker Desktop installation remains unverified. See [release evidence](RELEASE_EVIDENCE.md).

## Try the demo

Follow the [README installation guide](../README.md#quick-start) to start the application with `docker compose up --build`. Once IRIS is healthy and setup is complete, open `http://localhost:52773/iris-control-center/`. The browser authentication prompt is expected. The default Compose credentials are username `_SYSTEM` and password `SYS`; if `IRIS_PASSWORD` was overridden at startup, use that password instead.

### Windows reviewers

Docker Compose can be started from PowerShell with `docker compose up --build -d`; `docker compose ps` shows when the service is healthy. The browser walkthrough is the same on Windows. A native [PowerShell health and service-discovery check](TESTING.md#windows-evaluator-path) is also available; Bash is not required to evaluate the application. PowerShell client validation passed on Windows Server 2022, while Docker Desktop installation and the Windows browser walkthrough remain unverified.

## Three-minute walkthrough

### 0:00–0:30 — A live API inventory

IRIS Control Center turns the REST services registered in an IRIS instance into a searchable, task-focused API workspace. The catalogue comes from IRIS itself rather than a separately maintained, hard-coded list.

### 0:30–1:10 — Discover a service

The catalogue shows the service count and supports filtering by service name, namespace or web-application path. Selecting a service reveals its web application, namespace, dispatch class and required resource. Together, these details answer “what REST APIs are actually available on this instance?”

### 1:10–2:00 — Understand its contract

For a service with an advertised OpenAPI definition, the explorer displays the API title and version, method counts, paths, endpoint descriptions and path/query parameters. Endpoint filtering helps locate an operation while the IRIS service metadata stays in the same workflow.

### 2:00–2:40 — Exercise a read-only GET

Choose a known read-only GET endpoint, fill its required path/query parameters and run the request. The workbench validates required inputs and displays HTTP status, elapsed time, response headers and formatted JSON or readable text, including status for unsuccessful responses. The recorded example uses the first-party `/health` endpoint through the production request proxy.

Execution is limited to GET operations. POST, PUT, PATCH and DELETE remain available for inspection, and requests are constrained to the selected discovered local IRIS web application. IRIS authentication and authorization apply throughout.

### 2:40–3:00 — From discovery to diagnosis

**Discover → understand → exercise → diagnose.** The project is open source, uses Docker Compose for repeatable installation and includes smoke, static, runtime, browser and security acceptance checks.

## Evidence behind the demo

The video uses genuine IRIS states from [runtime acceptance run 75](https://github.com/mrtandmilo/iris-control-center/actions/runs/35834262463), captured on 23 September 2026:

| Evidence | What it shows |
| --- | --- |
| `01-real-catalogue.png` | Catalogue with discovered IRIS services. |
| `02-real-selected-service.png` | Live IRIS service metadata; the API definition is still loading in this image. |
| `03-real-openapi-explorer.png` | Completed exploration of the first-party Control Center OpenAPI contract. |
| `04-real-safe-get.png` | Successful first-party `/health` GET through the production proxy, including status, timing and result. |
| Validation transcripts | Anonymous public-checkout installation and clean smoke/release validation. |

The browser images are in `browser-evidence-35834262463`; the transcripts are in `release-validation-35834262463`. GitHub Actions retention for these artifacts expires on 7 October 2026. [Release evidence](RELEASE_EVIDENCE.md) records artifact links, archive hashes, exact tested revisions, the pinned IRIS Community 2026.1 image and validation scope. Deeper parameter tests use a browser fixture; the release screenshots show real IRIS operations.

Recording preparation, evidence preservation and publication checks are documented in the [maintainer release guide](RELEASE_PROCESS.md).
