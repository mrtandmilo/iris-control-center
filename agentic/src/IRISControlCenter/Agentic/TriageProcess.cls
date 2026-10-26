/// Real interoperability Business Process: AI Hub decision -> guardrail -> BO.
Class IRISControlCenter.Agentic.TriageProcess Extends Ens.BusinessProcess [ ClassType = persistent ]
{
Method OnRequest(pRequest As IRISControlCenter.Agentic.IncidentRequest, Output pResponse As IRISControlCenter.Agentic.IncidentResponse) As %Status
{
    Set pResponse = ##class(IRISControlCenter.Agentic.IncidentResponse).%New()
    Set pResponse.IncidentId = pRequest.IncidentId
    Set raw = ##class(IRISControlCenter.Agentic.DecisionAgent).Assess(pRequest)
    Set safe = ##class(IRISControlCenter.Agentic.DecisionPolicy).Normalize(pRequest,raw)
    Set pResponse.Decision = safe.decision
    Set pResponse.Route = safe.route
    Set pResponse.Reason = safe.reason
    Set pResponse.Confidence = safe.confidence
    Set pResponse.Source = safe.source
    Set pResponse.ApprovalRequired = 1

    // No side effects other than the audit ledger; NEVER retry or quarantine here.
    Set sc = ..SendRequestSync("IncidentLedger",pResponse,.ledgerResponse)
    If $$$ISERR(sc) Quit sc
    If '$IsObject(ledgerResponse) Quit $$$ERROR($$$GeneralError,"Ledger did not return a response")
    Set pResponse.AuditId = ledgerResponse.AuditId
    Quit $$$OK
}

Method OnResponse(pRequest As Ens.Request, pResponse As Ens.Response, pCallRequest As Ens.Request, pCallResponse As Ens.Response, pCompletionKey As %String) As %Status
{
    Quit $$$OK
}
}
