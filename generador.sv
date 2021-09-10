//////////////////////////////////////////////////////////////////////////////////////////////////
// Agente/Generador: Este bloque se encarga de generar las secuencias de eventos para el driver //
// En este ejemplo se generarán 2 tipos de secuencias:                                          //
//    llenado_vaciado: En esta se genera un número parametrizable de tarnsacciones de lecturas  //
//                     y escrituras para llenar y vaciar la fifo.                               //
//    Aleatoria: En esta se generarán transacciones totalmente aleatorias                       //
//    Específica: en este tipo se generan trasacciones semi específicas para casos esquina      // 
//////////////////////////////////////////////////////////////////////////////////////////////////

typedef enum{llenado_aleatorio, llenado_especifico} tipos_de_transaccion;


typedef enum {ceros, unos, ceroyunos, direccion_incorrecta, broadcasttt} cas_esq;


class Generador#(parameter message, tama_de_paquete,controladores,caso,opcion,broadcast);
    mailbox generador_al_agente;
    tipos_de_transaccion tipo_llenado = caso;

task run();
    case(tipo_llenado)
        llenado_aleatorio: 
          begin 
            $display("t = %0t Generador: Se ha escogido la transaccion de llenado aleatorio", $time);
          end
        llenado_especifico: //genera una transaccion con algunos datos especificos
          begin
            $display("t = %0t Generador: Se ha escogido la transaccion de llenado especifico", $time);
            for (int i = 0; i < message; i++) begin
              trans_entrada_DUT #(.tama_de_paquete(tama_de_paquete),.controladores(controladores),.caso(caso),.opcion(opcion)) valor; //creamos una nueva transacción
              valor = new;
              valor.randomize();
              case (caso_de_esquina)//en el case se asignan algunos valores que no sean aleatorios, dependiendo del caso elegido
                ceros:
                  begin
                    $display("t = %0t Ambiente: Se ha escogido el caso de opcion con un contenido de ceros", $time);
            		valor.contenido = {8{1'b0}};
                  end

        	    unos:
          		  begin
            		$display("t = %0t Ambiente: Se ha escogido el caso de opcion con un contenido de unos", $time);
            		valor.contenido = 8'b11111111;
          		  end

        		ceroyunos:
          		  begin
            		$display("t = %0t Ambiente: Se ha escogido el caso de opcion con un contenido de ceros y unos", $time);
            		valor.contenido= 8'b01010101;
          		  end

        		direccion_incorrecta:
          		 begin
            		$display("t = %0t Ambiente: Se ha escogido el caso de opcion con una direccion incorrecta", $time);
          		 end
        
        		broadcasttt:
          		  begin
            		$display("t = %0t Ambiente: Se ha escogido mandar mensajes con broadcast", $time);
            		valor.destino=broadcast;
          		  end
        
      		endcase
         
          end
    endcase
  endtask
endclass