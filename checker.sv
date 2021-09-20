// Inico del modulo para definir el bloque del checker del ambiente //
int arrayglobal [$]; //para comporbar usando los tiempos como índice

class Checker#(parameter profundidad,message,broadcast,controladores);
  mailbox monitor_al_checker; //declaracion de los mailboxes sin incluir el del testebench al checker en esta seccion pero accedido más adelante para obtener el nombre del reporte
  mailbox agente_al_checker;
  trans_entrada_DUT #(.profundidad(profundidad),.controladores(controladores)) del_agente; //instanciacion de las clases del ambiente
  trans_salida_DUT  #(.profundidad(profundidad))del_monitor;
  solicitud_checker reporte; //constante definidad para el nombre del archivo a partir del mailbox desde el testbench
  bit [profundidad-1:0] suma_mensajes [message]; //declaracion de variables para el manejo de nombres, retrasos, estrucutras de comprobacion, comprobacion de payloads desde el DUT y guardado en archivos 
  bit [profundidad-1:0] estructura_payload [3][message];
  int repositorio_de_mensajes[$];
  int ttime,tiempo_envio,suma_tiempos,control_de_tiempos;
  string mensaje,retraso_por_dispositivo,atraso_csv,llegada_csv,envio_csv;
  string pa_la_hoja;
  real tiempo_simulacion; 
  int retraso_por_dispositivo[0:controladores];
  int prueba=0;
  int contador2 = 0; //centinela para llamar a hacer el reporte 
  int contador; //centinela para contar la cantidad de mensajes correctamente analizados
  int fd1;
  
    task run(); //task principal
      $display("t = %0t Checker: iniciado el proceso",$time);
      del_monitor = new; //construccion de las instancias desde el monitor del DUT y desde el agente 
      del_agente = new;
      tb.test_al_checker.peek(reporte); //reviso el nombre del archivo del mailbox desde el testbench para rescatar la informacion de la prueba sin sacarlo del mailbox
      fd1 = $fopen("./simulacion.csv", "w"); //abro un archivo de buffer para los datos de la simualción para ser usado despues como archivo final de salida
      //   cuento la cantidad de mensajes
      for (int i=0;i<message;i++)begin //rescato los payload desde el agente para que luego la estructura sea utilizada para comprobar la saldiad desde el DUT usando el numero de fifo como índice asociado al contenido
        agente_al_checker.get(del_agente);
      	suma_mensajes[i] = del_agente.contenido;
        prueba = del_agente.numero_fifo;
        $display("Checker: Verificacion de mensajes desde el agente y guardado en la estructura de comprobacion: %0d", del_agente.contenido);
        estructura_payload[1][i] = del_agente.contenido;
        $display("Checker: Verificacion de fifo desde el agente y guardado en la estructura de comprobacion: %0d", del_agente.numero_fifo);
        estructura_payload[2][i] = del_agente.numero_fifo;
        if (estructura_payload[2][i] >= del_agente.destino)begin //si el destino desde el agente ya es incorrecto se sabe que el monitor no va a poder entregar un dato valido
          $display("Checker: El destino del mensaje es incorrecto, destino del mensaje fuera del rango del BUS.");
        end
      end
      
         
      forever begin
        #1monitor_al_checker.get(del_monitor); //reviso y saco del mailbox el payload desde el monitor para comprobar la salida
        contador = contador + 1;
        #1del_monitor.print("Checker: Mensaje a revisar en el DUT:"); //uso el monitor como una impresosa de sus propios datos a analizar 
        repositorio_de_mensajes = arrayglobal.find_index with (message==del_monitor.D_pop[profundidad-1:0]); //se buscan los tiempos de los mensajes de que salen de de la transaccion de salida del DUT  
        tiempo_envio = repositorio_de_mensajes[0]; // como es un array 2xn entonces se requiere solo la primera columna de datos para saber el tiempo de envio
        arrayglobal[tiempo_envio] = 0; //vacio ese tiempo de envio del array asociado a el mensaje analziado
        ttime = del_monitor.retraso-tiempo_envio; // calculo el atraso del payload 
       	control_de_tiempos = suma_tiempos;
        suma_tiempos = control_de_tiempos+ttime; //sumo el tiempo de simulación 
        retraso_por_dispositivo[del_monitor.numero_fifo]++; //un array para sumar los retrasos por disposiitivo
        #10if (del_monitor.D_pop[profundidad-1:0] == broadcast) begin //reviso si el mensaje viene por broadcast para indicarlo en la salida del checker
        $display("t = %0t Checker: Mensaje enviado por broadcast",$time); end
        contador = 0;
        #1for (int i=0;i<message;i++) begin //bucle for con un bucle for anidado para comporbar la estructura de comprobacion a paritr de los datos obtenidos desde el monitor
          if (estructura_payload[2][i] == del_monitor.numero_fifo)begin
            if (estructura_payload[1][i] == del_monitor.D_pop[profundidad-1:0])begin
              
              $display("t = %0t Checker: El destino del mensaje es correcto. FIFO esperado = %0d, FIFO analizado = %0d", $time, estructura_payload[2][i], del_monitor.numero_fifo);
              $display("t = %0t Checker: Contenido del mensaje  de esa FIFO es correcto. Dato esperado en esa FIFO = %0d, Dato analizado en esa FIFO = %0d", $time, estructura_payload[1][i], del_monitor.D_pop[profundidad-1:0]);
              $display (" /\\  /\\  /\\  /\\  /\\  /\\  /\\  /\\  /\\  /\\");
            	$display (" ||  ||  ||  ||  ||  ||  ||  ||  ||  || ");
            	$display (" - - - - - - - - -  - - - - - - - - - - ");
              estructura_payload[1][i] = 0; //una vez encontrados se borran de la estructura de comprobacion de para eliminar redundancias de comprobacion 
              estructura_payload[2][i] = 0;
              envio_a_la_hoja(fd1); //como es correcto todo se envia a la hoja buffer
              contador ++; //sumo el contador de mensajes
              contador2 ++; // sumo el centinela que prende el reporte cuando se cumple el numero total de mensajes enviados por el agente
              break;
            end 
          end
        end
        
        if (contador == 0) $display("El destino del mensaje es incorrecto"); //si no se encuetra en la estrucutra de comporbacion fifo junto con su respectivo mensaje entonces el destino es incorrecto
        tiempo_simulacion=$time;
        
        if (contador2 == message)begin //si todo se corroboró entonces se puede obtener un reporte 
          $display(" REPORTE DE LA PRUEBA");
          estadisticas(controladores, profundidad, message, tiempo_simulacion, reporte.name); //funcion que lee la hoja buffer y tambien imprimie las estadisticas a partir de los argumentos y usa el nombre de archivo del reporte a partir del mailbox desde el testbench
        end
       end
    endtask

  
  
  task envio_a_la_hoja(int fd1); //envia la informacion a una hoja de buffer
    mensaje.itoa(del_monitor.D_pop);
    retraso_por_dispositivo.itoa(del_monitor.numero_fifo);
    atraso_csv.itoa(ttime);
    llegada_csv.itoa(del_monitor.retraso);
    envio_csv.itoa(tiempo_envio);
    pa_la_hoja = {retraso_por_dispositivo,",",mensaje,",",envio_csv,",",llegada_csv,",",atraso_csv,"\n"};
    $fwrite(fd1, pa_la_hoja);
  endtask
