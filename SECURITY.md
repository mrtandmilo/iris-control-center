# Security policy

IRIS Control Center is a developer tool for inspecting REST applications on an InterSystems IRIS instance. Security issues that could cross the intended trust boundary are treated as release blockers.

## Supported version

The contest release on the `main` branch is the supported version. The validated target runtime is the pinned InterSystems IRIS Community 2026.1 container documented by the release evidence.

## Security model

IRIS remains the authentication and authorization authority. Control Center does not implement a second credential store.

The browser UI and backend API are protected by IRIS password authentication. Browser code does not persist passwords or authorization headers in local or session storage.

The request workbench is intentionally constrained:

- only discovered local IRIS REST applications may be selected as execution targets;
- the contest release executes GET operations only;
- mutating OpenAPI operations may be inspected but are not executable from the workbench;
- traversal attempts and unknown-service targets are rejected by the backend;
- arbitrary remote hosts are not accepted as proxy destinations.

These restrictions reduce the risk of turning an API explorer into a general-purpose request proxy or mutation console.

## Deployment guidance

IRIS Control Center is intended for trusted development or administrative environments. Use normal IRIS account and role management, expose the IRIS web endpoint only to networks and users that require it, and use TLS when traffic leaves a trusted local environment.

Do not commit IRIS passwords, registry credentials, tokens, private keys, or other secrets. Runtime credentials must be supplied through the deployment environment rather than source files.

## Reporting a vulnerability

Please do not publish credentials, exploit details, or other sensitive information in a public issue. Repository owners should use GitHub's private vulnerability-reporting mechanism when it is enabled. If private reporting is unavailable, report only that a security issue exists and request a private contact channel before sharing sensitive reproduction details.

A useful report includes the affected commit/version, the security boundary involved, minimal reproduction steps, expected versus observed behavior, and whether credentials or data may have been exposed. Never include real secrets in a report.

## Release security gate

Before a public contest release, the project must pass its automated credential guard, runtime traversal and unknown-service isolation checks, clean-checkout validation, and a final review for generated artifacts or accidental secrets. See `docs/TESTING.md` and `docs/RELEASE_EVIDENCE.md` for the auditable release gates.
