Class IRISControlCenter.ServiceDiscovery Extends %RegisteredObject
{

/// Return a normalized catalogue of REST-enabled web applications registered
/// in the current IRIS instance. Use the native %REST.API interface rather than
/// making a loopback HTTP request to /api/mgmnt/. This preserves the documented
/// discovery semantics (including manually-coded %CSP.REST applications) while
/// avoiding a second authentication hop from an already-authenticated request.
ClassMethod GetCatalogue(authHeader As %String = "", cookieHeader As %String = "") As %DynamicObject
{
    Set result = {"services":[],"source":"%REST.API.GetAllWebRESTApps","count":0}

    Try {
        Set sc = ##class(%REST.API).GetAllWebRESTApps(.appList)
        If $$$ISERR(sc) {
            Set result.error = "service_discovery_failed"
            Quit result
        }

        For index=1:1:appList.Count() {
            Set service = appList.GetAt(index)
            If '$IsObject(service) Continue

            // For web REST applications, name is the web application path.
            // webApplications is populated by newer/spec-first applications;
            // prefer it when present so request execution targets the deployed
            // URL rather than an implementation/package name.
            Set webApplication = service.webApplications
            If webApplication="" Set webApplication=service.name
            // A REST application can theoretically be deployed at multiple
            // comma-separated paths. Use the first deployment for interactive
            // execution while retaining the discovery name as the stable key.
            If webApplication["," Set webApplication=$Piece(webApplication,",",1)

            Set item = {
                "name":(service.name),
                "webApplication":(webApplication),
                "dispatchClass":(service.dispatchClass),
                "namespace":(service.namespace),
                "resource":(service.resource),
                "swagger":(service.swaggerSpec)
            }
            Do item.%Set("enabled",(service.enabled=1),"boolean")
            Do result.services.%Push(item)
        }
        Set result.count = result.services.%Size()
    } Catch ex {
        Set result.error = "service_discovery_failed"
    }

    Quit result
}

}
