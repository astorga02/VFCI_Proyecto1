// Inico del modulo para definir la FIFO virtual para el driver del ambiente //

class Fifo #(parameter profundidad);
  bit [profundidad-1:0]D_pop;
  bit [profundidad-1:0]D_push;
  bit [profundidad-1:0]queue[$];
  bit maximo;
  int tamano;
  int id;
  
    
  function new (bit maximo);
    this.maximo=maximo;
  endfunction
  
  task pop(output bit [profundidad-1:0] D_pop);
    if (queue.size()!=0)
      begin
		D_pop=queue.pop_front;
      end
    
    this.tamano=queue.size();

  endtask
  
  task push (input bit [profundidad-1:0]D_push);
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



    // Inico del modulo para definir el bloque del driver del ambiente //
class Driver#(parameter controladores,BITS,profundidad,caso,opcion);
  int contador_payload = 0;
  mailbox agente_al_driver;
  virtual Int_fifo #(.profundidad(profundidad),.controladores(controladores),.BITS(BITS)) interfaz_fifo;
  Fifo #(.profundidad(profundidad)) fifo_simulada[controladores-1:0];
  trans_entrada_DUT #(.profundidad(profundidad),.controladores(controladores),.caso(caso),.opcion(opcion)) instancia_entrada_DUT_1[controladores-1:0],instancia_entrada_DUT_2[controladores-1:0], item3;
  int tiempo_envio;
  
  
  task run();
    item3 = new;
    item3.randomize();
    for ( int i=0; i < item3.delay; i++) #2ns;
    for (int i=0;i<controladores;i++)begin // ciclo for para el reset
      interfaz_fifo.pndng[0][i]<=0;
      interfaz_fifo.D_push[0][i]<=0;
      interfaz_fifo.reset<=1'b1;
      #1interfaz_fifo.reset<=1'b0;
    end
    $display("t = %t DUT reseteado", $time);
    for (int q=0; q<controladores;q++)
      begin
        automatic int w=q;
        fork begin
          fifo_simulada[w]=new(profundidad);
          instancia_entrada_DUT_1[w]=new;
          instancia_entrada_DUT_2[w]=new;
          $display("Fifo numero: %0d creado y corriendo",w);
          forever begin
            @(posedge interfaz_fifo.clk)
            #1agente_al_driver.peek(instancia_entrada_DUT_1[w]);
            if (instancia_entrada_DUT_1[w].numero_fifo==w)begin
              #1agente_al_driver.get(instancia_entrada_DUT_1[w]);
              #1instancia_entrada_DUT_1[w].print("Driver: Transacción que llega al Driver");
              #1fifo_simulada[w].push(instancia_entrada_DUT_1[w].D_push);
              $display("t = %0t Driver: Mensaje (numero de fifo = %0d) ingresado al Fifo [%0d]",$time,instancia_entrada_DUT_1[w].numero_fifo,w);
              #1fifo_simulada[w].pop(instancia_entrada_DUT_2[w].D_push);
              #1interfaz_fifo.D_push[0][w]<=instancia_entrada_DUT_2[w].D_push;
              #1interfaz_fifo.pndng[0][w]<=1'b1;
              contador_payload++;
              $display("t = %0t Driver: Se ha prendido la bandera de pending del Fifo[%0d]",$time,w);
              @(negedge interfaz_fifo.pop[0][w])
              if (instancia_entrada_DUT_2[w].D_push[profundidad-1:0]<controladores)begin
              tiempo_envio=$time;
                arrayglobal[tiempo_envio]=instancia_entrada_DUT_2[w].D_push[profundidad-1:0];
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