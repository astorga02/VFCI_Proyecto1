// Inico del modulo para definir el bloque del checker del ambiente //
int arrayglobal [$];

class Checker#(parameter profundidad,message,broadcast,controladores);
  mailbox monitor_al_checker; 
  mailbox agente_al_checker;
  trans_entrada_DUT #(.profundidad(profundidad),.controladores(controladores)) del_agente;
  trans_salida_DUT  #(.profundidad(profundidad))del_monitor;
  event agen_listo;
  bit [profundidad-1:0] suma_mensajes [message];
  bit [profundidad-1:0] estructura_payload [3][message];
  int repositorio_de_mensajes[$];
  int ttime,tiempo_envio,suma_tiempos,control_de_tiempos;
  string mensaje,retraso_por_dispositivo,atraso_csv,llegada_csv,envio_csv;
  string pa_la_hoja;
  real tiempo_simulacion;
  int retraso_por_dispositivo[0:controladores];
  int retrasos_dispositivo [0:controladores-1][0:message-1];
  int prueba=0;
  int contador;
  
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

         
      forever begin

        #1monitor_al_checker.get(del_monitor);
        contador = contador + 1;
        #1del_monitor.print("Checker: Mensaje a revisar en el DUT:");
        repositorio_de_mensajes=arrayglobal.find_index with (message==del_monitor.D_pop[profundidad-1:0]);
        tiempo_envio = repositorio_de_mensajes[0];
        arrayglobal[tiempo_envio]=0;
        ttime = del_monitor.retraso-tiempo_envio;
       	control_de_tiempos = suma_tiempos;
        suma_tiempos = control_de_tiempos+ttime;
        retraso_por_dispositivo[del_monitor.numero_fifo]++;
        retrasos_dispositivo[del_monitor.numero_fifo][retraso_por_dispositivo[del_monitor.numero_fifo]] = ttime;
        #1if (del_monitor.D_pop[profundidad-1:0] == broadcast) begin 
        $display("t = %0t Checker: Mensaje enviado por broadcast",$time); end
        contador = 0;
        #1for (int i=0;i<message;i++)begin
          if (estructura_payload[2][i] == del_monitor.numero_fifo)begin
            if (estructura_payload[1][i] == del_monitor.D_pop[profundidad-1:0])begin
              $display("t = %0t Checker: El destino del mensaje es correcto. FIFO esperado = %0d, FIFO analizado = %0d", $time, estructura_payload[2][i], del_monitor.numero_fifo);
                $display("t = %0t Checker: Contenido del mensaje  de esa FIFO es correcto. Dato esperado en esa FIFO = %0d, Dato analizado en esa FIFO = %0d", $time, estructura_payload[1][i], del_monitor.D_pop[profundidad-1:0]);
              $display (" /\\  /\\  /\\  /\\  /\\  /\\  /\\  /\\  /\\  /\\");
            	$display (" ||  ||  ||  ||  ||  ||  ||  ||  ||  || ");
            	$display (" - - - - - - - - -  - - - - - - - - - - ");
              estructura_payload[1][i] = 0;
              estructura_payload[2][i] = 0;
              envio_a_la_hoja();
              contador ++;
            end 
          end 
        end
        if (contador == 0) $display("El destino del mensaje es incorrecto");
       end
      tiempo_simulacion=$time;
    endtask
	
  
  /*task reporte();
    if(test_al_checker.num()>0)begin
      $display("Aquiiiii");
    end
  endtask*/
  
  
  
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
