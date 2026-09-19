# Runtime validation

IRIS Control Center is intentionally tested as an installed IRIS application, not only as static browser code. This checklist is the release gate for the contest build.

## Build and installation

For day-to-day development the Compose build defaults to `containers.intersystems.com/intersystems/iris-community:latest-em`. For final release validation, pin the exact IRIS Community image tag so the evidence is reproducible.

First remove the existing Compose stack **and its named data volume**. A no-cache image build alone is not a clean IRIS installation because `iris-data` persists between runs:

```bash
docker compose down -v --remove-orphans
```

This command deletes the local IRIS data volume for this Compose project. Use it only for the disposable contest-validation instance, never for an IRIS instance containing data that must be retained.

Then build and start with the same pinned image tag:

```bash
export IRIS_IMAGE=containers.intersystems.com/intersystems/iris-community:<exact-tag>
docker compose build --no-cache
docker compose up
```

Do not use the literal `<exact-tag>` placeholder; replace it with the tested Community image tag available from the InterSystems container registry. Record that tag with the release evidence. Keeping `IRIS_IMAGE` exported for both commands also prevents the build and runtime steps from accidentally resolving different defaults.

1. Remove the disposable validation stack and `iris-data` volume with `docker compose down -v --remove-orphans`.
2. Export the exact IRIS Community image tag and run the no-cache build above.
3. Start the pinned Compose stack and wait for IRIS to report healthy.
4. Confirm the setup script imports all classes without compile errors.
5. Confirm `/iris-control-center` and `/iris-control-center/api` exist as enabled web applications.
6. Open `http://localhost:52773/iris-control-center/`.

## Automated smoke test

After starting the container, prompt for the IRIS password so it is not written into shell history, then execute the suite:

```bash
read -rs -p 'IRIS password: ' IRIS_PASSWORD; echo
export IRIS_PASSWORD
IRIS_USER=_SYSTEM ./scripts/smoke-test.sh
unset IRIS_PASSWORD
```

The smoke test deliberately has no default password and fails fast if `IRIS_PASSWORD` is absent. It waits for the authenticated Control Center health endpoint before running the full contract and security suite, so a normal IRIS startup does not produce a false failure. By default it allows 180 seconds for readiness, polls every 3 seconds, and bounds each HTTP request to 15 seconds. These values can be adjusted when validating slower environments:

```bash
READY_TIMEOUT=300 READY_INTERVAL=5 REQUEST_TIMEOUT=30 \
  IRIS_USER=_SYSTEM ./scripts/smoke-test.sh
```

`BASE_URL`, `IRIS_USER`, and `IRIS_PASSWORD` can also be overridden for a non-default local environment. Do not commit real credentials.

A successful run verifies the browser shell/assets, rejects unauthenticated API access, validates the authenticated health response and JSON contracts, exercises service discovery, and checks OpenAPI/request-proxy validation, isolation and traversal protections. A timeout or failed assertion is a release-gate failure and must not be treated as a successful runtime validation.

## API smoke tests

With an authenticated IRIS session, verify:

- An unauthenticated `GET /iris-control-center/api/health` is rejected with HTTP 401; the static UI may load without authentication, but management data must not be exposed before IRIS authenticates the API request.
- `GET /iris-control-center/api/health` returns HTTP 200, `status: ok`, the application name and namespace when authenticated.
- `GET /iris-control-center/api/services` returns HTTP 200 and a JSON object containing `services`, `source` and `count`.
- The service catalogue contains both generated REST applications and eligible manually configured REST applications present in the instance.
- A known service with an advertised Swagger/OpenAPI definition can be retrieved with `GET /iris-control-center/api/openapi?service=<encoded service name>`.
- Missing `service` returns HTTP 400.
- An unknown service returns HTTP 404.
- A service without an advertised API definition returns HTTP 404.
- A service name containing `/` is handled through the query parameter without route corruption.

## Browser acceptance tests

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
- Unauthenticated requests to the management API are rejected before application data is returned.
- The request workbench cannot supply an arbitrary remote host; its base path comes from the selected discovered service.
- Discovery and OpenAPI retrieval respect IRIS authentication/authorization.
- Mutating operations cannot be launched from the browser UI.
- HTML originating in service metadata or OpenAPI documents is escaped before rendering.

## Release evidence

Before contest submission, capture:

- exact pinned IRIS Community image tag used for the final validation;
- confirmation that the disposable validation data volume was removed before the build;
- successful clean container build output using that pinned tag;
- successful ObjectScript compile/setup output;
- successful `scripts/smoke-test.sh` output;
- health endpoint response;
- service catalogue screenshot;
- OpenAPI explorer screenshot;
- successful safe GET execution screenshot.

Any failed item above blocks the claim that the application is runtime-tested. Record remaining limitations explicitly in the README rather than presenting unverified behavior as complete.
