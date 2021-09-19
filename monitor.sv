


// Inico del modulo para definir el bloque del monitor del ambiente //

class Monitor#(parameter controladores,BITS,profundidad);
  virtual Int_fifo #(
      .profundidad(profundidad),
      .controladores(controladores),
      .BITS(BITS)) interfaz_fifo;

  trans_salida_DUT #(.profundidad(profundidad)) item[controladores-1:0];
  mailbox monitor_al_checker;
  Fifo #(.profundidad(profundidad)) f2[controladores-1:0];
  
  task run();
    for (int p=0;p<controladores;p++)begin
      automatic int w = p;
      $display("t = %0t Monitor: Mensaje recibido desde el DUT, ha sido tomado por el Fifo %0d",$time,w);
      fork begin
        item[w] = new;
        f2[w]=new(profundidad);
        forever begin
          
          @(posedge interfaz_fifo.pop[0][w])
          
          #10f2[w].push(interfaz_fifo.D_push[0][w]);
          #10f2[w].pop(item[w].D_pop);
          item[w].numero_fifo=w;
          item[w].retraso=$time;
          $display (" - - - - - - - - -  - - - - - - - - - - ");
      	  $display (" ||  ||  ||  ||  ||  ||  ||  ||  ||  || ");
      	  $display (" \\/  \\/  \\/  \\/  \\/  \\/  \\/  \\/  \\/  \\/");
          $display("t = %0t Monitor: Mensaje recibido desde el DUT, ha sido tomado por el Fifo %0d",$time,w);
          item[w].print("Monitor:");
          monitor_al_checker.put(item[w]);
        end
      end
      join_none
      end
  endtask
endclass
    // Fin del modulo para definir el bloque del monitor del ambiente //