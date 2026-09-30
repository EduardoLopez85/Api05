// Registro append-only de hitos comerciales (outbox).
// Cada cambio de Estado Cot. APAS y la creacion del Sales Order generan una fila.
// API CONNECT la consume y confirma con la accion "acknowledge" (reintento / conciliacion).
table 50100 "APAS Quote Status Event"
{
    Caption = 'Evento estado Cot. APAS';
    DataClassification = CustomerContent;
    InherentPermissions = RI;
    InherentEntitlements = RI;

    fields
    {
        field(1; "Entry No."; BigInteger)
        {
            Caption = 'N.º mov.';
            AutoIncrement = true;
        }
        field(2; "Event Type"; Enum "APAS Quote Event Type") { Caption = 'Tipo evento'; }
        field(3; "WO No."; Code[50]) { Caption = 'N.º WO CORE'; }
        field(4; "Quote No."; Code[20]) { Caption = 'N.º cotización'; }
        field(5; "Quote SystemId"; Guid) { Caption = 'Id cotización'; }
        field(6; "Previous Status"; Enum "APAS Quote Status") { Caption = 'Estado anterior'; }
        field(7; "New Status"; Enum "APAS Quote Status") { Caption = 'Estado nuevo'; }
        field(8; "Sales Order No."; Code[20]) { Caption = 'N.º pedido venta'; }
        field(9; "Customer No."; Code[20]) { Caption = 'N.º cliente'; }
        field(10; "Currency Code"; Code[10]) { Caption = 'Cód. divisa'; }
        field(11; Amount; Decimal) { Caption = 'Importe'; AutoFormatType = 1; }
        field(12; "Amount Including VAT"; Decimal) { Caption = 'Importe IVA incl.'; AutoFormatType = 1; }
        field(13; "Quote Valid Until Date"; Date) { Caption = 'Válida hasta'; }
        field(14; "Event DateTime"; DateTime) { Caption = 'Fecha/hora evento'; }
        field(15; "User ID"; Code[50])
        {
            Caption = 'Usuario';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(20; Acknowledged; Boolean) { Caption = 'Confirmado por API CONNECT'; }
        field(21; "Acknowledged At"; DateTime) { Caption = 'Fecha/hora confirmación'; }
        field(22; "Ack. Reference"; Text[100]) { Caption = 'Referencia confirmación'; }
    }

    keys
    {
        key(PK; "Entry No.") { Clustered = true; }
        key(WO; "WO No.", "Entry No.") { }
        key(Pending; Acknowledged, "Entry No.") { }
    }
}
