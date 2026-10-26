/// Deterministic, fail-closed policy is authoritative over any LLM response.
Class IRISControlCenter.Agentic.DecisionPolicy
{
ClassMethod Normalize(pIncident As IRISControlCenter.Agentic.IncidentRequest, pRaw As %DynamicObject) As %DynamicObject
{
    Set code = $ZConvert(pIncident.ErrorCode,"U")
    Set decision = "REVIEW"
    Set confidence = 0
    Set reason = "Human review required"
    Set source = "fallback"
    If $IsObject(pRaw) {
        Set decision = $ZConvert(pRaw.%Get("decision","REVIEW"),"U")
        Set confidence = +pRaw.%Get("confidence",0)
        Set reason = pRaw.%Get("reason","Human review required")
        Set source = pRaw.%Get("source","fallback")
    }
    If (decision'="RETRY")&&(decision'="REVIEW")&&(decision'="QUARANTINE") {
        Set decision = "REVIEW", confidence = 0, reason = "Invalid agent decision; human review required", source = "fallback"
    }
    If (confidence<0)!(confidence>1) Set confidence = 0
    If $Length(reason)>200 Set reason = $Extract(reason,1,200)
    If reason="" Set reason = "Human review required"
    If $Length(source)>30 Set source = "fallback"

    // Critical failures must never be recommended for retry.
    If (code="DATA_INTEGRITY")!(code="AUTH_FAILURE") {
        Set decision = "QUARANTINE", reason = "Safety policy: integrity/authentication failure requires isolation"
    }
    // Retry is an operator recommendation, not an automatic side effect.
    If decision="RETRY" {
        If ((code'="TIMEOUT")&&(code'="HTTP_503")&&(code'="CONNECTION_RESET"))!(pIncident.RetryCount'<2) {
            Set decision = "REVIEW", reason = "Safety policy: retry not allowed for this error or retry count"
        }
    }
    Set route = $Select(decision="RETRY":"RETRY_CANDIDATE",decision="QUARANTINE":"QUARANTINE_REVIEW",1:"HUMAN_REVIEW")
    Set result = {"decision":(decision),"route":(route),"reason":(reason),"confidence":(confidence),"source":(source)}
    Do result.%Set("approval_required",1,"boolean")
    Quit result
}
}
