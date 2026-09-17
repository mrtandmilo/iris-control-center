Class IRISControlCenter.REST Extends %CSP.REST
{

Parameter HandleCorsRequest = 1;

XData UrlMap [ XMLNamespace = "http://www.intersystems.com/urlmap" ]
{
<Routes>
  <Route Url="/health" Method="GET" Call="Health" />
  <Route Url="/services" Method="GET" Call="Services" />
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

    // The browser UI consumes a normalized service list. The management API
    // remains the source of truth; this endpoint deliberately starts read-only.
    Set services = []
    Set response = {
        "services":(services),
        "source":"/api/mgmnt/v2/",
        "note":"Service discovery adapter is under active development."
    }
    Write response.%ToJSON()
    Quit $$$OK
}

}
