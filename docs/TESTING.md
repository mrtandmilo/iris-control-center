# Runtime validation

IRIS Control Center is intentionally tested as an installed IRIS application, not only as static browser code. This checklist is the release gate for the contest build.

## Build and installation

1. Run `docker compose build --no-cache`.
2. Run `docker compose up` and wait for IRIS to report healthy.
3. Confirm the setup script imports all classes without compile errors.
4. Confirm `/iris-control-center` and `/iris-control-center/api` exist as enabled web applications.
5. Open `http://localhost:52773/iris-control-center/`.

## Automated smoke test

After starting the container, execute:

```bash
IRIS_USER=_SYSTEM IRIS_PASSWORD=SYS ./scripts/smoke-test.sh
```

The smoke test waits for the authenticated Control Center health endpoint before running the full contract and security suite, so a normal IRIS startup does not produce a false failure. By default it allows 180 seconds for readiness, polls every 3 seconds, and bounds each HTTP request to 15 seconds. These values can be adjusted when validating slower environments:

```bash
READY_TIMEOUT=300 READY_INTERVAL=5 REQUEST_TIMEOUT=30 \
  IRIS_USER=_SYSTEM IRIS_PASSWORD=SYS ./scripts/smoke-test.sh
```

`BASE_URL`, `IRIS_USER`, and `IRIS_PASSWORD` can also be overridden for a non-default local environment. Do not commit real credentials.

A successful run verifies the browser shell/assets, authenticated health response, JSON response contracts, service discovery, OpenAPI error isolation, request-proxy validation, and traversal protections. A timeout or failed assertion is a release-gate failure and must not be treated as a successful runtime validation.

## API smoke tests

With an authenticated IRIS session, verify:

- `GET /iris-control-center/api/health` returns HTTP 200, `status: ok`, the application name and namespace.
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
- The request workbench cannot supply an arbitrary remote host; its base path comes from the selected discovered service.
- Discovery and OpenAPI retrieval respect IRIS authentication/authorization.
- Mutating operations cannot be launched from the browser UI.
- HTML originating in service metadata or OpenAPI documents is escaped before rendering.

## Release evidence

Before contest submission, capture:

- successful clean container build output;
- successful ObjectScript compile/setup output;
- successful `scripts/smoke-test.sh` output;
- health endpoint response;
- service catalogue screenshot;
- OpenAPI explorer screenshot;
- successful safe GET execution screenshot;
- exact IRIS Community version used for the final validation.

Any failed item above blocks the claim that the application is runtime-tested. Record remaining limitations explicitly in the README rather than presenting unverified behavior as complete.
