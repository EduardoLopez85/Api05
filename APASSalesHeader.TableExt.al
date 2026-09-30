// Campos de correlacion con CORE y estado maestro APAS.
// Si ya fueron creados en API-04 / GAP, elimine esta tableextension y use los existentes.
tableextension 50100 "APAS Sales Header" extends "Sales Header"
{
    fields
    {
        field(50100; "APAS WO No."; Code[50])
        {
            Caption = 'N.º WO CORE';
            DataClassification = CustomerContent;
        }
        field(50101; "APAS Quote Status"; Enum "APAS Quote Status")
        {
            Caption = 'Estado Cot. APAS';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                QuoteEventMgt: Codeunit "APAS Quote Event Mgt.";
            begin
                QuoteEventMgt.CheckStatusTransition(xRec."APAS Quote Status", Rec."APAS Quote Status");
            end;
        }
    }

    keys
    {
        key(APASWONo; "APAS WO No.") { }
    }
}
