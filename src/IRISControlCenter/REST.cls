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

ClassMethod CookieHeader() As %String [ Private ]
{
    Quit %request.GetCgiEnv("HTTP_COOKIE","")
}

ClassMethod ApplyInboundAuth(request As %Net.HttpRequest) [ Private ]
{
    Set auth = ..AuthHeader()
    Set cookie = ..CookieHeader()
    If auth'="" Do request.SetHeader("Authorization",auth)
    If cookie'="" Do request.SetHeader("Cookie",cookie)
}

ClassMethod LocalPort() As %Integer [ Private ]
{
    Quit $Select($Get(^%SYS("WebServer","Port"))'="":$Get(^%SYS("WebServer","Port")),1:52773)
}

ClassMethod CatalogueService(service As %String) As %DynamicObject [ Private ]
{
    Set catalogue = ##class(IRISControlCenter.ServiceDiscovery).GetCatalogue(..AuthHeader(),..CookieHeader())
    Set found = ""
    Set iter = catalogue.services.%GetIterator()
    While iter.%GetNext(.key,.item) {
        If item.name = service Set found = item Quit
    }
    Quit found
}

ClassMethod IsSafeRelativePath(path As %String) As %Boolean [ Private ]
{
    If $Extract(path,1)'="/" Quit 0
    Set lower = $ZConvert(path,"L")
    If (lower["://")!(lower["\\") Quit 0
    // Keep the proxy pinned beneath the selected IRIS web application. Reject
    // literal, encoded, and double-encoded dot segments before the upstream
    // server gets an opportunity to normalize or decode them again.
    Set pathname = $Piece(lower,"?",1)
    If (pathname="/..")!(pathname["/../")!($Extract(pathname,$Length(pathname)-2,*)="/..") Quit 0
    If (pathname["%2e%2e")!(pathname["%2e.")!(pathname[".%2e") Quit 0
    If (pathname["%252e%252e")!(pathname["%252e.")!(pathname[".%252e") Quit 0
    Quit 1
}

ClassMethod WriteStream(stream As %Stream.Object) [ Private ]
{
    Do stream.Rewind()
    While 'stream.AtEnd {
        Write stream.Read(32767)
    }
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
    Set response = ##class(IRISControlCenter.ServiceDiscovery).GetCatalogue(..AuthHeader(),..CookieHeader())
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

    Set found = ..CatalogueService(service)
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
    // Management metadata is not allowed to turn this endpoint into a generic
    // HTTP fetcher. Specifications must be local IRIS-relative paths.
    If '..IsSafeRelativePath(found.swagger) {
        Set %response.Status = "502 Bad Gateway"
        Write {"error":"invalid_openapi_location","service":(service)}.%ToJSON()
        Quit $$$OK
    }

    Try {
        Set request = ##class(%Net.HttpRequest).%New()
        Set request.Server = "127.0.0.1"
        Set request.Port = ..LocalPort()
        Set request.Timeout = 15
        Do ..ApplyInboundAuth(request)
        Set sc = request.Get(found.swagger)
        If $$$ISERR(sc) {
            Set %response.Status = "502 Bad Gateway"
            Write {"error":"openapi_fetch_failed"}.%ToJSON()
            Quit $$$OK
        }
        If request.HttpResponse.StatusCode '= 200 {
            Set %response.Status = "502 Bad Gateway"
            Write {"error":"openapi_fetch_failed","upstreamStatus":(request.HttpResponse.StatusCode)}.%ToJSON()
            Quit $$$OK
        }
        If request.HttpResponse.ContentType'="" Set %response.ContentType = request.HttpResponse.ContentType
        Do ..WriteStream(request.HttpResponse.Data)
    } Catch ex {
        Set %response.Status = "502 Bad Gateway"
        Write {"error":"openapi_fetch_failed"}.%ToJSON()
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
    If '..IsSafeRelativePath(path) {
        Set %response.Status = "400 Bad Request"
        Write {"error":"invalid_path"}.%ToJSON()
        Quit $$$OK
    }

    Set found = ..CatalogueService(service)
    If '$IsObject(found) {
        Set %response.Status = "404 Not Found"
        Write {"error":"service_not_found","service":(service)}.%ToJSON()
        Quit $$$OK
    }
    Set base = found.webApplication
    If (base="")!('..IsSafeRelativePath(base)) {
        Set %response.Status = "400 Bad Request"
        Write {"error":"service_has_invalid_web_application"}.%ToJSON()
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
        Do ..ApplyInboundAuth(request)
        Set sc = request.Get(target)
        If $$$ISERR(sc) {
            Set %response.Status = "502 Bad Gateway"
            Write {"error":"request_failed"}.%ToJSON()
            Quit $$$OK
        }
        Set upstream = request.HttpResponse
        Set %response.Status = upstream.StatusCode_" "_upstream.ReasonPhrase
        If upstream.ContentType'="" Set %response.ContentType = upstream.ContentType
        Do ..WriteStream(upstream.Data)
    } Catch ex {
        Set %response.Status = "502 Bad Gateway"
        Write {"error":"request_failed"}.%ToJSON()
    }
    Quit $$$OK
}

}
