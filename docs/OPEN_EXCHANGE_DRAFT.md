# Open Exchange listing draft

This file prepares the public listing copy for IRIS Control Center. It is **not** a contest submission and does not accept any competition terms.

## Title

IRIS Control Center

## Short description

A developer-focused InterSystems IRIS management console for discovering REST web applications, exploring their OpenAPI contracts, and safely executing read-only requests from one workspace.

## Suggested categories / tags

Use only categories that are available in Open Exchange at submission time. Relevant terms are:

- InterSystems IRIS
- REST API
- OpenAPI
- Management
- Developer tools
- Docker

Do not claim ZPM, online-demo, or video bonuses unless those assets have actually been delivered and verified.

## Listing description

IRIS Control Center turns the REST services registered in an InterSystems IRIS instance into a searchable, task-focused API workspace.

Instead of manually moving between web-application configuration, service metadata, API documentation, and a separate REST client, a developer can use one screen to answer four practical questions:

1. **What REST applications are available?** Control Center discovers REST-enabled applications from IRIS's native REST application catalogue rather than maintaining a hard-coded inventory.
2. **How is a service configured?** The selected service shows its namespace, web-application path, dispatch class, required resource, and advertised OpenAPI/Swagger metadata.
3. **What does its API expose?** Control Center loads the advertised OpenAPI definition and presents paths, methods, descriptions, tags, and parameters in an integrated explorer.
4. **What does a safe request return?** Read-only GET operations can be executed from the request workbench with path and query parameters. Status, timing, headers, and formatted JSON/text responses are shown inline.

The contest release deliberately keeps POST, PUT, PATCH, and DELETE operations inspect-only. Executable requests are restricted to discovered local IRIS web applications, preserving IRIS authentication and authorization as the security boundary while avoiding an unrestricted proxy surface.

The project includes a reproducible Docker Compose environment based on IRIS Community 2026.1, automated ObjectScript import/setup, static checks, runtime acceptance tests, architecture and security documentation, and a repeatable evaluator demo walkthrough.

## Installation summary

Prerequisites: Docker with Compose support and access to the InterSystems IRIS Community image configured by the repository.

```bash
git clone https://github.com/mrtandmilo/iris-control-center.git
cd iris-control-center
docker compose up --build
```

After IRIS reports healthy, open:

```text
http://localhost:52773/iris-control-center/
```

Authenticate using an IRIS account permitted to access the discovered applications. Full installation, security, testing, and demo instructions are maintained in the repository README and `docs/` directory.

## Evaluator demo story

**Discover → understand → exercise → diagnose.**

A concise demonstration should:

1. show automatic discovery of REST services;
2. filter and select a service;
3. inspect its IRIS metadata;
4. browse its OpenAPI operations;
5. execute a known read-only GET operation;
6. show status, timing, headers, and formatted response;
7. point out the deliberate GET-only execution boundary.

## Technology bonus claim

Claim only the Docker/container bonus currently supported by the repository and the official contest rules at submission time. Recheck the live contest page immediately before submitting because bonus categories and wording may change.

## Submission-time fields still requiring owner action

- Public repository URL after visibility is changed.
- Final screenshots and/or demo-video URL, if used.
- Open Exchange account/author identity fields.
- Acceptance of any current Open Exchange or contest terms.
- Final submission action.

These owner-controlled fields must not be completed automatically.
