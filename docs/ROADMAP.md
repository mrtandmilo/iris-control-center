# Contest delivery roadmap

## Phase 1 — foundation — complete
- [x] Reproducible IRIS Community development environment
- [x] REST backend and health endpoint
- [x] Installer for `/iris-control-center`
- [x] Repository documentation and MIT license

## Phase 2 — service discovery — complete
- [x] Read IRIS management catalogue metadata
- [x] Normalize generated and manually configured REST-service metadata
- [x] Namespace/application/dispatch-class filtering
- [x] Permission/error states

## Phase 3 — API explorer — complete
- [x] Load the selected service's Swagger/OpenAPI specification
- [x] Render paths, methods and parameters
- [x] Filter operations by path, method, description and tags
- [x] Compose safe GET requests with OpenAPI path and query parameters
- [x] Display response status, timing, headers and formatted JSON/text
- [x] Keep POST/PUT/PATCH/DELETE inspect-only for the contest release
- [x] Restrict execution to the selected local IRIS web application

## Phase 4 — polish and validation — complete
- [x] Responsive dashboard
- [x] Empty/loading/error states
- [x] Accessibility pass
- [x] Demo walkthrough and screenshot checklist
- [x] Installation validation from a clean IRIS Community 2026.1 instance
- [x] Runtime smoke tests for discovery, OpenAPI and request-proxy security contracts
- [x] Real Chromium acceptance for catalogue, explorer and interactive GET execution

## Phase 5 — contest packaging — in progress
- [x] Final README and architecture documentation
- [x] Open Exchange metadata draft
- [x] Submission checklist and evaluator-focused demo script
- [x] Automated secret/private-information guard in CI
- [ ] Capture the five final evidence images defined in `DEMO.md`: catalogue, selected-service metadata, OpenAPI explorer, successful safe GET, and passing smoke test
- [ ] Reproduce README installation from the final public checkout
- [ ] Make the repository public
- [ ] Optional: publish a demo video if pursuing the announced video bonus
- [ ] Owner approval and final contest submission

## Release boundary

The application implementation and automated technical acceptance are complete for the contest scope. Remaining items are release/publication evidence and owner-controlled submission actions; they should not be represented as completed until they actually occur.

The screenshot set is intentionally defined once in `DEMO.md`; this roadmap tracks completion of that set rather than maintaining a competing screenshot count.

## Scope discipline

The contest rewards a useful management GUI. The release deliberately prioritizes one coherent workflow — discover a REST application, understand its contract, and safely exercise read-only operations — rather than reproducing the entire IRIS Management Portal.

Mutating-request execution is intentionally deferred. Supporting arbitrary request bodies and custom headers would enlarge the security and authorization surface immediately before submission without improving the core discovery-and-exploration story enough to justify that risk. The explorer still displays those operations so developers can understand the complete API contract.
