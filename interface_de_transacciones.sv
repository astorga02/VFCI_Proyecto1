
typedef enum{llenado_aleatorio,llenado_especifico} tipos_de_transaccion;
typedef enum {ceros, unos, ceroyunos, direccion_incorrecta,broadcasttt,cero_lejos, uno_cerca} cas_esq;
typedef enum {total_mess} tot_mensajes;



interface Int_fifo#(parameter tama_de_paquete, controladores, BITS)(input bit clk);
  bit pndng[BITS-1:0][controladores-1:0];
  bit reset;
  bit pop[BITS-1:0][controladores-1:0];
  bit push[BITS-1:0][controladores-1:0];
  bit [tama_de_paquete-1:0] D_pop[BITS-1:0][controladores-1:0];
  bit [tama_de_paquete-1:0] D_push[BITS-1:0][controladores-1:0];
endinterface

    // Fin del modulo para definir el bloque de la interfaz de transacciones del ambiente //


//  Entrada DUT //
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


//  Salida DUT  //
class trans_salida_DUT#(parameter tama_de_paquete);
  int numero_fifo;
  bit [tama_de_paquete-1:0] D_pop;
  int retraso;

  function print  (string mensaje_creado);
    $display("t = %g %s Numero de FIFO = %0d, Dato extraido = %0d, Tiempo de llegada = %0dns", 
             $time,
             mensaje_creado, 
             this.numero_fifo,
             this.D_pop,
             this.retraso);
  endfunction
  
endclass