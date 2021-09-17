 /////////////////////////////////////////////////////////////////////////////////////////////////////////////
 // Driver/Monitor: este objeto es responsable de la interacción entre el ambiente y el la fifo bajo prueba //
 /////////////////////////////////////////////////////////////////////////////////////////////////////////////

// Inico del modulo para definir la FIFO virtual para el driver del ambiente //

class Fifo #(parameter tama_de_paquete);
  bit [tama_de_paquete-1:0]D_pop;
  bit [tama_de_paquete-1:0]D_push;
  bit [tama_de_paquete-1:0]queue[$];
  bit maximo;
  int tamano;
  int id;
  
    
  function new (bit maximo);
    this.maximo=maximo;
  endfunction
  
  task pop(output bit [tama_de_paquete-1:0] D_pop);
    if (queue.size()!=0)
      begin
		D_pop=queue.pop_front;
      end
    
    this.tamano=queue.size();

  endtask
  
  task push (input bit [tama_de_paquete-1:0]D_push);
    if (queue.size>this.maximo)
      begin
        queue.push_back(D_push);
        queue.delete(0);
      end
    else 
      begin
        queue.push_back(D_push);
      end
    
    this.tamano = queue.size;
  endtask
endclass


class Driver#(parameter controladores,tam_fifo,BITS,tama_de_paquete,caso,opcion);
  int contador_payload = 0;
  mailbox agente_al_driver;
  virtual Int_fifo #(.tama_de_paquete(tama_de_paquete),.controladores(controladores),.BITS(BITS)) interfaz_fifo;
  Fifo #(.tama_de_paquete(tama_de_paquete)) f1[controladores-1:0];
  trans_entrada_DUT #(.tama_de_paquete(tama_de_paquete),.controladores(controladores),.caso(caso),.opcion(opcion)) item1[controladores-1:0],item2[controladores-1:0];
  int tiempo_envio;
  
  
  task reset();
    for (int i=0;i<controladores;i++)begin
      interfaz_fifo.pndng[0][i]<=0;
      interfaz_fifo.D_push[0][i]<=0;
      interfaz_fifo.reset<=1'b1;
      #1interfaz_fifo.reset<=1'b0;
    end
  endtask
    
  task run();
    reset();
    $display("DUT reseteado");
    for (int q=0; q<controladores;q++)
      begin
        automatic int w=q;
        fork begin
          f1[w]=new(tam_fifo);
          item1[w]=new;
          item2[w]=new;
          $display("Fifo numero: %0d creado y corriendo",w);
          forever begin
            @(posedge interfaz_fifo.clk)
            #1agente_al_driver.peek(item1[w]);
            if (item1[w].numero_fifo==w)begin
              #1agente_al_driver.get(item1[w]);
              #1item1[w].print("Driver: Transacción que llega al Driver");
              #1f1[w].push(item1[w].D_push);
              $display("t = %0t Driver: Mensaje (numero de fifo = %0d) ingresado al Fifo [%0d]",$time,item1[w].numero_fifo,w);
              #1f1[w].pop(item2[w].D_push);
              #1interfaz_fifo.D_push[0][w]<=item2[w].D_push;
              #1interfaz_fifo.pndng[0][w]<=1'b1;
              contador_payload++;
              $display("t = %0t Driver: Se ha prendido la bandera de pending del Fifo[%0d]",$time,w);
              @(negedge interfaz_fifo.pop[0][w])
              if (item2[w].D_push[tama_de_paquete-1:0]<controladores)begin
              tiempo_envio=$time;
                arrayglobal[tiempo_envio]=item2[w].D_push[tama_de_paquete-1:0];
              end
              interfaz_fifo.pndng[0][w]<=1'b0;
            end
            end
          end
        join_none
      end
  endtask
endclass

    // Fin del modulo para definir el bloque del driver del ambiente //