endclass




function void estadisticas (int controladores, profundidad, message, tiempo_simulacion, string reporte); //da algunas estadisitcas como el ancho de banda y el tiempo de simulacion y llama al lector del archivo buffer para dar otras estadisitcas a partir de esa hoja 
	real ancho_banda;
  	real retraso_promedio;
  ancho_banda=(message*profundidad*1000)/tiempo_simulacion; //calculo del ancho de banda
  $display ("Tiempo de simulación: %0d", tiempo_simulacion);
    $display("Ancho de banda: El ancho de banda total promedio fue de %0.1f x10^9 Hz,utilizando %0d dispositivos y una profundidad de Fifos de %0d",ancho_banda, controladores, profundidad);
  lector_csv(controladores, profundidad, message, tiempo_simulacion, .reporte(reporte));
  return ;
endfunction


task lector_csv(int controladores, profundidad, message, tiempo_simulacion, string reporte); // lee eel archivo buffer y guarda otro archivo como el final con el nombre de archivo configurado en el testbench
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
  string concat;
  int promedio, suma;

  fd = $fopen("./simulacion.csv", "r"); //verifico la existencia del archivo buffer
  if(fd) $display ("Archivo encontrado y abierto en modo lectura");
  else $display ("Archivo no encontrado");

  for(int i = 0; i < tb.message; i++) begin
    $fscanf(fd, "%0d,%0d,%0d,%0d,%0d", dispositivo[i], mensaje[i], tiempo_envio[i], tiempo_llegada[i], atraso[i]);
  end
  $fclose(fd);
  
  concat = {"./", reporte, ".csv"};
  $display("A VEEEER: %s", reporte);
  fd = $fopen(concat, "w");
  
  for (int i = 0; i < mensaje.size(); i++)begin //guardo la hoja con el nommbre de archvio configurado
    tiempo_envio[i] = tiempo_llegada[i-1]+13;
    atraso[i] = tiempo_llegada[i] - tiempo_envio[i];
    ms.itoa(mensaje[i]);
    dis.itoa(dispositivo[i]);
    tl.itoa(tiempo_llegada[i]);
    te.itoa(tiempo_envio[i]);
    at.itoa(atraso[i]);
    pa_la_hoja = {dis,",",ms,",",te,",",tl,",",at,"\n"};
    $fwrite(fd, pa_la_hoja);
  end
	$fclose(fd);
  for (int i = 0; i < tb.dispositivos; i++) begin //analizo los datos para entregar estadísticas exactas por dispositivo
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