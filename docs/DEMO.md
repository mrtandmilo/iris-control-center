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

   Do not record a demo until it passes. For the repository's unchanged local Community development image, the smoke script's documented development defaults may also be used; explicit credentials are preferable when validating a non-default environment.
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

## Screenshots for the submission

Capture these after final runtime validation:

1. Catalogue with several discovered services visible.
2. Selected service showing IRIS metadata.
3. OpenAPI endpoint list with method summary/filter.
4. Successful safe GET response showing status and timing.
5. Terminal showing the smoke test passing.

Avoid screenshots containing browser password dialogs, terminal command history with credentials, Authorization headers, cookies, or private system information.

## Demo acceptance gate

A polished recording is not evidence of correctness by itself. Before publishing or submitting a demo, complete every release-evidence item in `TESTING.md` and record the exact IRIS Community version used. If any runtime item remains unverified, describe it as a limitation rather than editing around it in the video.
