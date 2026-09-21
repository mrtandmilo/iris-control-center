# IRIS Control Center

A focused, developer-friendly management console for InterSystems IRIS.

Built for the 2026 InterSystems Programming Contest **Build Your Own Management Portal**.

## Why it exists

IRIS Control Center makes REST service discovery and API exploration faster and clearer than moving between multiple management screens. The contest release focuses on **managing awareness of web apps and exploring REST APIs**: discover what is available, understand its contract, and safely exercise read-only operations from one screen.

## Current capabilities

- Discover REST-enabled applications through the native IRIS REST application catalogue.
- Normalize generated and manually configured web applications into a searchable catalogue.
- Filter services by name, namespace and web application.
- Inspect namespace, dispatch class, required resource and OpenAPI/Swagger metadata.
- Browse OpenAPI operations grouped by their advertised paths.
- Execute **GET** operations from the integrated request workbench, including path and query parameters, using the current authenticated browser session.
- Display HTTP status and formatted JSON/text responses inline.
- Keep mutating POST/PUT/PATCH/DELETE operations inspect-only by design for the contest release.
- Restrict request execution to discovered local IRIS web applications.
- Provide a reproducible IRIS Community 2026.1 container build with automated ObjectScript import and application setup.

## Quick start

Prerequisites: Docker with Compose support and access to the InterSystems IRIS Community image configured by this repository.

```bash
docker compose up --build
```

After IRIS is healthy, open:

```text
http://localhost:52773/iris-control-center/
```

The UI and API are protected by IRIS password authentication. The API is mounted separately at `/iris-control-center/api`. Credentials and authorization headers are not stored by the browser application.

## Architecture

The application has three deliberately small layers:

1. **IRIS discovery adapter** — uses the native `%REST.API.GetAllWebRESTApps()` interface and normalizes `%REST.Application` metadata for generated and manually configured REST applications.
2. **IRIS REST backend** — exposes health, catalogue, OpenAPI and safe request-execution endpoints to the authenticated UI.
3. **Browser Control Center** — searchable service catalogue, OpenAPI viewer and safe GET request workbench.

The UI and API have separate IRIS web applications so routing and security responsibilities remain explicit, while both use the same IRIS authentication boundary. See [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) for the component diagram, request flow and trust-boundary rationale.

## Security principles

- No credentials committed to the repository.
- No passwords or authorization headers persisted in browser storage.
- IRIS remains responsible for authentication and authorization.
- Discovery is read-only by default.
- The interactive workbench executes GET operations only; mutating methods remain visible for documentation but cannot be launched from the UI.
- Request execution is restricted to the selected service's local web-application path rather than accepting an arbitrary remote host.
- Traversal attempts and unknown-service requests are rejected by the backend.

## Validation and contest preparation

The release is continuously validated from a clean disposable IRIS instance. The release-validation workflow removes the persistent test volume, pulls the pinned IRIS Community 2026.1 image, performs a no-cache build, compiles all ObjectScript classes, waits for container health and runs the application acceptance suite.

The clean runtime acceptance suite verifies authenticated UI delivery, browser assets, API authentication, health, native service discovery, OpenAPI input validation, request-proxy validation, traversal protection and unknown-service isolation.

- [`docs/TESTING.md`](docs/TESTING.md) defines the clean-build, API, browser and security release gates.
- [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) documents application boundaries and security decisions.
- [`docs/DEMO.md`](docs/DEMO.md) provides a repeatable three-minute judge/reviewer walkthrough and screenshot checklist.
- [`docs/CONTEST_SUBMISSION.md`](docs/CONTEST_SUBMISSION.md) contains the evaluator-focused project summary, demo flow and final submission gate.
- [`docs/ROADMAP.md`](docs/ROADMAP.md) tracks final contest packaging work.

## Development status

The core contest workflow is implemented and runtime-tested against the pinned InterSystems IRIS Community 2026.1 container: installation, authentication, service discovery, OpenAPI inspection, safe read-only request execution and backend security contracts. Remaining work is release polish and contest packaging: browser/demo evidence, final documentation review, public-repository readiness and submission assets.

## Contest

The official contest runs September 14–October 4, 2026, but **new submissions close September 27, 2026 at 23:59 EST**. Community voting runs September 28–October 4, and submitted applications may continue to be improved during voting.

The contest scores Complexity, Clarity of Instructions, Developer Experience, Applicability and Usability. IRIS Control Center uses a Docker container, one of the announced technology-bonus categories. Other bonus opportunities (such as IPM packaging, an online demo and a YouTube demo) are not claimed until they are actually delivered.

Official references:

- [Contest page](https://openexchange.intersystems.com/contest/48)
- [Developer Community announcement](https://community.intersystems.com/post/intersystems-programming-contest-build-your-own-management-portal)

## License

MIT — see `LICENSE`.
