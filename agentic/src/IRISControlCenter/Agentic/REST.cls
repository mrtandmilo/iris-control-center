/// Authenticated, local-only API for synthetic incident samples.
Class IRISControlCenter.Agentic.REST Extends %CSP.REST
{
Parameter HandleCorsRequest = 0;

XData UrlMap [ XMLNamespace = "http://www.intersystems.com/urlmap" ]
{
<Routes>
  <Route Url="/health" Method="GET" Call="Health" />
  <Route Url="/incident" Method="POST" Call="Incident" />
  <Route Url="/audit" Method="GET" Call="Audit" />
  <Route Url="/review" Method="POST" Call="Review" />
</Routes>
}

ClassMethod Health() As %Status
{
    Set %response.ContentType = "application/json"
    Set mode = $ZConvert($System.Util.GetEnviron("AGENTIC_MODE"),"L")
    Write {"status":"ok","app":"IRIS Control Center Agentic Edition","mode":(mode)}.%ToJSON()
    Quit $$$OK
}

ClassMethod Incident() As %Status
{
    Set %response.ContentType = "application/json"
    Try {
        Set raw = %request.Content.Read(8192)
        Set input = ##class(%DynamicObject).%FromJSON(raw)
        Set incidentId = input.%Get("incident_id","")
        Set sourceSystem = input.%Get("source_system","")
        Set errorCode = input.%Get("error_code","")
        Set summary = input.%Get("summary","")
        Set retryCount = +input.%Get("retry_count",0)
        If (incidentId="")!(sourceSystem="")!(errorCode="") {
            Set %response.Status = "400 Bad Request"
            Write {"error":"incident_id_source_system_error_code_required"}.%ToJSON()
            Quit $$$OK
        }
        If ($Length(incidentId)>80)!($Length(sourceSystem)>80)!($Length(errorCode)>40)!($Length(summary)>600)!(retryCount<0)!(retryCount>10) {
            Set %response.Status = "400 Bad Request"
            Write {"error":"invalid_incident_fields"}.%ToJSON()
            Quit $$$OK
        }
        Set request = ##class(IRISControlCenter.Agentic.IncidentRequest).%New()
        Set request.IncidentId = incidentId
        Set request.SourceSystem = sourceSystem
        Set request.ErrorCode = errorCode
        Set request.Summary = summary
        Set request.RetryCount = retryCount
        Set sc = ##class(Ens.Director).CreateBusinessService("IncidentIngress",.service)
        If $$$ISERR(sc) {
            Set %response.Status = "503 Service Unavailable"
            Write {"error":"production_not_running"}.%ToJSON()
            Quit $$$OK
        }
        Set sc = service.ProcessInput(request,.answer)
        If $$$ISERR(sc) {
            Set %response.Status = "503 Service Unavailable"
            Write {"error":"triage_failed"}.%ToJSON()
            Quit $$$OK
        }
        Set body = {
            "incident_id":(answer.IncidentId),
            "decision":(answer.Decision),
            "route":(answer.Route),
            "reason":(answer.Reason),
            "confidence":(answer.Confidence),
            "source":(answer.Source),
            "audit_id":(answer.AuditId)
        }
        Do body.%Set("approval_required",1,"boolean")
        Write body.%ToJSON()
    } Catch ex {
        Set %response.Status = "400 Bad Request"
        Write {"error":"invalid_json_or_incident"}.%ToJSON()
    }
    Quit $$$OK
}

/// Only an authenticated operator can approve/reject a recommendation.
ClassMethod Review() As %Status
{
    Set %response.ContentType = "application/json"
    Try {
        Set input = ##class(%DynamicObject).%FromJSON(%request.Content.Read(2048))
        Set id = +input.%Get("audit_id",0)
        Set action = input.%Get("action","")
        Set outcome = ##class(IRISControlCenter.Agentic.Review).Decide(id,action)
        Set error = outcome.%Get("error","")
        If error="invalid_action" Set %response.Status = "400 Bad Request"
        If error="invalid_audit_id" Set %response.Status = "400 Bad Request"
        If error="audit_not_found" Set %response.Status = "404 Not Found"
        If error="already_reviewed" Set %response.Status = "409 Conflict"
        If error="review_busy" Set %response.Status = "503 Service Unavailable"
        Write outcome.%ToJSON()
    } Catch ex {
        Set %response.Status = "400 Bad Request"
        Write {"error":"invalid_review_request"}.%ToJSON()
    }
    Quit $$OK
}

ClassMethod Audit() As %Status
{
    Set %response.ContentType = "application/json"
    Set limit = +$Get(%request.Data("limit",1),10)
    Set results = ##class(IRISControlCenter.Agentic.Audit).Tail(limit)
    Write results.%ToJSON()
    Quit $$$OK
}
}
