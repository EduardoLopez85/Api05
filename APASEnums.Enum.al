// Estado comercial maestro de la Quote (Estado Cot. APAS / Quote Status APAS).
// Si este enum ya existe en la extension de API-04 / GAP, elimine este objeto
// y apunte al existente (agregando la dependencia en app.json).
// Los nombres de valor van sin espacios para que la API los exponga limpios.
enum 50100 "APAS Quote Status"
{
    Extensible = true;
    Caption = 'Estado Cot. APAS';

    value(0; None) { Caption = ' '; }
    value(10; InPreparation) { Caption = 'En preparación comercial'; }
    value(20; Valued) { Caption = 'Valorizada'; }
    value(30; Sent) { Caption = 'Enviada'; }
    value(40; Accepted) { Caption = 'Aceptada'; }
    value(50; Rejected) { Caption = 'Rechazada'; }
    value(60; Expired) { Caption = 'Vencida'; }
    value(70; Canceled) { Caption = 'Cancelada'; }
}

enum 50101 "APAS Quote Event Type"
{
    Extensible = true;
    Caption = 'Tipo evento Cot. APAS';

    value(0; StatusChange) { Caption = 'Cambio de estado'; }
    value(1; SalesOrderCreated) { Caption = 'Pedido de venta creado'; }
    value(2; QuoteDeleted) { Caption = 'Cotización eliminada'; }
}
