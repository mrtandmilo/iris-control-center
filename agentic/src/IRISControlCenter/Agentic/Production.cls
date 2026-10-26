/// AI Hub incident-triage interoperability Production.
Class IRISControlCenter.Agentic.Production Extends Ens.Production
{
XData ProductionDefinition
{
<Production Name="IRISControlCenter.Agentic.Production" LogGeneralTraceEvents="true" TestingEnabled="true">
  <Description>Auditable agent-assisted incident triage; no automatic remediation</Description>
  <ActorPoolSize>2</ActorPoolSize>
  <Item Name="IncidentIngress" Category="" ClassName="IRISControlCenter.Agentic.IncidentService" PoolSize="1" Enabled="true" Foreground="false">
  </Item>
  <Item Name="IncidentTriage" Category="" ClassName="IRISControlCenter.Agentic.TriageProcess" PoolSize="1" Enabled="true" Foreground="false">
  </Item>
  <Item Name="IncidentLedger" Category="" ClassName="IRISControlCenter.Agentic.AuditOperation" PoolSize="1" Enabled="true" Foreground="false">
  </Item>
</Production>
}
}
