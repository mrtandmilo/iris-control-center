# Narrated demonstration script — target 150 seconds

**Do not record until real build-154 runtime acceptance has passed.** This is a script, not evidence that a video exists.

**0:00–0:25 — The problem.** "An integration has failed. Should an operator retry, investigate, or quarantine it? Making the wrong decision can turn a temporary outage into a data-integrity incident. IRIS Control Center now places an AI Hub agent inside the interoperability workflow, with deterministic safety controls."

**0:25–0:45 — Architecture.** Show the IRIS Production diagram: IncidentIngress Business Service → IncidentTriage Business Process → IncidentLedger Business Operation. Explain that AI proposes, policy validates, and the operator approves.

**0:45–1:05 — Transient outage.** Click the HTTP 503 scenario. Show the proposed RETRY_CANDIDATE and its audit ID. Explain that no retry is executed automatically.

**1:05–1:25 — Safety override.** Click the DATA_INTEGRITY scenario. Show QUARANTINE_REVIEW and explain the non-negotiable policy guardrail.

**1:25–1:45 — Retry exhaustion.** Click the timeout-after-three-retries scenario. Show HUMAN_REVIEW, demonstrating that retry loops are blocked.

**1:45–2:05 — Human approval.** Refresh the audit timeline. Approve or reject one recommendation; show who reviewed it and that the original decision is retained unchanged.

**2:05–2:25 — Live AI Hub proof.** If authorised live inference has been tested, show `source=ai_hub` and the model-generated rationale, followed by the IRIS message trace. **If live mode has not been validated, do not present fixture mode as AI.**

**2:25–2:30 — Close.** "A traceable AI decision, a deterministic safety boundary, and an accountable human reviewer — all inside InterSystems IRIS."

## Capture checklist

- Record the exact Git commit SHA and the local build-154 image identifier.
- Use synthetic data; redact local credentials and provider keys.
- Include audible narration and captions.
- Capture an actual IRIS message trace rather than a diagram alone.
- Retain a separate clean-checkout installation transcript.
- Review the video once before publication.
