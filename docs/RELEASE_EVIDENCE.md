# Release validation evidence

This record tracks the final contest release. Do not record passwords, tokens, cookies, authorization headers, registry credentials, or other secrets here.

## Environment

- Validation date (UTC): 2026-09-22
- Runtime-validated commit SHA: `65758bc44cf65709ebdf0165edb8b2d0c686c71e`
- IRIS Community release: 2026.1
- GitHub Actions runtime acceptance: **passed** (run 63)
- GitHub Actions static checks: **passed** (run 137)
- Real Chromium acceptance: **passed** as part of runtime acceptance run 63
- Browser evidence artifact: `browser-evidence-35697848091` (artifact `10680982415`, retained by GitHub Actions until 2026-10-06)
- Release-validation transcript artifact: `release-validation-35697848091` (artifact `10681211908`, retained by GitHub Actions until 2026-10-06)
- Host tooling/OS details: not retained in repository evidence; reproduce during final clean-checkout validation

## Clean build and installation

- [x] Clean IRIS Community 2026.1 image build completed.
- [x] Container reached a healthy IRIS state.
- [x] Setup imported and compiled all four application classes without errors.
- [x] `/iris-control-center` was enabled and authenticated UI assets were delivered.
- [x] `/iris-control-center/api` was enabled and authenticated API readiness passed.

Evidence/notes: The first fully clean runtime acceptance was established on `b821bac`. Subsequent documentation, accessibility, security, contest-packaging, browser-acceptance and publication-safety hardening culminated in `65758bc`, whose runtime-acceptance and static-check workflows both completed successfully. Earlier misleading green runs were rejected because build output still contained an ObjectScript compilation error; those runs are not treated as release evidence.

## Automated runtime validation

- [x] `scripts/smoke-test.sh` completed successfully against the clean instance.
- [x] Health contract passed.
- [x] Native service-discovery contract passed.
- [x] OpenAPI validation/error-isolation checks passed.
- [x] GET request-proxy validation checks passed.
- [x] Traversal/security regression checks passed.
- [x] Unknown-service isolation passed.
- [x] Authenticated UI, JavaScript and CSS delivery passed.

Evidence/notes: The clean acceptance suite reaches all 10 runtime checks successfully on IRIS Community 2026.1. Runtime acceptance run 63 also retains the complete clean release-validation transcript as a dedicated artifact, preserving the validator's real exit status without retaining the run-specific IRIS password.

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

Evidence/notes: `scripts/browser-acceptance.mjs` runs headless Chromium against the validated IRIS instance and uses a deterministic in-browser OpenAPI fixture for interaction paths that a clean IRIS install does not guarantee will be advertised. Runtime acceptance run 63 passed the complete harness on `65758bc`. The same run retained real-IRIS browser screenshots as a GitHub Actions artifact; mock-backed REST execution states are intentionally not presented as live IRIS evidence.

## Contest/demo evidence

The authoritative final screenshot set is the five-image checklist in `DEMO.md`.

- [x] Real-IRIS service catalogue browser evidence captured automatically.
- [x] Real-IRIS selected-service metadata browser evidence captured automatically.
- [ ] OpenAPI explorer final evidence image selected/captured from a real OpenAPI-advertising service. The automated artifact includes this view only when the clean IRIS instance advertises one.
- [ ] Successful safe GET final evidence image captured against a real service. Deterministic mock-backed browser acceptance proves the interaction but is deliberately not used as live demo evidence.
- [x] Passing smoke-test evidence retained as the complete `release-validation-35697848091` transcript artifact from runtime acceptance run 63; convert/select the final presentation image during demo packaging.
- [ ] README installation steps reproduced from a fresh public checkout.
- [x] README/demo local links checked automatically by `scripts/check-markdown-links.mjs`; static checks run 137 passed on `65758bc`.
- [x] Automated repository guard checks committed content for credential/private-information patterns in CI. Static checks run 137 validates the hardened guard, including common credential/key filenames and embedded private-key material.
- [ ] Final human review for private information completed before publication.
- [x] Known limitations reviewed for accuracy and documented explicitly in the README on `fd1af7e`.
- [ ] Repository made publicly accessible as required by the contest.

Evidence/notes: Runtime acceptance run 63 produced both `browser-evidence-35697848091` and `release-validation-35697848091`. The former preserves genuine browser evidence from the clean IRIS Community instance; the latter preserves the complete successful clean release-validation transcript and its genuine exit status. Fixture-backed states remain excluded from live-IRIS demo claims. The repository is currently private, so public-repository contest compliance is not yet satisfied.

## Release decision

Runtime validation status: **PASSED on `65758bc` / IRIS Community 2026.1, including complete interactive Chromium acceptance, retained clean validation transcript and hardened publication-safety checks**

Contest-release status: **NOT YET READY FOR FINAL SUBMISSION**

Remaining gates are real OpenAPI/safe-GET demo evidence, final presentation packaging of the retained smoke-test evidence, final clean-checkout/human privacy review, and public repository availability. Contest submission and acceptance of contest/legal terms remain owner actions.
