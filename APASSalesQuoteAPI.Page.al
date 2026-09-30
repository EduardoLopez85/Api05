// API de consulta (foto actual) para conciliacion: estado vigente de las Quotes con WO.
// GET .../api/dsm/apas/v1.0/companies({companyId})/apasSalesQuotes?$filter=woNumber eq 'WO-000123'
// Nota: una Quote convertida a Sales Order desaparece de aqui (BC la elimina);
// ese hito queda en quoteStatusEvents (eventType = SalesOrderCreated).
page 50101 "APAS Sales Quote API"
{
    PageType = API;
    Caption = 'apasSalesQuotes';
    APIPublisher = 'dsm';
    APIGroup = 'apas';
    APIVersion = 'v1.0';
    EntityName = 'apasSalesQuote';
    EntitySetName = 'apasSalesQuotes';
    SourceTable = "Sales Header";
    SourceTableView = where("Document Type" = const(Quote), "APAS WO No." = filter(<> ''));
    ODataKeyFields = SystemId;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;
    DataAccessIntent = ReadOnly;
    Extensible = false;

    layout
    {
        area(Content)
        {
            repeater(Records)
            {
                field(id; Rec.SystemId) { Caption = 'Id'; }
                field(number; Rec."No.") { Caption = 'No.'; }
                field(woNumber; Rec."APAS WO No.") { Caption = 'WO No.'; }
                field(status; Rec."APAS Quote Status") { Caption = 'Status'; }
                field(customerNumber; Rec."Sell-to Customer No.") { Caption = 'Customer No.'; }
                field(customerName; Rec."Sell-to Customer Name") { Caption = 'Customer Name'; }
                field(currencyCode; Rec."Currency Code") { Caption = 'Currency Code'; }
                field(amount; Rec.Amount) { Caption = 'Amount'; }
                field(amountIncludingVAT; Rec."Amount Including VAT") { Caption = 'Amount Including VAT'; }
                field(documentDate; Rec."Document Date") { Caption = 'Document Date'; }
                field(quoteValidUntilDate; Rec."Quote Valid Until Date") { Caption = 'Quote Valid Until Date'; }
                field(lastModifiedDateTime; Rec.SystemModifiedAt) { Caption = 'Last Modified DateTime'; }
            }
        }
    }
}
