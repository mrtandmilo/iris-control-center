# Release validation evidence

Use this record for the final contest release. Do not mark an item complete until it has been observed on a clean IRIS Community runtime. Do not record passwords, tokens, cookies, authorization headers, registry credentials, or other secrets here.

## Environment

- Validation date (UTC): _pending_
- Git commit SHA: _pending_
- IRIS Community image tag: _pending_
- Docker/Compose version: _pending_
- Host OS/architecture: _pending_

## Clean build and installation

- [ ] `docker compose build --no-cache` succeeds with the pinned IRIS image.
- [ ] `docker compose up` reaches a healthy IRIS state.
- [ ] Setup imports and compiles the application classes without errors.
- [ ] `/iris-control-center` is enabled.
- [ ] `/iris-control-center/api` is enabled.

Evidence/notes: _pending_

## Automated runtime validation

- [ ] `scripts/smoke-test.sh` completes successfully against the clean instance.
- [ ] Health contract passes.
- [ ] Service discovery contract passes.
- [ ] OpenAPI error isolation checks pass.
- [ ] Request-proxy validation checks pass.
- [ ] Traversal/security regression checks pass.

Evidence/notes: _pending_

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

Evidence/notes: _pending_

## Contest/demo evidence

- [ ] Service catalogue screenshot captured.
- [ ] OpenAPI explorer screenshot captured.
- [ ] Successful safe GET execution screenshot captured.
- [ ] README installation steps reproduced from a clean checkout.
- [ ] README/demo links checked.
- [ ] Repository checked for committed secrets and private information.
- [ ] Known limitations reviewed for accuracy.

Evidence/notes: _pending_

## Release decision

Runtime validation status: **PENDING**

The project must not be described as fully runtime-validated or ready for final contest submission until every required release-gate item above passes. Contest submission and acceptance of contest/legal terms remain owner actions.