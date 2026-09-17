Class IRISControlCenter.ServiceDiscovery Extends %RegisteredObject
{

/// Return a normalized catalogue of REST services registered in the current IRIS instance.
/// The management API remains the source of truth. This adapter isolates its wire format
/// from the browser UI so future IRIS versions can be supported in one place.
ClassMethod GetCatalogue() As %DynamicObject
{
    Set result = {"services":[],"source":"/api/mgmnt/v2/","count":0}

    Try {
        Set request = ##class(%Net.HttpRequest).%New()
        Set request.Server = "127.0.0.1"
        Set request.Port = $Select($Get(^%SYS("WebServer","Port"))'="":$Get(^%SYS("WebServer","Port")),1:52773)
        Set request.Https = 0
        Set sc = request.Get("/api/mgmnt/v2/")
        If $$$ISERR(sc) Set result.error = $System.Status.GetErrorText(sc) Quit result

        Set raw = {}.%FromJSON(request.HttpResponse.Data)
        Set sourceServices = raw.services
        If '$IsObject(sourceServices) Set sourceServices = raw

        If $IsObject(sourceServices) {
            Set iter = sourceServices.%GetIterator()
            While iter.%GetNext(.key,.service) {
                If '$IsObject(service) Continue
                Set item = {
                    "name":($Get(service.name)),
                    "webApplication":($Get(service.webApplication)),
                    "dispatchClass":($Get(service.dispatchClass)),
                    "namespace":($Get(service.namespace)),
                    "swagger":($Get(service.swaggerSpec))
                }
                Do result.services.%Push(item)
            }
        }
        Set result.count = result.services.%Size()
    } Catch ex {
        Set result.error = ex.DisplayString()
    }

    Quit result
}

}
