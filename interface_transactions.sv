
//**************Tipos de prueba con casos de opcion***********************
typedef enum {ceros, unos, ceroyunos, direccion_incorrecta,broadcasttt,cero_lejos, uno_cerca} cas_esq;


//**************DEFINICION DE TIPOS DE TRANSACCION**************************
typedef enum{llenado_aleatorio,llenado_especifico} tipos_de_transaccion;






interface Int_fifo#(parameter tama_de_paquete, controladores, BITS)(input bit clk); //conectar DUT con TB
  bit pndng[BITS-1:0][controladores-1:0];
  bit reset;
  bit pop[BITS-1:0][controladores-1:0];
  bit push[BITS-1:0][controladores-1:0];
  bit [tama_de_paquete-1:0] D_pop[BITS-1:0][controladores-1:0];
  bit [tama_de_paquete-1:0] D_push[BITS-1:0][controladores-1:0];
endinterface



