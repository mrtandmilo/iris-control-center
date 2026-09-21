# Release validation evidence

This record tracks the final contest release. Do not record passwords, tokens, cookies, authorization headers, registry credentials, or other secrets here.

## Environment

- Validation date (UTC): 2026-09-21
- Runtime-validated commit SHA: `1f4bb1fe431af8387c59fd6903e369a7c87f9967`
- IRIS Community release: 2026.1
- GitHub Actions runtime acceptance: **passed** (run 49)
- GitHub Actions static checks: **passed** (run 123)
- Real Chromium acceptance: **passed** as part of runtime acceptance run 49
- Host tooling/OS details: not retained in repository evidence; reproduce during final clean-checkout validation

## Clean build and installation

- [x] Clean IRIS Community 2026.1 image build completed.
- [x] Container reached a healthy IRIS state.
- [x] Setup imported and compiled all four application classes without errors.
- [x] `/iris-control-center` was enabled and authenticated UI assets were delivered.
- [x] `/iris-control-center/api` was enabled and authenticated API readiness passed.

Evidence/notes: The first fully clean runtime acceptance was established on `b821bac`. Subsequent documentation, accessibility, security, contest-packaging and browser-acceptance hardening culminated in `1f4bb1f`, whose runtime-acceptance and static-check workflows both completed successfully. Earlier misleading green runs were rejected because build output still contained an ObjectScript compilation error; those runs are not treated as release evidence.

## Automated runtime validation

- [x] `scripts/smoke-test.sh` completed successfully against the clean instance.
- [x] Health contract passed.
- [x] Native service-discovery contract passed.
- [x] OpenAPI validation/error-isolation checks passed.
- [x] GET request-proxy validation checks passed.
- [x] Traversal/security regression checks passed.
- [x] Unknown-service isolation passed.
- [x] Authenticated UI, JavaScript and CSS delivery passed.

Evidence/notes: The clean acceptance suite reaches all 10 runtime checks successfully on IRIS Community 2026.1. The latest validated repository head is `1f4bb1f`.

## Browser acceptance

- [x] Service catalogue loads and count matches the API response.
- [x] Catalogue filtering works, including the empty-result state.
- [x] Service metadata renders correctly.
- [x] Keyboard selection and selected-service `aria-pressed` state verified in real Chromium.
- [x] Refresh re-runs discovery without a page reload.
- [x] OpenAPI explorer reaches a terminal state when an OpenAPI-advertising service is available; endpoint filtering is exercised in that case.
- [x] GET path/query parameter composition and URL encoding verified end-to-end in the browser fixture.
- [x] Required path parameters block incomplete requests in the browser.
- [x] A deterministic read-only GET executes successfully from the browser explorer through the request proxy.
- [x] Response status, timing, headers and formatted JSON body render after browser execution.
- [x] Mutating POST operations remain inspect-only in the browser.

Evidence/notes: `scripts/browser-acceptance.mjs` runs headless Chromium against the validated IRIS instance and uses a deterministic in-browser OpenAPI fixture for interaction paths that a clean IRIS install does not guarantee will be advertised. Runtime acceptance run 49 passed the complete harness on `1f4bb1f`.

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

Runtime validation status: **PASSED on `1f4bb1f` / IRIS Community 2026.1, including complete interactive Chromium acceptance**

Contest-release status: **NOT YET READY FOR FINAL SUBMISSION**

Remaining gates are demo screenshots, final clean-checkout/repository review, and public repository availability. Contest submission and acceptance of contest/legal terms remain owner actions.
