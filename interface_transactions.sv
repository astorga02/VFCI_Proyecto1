//////////////////////////////////////////////////////////////
// Definición del tipo de transacciones posibles en el BUS  //
//////////////////////////////////////////////////////////////

interface Int_fifo#(parameter tama_de_paquete, controladores, BITS)(input bit clk);
  bit pndng[BITS-1:0][controladores-1:0];
  bit reset;
  bit pop[BITS-1:0][controladores-1:0];
  bit push[BITS-1:0][controladores-1:0];
  bit [tama_de_paquete-1:0] D_pop[BITS-1:0][controladores-1:0];
  bit [tama_de_paquete-1:0] D_push[BITS-1:0][controladores-1:0];
endinterface
