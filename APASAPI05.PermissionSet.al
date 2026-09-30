// Asignar a la aplicacion de Microsoft Entra usada por API CONNECT.
permissionset 50100 "APAS API05"
{
    Assignable = true;
    Caption = 'APAS API-05 Integración CORE';
    Permissions =
        table "APAS Quote Status Event" = X,
        tabledata "APAS Quote Status Event" = RM,
        tabledata "Sales Header" = R,
        tabledata "Sales Line" = R,
        page "APAS Quote Status Event API" = X,
        page "APAS Sales Quote API" = X,
        codeunit "APAS Quote Event Mgt." = X;
}
