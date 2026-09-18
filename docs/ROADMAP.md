# Contest delivery roadmap

## Phase 1 — foundation
- Reproducible IRIS Community development environment
- REST backend and health endpoint
- Installer for `/iris-control-center`
- Repository documentation and license

## Phase 2 — service discovery
- Read IRIS management catalogue metadata
- Normalize generated and manually configured REST-service metadata
- Namespace/application/dispatch-class filtering
- Permission/error states

## Phase 3 — API explorer
- Load the selected service's Swagger/OpenAPI specification
- Render paths, methods and parameters
- Filter operations by path, method, description and tags
- Compose safe GET requests with OpenAPI path and query parameters
- Display response status, timing, headers and formatted JSON/text
- Keep POST/PUT/PATCH/DELETE inspect-only for the contest release
- Restrict execution to the selected local IRIS web application

## Phase 4 — polish and validation
- Responsive dashboard
- Empty/loading/error states
- Accessibility pass
- Demo walkthrough and screenshot checklist
- Installation validation from a clean IRIS Community instance
- Runtime smoke tests for discovery, OpenAPI and request-proxy security contracts

## Phase 5 — contest submission
- Final README and architecture diagram
- Demo video
- Open Exchange metadata
- Public repository
- Submission checklist and final regression test

## Scope discipline

The contest rewards a useful management GUI. The release deliberately prioritizes one coherent workflow — discover a REST application, understand its contract, and safely exercise read-only operations — rather than reproducing the entire IRIS Management Portal.

Mutating-request execution is intentionally deferred. Supporting arbitrary request bodies and custom headers would enlarge the security and authorization surface immediately before submission without improving the core discovery-and-exploration story enough to justify that risk. The explorer still displays those operations so developers can understand the complete API contract.
