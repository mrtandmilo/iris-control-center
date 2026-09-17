Class IRISControlCenter.REST Extends %CSP.REST
{

Parameter HandleCorsRequest = 1;

XData UrlMap [ XMLNamespace = "http://www.intersystems.com/urlmap" ]
{
<Routes>
  <Route Url="/health" Method="GET" Call="Health" />
  <Route Url="/services" Method="GET" Call="Services" />
  <Route Url="/openapi/:service" Method="GET" Call="OpenAPI" />
</Routes>
}

ClassMethod Health() As %Status
{
    Set %response.ContentType = "application/json"
    Set body = {
        "status":"ok",
        "application":"IRIS Control Center",
        "namespace":($Namespace)
    }
    Write body.%ToJSON()
    Quit $$$OK
}

ClassMethod Services() As %Status
{
    Set %response.ContentType = "application/json"
    Set response = ##class(IRISControlCenter.ServiceDiscovery).GetCatalogue()
    Write response.%ToJSON()
    Quit $$$OK
}

ClassMethod OpenAPI(service As %String) As %Status
{
    Set %response.ContentType = "application/json"
    Set catalogue = ##class(IRISControlCenter.ServiceDiscovery).GetCatalogue()
    Set found = ""

    Set iter = catalogue.services.%GetIterator()
    While iter.%GetNext(.key,.item) {
        If item.name = service Set found = item Quit
    }

    If '$IsObject(found) {
        Set %response.Status = "404 Not Found"
        Write {"error":"service_not_found","service":(service)}.%ToJSON()
        Quit $$$OK
    }

    If found.swagger = "" {
        Set %response.Status = "404 Not Found"
        Write {"error":"openapi_not_available","service":(service)}.%ToJSON()
        Quit $$$OK
    }

    Try {
        Set request = ##class(%Net.HttpRequest).%New()
        Set request.Server = "127.0.0.1"
        Set request.Port = $Select($Get(^%SYS("WebServer","Port"))'="":$Get(^%SYS("WebServer","Port")),1:52773)
        Set sc = request.Get(found.swagger)
        If $$$ISERR(sc) {
            Set %response.Status = "502 Bad Gateway"
            Write {"error":"openapi_fetch_failed","detail":($System.Status.GetErrorText(sc))}.%ToJSON()
            Quit $$$OK
        }
        Do request.HttpResponse.Data.Rewind()
        Write request.HttpResponse.Data.Read()
    } Catch ex {
        Set %response.Status = "502 Bad Gateway"
        Write {"error":"openapi_fetch_failed","detail":(ex.DisplayString())}.%ToJSON()
    }

    Quit $$$OK
}

}
