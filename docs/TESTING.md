# Runtime validation

IRIS Control Center is intentionally tested as an installed IRIS application, not only as static browser code. This checklist is the release gate for the contest build.

## Build and installation

The repository defaults to the IRIS Community 2026.1 image pinned by manifest digest in both `Dockerfile` and `docker-compose.yml`. The digest is part of the release configuration so a clean validation does not silently move to a later maintenance image.

First remove the existing Compose stack **and its named data volume**. A no-cache image build alone is not a clean IRIS installation because `iris-data` persists between runs:

```bash
docker compose down -v --remove-orphans
```

This deletes the local IRIS data volume for this Compose project. Use it only for the disposable contest-validation instance, never for an IRIS instance containing data that must be retained.

Then build and start using the repository's immutable default:

```bash
docker compose build --pull --no-cache
docker compose up
```

`IRIS_IMAGE` may be exported to validate a different explicit IRIS Community release, but release evidence must record the exact tag/digest used. Do not use a moving `latest` tag.

1. Remove the disposable validation stack and `iris-data` volume with `docker compose down -v --remove-orphans`.
2. Run the no-cache build above against the pinned image.
3. Start the Compose stack and wait for IRIS to report healthy.
4. Confirm the setup script imports all classes without compile errors.
5. Confirm `/iris-control-center` and `/iris-control-center/api` exist as enabled web applications.
6. Open `http://localhost:52773/iris-control-center/` and authenticate with an IRIS account authorized to use the application.

## Automated smoke test

After starting the container, prompt for the IRIS password so it is not written into shell history, then execute the suite:

```bash
read -rs -p 'IRIS password: ' IRIS_PASSWORD; echo
export IRIS_PASSWORD
IRIS_USER=_SYSTEM ./scripts/smoke-test.sh
unset IRIS_PASSWORD
```

The smoke test deliberately has no default password and fails fast if `IRIS_PASSWORD` is absent. It waits for the authenticated Control Center health endpoint before running the full contract and security suite, so normal IRIS startup does not produce a false failure. By default it allows 180 seconds for readiness, polls every 3 seconds, and bounds each HTTP request to 15 seconds. These values can be adjusted for slower environments:

```bash
READY_TIMEOUT=300 READY_INTERVAL=5 REQUEST_TIMEOUT=30 \
  IRIS_USER=_SYSTEM ./scripts/smoke-test.sh
```

`BASE_URL`, `IRIS_USER`, and `IRIS_PASSWORD` can also be overridden for a non-default local environment. Do not commit real credentials.

A successful run verifies the authenticated browser shell/assets, rejects unauthenticated UI and API access, validates the authenticated health response and JSON contracts, exercises service discovery, and checks OpenAPI/request-proxy validation, isolation and traversal protections. A timeout or failed assertion is a release-gate failure.

## One-command release validation

For the final clean acceptance run, use the release-validation wrapper. It requires a clean Git worktree and an explicit password, records the commit and resolved base-image evidence, removes the disposable data volume, rebuilds without cache, waits for container health and runs the smoke suite:

```bash
read -rs -p 'IRIS password: ' IRIS_PASSWORD; echo
export IRIS_PASSWORD
export IRIS_IMAGE='intersystems/iris-community:2026.1@sha256:c57b65b2b454494091e7b3e49f6a53b3335f40adf475bcfcee0866083f35a7c2'
./scripts/release-validation.sh
unset IRIS_PASSWORD IRIS_IMAGE
```

Keep the successful transcript as release evidence. The validated stack is intentionally left running so browser screenshots and demo evidence can be captured from the same instance.

## API smoke tests

With an authenticated IRIS session, verify:

- Unauthenticated `GET /iris-control-center/` and `GET /iris-control-center/api/health` requests are rejected.
- Authenticated `GET /iris-control-center/api/health` returns HTTP 200, `status: ok`, the application name and namespace.
- `GET /iris-control-center/api/services` returns HTTP 200 and a JSON object containing `services`, `source` and `count`.
- The service catalogue contains eligible generated and manually configured REST applications present in the instance.
- A known service with an advertised Swagger/OpenAPI definition can be retrieved with `GET /iris-control-center/api/openapi?service=<encoded service name>`.
- Missing `service` returns HTTP 400.
- An unknown service returns HTTP 404.
- A service without an advertised API definition returns HTTP 404.
- A service name containing `/` is handled through the query parameter without route corruption.

## Browser acceptance tests

- The UI is unavailable until IRIS authentication succeeds.
- The catalogue loads after authentication and the count matches the API response.
- Filtering works by service name, namespace and web-application path.
- Selecting a service displays its web application, namespace, dispatch class and required resource.
- OpenAPI paths and supported HTTP methods render correctly.
- Path and query parameters are displayed for GET operations.
- Required path parameters prevent execution when blank.
- A known read-only GET operation executes against the selected local web application.
- JSON responses are formatted and text responses remain readable.
- HTTP status is shown for unsuccessful responses.
- POST, PUT, PATCH and DELETE operations remain inspect-only and cannot be executed from the contest UI.
- Refresh re-runs discovery without a page reload.

## Security regression checks

- No credentials, authorization headers or session tokens appear in repository files or browser local/session storage.
- Unauthenticated requests to both UI and management API are rejected before application data is returned.
- The request workbench cannot supply an arbitrary remote host; its base path comes from the selected discovered service.
- Discovery uses the native IRIS REST application catalogue and remains subject to the authenticated Control Center request.
- OpenAPI retrieval and request execution respect IRIS authentication/authorization.
- Mutating operations cannot be launched from the browser UI.
- Path traversal attempts are rejected by the backend.
- Unknown services are isolated and cannot be used to turn the proxy into an arbitrary local requester.
- HTML originating in service metadata or OpenAPI documents is escaped before rendering.

## Release evidence

Before contest submission, capture:

- exact pinned IRIS Community image reference and resolved digest used for final validation;
- confirmation that the disposable validation data volume was removed before the build;
- successful clean container build output;
- successful ObjectScript compile/setup output;
- successful `scripts/smoke-test.sh` output;
- health endpoint response;
- service catalogue screenshot;
- OpenAPI explorer screenshot;
- successful safe GET execution screenshot.

The clean CI acceptance run on commit `b821bac` passed all ten automated runtime checks against the pinned IRIS Community 2026.1 image, including clean ObjectScript compilation. Subsequent release changes must continue to pass the same gate. Any failed item blocks the claim that the current revision is runtime-tested.
