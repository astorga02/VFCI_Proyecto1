`timescale 1ns/1ps
`include "fifo.sv"
`include "interface_transactions.sv"
`include "driver.sv"
`include "checker.sv"
`include "score_board.sv"
`include "agent.sv"
`include "ambiente.sv"
`include "test.sv"

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



endmodule
