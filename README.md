# VFCI_Proyecto1

La prueba se corre utilizando EDA Playground
Comandos para la prueba:
A partir de la línea 14 del testbench
parameter profundidad = 8; // profundidad
parameter dispositivos = 5;   //cantidad de dispositivos
parameter BITS = 8;     // canttidad de Bits
parameter message = 20;     //se refiere a la cantidad de mensajes que va a generar la prueba
parameter broadcast = 145;    // contenido del mensaje enviado por brodcast en caso de ser usado
parameter destino = 2;    //dispositivo único de destino en caso de ser usado




//////////////////////////////////////////////////////////////////////////////
Para el test de llenado aletorio modificar en la línea 46 del testbench:

 caso = llenado_aleatorio;
 opcion = unos;  (no importa que se ponga acá) 
 nombre_reporte = sim_llenado_aleatorio; 
 
 /////////////////////////////////////////////////////////////////////////////////////
 Para el test de llenado especifico con ceros modificar en la línea 46 del testbench:

 caso = llenado_especifico;
 opcion = ceros;  
 nombre_reporte = sim_ceros; 
 
 /////////////////////////////////////////////////////////////////////////////////////
 Para el test de llenado especifico con unos modificar en la línea 46 del testbench:

 caso = llenado_especifico;
 opcion = unos;  
 nombre_reporte = sim_unos; 
 
 /////////////////////////////////////////////////////////////////////////////////////
 Para el test de llenado especifico con unos modificar en la línea 46 del testbench:

 caso = llenado_especifico;
 opcion = ceroyunos;  
 nombre_reporte = sim_ceroyunos; 
 
 /////////////////////////////////////////////////////////////////////////////////////
 Para el test de llenado especifico con unos modificar en la línea 46 del testbench:

 caso = llenado_especifico;
 opcion = direccion_incorrecta;  
 nombre_reporte = sim_direcc_incorrecta; 
 
 /////////////////////////////////////////////////////////////////////////////////////
 Para el test de llenado especifico con unos modificar en la línea 46 del testbench:

 caso = llenado_especifico;
 opcion = broadcasttt;  
 nombre_reporte = sim_broadcast; 
 
  /////////////////////////////////////////////////////////////////////////////////////
 Para el test de llenado especifico con unos modificar en la línea 46 del testbench:

 caso = llenado_especifico;
 opcion = un_dispo;  
 nombre_reporte = sim_un_dispo; 
