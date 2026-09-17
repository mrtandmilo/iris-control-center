Class IRISControlCenter.Installer
{

ClassMethod Setup() As %Status
{
    Set sc = $$$OK
    Try {
        // Static browser application.
        Set ui = ##class(Security.Applications).%OpenId("/iris-control-center")
        If '$IsObject(ui) {
            Set ui = ##class(Security.Applications).%New()
            Set ui.Name = "/iris-control-center"
        }
        Set ui.Description = "IRIS Control Center"
        Set ui.Namespace = $Namespace
        Set ui.Enabled = 1
        Set ui.Path = "/home/irisowner/dev/web"
        Set ui.ServeFiles = 1
        Set ui.Recurse = 1
        Set ui.AutheEnabled = 64
        Set sc = ui.%Save()
        Quit:$$$ISERR(sc) sc

        // API is kept separate from static files so its dispatch class receives
        // only API traffic. Password authentication is used by default.
        Set api = ##class(Security.Applications).%OpenId("/iris-control-center/api")
        If '$IsObject(api) {
            Set api = ##class(Security.Applications).%New()
            Set api.Name = "/iris-control-center/api"
        }
        Set api.Description = "IRIS Control Center API"
        Set api.Namespace = $Namespace
        Set api.Enabled = 1
        Set api.DispatchClass = "IRISControlCenter.REST"
        Set api.MatchRoles = ""
        Set api.AutheEnabled = 32
        Set sc = api.%Save()
    } Catch ex {
        Set sc = ex.AsStatus()
    }
    Quit sc
}

}
