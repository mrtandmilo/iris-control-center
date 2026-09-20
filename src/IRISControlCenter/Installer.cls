Class IRISControlCenter.Installer
{

ClassMethod Setup() As %Status
{
    Set sc = $$$OK
    Set appNamespace = $Namespace
    Set originalNamespace = $Namespace
    Try {
        // Security.Applications is stored in %SYS rather than application
        // namespaces. Preserve USER as the namespace assigned to both apps.
        ZN "%SYS"

        Set ui = ##class(Security.Applications).%OpenId("/iris-control-center")
        If '$IsObject(ui) {
            Set ui = ##class(Security.Applications).%New()
            Set ui.Name = "/iris-control-center"
        }
        Set ui.Description = "IRIS Control Center"
        Set ui.NameSpace = appNamespace
        Set ui.Enabled = 1
        // iris-main relocates the private web server CSP tree beneath the
        // persistent ISC_DATA_DIRECTORY. The image seeds this path with a
        // symlink to the immutable UI files before the volume is initialized.
        Set ui.Path = "/home/irisowner/irisdata/csp/iris-control-center"
        Set ui.ServeFiles = 1
        Set ui.Recurse = 1
        Set ui.AutheEnabled = 64
        Set sc = ui.%Save()
        If $$$ISERR(sc) $$$ThrowStatus(sc)

        Set api = ##class(Security.Applications).%OpenId("/iris-control-center/api")
        If '$IsObject(api) {
            Set api = ##class(Security.Applications).%New()
            Set api.Name = "/iris-control-center/api"
        }
        Set api.Description = "IRIS Control Center API"
        Set api.NameSpace = appNamespace
        Set api.Enabled = 1
        Set api.DispatchClass = "IRISControlCenter.REST"
        Set api.MatchRoles = ""
        Set api.AutheEnabled = 32
        Set sc = api.%Save()
    } Catch ex {
        Set sc = ex.AsStatus()
    }
    ZN originalNamespace
    Quit sc
}

}
