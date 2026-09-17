Class IRISControlCenter.REST Extends %CSP.REST
{

Parameter HandleCorsRequest = 1;

XData UrlMap [ XMLNamespace = "http://www.intersystems.com/urlmap" ]
{
<Routes>
  <Route Url="/health" Method="GET" Call="Health" />
  <Route Url="/services" Method="GET" Call="Services" />
  <Route Url="/openapi" Method="GET" Call="OpenAPI" />
  <Route Url="/request" Method="GET" Call="RequestGET" />
</Routes>
}

ClassMethod AuthHeader() As %String [ Private ]
{
    Quit %request.GetCgiEnv("HTTP_AUTHORIZATION","")
}

ClassMethod LocalPort() As %Integer [ Private ]
{
    Quit $Select($Get(^%SYS("WebServer","Port"))'="":$Get(^%SYS("WebServer","Port")),1:52773)
}

ClassMethod CatalogueService(service As %String, auth As %String) As %DynamicObject [ Private ]
{
    Set catalogue = ##class(IRISControlCenter.ServiceDiscovery).GetCatalogue(auth)
    Set found = ""
    Set iter = catalogue.services.%GetIterator()
    While iter.%GetNext(.key,.item) {
        If item.name = service Set found = item Quit
    }
    Quit found
}

ClassMethod Health() As %Status
{
    Set %response.ContentType = "application/json"
    Set body = {"status":"ok","application":"IRIS Control Center","namespace":($Namespace)}
    Write body.%ToJSON()
    Quit $$$OK
}

ClassMethod Services() As %Status
{
    Set %response.ContentType = "application/json"
    Set response = ##class(IRISControlCenter.ServiceDiscovery).GetCatalogue(..AuthHeader())
    Write response.%ToJSON()
    Quit $$$OK
}

ClassMethod OpenAPI() As %Status
{
    Set %response.ContentType = "application/json"
    Set service = $Get(%request.Data("service",1))
    If service="" {
        Set %response.Status = "400 Bad Request"
        Write {"error":"service_required"}.%ToJSON()
        Quit $$$OK
    }

    Set auth = ..AuthHeader()
    Set found = ..CatalogueService(service,auth)
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
        Set request.Port = ..LocalPort()
        If auth'="" Do request.SetHeader("Authorization",auth)
        Set sc = request.Get(found.swagger)
        If $$$ISERR(sc) {
            Set %response.Status = "502 Bad Gateway"
            Write {"error":"openapi_fetch_failed","detail":($System.Status.GetErrorText(sc))}.%ToJSON()
            Quit $$$OK
        }
        If request.HttpResponse.StatusCode '= 200 {
            Set %response.Status = "502 Bad Gateway"
            Write {"error":"openapi_fetch_failed","upstreamStatus":(request.HttpResponse.StatusCode)}.%ToJSON()
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

ClassMethod RequestGET() As %Status
{
    Set %response.ContentType = "application/json"
    Set service = $Get(%request.Data("service",1))
    Set path = $Get(%request.Data("path",1))
    If (service="")!(path="") {
        Set %response.Status = "400 Bad Request"
        Write {"error":"service_and_path_required"}.%ToJSON()
        Quit $$$OK
    }
    If $Extract(path,1)'="/" {
        Set %response.Status = "400 Bad Request"
        Write {"error":"path_must_be_relative"}.%ToJSON()
        Quit $$$OK
    }
    If (path["://")!(path["\\") {
        Set %response.Status = "400 Bad Request"
        Write {"error":"invalid_path"}.%ToJSON()
        Quit $$$OK
    }

    Set auth = ..AuthHeader()
    Set found = ..CatalogueService(service,auth)
    If '$IsObject(found) {
        Set %response.Status = "404 Not Found"
        Write {"error":"service_not_found","service":(service)}.%ToJSON()
        Quit $$$OK
    }
    Set base = found.webApplication
    If base="" {
        Set %response.Status = "400 Bad Request"
        Write {"error":"service_has_no_web_application"}.%ToJSON()
        Quit $$$OK
    }
    If $Extract(base,$Length(base))="/" Set base=$Extract(base,1,$Length(base)-1)
    Set target = base _ path

    Try {
        Set request = ##class(%Net.HttpRequest).%New()
        Set request.Server = "127.0.0.1"
        Set request.Port = ..LocalPort()
        Set request.Timeout = 15
        Do request.SetHeader("Accept","application/json")
        If auth'="" Do request.SetHeader("Authorization",auth)
        Set sc = request.Get(target)
        If $$$ISERR(sc) {
            Set %response.Status = "502 Bad Gateway"
            Write {"error":"request_failed","detail":($System.Status.GetErrorText(sc))}.%ToJSON()
            Quit $$$OK
        }
        Set upstream = request.HttpResponse
        Set %response.Status = upstream.StatusCode_" "_upstream.ReasonPhrase
        If upstream.ContentType'="" Set %response.ContentType = upstream.ContentType
        Do upstream.Data.Rewind()
        Write upstream.Data.Read()
    } Catch ex {
        Set %response.Status = "502 Bad Gateway"
        Write {"error":"request_failed","detail":(ex.DisplayString())}.%ToJSON()
    }
    Quit $$$OK
}

}
