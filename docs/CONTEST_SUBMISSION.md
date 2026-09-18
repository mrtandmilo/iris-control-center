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

## Verified contest requirements

The official 2026 **Build Your Own Management Portal** announcement defines the relevant release requirements for this project:

- the application must be fully functional and sufficiently original/useful for contest approval;
- it must work on IRIS Community Edition or IRIS for Health Community Edition;
- it must be open source and published on GitHub or GitLab;
- its README must be in English, include installation steps, and include either a video demo or a description of how the application works;
- the submission deadline is **September 27, 2026 at 23:59 EST**;
- improvements may continue during the subsequent voting period.

The contest task explicitly includes **managing web apps and exploring REST APIs**, which is the scope targeted by IRIS Control Center.

## Final release gate

Do not describe the application as tested until every applicable item in `docs/TESTING.md` has been validated against the target IRIS Community container.

Before submission:

- [ ] Confirm the repository is publicly accessible.
- [ ] Confirm the application is open source and the MIT license is present.
- [ ] Validate a clean installation against IRIS Community Edition from the public repository.
- [ ] Run the complete runtime checklist in `docs/TESTING.md` and capture the tested IRIS version.
- [ ] Verify the English README contains working installation steps and an accurate description/demo of the application.
- [ ] Add final screenshots and/or demo media that reflect the tested build.
- [ ] Verify README and documentation links from a clean checkout.
- [ ] Perform a final credentials/secrets and generated-artifact review.
- [ ] Confirm any Open Exchange/contest-registration requirements and current competition terms at the official source immediately before submission.
- [ ] Obtain the repository owner’s explicit approval before accepting contest terms or making the final submission.

The technical release can be prepared without accepting competition terms. Registration, identity verification if later required for a prize, and the final contest submission remain owner-controlled actions.
