

typedef enum{llenado_aleatorio,llenado_especifico} tipos_de_transaccion;
typedef enum {ceros, unos, ceroyunos, direccion_incorrecta,broadcasttt,cero_lejos, uno_cerca, alea_reset, un_dispo} cas_esq;


typedef enum {total_mess} tot_mensajes;


// Inico del modulo para definir el bloque de la interfaz de transacciones del ambiente //

interface Int_fifo#(parameter profundidad, controladores, BITS)(input bit clk);
  bit pndng[BITS-1:0][controladores-1:0];
  bit reset;
  bit pop[BITS-1:0][controladores-1:0];
  bit push[BITS-1:0][controladores-1:0];
  bit [profundidad-1:0] D_pop[BITS-1:0][controladores-1:0];
  bit [profundidad-1:0] D_push[BITS-1:0][controladores-1:0];
endinterface

    // Fin del modulo para definir el bloque de la interfaz de transacciones del ambiente //


//  Entrada DUT //
class trans_entrada_DUT#(parameter profundidad,controladores,caso,opcion);

  randc bit [profundidad-1:0] contenido;
  rand bit delay;
  rand int numero_fifo;
  
  constraint rest_num_fifo {0 <= numero_fifo;  numero_fifo <= controladores-1;}
  constraint rest_delay {0 <= delay;  numero_fifo <= 20;}
  
  
  int destino = controladores;
  
  bit [profundidad-1:0] D_push;

  function print  (string mensaje_creado);
    $display("t = %g %s Dato a ingresar = %d, Numero de FIFO = %0d, Dato ingresado = %0d", $time, mensaje_creado, this.contenido, this.numero_fifo, this.D_push);
  endfunction
  
endclass


//  Salida DUT  //
class trans_salida_DUT#(parameter profundidad);
  int numero_fifo;
  bit [profundidad-1:0] D_pop;
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