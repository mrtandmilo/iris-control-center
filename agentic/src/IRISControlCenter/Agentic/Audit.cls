/// Read-only audit access for demo and authenticated REST endpoint.
Class IRISControlCenter.Agentic.Audit
{
ClassMethod Tail(pLimit As %Integer = 10) As %DynamicArray
{
    If (pLimit<1)!(pLimit>50) Set pLimit = 10
    Set results = []
    Set last = +$Get(^ICCAgenticAuditSeq)
    For n=last:-1:1 {
        If results.%Size()>=pLimit Quit
        If '$Data(^ICCAgenticAudit(n)) Continue
        Try {
            Set entry = ##class(%DynamicObject).%FromJSON(^ICCAgenticAudit(n))
            Do results.%Push(entry)
        } Catch ex {
            // Skip corrupt records; never emit raw global contents.
        }
    }
    Quit results
}
}
