# IRIS Control Center

A focused, developer-friendly management console for InterSystems IRIS.

Built for the 2026 InterSystems Programming Contest **Build Your Own Management Portal**.

## Goal

IRIS Control Center makes REST service discovery and API exploration faster and clearer than moving between multiple management screens. The first release focuses on the contest task **Manage web apps and explore REST APIs**.

## Planned capabilities

- Discover REST-enabled applications from IRIS management APIs.
- Search and filter services by namespace, application and dispatch class.
- Inspect service metadata and OpenAPI/Swagger specifications.
- Launch requests from an integrated API explorer.
- Keep credentials out of source code and browser persistence.
- Provide clear health, permission and request feedback.

## Architecture

The application will use an InterSystems IRIS backend and a lightweight browser UI. IRIS exposes REST service metadata through `/api/mgmnt/` and `/api/mgmnt/v2/`; the control center will normalize those responses for the UI and proxy authenticated management requests where appropriate.

## Status

Initial development is in progress.

## Security principles

- No credentials committed to the repository.
- Prefer HTTP authentication headers for IRIS REST services.
- Least-privilege access: read-only discovery by default; privileged operations are separated and clearly identified.
- Do not persist passwords or authorization headers in browser storage.

## Contest

Submission deadline: September 27, 2026 (23:59 EST). The contest permits continued improvements during the voting period.

## License

MIT — see `LICENSE`.
