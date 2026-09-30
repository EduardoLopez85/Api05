// OPCIONAL: ejecutar desde Cola de proyectos (diario) para pasar a Expired
// las Quotes vencidas. El cambio de estado dispara el evento hacia CORE.
// Omitir si el vencimiento ya lo gestiona otro proceso del GAP.
codeunit 50101 "APAS Quote Expiration"
{
    trigger OnRun()
    var
        SalesHeader: Record "Sales Header";
        QuoteToExpire: Record "Sales Header";
    begin
        SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Quote);
        SalesHeader.SetFilter("APAS WO No.", '<>%1', '');
        SalesHeader.SetFilter("Quote Valid Until Date", '<>%1&<%2', 0D, Today());
        SalesHeader.SetFilter("APAS Quote Status", '%1|%2|%3',
            SalesHeader."APAS Quote Status"::InPreparation,
            SalesHeader."APAS Quote Status"::Valued,
            SalesHeader."APAS Quote Status"::Sent);
        if SalesHeader.FindSet() then
            repeat
                QuoteToExpire.Get(SalesHeader."Document Type", SalesHeader."No.");
                QuoteToExpire.Validate("APAS Quote Status", QuoteToExpire."APAS Quote Status"::Expired);
                QuoteToExpire.Modify(true);
            until SalesHeader.Next() = 0;
    end;
}
