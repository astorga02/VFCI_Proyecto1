// Code your testbench here
// or browse Examples
`include "Interface_de_transacciones.sv"
`include "agente.sv"
`include "driver.sv"
`include "checker.sv"
`include "monitor.sv"
`include "generador.sv"
`include "ambiente.sv"

//  Modulo para prueba  //
module tb;
  
  // Declaracion de algunos parametros generales de la prueba 
  parameter profundidad = 8;
  parameter dispositivos = 5;
  parameter BITS = 8;
  parameter message = 20;     //se refiere a la cantidad de mensajes que va a generar la prueba
  parameter broadcast = 145;    // contenido del mensaje enviado por brodcast
  parameter destino = 2;      //  parametro especial para el caso de usar el caso de esquina de enviar a un solo dispositivo el payload
  

                                //declaracion de las variables para la prueba a partir de la definicion de los tpos enumerados en la 
                                // en la interfaz de transacciones
  tipos_de_transaccion caso;    
  cas_esq opcion;
  solicitud_checker nombre_reporte;
  reg clk;  
  mailbox test_al_generador = new();    // definicion de los mailbozes que no fueron difinidos en el ambiente para conectar el test con el checker y el generador
  mailbox test_al_checker = new();
  
  initial begin
    $dumpvars(0,bs_gnrtr_n_rbtr);
    $dumpfile("dump.vcd");
  end
  
  always #100 clk=~clk;   // reloj general de la prueba y el DUT
  Int_fifo #(.profundidad(profundidad),.controladores(dispositivos),.BITS(BITS)) interfaz_fifo(clk); //instanciacion de las clases necesarias para correr el ambiente, interfaz y DUT
  bs_gnrtr_n_rbtr uut(.clk(clk),.reset(interfaz_fifo.reset),.pndng(interfaz_fifo.pndng),.push(interfaz_fifo.push),.pop(interfaz_fifo.pop),.D_pop(interfaz_fifo.D_pop),.D_push(interfaz_fifo.D_push));
  Ambiente #(.profundidad(profundidad),.controladores(dispositivos),.BITS(BITS),.message(message),.broadcast(broadcast)) ambiente_instancia, ambiente_instancia_1;

  initial begin   //inico de la prueba 
    {clk,interfaz_fifo.reset} <= 0; // incio de las variables principales de la prueba en cero
    ambiente_instancia = new();   //construcccion de la instancia del ambiente
    ambiente_instancia.interfaz_fifo = interfaz_fifo;   //conexion de la interfaz con el ambiente
    ambiente_instancia.run();   //corrida de la instancia del ambiente
    caso = llenado_especifico;    //se colcoca el caso ya sea: llenado_aleatorio o llenado_especifico
    opcion = unos;    // en caso de seleccionar el llenado especifico en la variable anterior es necesario escoger el caso de esquina a probar
    nombre_reporte = sim_llenado_aleatorio;   //se selecciona el nombre del archivo de salida para cada tipo de prueba 
    test_al_checker.put(nombre_reporte);    //envio de los mensajes de los tipos casos por medio de los mailboxes
    test_al_generador.put(caso);
    test_al_generador.put(opcion);
    
    //ambiente_instancia.checker_instancia.simarchivo; 
    //test_al_generador.get(opcion); //saco la instruccion de la prueba
    
    //sol_checker = reporte;
    //test_al_checker.put(sol_checker);
    #1500000 
    /*
    $display ("-- \\ -- \\ -- \\ -- \\ -- \\ -- \\ -- \\ -- \\");
    $display ("-- / -- / -- / -- / -- / -- / -- / -- /");
    $display (" CAMBIO DE ESCENARIO DE PRUEBAS");
    $display ("/-- /-- /-- /-- /-- /-- /-- /-- /-- /--");
    $display ("\\-- \\-- \\-- \\-- \\-- \\-- \\-- \\-- \\-- \\--");
    
    ambiente_instancia = null;
    {clk,interfaz_fifo.reset} <= 0;
    ambiente_instancia = new();
    ambiente_instancia.interfaz_fifo = interfaz_fifo;
    ambiente_instancia.run();
    caso = llenado_especifico;
    opcion = ceros;
    test_al_generador.put(caso);
    test_al_generador.put(opcion);
    test_al_generador.get(opcion); //saco la instruccion de la prueba
    #1500000
    
    $display ("-- \\ -- \\ -- \\ -- \\ -- \\ -- \\ -- \\ -- \\");
    $display ("-- / -- / -- / -- / -- / -- / -- / -- /");
    $display (" CAMBIO DE ESCENARIO DE PRUEBAS");
    $display ("/-- /-- /-- /-- /-- /-- /-- /-- /-- /--");
    $display ("\\-- \\-- \\-- \\-- \\-- \\-- \\-- \\-- \\-- \\--");
    
    {clk,interfaz_fifo.reset} <= 0;
    ambiente_instancia = new();
    ambiente_instancia.interfaz_fifo = interfaz_fifo;
    ambiente_instancia.run();
    caso = llenado_especifico;
    opcion = unos;
    test_al_generador.put(caso);
    test_al_generador.put(opcion);
    test_al_generador.get(opcion); //saco la instruccion de la prueba
    #1500000
    
    $display ("-- \\ -- \\ -- \\ -- \\ -- \\ -- \\ -- \\ -- \\");
    $display ("-- / -- / -- / -- / -- / -- / -- / -- /");
    $display (" CAMBIO DE ESCENARIO DE PRUEBAS");
    $display ("/-- /-- /-- /-- /-- /-- /-- /-- /-- /--");
    $display ("\\-- \\-- \\-- \\-- \\-- \\-- \\-- \\-- \\-- \\--");
    
    {clk,interfaz_fifo.reset} <= 0;
    ambiente_instancia = new();
    ambiente_instancia.interfaz_fifo = interfaz_fifo;
    ambiente_instancia.run();
    caso = llenado_especifico;
    opcion = ceroyunos;
    test_al_generador.put(caso);
    test_al_generador.put(opcion);
    test_al_generador.get(opcion); //saco la instruccion de la prueba
    #1500000
    
    $display ("-- \\ -- \\ -- \\ -- \\ -- \\ -- \\ -- \\ -- \\");
    $display ("-- / -- / -- / -- / -- / -- / -- / -- /");
    $display (" CAMBIO DE ESCENARIO DE PRUEBAS");
    $display ("/-- /-- /-- /-- /-- /-- /-- /-- /-- /--");
    $display ("\\-- \\-- \\-- \\-- \\-- \\-- \\-- \\-- \\-- \\--");
    
    {clk,interfaz_fifo.reset} <= 0;
    ambiente_instancia = new();
    ambiente_instancia.interfaz_fifo = interfaz_fifo;
    ambiente_instancia.run();
    caso = llenado_especifico;
    opcion = direccion_incorrecta;
    test_al_generador.put(caso);
    test_al_generador.put(opcion);
    test_al_generador.get(opcion); //saco la instruccion de la prueba
    #1500000
    
    $display ("-- \\ -- \\ -- \\ -- \\ -- \\ -- \\ -- \\ -- \\");
    $display ("-- / -- / -- / -- / -- / -- / -- / -- /");
    $display (" CAMBIO DE ESCENARIO DE PRUEBAS");
    $display ("/-- /-- /-- /-- /-- /-- /-- /-- /-- /--");
    $display ("\\-- \\-- \\-- \\-- \\-- \\-- \\-- \\-- \\-- \\--");
    
    {clk,interfaz_fifo.reset} <= 0;
    ambiente_instancia = new();
    ambiente_instancia.interfaz_fifo = interfaz_fifo;
    ambiente_instancia.run();
    caso = llenado_especifico;
    opcion = broadcasttt;
    test_al_generador.put(caso);
    test_al_generador.put(opcion);
    test_al_generador.get(opcion); //saco la instruccion de la prueba
    #1500000
    
    $display ("-- \\ -- \\ -- \\ -- \\ -- \\ -- \\ -- \\ -- \\");
    $display ("-- / -- / -- / -- / -- / -- / -- / -- /");
    $display (" CAMBIO DE ESCENARIO DE PRUEBAS");
    $display ("/-- /-- /-- /-- /-- /-- /-- /-- /-- /--");
    $display ("\\-- \\-- \\-- \\-- \\-- \\-- \\-- \\-- \\-- \\--");
    
    {clk,interfaz_fifo.reset} <= 0;
    ambiente_instancia = new();
    ambiente_instancia.interfaz_fifo = interfaz_fifo;
    ambiente_instancia.run();
    caso = llenado_especifico;
    opcion = un_dispo;
    test_al_generador.put(caso);
    test_al_generador.put(opcion);
    test_al_generador.get(opcion); //saco la instruccion de la prueba
    #1500000
    
    
    //sol_checker = reporte;
    //test_al_checker.put(sol_checker);
    */

    
    $finish;
    
  end


endmodule