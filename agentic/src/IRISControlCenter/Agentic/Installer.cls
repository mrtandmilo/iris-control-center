/// Password-authenticated API, separate from the original Control Center app.
Class IRISControlCenter.Agentic.Installer
{
ClassMethod Setup() As %Status
{
    Set namespace = $Namespace
    Set sc = $$$OK
    Try {
        ZN "%SYS"
        Set app = ##class(Security.Applications).%OpenId("/iris-control-center/agentic")
        If '$IsObject(app) {
            Set app = ##class(Security.Applications).%New()
            Set app.Name = "/iris-control-center/agentic"
        }
        Set app.Description = "IRIS Control Center Agentic Edition"
        Set app.NameSpace = namespace
        Set app.Enabled = 1
        Set app.DispatchClass = "IRISControlCenter.Agentic.REST"
        Set app.MatchRoles = ""
        Set app.AutheEnabled = 32
        Set sc = app.%Save()
    } Catch ex {
        Set sc = ex.AsStatus()
    }
    ZN namespace
    Quit sc
}
}
