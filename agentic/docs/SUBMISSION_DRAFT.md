# Open Exchange listing draft — NOT SUBMITTED

**Proposed name:** IRIS Control Center — Agentic Incident Triage

**One-line pitch:** Explainable, safety-gated AI Hub decisions for IRIS interoperability failures, with an auditable human approval queue.

## Description

This project extends IRIS Control Center with a native IRIS interoperability Production that receives synthetic integration incidents, asks an IRIS AI Hub agent to classify the next action, validates the decision against deterministic operational policy, and records the result through a Business Operation. An authenticated browser dashboard presents three representative incidents and lets operators approve or reject the recommendations without performing automatic remediation.

The AI Hub agent proposes RETRY, REVIEW, or QUARANTINE. The policy prevents retries for authentication and data-integrity errors and prevents endless retries after two attempts. Malformed AI output or provider failures fall back to human review. The complete message flow is visible in IRIS interoperability traces.

## What is technically distinctive?

- A **native IRIS AI Hub agent inside an Ens.BusinessProcess**, not an external chatbot.
- Three IRIS interoperability host types: Business Service, Business Process, and Business Operation.
- Deterministic policy controls and human-in-the-loop approval records.
- Separate fixture and live modes, labelled clearly to avoid misleading AI claims.
- Authenticated, accessible browser dashboard; audit history stores no raw incident summaries.
- Isolated EAP build-154 Docker Compose target; the earlier prize-winning release remains intact.

## Judges' walkthrough (target 3 minutes)

1. Open the authenticated dashboard; identify fixture/live mode and safety boundary.
2. Submit HTTP 503; show a retry **recommendation**, not a retry execution.
3. Submit data-integrity failure; show forced quarantine review.
4. Submit a timeout after three retries; show blocked retry and human review.
5. Open audit history; approve or reject a recommendation and show the separate review record.
6. Show IRIS Production visual trace proving Business Service → Business Process → Business Operation.
7. In an authorised live session, show an actual AI Hub agent response and its `source=ai_hub` label.

## Judge criteria and evidence requirements

| Criterion | Implementation | Evidence still needed |
| --- | --- | --- |
| Complexity | Native agent + IRIS production + policy + audit + review | Runtime trace and compiled classes |
| Clarity | Build-154 quick start and synthetic sample cases | Clean-checkout install transcript |
| Developer experience | One-command Compose, REST, dashboard, test harness | Judge walkthrough |
| Applicability | Incident classification with fail-closed guardrails | Live agent case and failure test |
| Usability | Responsive dashboard, source labels, review buttons | Browser screenshots and keyboard test |

## Links and metadata

- Repository: https://github.com/mrtandmilo/iris-control-center
- Development branch: feature/agentic-interoperability-2026
- Installation guide: agentic/README.md
- Demo script: agentic/docs/DEMO_SCRIPT.md
- License: MIT
- Demo video: **not recorded**
- Hosted demo: **not deployed**
- Official contest registration/submission: **not performed**

**Do not paste this into Open Exchange until build 154 runtime acceptance has passed and the user has explicitly approved submission.**
