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

  parameter profundidad = 8;
  parameter dispositivos = 5;
  parameter BITS = 9;
  parameter message = 20;
  parameter broadcast = 145;
  parameter destino = 2;
  
  tipos_de_transaccion caso;
  cas_esq opcion;
  solicitud_checker nombre_reporte;
  reg clk;
  real ancho_banda;
  real retraso_promedio;
  mailbox test_al_generador = new();
  mailbox test_al_checker = new();
  
  initial begin
    $dumpvars(0,bs_gnrtr_n_rbtr);
    $dumpfile("dump.vcd");
  end
  
  always #100 clk=~clk;
  Int_fifo #(.profundidad(profundidad),.controladores(dispositivos),.BITS(BITS)) interfaz_fifo(clk);
  bs_gnrtr_n_rbtr uut(.clk(clk),.reset(interfaz_fifo.reset),.pndng(interfaz_fifo.pndng),.push(interfaz_fifo.push),.pop(interfaz_fifo.pop),.D_pop(interfaz_fifo.D_pop),.D_push(interfaz_fifo.D_push));
  Ambiente #(.profundidad(profundidad),.controladores(dispositivos),.BITS(BITS),.message(message),.broadcast(broadcast)) ambiente_instancia, ambiente_instancia_1;

  
  
  //string nombre_archivo = "simulacion_llenado_aleatorio";
  initial begin
    
    {clk,interfaz_fifo.reset} <= 0;
    ambiente_instancia = new();
    ambiente_instancia.interfaz_fifo = interfaz_fifo;
    ambiente_instancia.run();
    caso = llenado_aleatorio;
    opcion = ceros;
    nombre_reporte = sim_llenado_aleatorio;
    test_al_checker.put(nombre_reporte);
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