`timescale 1ns/1ps
`include "Interface_de_transacciones.sv"
`include "agente.sv"
`include "driver.sv"
`include "checker.sv"
`include "monitor.sv"
`include "generador.sv"
`include "ambiente.sv"

///////////////////////////////////
// Módulo para correr la prueba  //
///////////////////////////////////
module tb; 


  //  Parametros para la configuracion de la prueba   //
  parameter tama_de_paquete = 16; 				 
  parameter caso = llenado_aleatorio;
  parameter opcion = direccion_incorrecta; 	
  parameter dispositivos = 2;
  parameter BITS = 1;
  parameter message = 2;
  parameter tam_fifo = 12;
  parameter broadcast = {8{1'b1}};

  // variables y registros necesarios para la prueba //
  reg clk;
  int ancho_banda;
  int retraso_promedio;
  int resultado[0:dispositivos];



always #100 clk=~clk;
  Int_fifo #(.tama_de_paquete(tama_de_paquete),.controladores(dispositivos),.BITS(BITS)) interfaz_fifo(clk);
  bs_gnrtr_n_rbtr uut(.clk(clk),.reset(interfaz_fifo.reset),.pndng(interfaz_fifo.pndng),.push(interfaz_fifo.push),.pop(interfaz_fifo.pop),.D_pop(interfaz_fifo.D_pop),.D_push(interfaz_fifo.D_push));
  Ambiente #(.tama_de_paquete(tama_de_paquete),.controladores(dispositivos),.BITS(BITS),.message(message),.tam_fifo(tam_fifo),.broadcast(broadcast),.caso(caso),.opcion(opcion)) ambiente_instancia;
  
  initial begin
    $dumpvars(0,bs_gnrtr_n_rbtr);
    $dumpfile("dump.vcd");
  end
  
  initial begin
    ambiente_instancia = new();
    ambiente_instancia.interfaz_fifo = interfaz_fifo;
    ambiente_instancia.run(); 
    $finish;
  end
 

endmodule
