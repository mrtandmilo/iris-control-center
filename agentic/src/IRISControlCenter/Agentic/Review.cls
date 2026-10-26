/// Human-in-the-loop review: records approval or rejection, never executes actions.
Class IRISControlCenter.Agentic.Review
{
ClassMethod Decide(pAuditId As %Integer, pAction As %String) As %DynamicObject
{
    Set action = $ZConvert(pAction,"U")
    If (action'="APPROVE")&&(action'="REJECT") Quit {"error":"invalid_action"}
    If pAuditId<1 Quit {"error":"invalid_audit_id"}
    Lock +^ICCAgenticReview(pAuditId):3
    If '$Test Quit {"error":"review_busy"}
    Set result = {}
    If '$Data(^ICCAgenticAudit(pAuditId)) {
        Set result = {"error":"audit_not_found"}
    } ElseIf $Data(^ICCAgenticReview(pAuditId)) {
        Set result = {"error":"already_reviewed"}
    } Else {
        Set result = {
            "audit_id":(pAuditId),
            "action":(action),
            "reviewed_by":($Username),
            "reviewed_at":($ZDATETIME($HOROLOG,3))
        }
        Set ^ICCAgenticReview(pAuditId) = result.%ToJSON()
    }
    Lock -^ICCAgenticReview(pAuditId)
    Quit result
}
}
