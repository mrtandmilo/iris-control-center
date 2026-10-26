/// Business Service entry point. REST uses CreateBusinessService/ProcessInput.
Class IRISControlCenter.Agentic.IncidentService Extends Ens.BusinessService
{
Parameter ADAPTER = "";

Method OnProcessInput(pRequest As IRISControlCenter.Agentic.IncidentRequest, Output pResponse As IRISControlCenter.Agentic.IncidentResponse) As %Status
{
    Quit ..SendRequestSync("IncidentTriage",pRequest,.pResponse)
}
}
