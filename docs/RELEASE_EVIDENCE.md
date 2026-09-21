# Release validation evidence

This record tracks the final contest release. Do not record passwords, tokens, cookies, authorization headers, registry credentials, or other secrets here.

## Environment

- Validation date (UTC): 2026-09-21
- Runtime-validated commit SHA: `b821bac13be54ceac491978d9633c692d57e9aac`
- Current documentation descendants: `0b9c883`, `10be27e` (documentation-only changes after the validated runtime commit)
- IRIS Community release: 2026.1
- Host tooling/OS details: not retained in repository evidence; reproduce during final clean-checkout validation

## Clean build and installation

- [x] Clean IRIS Community 2026.1 image build completed.
- [x] Container reached a healthy IRIS state.
- [x] Setup imported and compiled all four application classes without errors.
- [x] `/iris-control-center` was enabled and authenticated UI assets were delivered.
- [x] `/iris-control-center/api` was enabled and authenticated API readiness passed.

Evidence/notes: Clean runtime acceptance completed on `b821bac`. Earlier misleading green runs were rejected because build output still contained an ObjectScript compilation error; the recorded pass is the subsequent run after that compiler defect was fixed.

## Automated runtime validation

- [x] `scripts/smoke-test.sh` completed successfully against the clean instance.
- [x] Health contract passed.
- [x] Native service-discovery contract passed.
- [x] OpenAPI validation/error-isolation checks passed.
- [x] GET request-proxy validation checks passed.
- [x] Traversal/security regression checks passed.
- [x] Unknown-service isolation passed.
- [x] Authenticated UI, JavaScript and CSS delivery passed.

Evidence/notes: The clean acceptance suite reached all 10 runtime checks successfully on IRIS Community 2026.1.

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

Evidence/notes: Automated delivery and API behaviour are proven; visual/browser interaction remains a separate final acceptance gate and must not be inferred from HTTP smoke tests.

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

Runtime validation status: **PASSED on `b821bac` / IRIS Community 2026.1**

Contest-release status: **NOT YET READY FOR FINAL SUBMISSION**

Remaining gates are browser/demo evidence, final clean-checkout/repository review, and public repository availability. Contest submission and acceptance of contest/legal terms remain owner actions.