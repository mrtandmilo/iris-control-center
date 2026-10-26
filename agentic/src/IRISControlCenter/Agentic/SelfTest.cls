/// Fixture-mode end-to-end acceptance test. Must be run on real build 154.
Class IRISControlCenter.Agentic.SelfTest
{
ClassMethod Run() As %Status
{
    If $ZConvert($System.Util.GetEnviron("AGENTIC_MODE"),"L")'="fixture" {
        Quit $$$ERROR($$$GeneralError,"Set AGENTIC_MODE=fixture before running this test")
    }
    If '##class(Ens.Director).IsProductionRunning("IRISControlCenter.Agentic.Production") {
        Set sc = ##class(Ens.Director).StartProduction("IRISControlCenter.Agentic.Production")
        If $$$ISERR(sc) Quit sc
    }
    Set sc = ##class(Ens.Director).CreateBusinessService("IncidentIngress",.service)
    If $$$ISERR(sc) Quit sc

    Set cases = [
        {"id":"TEST-RETRY","code":"HTTP_503","retries":0,"decision":"RETRY","route":"RETRY_CANDIDATE"},
        {"id":"TEST-INTEGRITY","code":"DATA_INTEGRITY","retries":0,"decision":"QUARANTINE","route":"QUARANTINE_REVIEW"},
        {"id":"TEST-LIMIT","code":"TIMEOUT","retries":3,"decision":"REVIEW","route":"HUMAN_REVIEW"},
        {"id":"TEST-UNKNOWN","code":"UNKNOWN","retries":0,"decision":"REVIEW","route":"HUMAN_REVIEW"}
    ]
    Set before = +$Get(^ICCAgenticAuditSeq)
    For i=0:1:(cases.%Size()-1) {
        Set c = cases.%Get(i)
        Set req = ##class(IRISControlCenter.Agentic.IncidentRequest).%New()
        Set req.IncidentId = c.id
        Set req.SourceSystem = "Fixture"
        Set req.ErrorCode = c.code
        Set req.Summary = "Synthetic acceptance test"
        Set req.RetryCount = c.retries
        Set sc = service.ProcessInput(req,.answer)
        If $$$ISERR(sc) Quit sc
        If (answer.Decision'=c.decision)!(answer.Route'=c.route) {
            Quit $$$ERROR($$$GeneralError,"Incorrect decision for "_c.id)
        }
        If (answer.ApprovalRequired'=1)!(answer.AuditId'>0) {
            Quit $$$ERROR($$$GeneralError,"Missing approval boundary or audit for "_c.id)
        }
        If answer.Source'="fixture" Quit $$$ERROR($$$GeneralError,"Unexpected agent source for "_c.id)
        Write "PASS ",c.id," ",answer.Decision," audit=",answer.AuditId,!
    }
    If (+$Get(^ICCAgenticAuditSeq)-before)'=cases.%Size() {
        Quit $$$ERROR($$$GeneralError,"Audit count did not increase by expected amount")
    }
    Write "PASS: ",cases.%Size()," real Production fixture scenarios and audit records",!
    Quit $$$OK
}
}
