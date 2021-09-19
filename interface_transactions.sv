
///////////////////////////////////////////////////////////////////////////////////////////////////////
// interface_de_transacciones: Este módulo representa las transacciones que entran y salen del DUT.  //
//         Además, en este módulo se define la interfaz de transacciones del ambiente, así como los  //
//          tipos de transacciones y los casos de esquina.                                           //
///////////////////////////////////////////////////////////////////////////////////////////////////////


typedef enum{llenado_aleatorio,llenado_especifico} tipos_de_transaccion; //se definen los casos de generación del test

typedef enum {ceros, unos, ceroyunos, direccion_incorrecta,broadcasttt,un_dispo} cas_esq; //se definen los casos de esquina
typedef enum {total_mess} tot_mensajes; //se definen los casos de opcion
typedef enum {reporte} solicitud_checker; //se definen los casos de opcion


// Inicio del modulo para definir el bloque de la interfaz de transacciones del ambiente //

interface Int_fifo#(parameter profundidad, controladores, BITS)(input bit clk); //interfaz para conectar DUT con el testbench (tb)
  bit pndng[BITS-1:0][controladores-1:0];  //se declaran variables de tipo bit
  bit reset;
  bit pop[BITS-1:0][controladores-1:0];
  bit push[BITS-1:0][controladores-1:0];
  bit [profundidad-1:0] D_pop[BITS-1:0][controladores-1:0];
  bit [profundidad-1:0] D_push[BITS-1:0][controladores-1:0];
endinterface

// Fin del modulo para definir el bloque de la interfaz de transacciones del ambiente //


//  Entrada DUT //
class trans_entrada_DUT#(parameter profundidad,controladores);  //transacción del mensaje que entra al DUT

  randc bit [profundidad-1:0] contenido;
  rand bit delay;
  rand int numero_fifo;
  int destino = controladores;
  bit [profundidad-1:0] D_push;
  
  constraint rest_num_fifo {0 <= numero_fifo;  numero_fifo <= controladores-1;} //se crean restricciones para el número de FIFOS
  constraint rest_delay {0 <= delay;  numero_fifo <= 20;} //se crean restricciones para el delay


  function print  (string mensaje_creado); //se crea una función para imprimir el contenido del mensaje a ingresar
    $display("t = %g %s Dato a ingresar = %d, Numero de FIFO = %0d, Dato ingresado = %0d", $time, mensaje_creado, this.contenido, this.numero_fifo, this.D_push); //imprime información del mensaje a ingresar en el DUT
  endfunction
  
endclass


//  Salida DUT  //
class trans_salida_DUT#(parameter profundidad); //transacción del mensaje que sale del DUT
  int numero_fifo;
  bit [profundidad-1:0] D_pop;
  int retraso;

  function print  (string mensaje_creado); //se crea una función para imprimir el contenido del mensaje a extaer 
    $display("t = %g %s Numero de FIFO = %0d, Dato extraido = %0d, Tiempo de llegada = %0dns", $time, mensaje_creado, this.numero_fifo, this.D_pop, this.retraso); //imprime información del mensaje extraido del DUT
  endfunction
  
endclass




