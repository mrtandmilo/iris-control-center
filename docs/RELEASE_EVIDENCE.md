# Release validation evidence

## Validated public release candidate — 2026-09-23

- Original public main HEAD: `ef591f245f56cd1595dcae2d46b3fb59ed086f3d`; anonymous clone succeeded without Git credentials.
- Corrected source revision: `3b3edee6616185b8364ea31fce77e7273c1b6c30` in [PR #1](https://github.com/mrtandmilo/iris-control-center/pull/1).
- Exact checked-out and runtime-tested PR merge revision: `7b18318d84ea8d8f1088fdc5f55e3e9fe2302d61`.
- [Runtime acceptance run 75](https://github.com/mrtandmilo/iris-control-center/actions/runs/35834262463): **PASSED**.
- [Static checks](https://github.com/mrtandmilo/iris-control-center/actions/runs/35834262381): **PASSED**.
- Runtime: IRIS Community 2026.1 on a GitHub-hosted Ubuntu runner.
- Image: `intersystems/iris-community:2026.1@sha256:c57b65b2b454494091e7b3e49f6a53b3335f40adf475bcfcee0866083f35a7c2`.
- Resolved image ID: `sha256:cea94d88bfa91557c5fabba5221e19bbdd4e87c5f8ecc9e10e990789df4e8d64`.

The local verification Mac has no Docker installation. Runtime execution was therefore performed in CI, not claimed as a local run. The workflow explicitly clones the public repository anonymously and checks out the exact tested revision before installation.

## Installation and tests

- [x] Public repository access and MIT license verified.
- [x] Fresh anonymous checkout, README Compose build/start and authenticated smoke suite passed.
- [x] Disposable stack and data volume removed before a separate no-cache release build.
- [x] All four ObjectScript classes compiled; container became healthy.
- [x] All ten smoke checks passed, including authentication, assets, health, native discovery, input validation, traversal protection and unknown-service isolation.
- [x] Chromium catalogue count (12 services), filtering, keyboard selection, metadata and refresh passed.
- [x] Genuine first-party OpenAPI and `/health` GET through the production proxy passed.
- [x] Response rendering, parameter encoding, required parameters and inspect-only mutation controls passed. Deeper parameter cases use a browser fixture; release screenshots do not.
- [x] UTF-8 HTML placeholder and delivered JavaScript text passed browser assertions.
- [x] JavaScript syntax, shell syntax, UI/ObjectScript contracts, local Markdown links, fail-fast guards, Compose configuration and tracked-file credential guards passed.

## Retained evidence

Use all files from runtime run 75 together:

- [Browser evidence](https://github.com/mrtandmilo/iris-control-center/actions/runs/35834262463/artifacts/10739075108): `01-real-catalogue.png`, `02-real-selected-service.png`, `03-real-openapi-explorer.png`, `04-real-safe-get.png`.
- [Validation transcripts](https://github.com/mrtandmilo/iris-control-center/actions/runs/35834262463/artifacts/10737699543): `public-install-validation.log` and `release-validation.log`.
- Browser ZIP SHA-256: `bee843e38121304fc847332a93d1eb5fdb7ea20a7bf236b869640fa023492cbe`.
- Transcript ZIP SHA-256: `75eaa541a5bacf4f3210c02604aef422068bfcef19aabc07ad22bf2c7c834e51`.

Both archives were downloaded and their hashes verified. All four screenshots were visually inspected: no visible credentials, account identity, cookies, authorization data or private infrastructure details were found. The selected-service image captures metadata while its API definition is loading; the separate explorer and GET images show completed real operations. Both unmodified transcripts were reviewed and retained with the screenshots. GitHub's 14-day retention expires on 2026-10-07; preserve the package before then.

## Justified corrections

Public verification added an anonymous installation rehearsal and replaced a job-wide predictable disposable credential with a random credential masked before export. Historical disposable runtimes were torn down. Documentation now references the correct evidence and does not claim the smoke suite has a password default.

Visual review also found corrupted UTF-8 punctuation in HTML. The UI now explicitly decodes UTF-8 files and sets the response character set consistently for HTML, JavaScript, CSS and JSON. An intermediate revision failed browser acceptance and was not accepted as evidence; run 75 validates the complete correction.

## Release decision

**Technical validation passed for the exact candidate above.** Documentation-only updates to this record do not change the tested application. Subsequent source changes must pass the same gates.

No contest submission, terms acceptance, identity information or payment was performed. Final contest eligibility and approval belong to the organisers; owner approval is still required before submission or accepting any terms.
