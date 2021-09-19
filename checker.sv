// Inico del modulo para definir el bloque del checker del ambiente //
int arrayglobal [$];

class Checker#(parameter profundidad,message,broadcast,controladores);
  mailbox monitor_al_checker; 
  mailbox agente_al_checker;
  mailbox test_al_checker;
  trans_entrada_DUT #(.profundidad(profundidad),.controladores(controladores)) del_agente;
  trans_salida_DUT  #(.profundidad(profundidad))del_monitor;
  solicitud_checker reporte;
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
  int contador2 = 0;
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
        $display ("Tiempo de verificacion: %0d", del_monitor.buffer_retraso);
        repositorio_de_mensajes=arrayglobal.find_index with (message==del_monitor.D_pop[profundidad-1:0]);
        tiempo_envio = repositorio_de_mensajes[0];
        arrayglobal[tiempo_envio]=0;
        ttime = del_monitor.retraso-tiempo_envio;
       	control_de_tiempos = suma_tiempos;
        suma_tiempos = control_de_tiempos+ttime;
        retraso_por_dispositivo[del_monitor.numero_fifo]++;
        retrasos_dispositivo[del_monitor.numero_fifo][retraso_por_dispositivo[del_monitor.numero_fifo]] = ttime;
        #10if (del_monitor.D_pop[profundidad-1:0] == broadcast) begin 
        $display("t = %0t Checker: Mensaje enviado por broadcast",$time); end
        contador = 0;
        #1for (int i=0;i<message;i++) begin
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
              contador2 ++;
            end 
          end
        end
        
        if (contador == 0) $display("El destino del mensaje es incorrecto");
        tiempo_simulacion=$time;
        
        if (contador2 == message)begin
          $display(" REPORTE DE LA PRUEBA %0d", contador2);
          estadisticas(controladores, profundidad, message, tiempo_simulacion);
        end
       end
    endtask

  
  
  

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




task estadisticas (int controladores, profundidad, message, tiempo_simulacion);
	real ancho_banda;
  	real retraso_promedio;
  ancho_banda=(message*profundidad*1000)/tiempo_simulacion; //calculo del ancho de banda
    //retraso_promedio=Checker.suma_tiempos/Checker.contador;//calculo el retraso promedio total
  $display ("Tiempo de simulación: %0d", tiempo_simulacion);
    $display("Ancho de banda: El ancho de banda total promedio fue de %0.1f x10^9 Hz,utilizando %0d dispositivos y una profundidad de Fifos de %0d",ancho_banda, controladores, profundidad);
    lector_csv(controladores, profundidad, message, tiempo_simulacion);
  
endtask


task lector_csv(int controladores, profundidad, message, tiempo_simulacion);
  int fd;
  int tiempo_envio [$];
  int tiempo_llegada [$];
  int atraso [$];
  int mensaje [$];
  int dispositivo [$];
  int imprimible [$];
  int counter = 0;
  int contador_de_total_mensajes[$];
  string pa_la_hoja;
  string ms, dis, te, tl, at;
  int promedio, suma;

  fd = $fopen("./simulacion.csv", "r");
  if(fd) $display ("Archivo encontrado y abierto en modo lectura");
  else $display ("Archivo no encontrado");

  for(int i = 0; i < tb.message; i++) begin
    $fscanf(fd, "%0d,%0d,%0d,%0d,%0d", dispositivo[i], mensaje[i], tiempo_envio[i], tiempo_llegada[i], atraso[i]);
  end
  $fclose(fd);
  
  for (int i = 0; i < mensaje.size(); i++)begin
    tiempo_envio[i] = tiempo_llegada[i-1];
    atraso[i] = tiempo_llegada[i] - tiempo_envio[i];
    ms.itoa(mensaje[i]);
    dis.itoa(dispositivo[i]);
    tl.itoa(tiempo_llegada[i]);
    te.itoa(tiempo_envio[i]);
    at.itoa(atraso[i]);
    pa_la_hoja = {dis,",",ms,",",te,",",tl,",",at};
    $system($sformatf("echo %0s >> simulacion2.csv", pa_la_hoja));
  end

  for (int i = 0; i < tb.dispositivos; i++) begin
    contador_de_total_mensajes = dispositivo.find_index with (item == i);
    $display ("Dispositivo: %0d, Cantidad de mensajes enviados a ese dispositivo: %0d", i, contador_de_total_mensajes.size());
    if (contador_de_total_mensajes.size() != 0)begin
      for(int c = 0; c < contador_de_total_mensajes.size; c++) begin
        suma = atraso[contador_de_total_mensajes[c]]++;
      end
      promedio = suma/contador_de_total_mensajes.size;
      $display ("Retraso promedio para ese dispositivo: %0d ns", promedio);
    end
  end
  $display("Retraso: El retraso promedio de los mensajes que fueron recibidos fue de %0.01f ns, utilizando %0d dispositivos y una profundidad de Fifo de %0d",atraso.sum()/message, controladores, profundidad);
endtask

