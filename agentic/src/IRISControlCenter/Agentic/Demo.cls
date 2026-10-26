/// Reproducible synthetic demonstration using the Production message pipeline.
Class IRISControlCenter.Agentic.Demo
{
ClassMethod Run() As %Status
{
    If '##class(Ens.Director).IsProductionRunning("IRISControlCenter.Agentic.Production") {
        Set sc = ##class(Ens.Director).StartProduction("IRISControlCenter.Agentic.Production")
        If $$$ISERR(sc) Quit sc
    }
    Set sc = ##class(Ens.Director).CreateBusinessService("IncidentIngress",.service)
    If $$$ISERR(sc) Quit sc
    Set scenarios = [
        {"id":"DEMO-001","system":"Orders","code":"HTTP_503","summary":"Temporary upstream outage","retries":0},
        {"id":"DEMO-002","system":"Quality","code":"DATA_INTEGRITY","summary":"Conflicting part measurement metadata","retries":0},
        {"id":"DEMO-003","system":"Billing","code":"TIMEOUT","summary":"Repeated timeout after retries","retries":3}
    ]
    For i=0:1:(scenarios.%Size()-1) {
        Set sample = scenarios.%Get(i)
        Set req = ##class(IRISControlCenter.Agentic.IncidentRequest).%New()
        Set req.IncidentId = sample.id
        Set req.SourceSystem = sample.system
        Set req.ErrorCode = sample.code
        Set req.Summary = sample.summary
        Set req.RetryCount = sample.retries
        Set sc = service.ProcessInput(req,.response)
        If $$$ISERR(sc) Quit sc
        Write req.IncidentId," -> ",response.Decision," / ",response.Route," [",response.Source,"] audit=",response.AuditId,!
    }
    Quit $$$OK
}
}
