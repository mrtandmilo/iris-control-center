Class IRISControlCenter.ServiceDiscovery Extends %RegisteredObject
{

/// Return a normalized catalogue of REST-enabled web applications registered
/// in the current IRIS instance. The legacy management endpoint is intentional:
/// unlike /api/mgmnt/v2/, it includes both generated and manually-coded REST
/// applications, which makes it the more complete discovery source for a portal.
ClassMethod GetCatalogue(authHeader As %String = "") As %DynamicObject
{
    Set result = {"services":[],"source":"/api/mgmnt/","count":0}

    Try {
        Set request = ##class(%Net.HttpRequest).%New()
        Set request.Server = "127.0.0.1"
        Set request.Port = $Select($Get(^%SYS("WebServer","Port"))'="":$Get(^%SYS("WebServer","Port")),1:52773)
        Set request.Https = 0
        If authHeader'="" Do request.SetHeader("Authorization",authHeader)
        Set sc = request.Get("/api/mgmnt/")
        If $$$ISERR(sc) {
            Set result.error = $System.Status.GetErrorText(sc)
            Quit result
        }

        If request.HttpResponse.StatusCode '= 200 {
            Set result.error = "IRIS management API returned HTTP "_request.HttpResponse.StatusCode
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
        Set result.error = ex.DisplayString()
    }

    Quit result
}

}
