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
  parameter BITS = 1;
  parameter message = 2;
  parameter broadcast = {8{1'b1}};
  reg clk;


  always #10 clk=~clk;
  Int_fifo #(.tama_de_paquete(tama_de_paquete),.controladores(dispositivos),.BITS(BITS)) interfaz_fifo(clk);


  initial begin
    $dumpvars(0,bs_gnrtr_n_rbtr);
    $dumpfile("dump.vcd");
  end
  
endmodule
