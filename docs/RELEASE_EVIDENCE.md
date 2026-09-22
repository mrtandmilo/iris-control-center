# Release validation evidence

This record tracks the final contest release. Do not record passwords, tokens, cookies, authorization headers, registry credentials, or other secrets here.

## Environment

- Validation date (UTC): 2026-09-22
- Runtime-validated commit SHA: `fd1af7e2738c04b332239023bc088945bd74034b`
- IRIS Community release: 2026.1
- GitHub Actions runtime acceptance: **passed** (run 59)
- GitHub Actions static checks: **passed** (run 133)
- Real Chromium acceptance: **passed** as part of runtime acceptance run 59
- Browser evidence artifact: `browser-evidence-35682094739` (artifact `10675615184`, retained by GitHub Actions until 2026-10-06)
- Host tooling/OS details: not retained in repository evidence; reproduce during final clean-checkout validation

## Clean build and installation

- [x] Clean IRIS Community 2026.1 image build completed.
- [x] Container reached a healthy IRIS state.
- [x] Setup imported and compiled all four application classes without errors.
- [x] `/iris-control-center` was enabled and authenticated UI assets were delivered.
- [x] `/iris-control-center/api` was enabled and authenticated API readiness passed.

Evidence/notes: The first fully clean runtime acceptance was established on `b821bac`. Subsequent documentation, accessibility, security, contest-packaging and browser-acceptance hardening culminated in `fd1af7e`, whose runtime-acceptance and static-check workflows both completed successfully. Earlier misleading green runs were rejected because build output still contained an ObjectScript compilation error; those runs are not treated as release evidence.

## Automated runtime validation

- [x] `scripts/smoke-test.sh` completed successfully against the clean instance.
- [x] Health contract passed.
- [x] Native service-discovery contract passed.
- [x] OpenAPI validation/error-isolation checks passed.
- [x] GET request-proxy validation checks passed.
- [x] Traversal/security regression checks passed.
- [x] Unknown-service isolation passed.
- [x] Authenticated UI, JavaScript and CSS delivery passed.

Evidence/notes: The clean acceptance suite reaches all 10 runtime checks successfully on IRIS Community 2026.1. The latest validated repository head is `fd1af7e`.

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

Evidence/notes: `scripts/browser-acceptance.mjs` runs headless Chromium against the validated IRIS instance and uses a deterministic in-browser OpenAPI fixture for interaction paths that a clean IRIS install does not guarantee will be advertised. Runtime acceptance run 59 passed the complete harness on `fd1af7e`. The same run retained real-IRIS browser screenshots as a GitHub Actions artifact; mock-backed REST execution states are intentionally not presented as live IRIS evidence.

## Contest/demo evidence

The authoritative final screenshot set is the five-image checklist in `DEMO.md`.

- [x] Real-IRIS service catalogue browser evidence captured automatically.
- [x] Real-IRIS selected-service metadata browser evidence captured automatically.
- [ ] OpenAPI explorer final evidence image selected/captured from a real OpenAPI-advertising service. The automated artifact includes this view only when the clean IRIS instance advertises one.
- [ ] Successful safe GET final evidence image captured against a real service. Deterministic mock-backed browser acceptance proves the interaction but is deliberately not used as live demo evidence.
- [ ] Passing smoke-test evidence image captured for the final demo set.
- [ ] README installation steps reproduced from a fresh public checkout.
- [x] README/demo local links checked automatically by `scripts/check-markdown-links.mjs`; static checks run 133 passed on `fd1af7e`.
- [x] Automated repository guard checks committed content for credential/private-information patterns in CI.
- [ ] Final human review for private information completed before publication.
- [x] Known limitations reviewed for accuracy and documented explicitly in the README on `fd1af7e`.
- [ ] Repository made publicly accessible as required by the contest.

Evidence/notes: Runtime acceptance run 59 produced `browser-evidence-35682094739`, preserving genuine browser evidence from the clean IRIS Community instance. This advances the demo-evidence gate without presenting fixture-backed states as live IRIS screenshots. Static checks run 133 also validates local Markdown links across `README.md` and `docs/`. The repository is currently private, so public-repository contest compliance is not yet satisfied.

## Release decision

Runtime validation status: **PASSED on `fd1af7e` / IRIS Community 2026.1, including complete interactive Chromium acceptance**

Contest-release status: **NOT YET READY FOR FINAL SUBMISSION**

Remaining gates are completion of the five-image demo set, final clean-checkout/human privacy review, and public repository availability. Contest submission and acceptance of contest/legal terms remain owner actions.
