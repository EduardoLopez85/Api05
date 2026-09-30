// Captura los hitos comerciales de las Sales Quote asociadas a una WO.
// BC NO calcula Steps de CORE: solo informa estado anterior/nuevo y el Sales Order creado.
// La transicion de Step (13->14, 14->15, 15->14, 15->16, ->12) la resuelve CORE / API CONNECT.
codeunit 50100 "APAS Quote Event Mgt."
{
    // Cambio de Estado Cot. APAS: se compara contra el valor en BD para capturar
    // tambien asignaciones hechas por codigo sin Validate.
    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnBeforeModifyEvent', '', false, false)]
    local procedure OnBeforeModifySalesHeader(var Rec: Record "Sales Header"; var xRec: Record "Sales Header"; RunTrigger: Boolean)
    var
        OldSalesHeader: Record "Sales Header";
    begin
        if not IsTrackedQuote(Rec) then
            exit;
        if not OldSalesHeader.Get(Rec."Document Type", Rec."No.") then
            exit;
        if OldSalesHeader."APAS Quote Status" = Rec."APAS Quote Status" then
            exit;

        CheckStatusTransition(OldSalesHeader."APAS Quote Status", Rec."APAS Quote Status");
        InsertStatusEvent(Rec, "APAS Quote Event Type"::StatusChange, OldSalesHeader."APAS Quote Status", Rec."APAS Quote Status");
    end;

    // Al convertir Quote -> Order, BC crea el pedido y luego ELIMINA la Quote
    // (codeunit "Sales-Quote to Order"). Se detecta aqui, antes de que desaparezca.
    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnBeforeDeleteEvent', '', false, false)]
    local procedure OnBeforeDeleteSalesHeader(var Rec: Record "Sales Header"; RunTrigger: Boolean)
    var
        SalesOrderHeader: Record "Sales Header";
    begin
        if not IsTrackedQuote(Rec) then
            exit;

        SalesOrderHeader.SetRange("Document Type", SalesOrderHeader."Document Type"::Order);
        SalesOrderHeader.SetRange("Quote No.", Rec."No.");
        if SalesOrderHeader.FindLast() then
            InsertOrderCreatedEvent(Rec, SalesOrderHeader)
        else
            // Eliminacion manual sin conversion: tratamiento funcional pendiente (¿equivale a Canceled?).
            InsertStatusEvent(Rec, "APAS Quote Event Type"::QuoteDeleted, Rec."APAS Quote Status", Rec."APAS Quote Status");
    end;

    // Rejected, Expired y Canceled son terminales: la Quote no puede salir de ellos.
    // Si la WO vuelve a Pricing, se crea una nueva Sales Quote via API-04.
    procedure CheckStatusTransition(OldStatus: Enum "APAS Quote Status"; NewStatus: Enum "APAS Quote Status")
    var
        TerminalStatusErr: Label 'La cotización está en un estado terminal (%1) y no puede pasar a %2. Si la WO vuelve a Pricing, se debe crear una nueva Sales Quote (API-04).', Comment = '%1 = estado actual, %2 = estado nuevo';
    begin
        if OldStatus = NewStatus then
            exit;
        if IsTerminal(OldStatus) then
            Error(TerminalStatusErr, OldStatus, NewStatus);
    end;

    procedure IsTerminal(Status: Enum "APAS Quote Status"): Boolean
    begin
        exit(Status in ["APAS Quote Status"::Rejected, "APAS Quote Status"::Expired, "APAS Quote Status"::Canceled]);
    end;

    // Confirmacion de recepcion desde API CONNECT (idempotente).
    procedure Acknowledge(var QuoteEvent: Record "APAS Quote Status Event"; AckReference: Text)
    begin
        if QuoteEvent.Acknowledged then
            exit;
        QuoteEvent.Acknowledged := true;
        QuoteEvent."Acknowledged At" := CurrentDateTime();
        QuoteEvent."Ack. Reference" := CopyStr(AckReference, 1, MaxStrLen(QuoteEvent."Ack. Reference"));
        QuoteEvent.Modify();
    end;

    local procedure IsTrackedQuote(var SalesHeader: Record "Sales Header"): Boolean
    begin
        if SalesHeader.IsTemporary() then
            exit(false);
        exit((SalesHeader."Document Type" = SalesHeader."Document Type"::Quote) and (SalesHeader."APAS WO No." <> ''));
    end;

    local procedure InsertStatusEvent(QuoteHeader: Record "Sales Header"; EventType: Enum "APAS Quote Event Type"; PreviousStatus: Enum "APAS Quote Status"; NewStatus: Enum "APAS Quote Status")
    var
        QuoteEvent: Record "APAS Quote Status Event";
    begin
        InitEvent(QuoteEvent, QuoteHeader, EventType, PreviousStatus, NewStatus);
        SetAmounts(QuoteEvent, QuoteHeader);
        QuoteEvent.Insert(true);
    end;

    local procedure InsertOrderCreatedEvent(QuoteHeader: Record "Sales Header"; SalesOrderHeader: Record "Sales Header")
    var
        QuoteEvent: Record "APAS Quote Status Event";
    begin
        InitEvent(QuoteEvent, QuoteHeader, "APAS Quote Event Type"::SalesOrderCreated, QuoteHeader."APAS Quote Status", "APAS Quote Status"::Accepted);
        QuoteEvent."Sales Order No." := SalesOrderHeader."No.";
        SetAmounts(QuoteEvent, SalesOrderHeader);
        QuoteEvent.Insert(true);
    end;

    local procedure InitEvent(var QuoteEvent: Record "APAS Quote Status Event"; QuoteHeader: Record "Sales Header"; EventType: Enum "APAS Quote Event Type"; PreviousStatus: Enum "APAS Quote Status"; NewStatus: Enum "APAS Quote Status")
    begin
        QuoteEvent.Init();
        QuoteEvent."Event Type" := EventType;
        QuoteEvent."WO No." := QuoteHeader."APAS WO No.";
        QuoteEvent."Quote No." := QuoteHeader."No.";
        QuoteEvent."Quote SystemId" := QuoteHeader.SystemId;
        QuoteEvent."Previous Status" := PreviousStatus;
        QuoteEvent."New Status" := NewStatus;
        QuoteEvent."Customer No." := QuoteHeader."Sell-to Customer No.";
        QuoteEvent."Currency Code" := QuoteHeader."Currency Code";
        QuoteEvent."Quote Valid Until Date" := QuoteHeader."Quote Valid Until Date";
        QuoteEvent."Event DateTime" := CurrentDateTime();
        QuoteEvent."User ID" := CopyStr(UserId(), 1, MaxStrLen(QuoteEvent."User ID"));
    end;

    local procedure SetAmounts(var QuoteEvent: Record "APAS Quote Status Event"; SalesHeader: Record "Sales Header")
    begin
        SalesHeader.CalcFields(Amount, "Amount Including VAT");
        QuoteEvent.Amount := SalesHeader.Amount;
        QuoteEvent."Amount Including VAT" := SalesHeader."Amount Including VAT";
    end;
}
