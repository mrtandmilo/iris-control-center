# IRIS Control Center

A focused, developer-friendly management console for InterSystems IRIS.

Built for the 2026 InterSystems Programming Contest **Build Your Own Management Portal**.

## Why it exists

IRIS Control Center makes REST service discovery and API exploration faster and clearer than moving between multiple management screens. The contest release focuses on **managing awareness of web apps and exploring REST APIs**: discover what is available, understand its contract, and safely exercise read-only operations from one screen.

## Current capabilities

- Discover REST-enabled applications through the IRIS management API.
- Normalize generated and manually configured web applications into a searchable catalogue.
- Filter services by name, namespace and web application.
- Inspect namespace, dispatch class, required resource and OpenAPI/Swagger metadata.
- Browse OpenAPI operations grouped by their advertised paths.
- Execute **GET** operations from the integrated request workbench, including query parameters, using the current authenticated browser session.
- Display HTTP status and formatted JSON/text responses inline.
- Keep mutating POST/PUT/PATCH/DELETE operations inspect-only by design for the contest release.
- Provide a reproducible IRIS Community container build with automated ObjectScript import and application setup.

## Quick start

Prerequisites: Docker with Compose support and access to the InterSystems IRIS Community image configured by this repository.

```bash
docker compose up --build
```

After IRIS is healthy, open the Control Center web application at:

```text
http://localhost:52773/iris-control-center/
```

The API is mounted separately at `/iris-control-center/api`. Authentication is delegated to IRIS; credentials and authorization headers are not stored by the browser application.

## Architecture

The application has three deliberately small layers:

1. **IRIS discovery adapter** — queries `/api/mgmnt/v2/` and normalizes service metadata.
2. **IRIS REST backend** — exposes health, catalogue and OpenAPI endpoints to the UI while forwarding the authenticated IRIS session where required.
3. **Browser Control Center** — searchable service catalogue, OpenAPI viewer and safe GET request workbench.

Keeping the UI and API web applications separate makes their responsibilities and security settings explicit while allowing the UI to use the user's existing IRIS session.

## Security principles

- No credentials committed to the repository.
- No passwords or authorization headers persisted in browser storage.
- IRIS remains responsible for authentication and authorization.
- Discovery is read-only by default.
- The interactive workbench executes GET operations only; mutating methods remain visible for documentation but cannot be launched from the UI.
- Request execution is restricted to the selected service's local web-application path rather than accepting an arbitrary remote host.

## Validation and contest preparation

- [`docs/TESTING.md`](docs/TESTING.md) defines the clean-build, API, browser and security checks that must pass before the project is described as runtime-tested.
- [`docs/CONTEST_SUBMISSION.md`](docs/CONTEST_SUBMISSION.md) contains the evaluator-focused project summary, demo flow and final submission gate.
- [`docs/ROADMAP.md`](docs/ROADMAP.md) tracks the remaining delivery work.

## Development status

The main application flow is implemented: installation, service discovery, OpenAPI inspection and read-only request execution. Runtime validation against the target IRIS container and contest-focused testing/documentation remain in progress. Until the runtime checklist passes, this repository deliberately does not claim that the complete flow has been validated on the target container.

## Contest

Submission deadline: September 27, 2026 (23:59 EST). The contest permits continued improvements during the voting period.

## License

MIT — see `LICENSE`.
