// API principal de API-05 (feed de eventos, solo lectura + confirmacion).
// GET  .../api/dsm/apas/v1.0/companies({companyId})/quoteStatusEvents?$filter=acknowledged eq false&$orderby=entryNo
// POST .../quoteStatusEvents({id})/Microsoft.NAV.acknowledge   body: { "ackReference": "..." }
// Soporta webhooks: POST .../api/dsm/apas/v1.0/subscriptions con resource "api/dsm/apas/v1.0/companies({companyId})/quoteStatusEvents"
// (BC agrupa cambios y notifica ~30 s despues; la suscripcion expira a los 3 dias y debe renovarse con PATCH)
page 50100 "APAS Quote Status Event API"
{
    PageType = API;
    Caption = 'quoteStatusEvents';
    APIPublisher = 'dsm';
    APIGroup = 'apas';
    APIVersion = 'v1.0';
    EntityName = 'quoteStatusEvent';
    EntitySetName = 'quoteStatusEvents';
    SourceTable = "APAS Quote Status Event";
    ODataKeyFields = SystemId;
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;
    Extensible = false;

    layout
    {
        area(Content)
        {
            repeater(Records)
            {
                field(id; Rec.SystemId) { Caption = 'Id'; }
                field(entryNo; Rec."Entry No.") { Caption = 'Entry No.'; }
                field(eventType; Rec."Event Type") { Caption = 'Event Type'; }
                field(woNumber; Rec."WO No.") { Caption = 'WO No.'; }
                field(quoteNumber; Rec."Quote No.") { Caption = 'Quote No.'; }
                field(quoteId; Rec."Quote SystemId") { Caption = 'Quote Id'; }
                field(previousStatus; Rec."Previous Status") { Caption = 'Previous Status'; }
                field(status; Rec."New Status") { Caption = 'Status'; }
                field(salesOrderNumber; Rec."Sales Order No.") { Caption = 'Sales Order No.'; }
                field(customerNumber; Rec."Customer No.") { Caption = 'Customer No.'; }
                field(currencyCode; Rec."Currency Code") { Caption = 'Currency Code'; }
                field(amount; Rec.Amount) { Caption = 'Amount'; }
                field(amountIncludingVAT; Rec."Amount Including VAT") { Caption = 'Amount Including VAT'; }
                field(quoteValidUntilDate; Rec."Quote Valid Until Date") { Caption = 'Quote Valid Until Date'; }
                field(eventDateTime; Rec."Event DateTime") { Caption = 'Event DateTime'; }
                field(userId; Rec."User ID") { Caption = 'User Id'; }
                field(acknowledged; Rec.Acknowledged) { Caption = 'Acknowledged'; }
                field(acknowledgedAt; Rec."Acknowledged At") { Caption = 'Acknowledged At'; }
                field(ackReference; Rec."Ack. Reference") { Caption = 'Ack. Reference'; }
                field(lastModifiedDateTime; Rec.SystemModifiedAt) { Caption = 'Last Modified DateTime'; }
            }
        }
    }

    [ServiceEnabled]
    procedure acknowledge(ackReference: Text)
    var
        QuoteEventMgt: Codeunit "APAS Quote Event Mgt.";
    begin
        QuoteEventMgt.Acknowledge(Rec, ackReference);
    end;
}
