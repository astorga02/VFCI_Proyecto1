// Modulo para definir el bloque del monitor del ambiente //

class Monitor#(parameter controladores,tam_fifo,BITS,tama_de_paquete);
  virtual Int_fifo #(
      .tama_de_paquete(tama_de_paquete),
      .controladores(controladores),
      .BITS(BITS)) interfaz_fifo;


  Fifo #(.tama_de_paquete(tama_de_paquete)) f2[controladores-1:0];
  mailbox monitor_al_checker;

  
  task run();
    for (int p=0;p<controladores;p++)begin
      automatic int w=p;
      fork begin
        item[w]=new;
        f2[w]=new(tam_fifo);
        begin
          @(posedge interfaz_fifo.pop[0][w])
            #1f2[w].push(interfaz_fifo.D_push[0][w]);
            #1f2[w].pop(item[w].D_push);
        end
      end
      end
  endtask
endclass
