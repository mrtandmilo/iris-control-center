# Contest submission preparation

This document keeps the final InterSystems Programming Contest entry accurate and reproducible. It is a preparation aid, not a submitted entry.

## Project summary

**IRIS Control Center** is a focused management console for developers working with InterSystems IRIS REST services. It discovers REST-enabled web applications from IRIS, presents them as a searchable service catalogue, retrieves their advertised OpenAPI definitions, and turns those definitions into an integrated API explorer. The contest release deliberately limits execution to GET operations so developers can inspect and exercise read-oriented APIs without turning the explorer into an unrestricted mutation console.

## Problem addressed

Developers investigating an unfamiliar IRIS instance often need to answer several related questions: which REST applications exist, which namespace and dispatch class they use, whether they publish an API contract, what endpoints that contract contains, and what a safe request returns. Control Center brings that workflow into one task-focused screen.

## Judging-oriented highlights

### Applicability

- Works from IRIS's own management/service metadata rather than a hard-coded demo catalogue.
- Designed to remain useful as services are added or changed.
- Keeps the selected service's IRIS web-application path as the execution boundary.

### Developer experience

- Searchable catalogue instead of manual navigation between configuration pages.
- OpenAPI paths, methods and parameters shown next to service metadata.
- Safe GET workbench displays status and formatted JSON/text responses inline.
- Reproducible Docker-based installation for evaluation.

### Usability

- Responsive single-page interface.
- Clear service selection and filtering.
- Required path parameters are validated before execution.
- Mutating methods remain visible for understanding the contract but are inspect-only.

### Clarity of instructions

- One-command Docker Compose start.
- Architecture, security model and current limitations documented in the README.
- Explicit runtime acceptance checklist in `docs/TESTING.md`.

## Demo flow

A concise evaluator demo should show:

1. Start the container from a clean checkout.
2. Open Control Center and authenticate to IRIS when required.
3. Show automatic discovery of REST services.
4. Filter the catalogue and select a service.
5. Point out namespace, dispatch class and web-application metadata.
6. Load the service's OpenAPI definition.
7. Choose a read-only GET operation, enter any required path/query parameters and run it.
8. Show the HTTP status and formatted response.
9. Point out that mutating methods are intentionally inspect-only.

## Final release gate

Do not describe the application as tested until every applicable item in `docs/TESTING.md` has been validated against the target IRIS Community container.

Before submission:

- make the repository publicly accessible as required by the contest;
- confirm the final contest rules, eligibility and submission deadline at the official source;
- validate a clean installation from the public repository;
- add final screenshots/demo media;
- record the tested IRIS version;
- verify README links and installation instructions;
- perform a credentials/secrets review;
- obtain the repository owner’s explicit approval before the final contest submission.
