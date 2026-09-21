# Release validation evidence

This record tracks the final contest release. Do not record passwords, tokens, cookies, authorization headers, registry credentials, or other secrets here.

## Environment

- Validation date (UTC): 2026-09-21
- Runtime-validated commit SHA: `e420ab90d683531f658a9ea908a567a51a0398a8`
- IRIS Community release: 2026.1
- GitHub Actions runtime acceptance: **passed** (run 47)
- GitHub Actions static checks: **passed** (run 121)
- Real Chromium acceptance: **passed** as part of runtime acceptance run 47
- Host tooling/OS details: not retained in repository evidence; reproduce during final clean-checkout validation

## Clean build and installation

- [x] Clean IRIS Community 2026.1 image build completed.
- [x] Container reached a healthy IRIS state.
- [x] Setup imported and compiled all four application classes without errors.
- [x] `/iris-control-center` was enabled and authenticated UI assets were delivered.
- [x] `/iris-control-center/api` was enabled and authenticated API readiness passed.

Evidence/notes: The first fully clean runtime acceptance was established on `b821bac`. Subsequent documentation, accessibility, security, contest-packaging and browser-acceptance hardening culminated in `e420ab9`, whose runtime-acceptance and static-check workflows both completed successfully. Earlier misleading green runs were rejected because build output still contained an ObjectScript compilation error; those runs are not treated as release evidence.

## Automated runtime validation

- [x] `scripts/smoke-test.sh` completed successfully against the clean instance.
- [x] Health contract passed.
- [x] Native service-discovery contract passed.
- [x] OpenAPI validation/error-isolation checks passed.
- [x] GET request-proxy validation checks passed.
- [x] Traversal/security regression checks passed.
- [x] Unknown-service isolation passed.
- [x] Authenticated UI, JavaScript and CSS delivery passed.

Evidence/notes: The clean acceptance suite reaches all 10 runtime checks successfully on IRIS Community 2026.1. The latest validated repository head is `e420ab9`.

## Browser acceptance

- [x] Service catalogue loads and count matches the API response.
- [x] Catalogue filtering works, including the empty-result state.
- [x] Service metadata renders correctly.
- [x] Keyboard selection and selected-service `aria-pressed` state verified in real Chromium.
- [x] Refresh re-runs discovery without a page reload.
- [x] OpenAPI explorer reaches a terminal state when an OpenAPI-advertising service is available; endpoint filtering is exercised in that case.
- [ ] GET path/query parameter composition verified end-to-end in the browser.
- [ ] Required path parameters block incomplete requests in the browser.
- [ ] A known read-only GET executes successfully from the browser explorer.
- [ ] Response status, timing, headers and body render correctly after browser execution.
- [ ] Mutating methods remain inspect-only in the browser.

Evidence/notes: `scripts/browser-acceptance.mjs` now runs headless Chromium against the validated IRIS instance in CI. Runtime acceptance run 47 passed this harness. The unchecked items above require an OpenAPI fixture/service with a deterministic safe GET operation; they are not inferred from HTTP or source-level checks.

## Contest/demo evidence

- [ ] Service catalogue screenshot captured.
- [ ] OpenAPI explorer screenshot captured.
- [ ] Successful safe GET execution screenshot captured.
- [ ] README installation steps reproduced from a fresh public checkout.
- [ ] README/demo links checked.
- [ ] Repository checked for committed secrets and private information.
- [ ] Known limitations reviewed for accuracy.
- [ ] Repository made publicly accessible as required by the contest.

Evidence/notes: The repository is currently private, so public-repository contest compliance is not yet satisfied.

## Release decision

Runtime validation status: **PASSED on `e420ab9` / IRIS Community 2026.1, including real Chromium acceptance**

Contest-release status: **NOT YET READY FOR FINAL SUBMISSION**

Remaining gates are deterministic browser coverage of interactive REST execution, demo screenshots, final clean-checkout/repository review, and public repository availability. Contest submission and acceptance of contest/legal terms remain owner actions.
