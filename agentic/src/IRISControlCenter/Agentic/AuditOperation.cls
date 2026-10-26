/// Business Operation: append-only incident decision ledger, no remediation.
Class IRISControlCenter.Agentic.AuditOperation Extends Ens.BusinessOperation
{
Parameter ADAPTER = "Ens.OutboundAdapter";
Parameter INVOCATION = "Queue";

Method Record(pRequest As IRISControlCenter.Agentic.AuditRequest, Output pResponse As IRISControlCenter.Agentic.AuditAck) As %Status
{
    Set id = $Increment(^ICCAgenticAuditSeq)
    Set entry = {
        "audit_id":(id),
        "recorded_at":($ZDATETIME($HOROLOG,3)),
        "incident_id":(pRequest.IncidentId),
        "decision":(pRequest.Decision),
        "route":(pRequest.Route),
        "reason":(pRequest.Reason),
        "confidence":(pRequest.Confidence),
        "source":(pRequest.Source)
    }
    Set ^ICCAgenticAudit(id) = entry.%ToJSON()
    Set pResponse = ##class(IRISControlCenter.Agentic.AuditAck).%New()
    Set pResponse.AuditId = id
    Quit $$$OK
}

XData MessageMap
{
<MapItems>
  <MapItem MessageType="IRISControlCenter.Agentic.AuditRequest">
    <Method>Record</Method>
  </MapItem>
</MapItems>
}
}
