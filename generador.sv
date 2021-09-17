
class Generador#(parameter message, tama_de_paquete,controladores,caso,opcion,broadcast);
  mailbox generador_al_agente;
  event agen_listo;
  tipos_de_transaccion tipo_llenado=caso;
  cas_esq caso_de_esquina = opcion; 
  
  
  task run();
    case(tipo_llenado)
        llenado_aleatorio:
          begin 
            $display("t = %0t Generador: Se ha escogido la transaccion de llenado aleatorio", $time);
            for (int i = 0; i < message; i++) begin
              trans_entrada_DUT #(.tama_de_paquete(tama_de_paquete),.controladores(controladores),.caso(caso),.opcion(opcion)) valor1;
              valor1 = new;
              valor1.randomize();
              valor1.item1.constraint_mode(0);
              for ( int h=0; h < valor1.delay;h++)
                      begin
                        #1ns;
                      end
              
              generador_al_agente.put(valor1);
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
        
        llenado_especifico: 
          begin
            $display("t = %0t Generador: Se ha escogido la transaccion de llenado especifico", $time);
            for (int i = 0; i < message; i++) begin
              trans_entrada_DUT #(.tama_de_paquete(tama_de_paquete),.controladores(controladores),.caso(caso),.opcion(opcion)) valor2; 
              valor2 = new;
              valor2.randomize();
              case (caso_de_esquina)
                ceros:
                  begin
                    $display("t = %0t Ambiente: Se ha escogido el caso de opcion con un contenido de ceros", $time);
            		valor2.contenido = {8{1'b0}}; // 0
                  end

        	    unos:
          		  begin
            		$display("t = %0t Ambiente: Se ha escogido el caso de opcion con un contenido de unos", $time);
            		valor2.contenido = 8'b11111111; // 255
          		  end

        		ceroyunos:
          		  begin
            		$display("t = %0t Ambiente: Se ha escogido el caso de opcion con un contenido de ceros-unos", $time);
            		valor2.contenido= 8'b01010101;
          		 
                  end

        		direccion_incorrecta:
          		 begin
            		$display("t = %0t Ambiente: Se ha escogido el caso de opcion con una direccion incorrecta", $time);
                   valor2.item1.constraint_mode(1);
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
                  $display("t = %0t Ambiente: Se ha escogido aleatorizar el uso del reset",$time);
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