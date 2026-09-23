# Release validation evidence

This record tracks the final contest release. Do not record passwords, tokens, cookies, authorization headers, registry credentials, or other secrets here.

## Environment

- Validation date (UTC): 2026-09-22
- Runtime-validated commit SHA: `e2b4b926a4f99308c449be3b1aa5c32a8c7912f5`
- IRIS Community release: 2026.1
- GitHub Actions runtime acceptance: **passed** (run 71)
- GitHub Actions static checks: **passed** (run 145)
- Real Chromium acceptance: **passed** as part of runtime acceptance run 71
- Browser evidence artifact: `browser-evidence-35731282996` (artifact `10698386131`, retained by GitHub Actions until 2026-10-06)
- Release-validation transcript artifact: `release-validation-35731282996` (artifact `10698204624`, retained by GitHub Actions until 2026-10-06)
- Host tooling/OS details: not retained in repository evidence; reproduce during final clean-checkout validation

## Clean build and installation

- [x] Clean IRIS Community 2026.1 image build completed.
- [x] Container reached a healthy IRIS state.
- [x] Setup imported and compiled all four application classes without errors.
- [x] `/iris-control-center` was enabled and authenticated UI assets were delivered.
- [x] `/iris-control-center/api` was enabled and authenticated API readiness passed.

Evidence/notes: The first fully clean runtime acceptance was established on `b821bac`. Subsequent documentation, accessibility, security, contest-packaging, browser-acceptance, publication-safety, first-party OpenAPI, genuine safe-GET evidence and deterministic demo-packaging hardening culminated in `e2b4b92`, whose runtime-acceptance and static-check workflows both completed successfully. Earlier misleading green runs were rejected because build output still contained an ObjectScript compilation error; those runs are not treated as release evidence.

## Automated runtime validation

- [x] `scripts/smoke-test.sh` completed successfully against the clean instance.
- [x] Health contract passed.
- [x] Native service-discovery contract passed.
- [x] OpenAPI validation/error-isolation checks passed.
- [x] GET request-proxy validation checks passed.
- [x] Traversal/security regression checks passed.
- [x] Unknown-service isolation passed.
- [x] Authenticated UI, JavaScript and CSS delivery passed.

Evidence/notes: The clean acceptance suite reaches all 10 runtime checks successfully on IRIS Community 2026.1. Runtime acceptance run 71 also retains the complete clean release-validation transcript as a dedicated artifact, preserving the validator's real exit status without retaining the run-specific IRIS password.

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

Evidence/notes: `scripts/browser-acceptance.mjs` runs headless Chromium against the validated IRIS instance. The Control Center advertises its own first-party OpenAPI 3.0 contract, making real explorer rendering deterministic on every clean installation. Runtime acceptance run 71 drives the discovered first-party `/health` GET through the production request proxy and captures the genuine result. The interaction harness still uses a deterministic in-browser fixture only for deeper parameter-encoding and mutation-safety cases; fixture-backed states are deliberately not captured as release screenshots.

## Contest/demo evidence

The authoritative final screenshot set is the five-image checklist in `DEMO.md`.

- [x] Real-IRIS service catalogue browser evidence captured automatically.
- [x] Real-IRIS selected-service metadata browser evidence captured automatically.
- [x] OpenAPI explorer final evidence captured from the real first-party Control Center API as `03-real-openapi-explorer.png` in the browser evidence artifact.
- [x] Successful safe GET final evidence captured against the real first-party `/health` operation as `04-real-safe-get.png` in `browser-evidence-35731282996`.
- [x] Passing smoke-test evidence retained as the complete `release-validation-35731282996` transcript artifact from runtime acceptance run 71; convert/select the final presentation image during demo packaging.
- [ ] README installation steps reproduced from a fresh public checkout.
- [x] README/demo local links checked automatically by `scripts/check-markdown-links.mjs`; static checks run 145 passed on `e2b4b92`.
- [x] Automated repository guard checks committed content for credential/private-information patterns in CI. Static checks run 145 validates the hardened guard, including common credential/key filenames and embedded private-key material.
- [x] Final human review of the retained release screenshots found no visible credentials, account identity, cookies, authorization data, or private infrastructure information before publication.
- [x] Known limitations reviewed for accuracy and documented explicitly in the README on `fd1af7e`.
- [x] Repository publicly accessible; anonymous clone verified on 2026-09-23 at `ef591f245f56cd1595dcae2d46b3fb59ed086f3d`.

Evidence/notes: Runtime acceptance run 71 produced the final retained `browser-evidence-35731282996` and `release-validation-35731282996` artifacts. The browser artifact contains the complete genuine-IRIS browser story: catalogue, selected-service metadata, first-party OpenAPI exploration and successful first-party safe GET execution. The release-validation artifact preserves the complete successful clean validation transcript and its genuine exit status. The first browser attempt on run 71 timed out waiting for the real `/health` result while the IRIS stack remained healthy; a retry completed successfully and produced the final evidence artifact above. Fixture-backed states remain excluded from live-IRIS demo claims. The repository is now public. The fresh public-checkout installation gate remains open until the new rehearsal has passed.

## Release decision

Runtime validation status: **PASSED on `e2b4b92` / IRIS Community 2026.1, including first-party OpenAPI exploration, genuine safe-GET browser execution, complete interactive Chromium acceptance, retained clean validation transcript, deterministic demo packaging and hardened publication-safety checks**

Contest-release status: **NOT YET READY FOR FINAL SUBMISSION**

The remaining technical gate is the fresh public-checkout installation rehearsal. Contest submission and acceptance of contest/legal terms remain owner actions.

## Public HEAD verification — 2026-09-23

Anonymous clone of public HEAD `ef591f245f56cd1595dcae2d46b3fb59ed086f3d` succeeded. Local JavaScript syntax, UI integrity, ObjectScript contracts, shell syntax and documentation links passed. No application source changes were needed.

The same HEAD passed [runtime run 72](https://github.com/mrtandmilo/iris-control-center/actions/runs/35744656238) and [static run 146](https://github.com/mrtandmilo/iris-control-center/actions/runs/35744656301). Runtime logs confirm clean compilation, smoke acceptance and Chromium acceptance with 12 discovered services. The current HEAD artifacts supersede the historical run 71 package above: browser artifact `10702911443` and validation transcript artifact `10702921382`, retained until 2026-10-06. Their screenshots still require review before publication.

The local verification host has no Docker installation, so no new local runtime success is claimed. The runtime workflow now performs an anonymous checkout and README installation/smoke rehearsal before the clean release gate. It also generates and masks a random disposable password before exporting it; the previous job-wide value appeared in GitHub step environment logs. Historical disposable instances were torn down after their runs.
