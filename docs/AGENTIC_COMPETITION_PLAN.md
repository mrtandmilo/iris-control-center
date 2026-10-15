# Agentic Edition — competition quality gates

This work is isolated from the previously validated IRIS Control Center release.

## Lessons from previous contest
- Demonstrate user value and a real operational scenario in the first 30 seconds.
- Produce a narrated demo, not a silent screen recording.
- Map each judging criterion to a feature, test and screenshot/video timestamp.
- Make installation and the judge's three-minute walkthrough reproducible.
- Preserve exact commit SHAs, CI evidence and regression results.
- Review competitors and judge feedback before submission; distinguish verified facts from hypotheses.
- Never claim runtime validation from static checks alone.

## Gates
1. **Rules and architecture:** Confirm AI Hub requirements, existing-project eligibility, judging rubric and deadlines; document a real interoperability decision workflow.
2. **Baseline:** Capture current main revision and passing CI; keep main unchanged.
3. **Functional proof:** Agent receives an interoperability event, makes a traceable decision, and routes it with bounded permissions and human approval for high-risk actions.
4. **Reliability:** Clean IRIS install; tests for success, failure, timeout, invalid agent output, fallback, authentication and audit trail.
5. **Judge experience:** Narrated 90–180 second demo, quick-start guide, realistic sample data and screenshots. Check every link.
6. **Submission:** Verify eligibility, required listing and deadline; retain submitted artifact and evidence.

No agent implementation or runtime validation is claimed by this document.
