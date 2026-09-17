Class IRISControlCenter.Installer
{

ClassMethod Setup() As %Status
{
    Set sc = $$$OK
    Try {
        Set app = ##class(Security.Applications).%OpenId("/iris-control-center")
        If '$IsObject(app) {
            Set app = ##class(Security.Applications).%New()
            Set app.Name = "/iris-control-center"
        }
        Set app.Description = "IRIS Control Center API"
        Set app.Namespace = $Namespace
        Set app.Enabled = 1
        Set app.DispatchClass = "IRISControlCenter.REST"
        Set app.MatchRoles = ""
        Set app.AutheEnabled = 32
        Set sc = app.%Save()
    } Catch ex {
        Set sc = ex.AsStatus()
    }
    Quit sc
}

}
