// Inico del modulo para definir la FIFO virtual para el driver del ambiente //

class Fifo #(parameter profundidad); // clase necesaria para emular las FIFO's que va a tener el DUT
  bit [profundidad-1:0]D_pop;
  bit [profundidad-1:0]D_push;
  bit [profundidad-1:0]queue[$];
  int id;


  task pop(output bit [profundidad-1:0] D_pop);   //task para poder hace los push a una cola en software
    if (queue.size()!=0)    //verificacion de que la cola no está vacía para poder hacer pop
      begin
		D_pop=queue.pop_front;
      end
    

  endtask
  
  task push (input bit [profundidad-1:0]D_push); //task para poder hace los pop a una cola en software
    if (queue.size>profundidad) // verificacion de que la FIFO excede la capacidad del tamaño de la FIFO
      begin
        queue.push_back(D_push);
        queue.delete(0);
      end
    else 
      begin
        queue.push_back(D_push); // si no excede entonces se realiza la tarea normalmente
      end

  endtask
endclass



    // Inico del modulo para definir el bloque del driver del ambiente //
class Driver#(parameter controladores,BITS,profundidad);
  int contador_payload = 0; // contador para tener en cuenta las veces en que se acierta la condicion del if de verificacion en el forever
  mailbox agente_al_driver; //mailbox para obtener el payload a tratar
  virtual Int_fifo #(.profundidad(profundidad),.controladores(controladores),.BITS(BITS)) interfaz_fifo; //instancia virtual de la interfaz entre el el hardware y el software
  Fifo #(.profundidad(profundidad)) fifo_simulada[controladores-1:0]; // isnstancia de las FIFOS simuladas
  trans_entrada_DUT #(.profundidad(profundidad),.controladores(controladores)) instancia_entrada_DUT_1[controladores-1:0],instancia_entrada_DUT_2[controladores-1:0], item3; //interface de transacciones para el driver 
  int tiempo_envio; //variable para salvar el momento cuando se envía el mensaje
  
  
  task run(); //task principal para correr
    item3 = new; //construccion de una instancia de las transacciones de entrada para obtener el retraso de envio
    item3.randomize();
    for ( int i=0; i < item3.delay; i++) #3; //el retraso de envio se determina por cada corrida del for un retraso de 2 nanosegundos que depende de la variable aleatoria "delay"
    for (int i=0;i<controladores;i++)begin // ciclo for para el reset de la prueba usando la interfaz de coneccion con el DUT que tambien afecta al momenento en que suscede el reset
      interfaz_fifo.pndng[0][i]<=0;
      interfaz_fifo.D_push[0][i]<=0;
      interfaz_fifo.reset<=1'b1;
      #1interfaz_fifo.reset<=1'b0;
    end
    $display("t = %t DUT reseteado", $time); //una vez es resetado se muestra este mensaje 
    for (int q=0; q<controladores;q++)
      begin
        automatic int w=q;  //reparacion de error en la indexacion en algunas estructuras para dejar que el código determine le mejor tipo de integer en cada caso
        fork begin    
          fifo_simulada[w]=new();   // construccion instancias de fifos dependiendo de la cantidada de controladores configurados en la prueba
          instancia_entrada_DUT_1[w]=new; //construcicon de instancias de transacciones de entrada a modo de pushes al DUT
          instancia_entrada_DUT_2[w]=new; //construcicon de instancias de transacciones de entrada a modo de pops al DUT
          $display("Fifo numero: %0d creado", w); 
          forever begin //ciclo for sin fin hasta terminar la prueba u otra condicion de salida
            @(posedge interfaz_fifo.clk) //revision de cada flanco positivo de la interfaz 
            #1agente_al_driver.peek(instancia_entrada_DUT_1[w]); // copio la transaccion del mailbox desde el agente en la instancia correspondientee al dispositivo
            if (instancia_entrada_DUT_1[w].numero_fifo==w)begin   // si se encuentra el dispositivo en el mailbox correspondiente al momento del ciclo for entonces se ingresa el mensaje a la fifo correspondiente en el BUS
              #1agente_al_driver.get(instancia_entrada_DUT_1[w]);   //se saca del mailbo esa transaccion y ahora su se asigna a la instacia con el controlador asociado a la corrida del ciclo
              #1instancia_entrada_DUT_1[w].print("Driver: Transacción que llega al Driver");  //se imprime el dispositvo a tratar e informacion relevante através de la interface de transacciones
              #1fifo_simulada[w].push(instancia_entrada_DUT_1[w].D_push); //se hace push a la fifo simulada a partir de los datos de la interface de entrada de datos y alojandolo en el BUS
              $display("t = %0t Driver: Mensaje (numero de fifo = %0d) ingresado al Fifo [%0d]",$time,instancia_entrada_DUT_1[w].numero_fifo,w);  // 
              #1fifo_simulada[w].pop(instancia_entrada_DUT_2[w].D_push);  //Una vez ingresao del dato se saca de la fifo simualada a la instancia de de entrada adyacente 
              #1interfaz_fifo.D_push[0][w]<=instancia_entrada_DUT_2[w].D_push; //El valor obtenido se asigna a la iterfaz de la fifo con el DUT
              #1interfaz_fifo.pndng[0][w]<=1'b1; //la bandera de pendiente de la interfaz se marca como activa
              contador_payload++; //se cuenta la trasaccion realizada satisfactoriamente 
              $display("t = %0t Driver: Se ha prendido la bandera de pending del Fifo[%0d]",$time,w);
              @(negedge interfaz_fifo.pop[0][w]) //para luego de realizar lo anterior se busca que apenas sea posible, saque el dato del DUT en la ubicacion del controlador
              if (instancia_entrada_DUT_2[w].D_push[profundidad-1:0] < controladores)begin //si 
              tiempo_envio=$time;
                arrayglobal[tiempo_envio]=instancia_entrada_DUT_2[w].D_push[profundidad-1:0]; //el array global sirve para luego corrobarar los datos con el tiempo de envio como índice en el checker
              end
              interfaz_fifo.pndng[0][w]<=1'b0; //una vez sacado, se restablece a cero la bandera del pending 
            end
            end
          end
        join_none
      end
  endtask
endclass

    // Fin del modulo para definir el bloque del driver del ambiente //