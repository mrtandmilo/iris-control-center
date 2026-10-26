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
        If $$ISERR(sc) $$ThrowStatus(sc)

        Set ui = ##class(Security.Applications).%OpenId("/iris-control-center/agentic-ui")
        If '$IsObject(ui) {
            Set ui = ##class(Security.Applications).%New()
            Set ui.Name = "/iris-control-center/agentic-ui"
        }
        Set ui.Description = "IRIS Control Center Agentic Judge Dashboard"
        Set ui.NameSpace = namespace
        Set ui.Enabled = 1
        Set ui.Path = "/home/irisowner/dev/agentic/web"
        Set ui.DispatchClass = "IRISControlCenter.Agentic.UI"
        Set ui.ServeFiles = 0
        Set ui.Recurse = 1
        Set ui.MatchRoles = ""
        Set ui.AutheEnabled = 32
        Set sc = ui.%Save()
    } Catch ex {
        Set sc = ex.AsStatus()
    }
    ZN namespace
    Quit sc
}
}
