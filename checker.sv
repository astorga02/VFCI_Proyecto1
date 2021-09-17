////////////////////////////////////////////////////////////////////////////////////////////////////
// Checker/scoreboard: este objeto es responsable de verificar que el comportamiento del DUT sea el esperado //
////////////////////////////////////////////////////////////////////////////////////////////////////

// Inico del modulo para definir el bloque del checker del ambiente //
int arrayglobal [$];

class Checker#(parameter tama_de_paquete,message,broadcast,controladores,caso,opcion);
    mailbox monitor_al_checker;
    mailbox agente_al_checker;
  	trans_entrada_DUT #(.tama_de_paquete(tama_de_paquete),.controladores(controladores),.caso(caso),.opcion(opcion)) del_agente;
  	trans_salida_DUT  #(.tama_de_paquete(tama_de_paquete))del_monitor;
  	event agen_listo;
  bit [tama_de_paquete-1:0] suma_mensajes [message];
  bit [tama_de_paquete-1:0]copia_de_seguridad[$];
  bit [tama_de_paquete-1:0] estructura_payload [3][message];
  
  int prueba=0;
  
  	int repositorio_de_mensajes[$];
  	int ttime;
    int suma_tiempos;
    int tiempo_envio;
    int control_de_tiempos;
  	string pa_la_hoja;
  	real tiempo_simulacion;
  	int retraso_por_dispositivo[0:controladores];
    int retrasos_dispositivo [0:controladores-1][0:message-1];
  
  
  

  
  int contador = 0;
  
    task run();
      $display("t = %0t Checker: iniciado el proceso",$time);
      del_monitor=new;
      del_agente=new;

      //   cuento la cantidad de mensajes
      for (int i=0;i<message;i++)begin
        agente_al_checker.get(del_agente);
      	suma_mensajes[i] = del_agente.contenido;
        prueba = del_agente.numero_fifo;
        $display("Checker: Verificacion de mensajes desde el agente y guardado en la estructura de comprobacion: %0d", del_agente.contenido);
        estructura_payload[1][i] = del_agente.contenido;
        $display("Checker: Verificacion de fifo desde el agente y guardado en la estructura de comprobacion: %0d", del_agente.numero_fifo);
        estructura_payload[2][i] = del_agente.numero_fifo;
        if (estructura_payload[2][i] >= del_agente.destino)begin
          $display("Checker: El destino del mensaje es incorrecto, destino del mensaje fuera del rango del BUS.");
        end
        
        
      end


      #1$display("t = %0t Checker: Se han obtenido suma_mensajes los mensajes que haya generado el TB",$time);
      $system("echo Dispositivo, Mensaje, Tiempo de envio[ns],Tiempo de llegada [ns], Retraso del mensaje[ns] > simulacion.csv");
      forever begin//un ciclo forever para que corra una y otra vez
        #1monitor_al_checker.get(del_monitor);
        contador = contador + 1;
        #1del_monitor.print("Checker: Mensaje a revisar en el DUT:");
        #1copia_de_seguridad=suma_mensajes.find(x) with (x==del_monitor.D_pop[tama_de_paquete-1:0]);
        repositorio_de_mensajes=arrayglobal.find_index with (message==del_monitor.D_pop[tama_de_paquete-1:0]);
        tiempo_envio=repositorio_de_mensajes[0];
        arrayglobal[tiempo_envio]=0;
        ttime=del_monitor.retraso-tiempo_envio;
       	control_de_tiempos=suma_tiempos;
        suma_tiempos=control_de_tiempos+ttime;
        retraso_por_dispositivo[del_monitor.numero_fifo]++;
        retrasos_dispositivo[del_monitor.numero_fifo][retraso_por_dispositivo[del_monitor.numero_fifo]]=ttime;
        #1if (del_monitor.D_pop[tama_de_paquete-1:0]==broadcast) begin 
        $display("t = %0t Checker: Mensaje enviado por broadcast",$time); end
        #1for (int i=0;i<message;i++)begin
          if (estructura_payload[2][i] == del_monitor.numero_fifo)begin
            if (estructura_payload[1][i] == del_monitor.D_pop[tama_de_paquete-1:0])begin
              $display("t = %0t Checker: El destino del mensaje es correcto. FIFO esperado = %0d, FIFO analizado = %0d", $time, estructura_payload[2][i], del_monitor.numero_fifo);
                $display("t = %0t Checker: Contenido del mensaje  de esa FIFO es correcto. Dato esperado en esa FIFO = %0d, Dato analizado en esa FIFO = %0d", $time, estructura_payload[1][i], del_monitor.D_pop[tama_de_paquete-1:0]);
              estructura_payload[1][i] = 0;
              estructura_payload[2][i] = 0;
              envio_a_la_hoja();
            end 
          end 
        end
       end
    endtask

  
  string mensaje;
  string retraso_por_dispositivo;
  string atraso_csv;
  string llegada_csv;
  string envio_csv;

  task envio_a_la_hoja();
    mensaje.itoa(del_monitor.D_pop);
    retraso_por_dispositivo.itoa(del_monitor.numero_fifo);
    atraso_csv.itoa(ttime);
    llegada_csv.itoa(del_monitor.retraso);
    envio_csv.itoa(tiempo_envio);
    pa_la_hoja = {retraso_por_dispositivo,",",mensaje,",",envio_csv,",",llegada_csv,",",atraso_csv};
    $system($sformatf("echo %0s >> simulacion.csv", pa_la_hoja));
  endtask
  
endclass

    // Fin del modulo para definir el bloque del checker del ambiente //
