

  // Generador //
class Generador#(parameter message, profundidad,controladores,broadcast);
  mailbox generador_al_agente;
  event agen_listo;
  tipos_de_transaccion tipo_llenado;
  cas_esq caso_de_esquina; 
  
  //string data;
  
  
  task run();  
    $display ("Generador: Senal de vida: %0d", tb.test_al_generador.num());
    tb.test_al_generador.get(tipo_llenado);
    case(tipo_llenado)
        llenado_aleatorio: 
          begin 
            $display("t = %0t Generador: Se ha escogido la transaccion de llenado aleatorio", $time);
            for (int i = 0; i < message; i++) begin
              trans_entrada_DUT #(.profundidad(profundidad),.controladores(controladores)) instancia_entrada_DUT_1;//creamos una nueva transacción
              instancia_entrada_DUT_1 = new;
              instancia_entrada_DUT_1.randomize();
              instancia_entrada_DUT_1.rest_num_fifo.constraint_mode(0);
              for ( int h=0; h < instancia_entrada_DUT_1.delay;h++)
                      begin
                        #1ns;
                      end
              
              generador_al_agente.put(instancia_entrada_DUT_1);
              @(agen_listo);
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
              trans_entrada_DUT #(.profundidad(profundidad),.controladores(controladores)) valor2; 
              valor2 = new;
              valor2.randomize();
              tb.test_al_generador.peek(caso_de_esquina);
              case (caso_de_esquina)
                ceros:
                  begin
                    $display("t = %0t Ambiente: Se ha escogido el caso de opcion con un contenido de ceros", $time);
            		    valor2.contenido = {valor2.profundidad{1'b0}};
                  end

                unos:
                  begin
                    $display("t = %0t Ambiente: Se ha escogido el caso de opcion con un contenido de unos", $time);
                    valor2.contenido = {valor2.profundidad{1'b1}};
                  end

                ceroyunos:
                    begin
                    $display("t = %0t Ambiente: Se ha escogido el caso de opcion con un contenido de ceros-unos", $time);
                    valor2.contenido= 8'b01010101;
                    end

                direccion_incorrecta:
                  begin
                    $display("t = %0t Ambiente: Se ha escogido el caso de opcion con una direccion incorrecta", $time);
                    valor2.rest_num_fifo.constraint_mode(1);
                    valor2.numero_fifo = valor2.destino + valor2.numero_fifo;
                  end
            
                broadcasttt:
                  begin
                    $display("t = %0t Ambiente: Se ha escogido mandar mensajes con broadcast",$time);
                    valor2.contenido=broadcast;
                  end
            
                un_dispo:
                  begin
                    valor2.numero_fifo = tb.destino;
                    $display("t = %0t Ambiente: Se ha escogido enviar datos a un solo dispostivo, el dispositivo es el: %0d",$time, valor2.numero_fifo);
                  end
        
      		endcase
              for ( int h=0; h<valor2.delay;h++)
                      begin
                        #1ns;
                      end
              	generador_al_agente.put(valor2);
                  @(agen_listo);
              end
            $display ("t = %0t Generador: Lista la creacion y envio de los mensajes al driver y al checker", $time, message);
          end
    endcase
  endtask
endclass
