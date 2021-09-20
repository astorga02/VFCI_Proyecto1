  // Generador //
class Generador#(parameter message, profundidad,controladores,broadcast);
  mailbox generador_al_agente;
  event agen_listo;
  tipos_de_transaccion tipo_llenado; //declacion de los tipos de transaccion a ser usados por el mailbox directo entre el testbench y el generador
  cas_esq caso_de_esquina; 
  
  
  task run();  // tasp principal 
    tb.test_al_generador.get(tipo_llenado);   //obtengo el mailbox de tipo de llenado desde el test y lo asigno a una variable a ingresar en el case
    case(tipo_llenado)
        llenado_aleatorio: //llena aleaotorizando el tiempo de envio, el disposiivio, el contenido del mensaje y envio de muchas transacciones a dispostivios sin ser checkedas aún
          begin 
            $display("t = %0t Generador: Se ha escogido la transaccion de llenado aleatorio", $time);
            for (int i = 0; i < message; i++) begin
              trans_entrada_DUT #(.profundidad(profundidad),.controladores(controladores)) instancia_entrada_DUT_1; //instancio la transaccion de entrada del DUT para ser usado como payload
              instancia_entrada_DUT_1 = new; // construccion de la instandia de la transaccion de entrada
              instancia_entrada_DUT_1.randomize(); // aleaotorizo todos los objetos respetando los constraints para los objetos 
              instancia_entrada_DUT_1.rest_num_fifo.constraint_mode(0); // activo el constraint para el caso del numero maximo de dispositivos o FIFO'S
              for ( int h=0; h < instancia_entrada_DUT_1.delay;h++) //aleatorizo el tiempo de envio de la instruccion del payload con un cliclo for y el delay aleatorio
                      begin
                        #1ns;
                      end
              
              generador_al_agente.put(instancia_entrada_DUT_1); //nevio el payload usando el mailbox
              @(agen_listo); //indico que el agente envió correctamte la instruccion al generador para que contniue con la proxima transaccion 
                end
            $display (" ||  ||  ||  ||  ||  ||  ||  ||  ||  || ");
            $display (" ||  ||  ||  ||  ||  ||  ||  ||  ||  || ");
            $display (" \\/  \\/  \\/  \\/  \\/  \\/  \\/  \\/  \\/  \\/");
            $display ("t = %0t Generador: Generados los %0d mensajes", $time, message);
            $display (" /\\  /\\  /\\  /\\  /\\  /\\  /\\  /\\  /\\  /\\");
            $display (" ||  ||  ||  ||  ||  ||  ||  ||  ||  || ");
            $display (" ||  ||  ||  ||  ||  ||  ||  ||  ||  || ");
          end
        
        llenado_especifico: //genera una transaccion con algunos datos especificos
          begin
            $display("t = %0t Generador: Se ha escogido la transaccion de llenado especifico", $time);
            for (int i = 0; i < message; i++) begin
              trans_entrada_DUT #(.profundidad(profundidad),.controladores(controladores)) instancia_entrada_DUT_2; // lo mismo que con la aleaotorizacion
              instancia_entrada_DUT_2 = new;
              instancia_entrada_DUT_2.randomize();
              tb.test_al_generador.peek(caso_de_esquina);
              case (caso_de_esquina) // establece los casos de esquina y las limitaciones para cada caso como ceros, unos, un dispositivo, etc
                ceros:
                  begin
                    $display("t = %0t Ambiente: Se ha escogido el caso de opcion con un contenido de ceros", $time);
            		    instancia_entrada_DUT_2.contenido = {instancia_entrada_DUT_2.profundidad{1'b0}};
                  end

                unos:
                  begin
                    $display("t = %0t Ambiente: Se ha escogido el caso de opcion con un contenido de unos", $time);
                    instancia_entrada_DUT_2.contenido = {instancia_entrada_DUT_2.profundidad{1'b1}};
                  end

                ceroyunos:
                    begin
                    $display("t = %0t Ambiente: Se ha escogido el caso de opcion con un contenido de ceros-unos", $time);
                    instancia_entrada_DUT_2.contenido= 8'b01010101;
                    end

                direccion_incorrecta:
                  begin
                    $display("t = %0t Ambiente: Se ha escogido el caso de opcion con una direccion incorrecta", $time);
                    instancia_entrada_DUT_2.rest_num_fifo.constraint_mode(1);
                    instancia_entrada_DUT_2.numero_fifo = instancia_entrada_DUT_2.destino + instancia_entrada_DUT_2.numero_fifo;
                  end
            
                broadcasttt:
                  begin
                    $display("t = %0t Ambiente: Se ha escogido mandar mensajes con broadcast",$time);
                    instancia_entrada_DUT_2.contenido=broadcast;
                  end
            
                un_dispo:
                  begin
                    instancia_entrada_DUT_2.numero_fifo = tb.destino;
                    $display("t = %0t Ambiente: Se ha escogido enviar datos a un solo dispostivo, el dispositivo es el: %0d",$time, instancia_entrada_DUT_2.numero_fifo);
                  end
        
      		endcase
              for ( int h=0; h<instancia_entrada_DUT_2.delay;h++) //aleatorizo el tiempo de envio de la instruccion del payload con un cliclo for y el delay aleatorio
                      begin
                        #1ns;
                      end
              	generador_al_agente.put(instancia_entrada_DUT_2);
                  @(agen_listo);
              end
            $display ("t = %0t Generador: Lista la creacion y envio de los mensajes al driver y al checker", $time, message);
          end
    endcase
  endtask
endclass
