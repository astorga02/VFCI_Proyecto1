`timescale 1ns/1ps
`include "Interface_de_transacciones.sv"
`include "agente.sv"
`include "driver.sv"
`include "checker.sv"
`include "monitor.sv"
`include "generador.sv"
`include "ambiente.sv"

module tb;
  parameter tama_de_paquete = 16; 
  parameter tam_fifo = 12;
  parameter caso = llenado_aleatorio;

  
endmodule
