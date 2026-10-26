/// Persistable decision passed through the IRIS Production.
Class IRISControlCenter.Agentic.IncidentResponse Extends Ens.Response
{
Property IncidentId As %String(MAXLEN = 80);
Property Decision As %String(MAXLEN = 20);
Property Route As %String(MAXLEN = 40);
Property Reason As %String(MAXLEN = 512);
Property Confidence As %Double;
Property Source As %String(MAXLEN = 30);
Property ApprovalRequired As %Boolean [ InitialExpression = 1 ];
Property AuditId As %Integer;
}
