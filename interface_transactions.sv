
//**************DEFINICION DE TIPOS DE TRANSACCION**************************
typedef enum{llenado_aleatorio,llenado_especifico} tipos_de_transaccion;


//**************Tipos de prueba con casos de opcion***********************
typedef enum {ceros, unos, direccion_incorrecta,broadcasttt} cas_esq;


typedef enum {total_mess} tot_mensajes;



interface Int_fifo#(parameter tama_de_paquete, controladores, BITS)(input bit clk);
  bit pndng[BITS-1:0][controladores-1:0];
  bit reset;
  bit pop[BITS-1:0][controladores-1:0];
  bit push[BITS-1:0][controladores-1:0];
  bit [tama_de_paquete-1:0] D_pop[BITS-1:0][controladores-1:0];
  bit [tama_de_paquete-1:0] D_push[BITS-1:0][controladores-1:0];
endinterface



class trans_entrada_DUT#(parameter tama_de_paquete,controladores,caso,opcion);
  randc bit [tama_de_paquete-1:0] contenido;
  rand bit [2:0] delay;
  rand int numero_fifo;
  constraint item1 {0 <= numero_fifo;  numero_fifo <= controladores-1;}
  int destino = controladores;
  bit [tama_de_paquete-1:0] D_push;

  function print  (string mensaje_creado);
    $display("t = %g %s Dato a ingresar = %d, numero_fifo = %0d, Dato ingresado = %0d", $time, mensaje_creado, this.contenido, this.numero_fifo, this.D_push);
  endfunction

endclass




class trans_salida_DUT#(parameter tama_de_paquete);
  int numero_fifo;
  int retraso;


  
endclass


