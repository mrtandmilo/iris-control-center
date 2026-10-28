# Runtime validation plan (not yet executed)

Use only the InterSystems IRIS AI Hub Community EAP build **154**. Run from a clean checkout after loading the locally downloaded image.

1. Set a non-default `IRIS_PASSWORD`, set `AGENTIC_MODE=fixture`, and run `docker compose -f agentic/docker-compose.yml up --build -d`.
2. Confirm the container becomes healthy, the Production `IRISControlCenter.Agentic.Production` auto-starts, and all three Business Hosts are enabled.
3. Run `do ##class(IRISControlCenter.Agentic.SelfTest).Run()` in a USER namespace IRIS terminal. **Four PASS lines and the final audit-count PASS are required.**
4. Confirm the authenticated `/health`, `/incident`, and `/audit` endpoints work, while unauthenticated calls fail.
5. POST invalid JSON, a missing incident ID, overlong summary, and an invalid retry count; verify HTTP 400 and no ledger mutation.
6. Test an invalid AI JSON decision and a provider exception in live mode: expected `REVIEW`, `source=fallback`, and no remediation. Do not invoke a paid provider without separate spending approval.
7. Verify a transient error with retry count 2 or more cannot be recommended for retry. Verify `AUTH_FAILURE` and `DATA_INTEGRITY` always route to quarantine review.
8. Confirm no keys, summaries, or credentials appear in the audit ledger or exported demo logs.
9. Record commit SHA, image ID, terminal output, endpoint responses, and a narrated 90–180 second demo.

Static CI success does not satisfy any of these runtime gates. Do not claim contest readiness until steps 1–8 pass.

## Automated local HTTP acceptance (added 28 October)

After build-154 has compiled, the Production is healthy, and `AGENTIC_MODE=fixture` is confirmed, run:

```bash
IRIS_PASSWORD="<local-non-default-password>" node agentic/tests/runtime-http-check.mjs
```

This loopback-only harness tests unauthenticated denial, authenticated fixture health, invalid incident rejection without audit mutation, four Production-routed decisions, monotonic audit IDs, and one-time review persistence. It refuses live AI mode and remote hosts. It has passed a local JavaScript syntax check, **not an IRIS runtime execution**. Do not include secrets in test logs. Use the same commit and EAP image ID for evidence.
