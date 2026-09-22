# Release validation evidence

This record tracks the final contest release. Do not record passwords, tokens, cookies, authorization headers, registry credentials, or other secrets here.

## Environment

- Validation date (UTC): 2026-09-22
- Runtime-validated commit SHA: `4e58aefb02e95bb57192eea3f93df7a4fc131463`
- IRIS Community release: 2026.1
- GitHub Actions runtime acceptance: **passed** (run 69)
- GitHub Actions static checks: **passed** (run 143)
- Real Chromium acceptance: **passed** as part of runtime acceptance run 69
- Browser evidence artifact: `browser-evidence-35719631567` (artifact `10689724820`, retained by GitHub Actions until 2026-10-06)
- Release-validation transcript artifact: `release-validation-35719631567` (artifact `10689999747`, retained by GitHub Actions until 2026-10-06)
- Host tooling/OS details: not retained in repository evidence; reproduce during final clean-checkout validation

## Clean build and installation

- [x] Clean IRIS Community 2026.1 image build completed.
- [x] Container reached a healthy IRIS state.
- [x] Setup imported and compiled all four application classes without errors.
- [x] `/iris-control-center` was enabled and authenticated UI assets were delivered.
- [x] `/iris-control-center/api` was enabled and authenticated API readiness passed.

Evidence/notes: The first fully clean runtime acceptance was established on `b821bac`. Subsequent documentation, accessibility, security, contest-packaging, browser-acceptance, publication-safety, first-party OpenAPI and genuine safe-GET evidence hardening culminated in `4e58aef`, whose runtime-acceptance and static-check workflows both completed successfully. Earlier misleading green runs were rejected because build output still contained an ObjectScript compilation error; those runs are not treated as release evidence.

## Automated runtime validation

- [x] `scripts/smoke-test.sh` completed successfully against the clean instance.
- [x] Health contract passed.
- [x] Native service-discovery contract passed.
- [x] OpenAPI validation/error-isolation checks passed.
- [x] GET request-proxy validation checks passed.
- [x] Traversal/security regression checks passed.
- [x] Unknown-service isolation passed.
- [x] Authenticated UI, JavaScript and CSS delivery passed.

Evidence/notes: The clean acceptance suite reaches all 10 runtime checks successfully on IRIS Community 2026.1. Runtime acceptance run 69 also retains the complete clean release-validation transcript as a dedicated artifact, preserving the validator's real exit status without retaining the run-specific IRIS password.

## Browser acceptance

- [x] Service catalogue loads and count matches the API response.
- [x] Catalogue filtering works, including the empty-result state.
- [x] Service metadata renders correctly.
- [x] Keyboard selection and selected-service `aria-pressed` state verified in real Chromium.
- [x] Refresh re-runs discovery without a page reload.
- [x] OpenAPI explorer reaches a terminal state for the first-party Control Center API and endpoint filtering is exercised.
- [x] GET path/query parameter composition and URL encoding verified end-to-end in the browser fixture.
- [x] Required path parameters block incomplete requests in the browser.
- [x] A deterministic read-only GET executes successfully from the browser explorer through the request proxy.
- [x] Response status, timing, headers and formatted JSON body render after browser execution.
- [x] Mutating POST operations remain inspect-only in the browser.

Evidence/notes: `scripts/browser-acceptance.mjs` runs headless Chromium against the validated IRIS instance. The Control Center advertises its own first-party OpenAPI 3.0 contract, making real explorer rendering deterministic on every clean installation. Runtime acceptance run 69 additionally drives the discovered first-party `/health` GET through the production request proxy and captures the genuine result. The interaction harness still uses a deterministic in-browser fixture only for deeper parameter-encoding and mutation-safety cases; fixture-backed states are deliberately not captured as release screenshots.

## Contest/demo evidence

The authoritative final screenshot set is the five-image checklist in `DEMO.md`.

- [x] Real-IRIS service catalogue browser evidence captured automatically.
- [x] Real-IRIS selected-service metadata browser evidence captured automatically.
- [x] OpenAPI explorer final evidence captured from the real first-party Control Center API as `03-real-openapi-explorer.png` in the browser evidence artifact.
- [x] Successful safe GET final evidence captured against the real first-party `/health` operation as `04-real-safe-get.png` in `browser-evidence-35719631567`.
- [x] Passing smoke-test evidence retained as the complete `release-validation-35719631567` transcript artifact from runtime acceptance run 69; convert/select the final presentation image during demo packaging.
- [ ] README installation steps reproduced from a fresh public checkout.
- [x] README/demo local links checked automatically by `scripts/check-markdown-links.mjs`; static checks run 143 passed on `4e58aef`.
- [x] Automated repository guard checks committed content for credential/private-information patterns in CI. Static checks run 143 validates the hardened guard, including common credential/key filenames and embedded private-key material.
- [ ] Final human review for private information completed before publication.
- [x] Known limitations reviewed for accuracy and documented explicitly in the README on `fd1af7e`.
- [ ] Repository made publicly accessible as required by the contest.

Evidence/notes: Runtime acceptance run 69 produced both `browser-evidence-35719631567` and `release-validation-35719631567`. The browser artifact now contains the complete genuine-IRIS browser story: catalogue, selected-service metadata, first-party OpenAPI exploration and successful first-party safe GET execution. The release-validation artifact preserves the complete successful clean validation transcript and its genuine exit status. Fixture-backed states remain excluded from live-IRIS demo claims. The repository is currently private, so public-repository contest compliance is not yet satisfied.

## Release decision

Runtime validation status: **PASSED on `4e58aef` / IRIS Community 2026.1, including first-party OpenAPI exploration, genuine safe-GET browser execution, complete interactive Chromium acceptance, retained clean validation transcript and hardened publication-safety checks**

Contest-release status: **NOT YET READY FOR FINAL SUBMISSION**

Remaining gates are final presentation packaging of the retained evidence, final clean-checkout/human privacy review, and public repository availability. Contest submission and acceptance of contest/legal terms remain owner actions.
