/// Synthetic interoperability incident; no credentials or patient data.
Class IRISControlCenter.Agentic.IncidentRequest Extends Ens.Request
{
Property IncidentId As %String(MAXLEN = 80);
Property SourceSystem As %String(MAXLEN = 80);
Property ErrorCode As %String(MAXLEN = 40);
Property Summary As %String(MAXLEN = 600);
Property RetryCount As %Integer [ InitialExpression = 0 ];
}
