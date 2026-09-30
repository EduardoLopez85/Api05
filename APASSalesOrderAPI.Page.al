// API para detectar la conversion Quote -> Sales Order (Step 15 -> 16).
// Al convertir, BC borra la Quote; el pedido conserva "Quote No." y el N.º WO CORE.
// GET  .../api/dsm/apas/v1.0/companies({companyId})/apasSalesOrders?$filter=woNumber eq 'WO-000123'
// Webhook: POST .../api/dsm/apas/v1.0/subscriptions con resource
//          "api/dsm/apas/v1.0/companies({companyId})/apasSalesOrders" (changeType "created")
page 50102 "APAS Sales Order API"
{
    PageType = API;
    Caption = 'apasSalesOrders';
    APIPublisher = 'dsm';
    APIGroup = 'apas';
    APIVersion = 'v1.0';
    EntityName = 'apasSalesOrder';
    EntitySetName = 'apasSalesOrders';
    SourceTable = "Sales Header";
    SourceTableView = where("Document Type" = const(Order), "APAS WO No." = filter(<> ''));
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
                field(quoteNumber; Rec."Quote No.") { Caption = 'Quote No.'; }
                field(woNumber; Rec."APAS WO No.") { Caption = 'WO No.'; }
                field(customerNumber; Rec."Sell-to Customer No.") { Caption = 'Customer No.'; }
                field(customerName; Rec."Sell-to Customer Name") { Caption = 'Customer Name'; }
                field(currencyCode; Rec."Currency Code") { Caption = 'Currency Code'; }
                field(amount; Rec.Amount) { Caption = 'Amount'; }
                field(amountIncludingVAT; Rec."Amount Including VAT") { Caption = 'Amount Including VAT'; }
                field(orderDate; Rec."Order Date") { Caption = 'Order Date'; }
                field(createdDateTime; Rec.SystemCreatedAt) { Caption = 'Created DateTime'; }
                field(lastModifiedDateTime; Rec.SystemModifiedAt) { Caption = 'Last Modified DateTime'; }
            }
        }
    }
}
