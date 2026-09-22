Class IRISControlCenter.UI Extends %CSP.REST
{

XData UrlMap [ XMLNamespace = "http://www.intersystems.com/urlmap" ]
{
<Routes>
  <Route Url="/" Method="GET" Call="Index" />
  <Route Url="/app.js" Method="GET" Call="AppJS" />
  <Route Url="/app.css" Method="GET" Call="AppCSS" />
  <Route Url="/openapi.json" Method="GET" Call="OpenAPI" />
</Routes>
}

ClassMethod Send(filename As %String, contentType As %String) As %Status [ Private ]
{
    Try {
        Set stream = ##class(%Stream.FileCharacter).%New()
        Set stream.Filename = "/home/irisowner/dev/web/"_filename
        Set %response.ContentType = contentType
        Do stream.Rewind()
        While 'stream.AtEnd { Write stream.Read(32767) }
    } Catch ex {
        Set %response.Status = "404 Not Found"
    }
    Quit $$$OK
}

ClassMethod Index() As %Status
{
    Quit ..Send("index.html","text/html; charset=utf-8")
}

ClassMethod AppJS() As %Status
{
    Quit ..Send("app.js","application/javascript; charset=utf-8")
}

ClassMethod AppCSS() As %Status
{
    Quit ..Send("app.css","text/css; charset=utf-8")
}

ClassMethod OpenAPI() As %Status
{
    Quit ..Send("openapi.json","application/json; charset=utf-8")
}

}
