Class IRISControlCenter.ServiceDiscovery Extends %RegisteredObject
{

/// Return a normalized catalogue of REST-enabled web applications registered
/// in the current IRIS instance. The legacy management endpoint is intentional:
/// unlike /api/mgmnt/v2/, it includes both generated and manually-coded REST
/// applications, which makes it the more complete discovery source for a portal.
/// Forward both HTTP Authorization and Cookie because IRIS deployments may use
/// either Basic authentication or an authenticated CSP session.
ClassMethod GetCatalogue(authHeader As %String = "", cookieHeader As %String = "") As %DynamicObject
{
    Set result = {"services":[],"source":"/api/mgmnt/","count":0}

    Try {
        Set request = ##class(%Net.HttpRequest).%New()
        Set request.Server = "127.0.0.1"
        Set request.Port = $Select($Get(^%SYS("WebServer","Port"))'="":$Get(^%SYS("WebServer","Port")),1:52773)
        Set request.Https = 0
        Set request.Timeout = 15
        If authHeader'="" Do request.SetHeader("Authorization",authHeader)
        If cookieHeader'="" Do request.SetHeader("Cookie",cookieHeader)
        Set sc = request.Get("/api/mgmnt/")
        If $$$ISERR(sc) {
            // Keep transport and IRIS status details out of the browser-facing
            // catalogue. Stable error codes are sufficient for the UI while
            // avoiding accidental disclosure of local paths or diagnostics.
            Set result.error = "service_discovery_failed"
            Quit result
        }

        If request.HttpResponse.StatusCode '= 200 {
            Set result.error = "service_discovery_failed"
            Set result.upstreamStatus = request.HttpResponse.StatusCode
            Quit result
        }

        Set raw = [].%FromJSON(request.HttpResponse.Data)
        Set iter = raw.%GetIterator()
        While iter.%GetNext(.key,.service) {
            If '$IsObject(service) Continue
            Set item = {
                "name":($Get(service.name)),
                "webApplication":($Get(service.name)),
                "dispatchClass":($Get(service.dispatchClass)),
                "namespace":($Get(service.namespace)),
                "resource":($Get(service.resource)),
                "enabled":($Get(service.enabled)),
                "swagger":($Get(service.swaggerSpec))
            }
            Do result.services.%Push(item)
        }
        Set result.count = result.services.%Size()
    } Catch ex {
        Set result.error = "service_discovery_failed"
    }

    Quit result
}

}
