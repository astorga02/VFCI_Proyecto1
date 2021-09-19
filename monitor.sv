
//////////////////////////////////////////////////////////////////////////////////////////////////
// Monitor: Este módulo se encarga de leer las señales de salida del DUT y las convierte        //
//          en transacciones.                                                                   //
//////////////////////////////////////////////////////////////////////////////////////////////////


class Monitor#(parameter controladores,BITS,profundidad);
  virtual Int_fifo #(
      .profundidad(profundidad),
      .controladores(controladores),
      .BITS(BITS)) interfaz_fifo; //declaro la interfaz de la FIFO virtual

  trans_salida_DUT #(.profundidad(profundidad)) item[controladores-1:0]; //declaro la salida del DUT como una transacción
  mailbox monitor_al_checker; //mailbox entre monitor y checker
  Fifo #(.profundidad(profundidad)) f2[controladores-1:0]; //declaro la FIFO
  
  task run(); //task donde correrá el monitor
    for (int p=0;p<controladores;p++)begin
      automatic int w = p; //se crea una variable automatic de tipo entero
      $display("t = %0t Monitor: Mensaje recibido desde el DUT, ha sido tomado por el Fifo %0d",$time,w); //imprime tiempo y número de FIFO
      fork begin
        item[w] = new; //construyo la salida del DUT
        f2[w]=new(profundidad); //contruyo una FIFO
        forever begin
          
          @(posedge interfaz_fifo.pop[0][w]) //cada vez que se de un flanco positivo de reloj de pop del dispositivo
          
            #10f2[w].push(interfaz_fifo.D_push[0][w]); //se hace push al mensaje que viene del bus en el FIFO
          
          #10f2[w].pop(item[w].D_pop); //se hace pop al mensaje desde la FIFO
          item[w].numero_fifo=w; //se indica cual fue la FIFO que recibió el mensaje
            item[w].retraso=$time; //tiempo de simulación en el que se recibió el mensaje
          $display (" - - - - - - - - -  - - - - - - - - - - ");
      	  $display (" ||  ||  ||  ||  ||  ||  ||  ||  ||  || ");
      	  $display (" \\/  \\/  \\/  \\/  \\/  \\/  \\/  \\/  \\/  \\/");
          $display("t = %0t Monitor: Mensaje recibido desde el DUT, ha sido tomado por el Fifo %0d",$time,w); //imprime tiempo y número de FIFO
          item[w].print("Monitor:"); //imprimo datos almacenados en item
            monitor_al_checker.put(item[w]); //mete los mensajes en el mailbox
        end
      end
      join_none
      end
  endtask
endclass
