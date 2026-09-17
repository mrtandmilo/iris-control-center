# IRIS Control Center architecture

IRIS Control Center is intentionally small: a static browser UI talks to a dedicated `%CSP.REST` application, which in turn discovers management APIs from the same IRIS instance. The design keeps credentials inside the existing IRIS authenticated session and avoids storing secrets in the application.

```mermaid
flowchart LR
    B[Browser\nControl Center UI] -->|same-origin session| A[/iris-control-center/api\nIRISControlCenter.REST]
    A -->|authenticated local request| M[/api/mgmnt/v2/\nIRIS Management API]
    M -->|service catalogue| A
    A -->|normalized catalogue| B
    A -->|fetch advertised spec| S[Swagger / OpenAPI definition]
    S --> A
    A -->|OpenAPI JSON| B
    B -->|explicit GET only| R[Selected IRIS REST application]
    R -->|status + headers + body| B
```

## Components

### Browser UI

`web/index.html`, `web/app.css`, and `web/app.js` provide a dependency-free responsive interface. The browser:

- searches the normalized service catalogue;
- displays namespace, web application, dispatch class, resource and availability metadata;
- renders paths, methods and path/query parameters from OpenAPI;
- permits explicit execution of documented GET operations only;
- reports HTTP status, elapsed client time, response headers and a formatted response body.

Mutating methods are deliberately inspect-only. This is a safety boundary, not a technical limitation.

### Application REST API

`IRISControlCenter.REST` exposes the Control Center's small backend API. It delegates discovery to `IRISControlCenter.ServiceDiscovery` and retrieves an advertised OpenAPI document only after matching it to a discovered service.

### Service discovery

`IRISControlCenter.ServiceDiscovery` queries the local IRIS management API and converts IRIS metadata into the stable shape consumed by the browser. Keeping normalization server-side prevents the UI from depending directly on management-API response details.

## Trust boundaries and security choices

1. **Same IRIS instance.** Management discovery and OpenAPI retrieval target the local IRIS web server rather than an arbitrary host. This avoids turning Control Center into an SSRF proxy.
2. **Existing authentication.** The API forwards the current request's `Authorization` header to local management discovery. Control Center does not persist passwords, tokens or API keys.
3. **Read-oriented explorer.** The browser executes only GET operations. POST, PUT, PATCH and DELETE remain visible for documentation but are not executable.
4. **No hidden privilege escalation.** Access remains subject to the permissions of the authenticated IRIS user and the target REST application.
5. **Bounded display.** Large response bodies are truncated in the browser to keep the management UI responsive.

## Deployment

The repository's `Dockerfile`, `docker-compose.yml`, `iris.script`, and setup script provide a reproducible IRIS Community development deployment. The installer creates separate web applications for the static UI and authenticated REST API.

## Design objective

The project does not attempt to replace the full IRIS Management Portal. It optimizes a single developer/administrator workflow:

**discover service → inspect metadata → understand OpenAPI → supply parameters → execute a safe request → inspect the result**
