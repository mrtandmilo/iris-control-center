# Release validation evidence

This record tracks the final contest release. Do not record passwords, tokens, cookies, authorization headers, registry credentials, or other secrets here.

## Environment

- Validation date (UTC): 2026-09-21
- Runtime-validated commit SHA: `78715a01be99b32d6b3b4305f9620abad14c9f33`
- IRIS Community release: 2026.1
- GitHub Actions runtime acceptance: **passed** (run 38)
- GitHub Actions static checks: **passed** (run 112)
- Host tooling/OS details: not retained in repository evidence; reproduce during final clean-checkout validation

## Clean build and installation

- [x] Clean IRIS Community 2026.1 image build completed.
- [x] Container reached a healthy IRIS state.
- [x] Setup imported and compiled all four application classes without errors.
- [x] `/iris-control-center` was enabled and authenticated UI assets were delivered.
- [x] `/iris-control-center/api` was enabled and authenticated API readiness passed.

Evidence/notes: The first fully clean runtime acceptance was established on `b821bac`. Subsequent documentation, accessibility and security-release hardening culminated in `78715a0`, whose runtime-acceptance and static-check workflows both completed successfully. Earlier misleading green runs were rejected because build output still contained an ObjectScript compilation error; those runs are not treated as release evidence.

## Automated runtime validation

- [x] `scripts/smoke-test.sh` completed successfully against the clean instance.
- [x] Health contract passed.
- [x] Native service-discovery contract passed.
- [x] OpenAPI validation/error-isolation checks passed.
- [x] GET request-proxy validation checks passed.
- [x] Traversal/security regression checks passed.
- [x] Unknown-service isolation passed.
- [x] Authenticated UI, JavaScript and CSS delivery passed.

Evidence/notes: The clean acceptance suite reaches all 10 runtime checks successfully on IRIS Community 2026.1. The latest validated repository head is `78715a0`.

## Browser acceptance

- [ ] Service catalogue loads and count matches the API response.
- [ ] Catalogue filtering works.
- [ ] Service metadata renders correctly.
- [ ] OpenAPI operations render and filter correctly.
- [ ] GET path/query parameter composition works.
- [ ] Required path parameters block incomplete requests.
- [ ] A known read-only GET executes successfully.
- [ ] Response status, timing, headers and body render correctly.
- [ ] Mutating methods remain inspect-only.
- [ ] Refresh re-runs discovery without a page reload.
- [ ] Keyboard navigation/focus and service-selection state verified in a real browser.

Evidence/notes: Automated delivery, API behaviour and static accessibility contracts are proven; visual/browser interaction remains a separate final acceptance gate and must not be inferred from HTTP or source-level checks.

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

Runtime validation status: **PASSED on `78715a0` / IRIS Community 2026.1**

Contest-release status: **NOT YET READY FOR FINAL SUBMISSION**

Remaining gates are real-browser/demo evidence, final clean-checkout/repository review, and public repository availability. Contest submission and acceptance of contest/legal terms remain owner actions.
