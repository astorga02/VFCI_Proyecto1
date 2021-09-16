////////////////////////////////////////////////////////////////////////////////////////////////////
// Checker/scoreboard: este objeto es responsable de verificar que el comportamiento del DUT sea el esperado //
////////////////////////////////////////////////////////////////////////////////////////////////////

class checker #(parameter tama_de_paquete,message,broadcast,controladores,caso,opcion);
  mailbox monitor_al_checker; 
  mailbox agente_al_checker;
  trans_entrada_DUT #(.tama_de_paquete(tama_de_paquete),.controladores(controladores),.caso(caso),.opcion(opcion)) del_agente;
  trans_salida_DUT  #(.tama_de_paquete(tama_de_paquete)) del_monitor;
  bit [tama_de_paquete-1:tama_de_paquete-8] suma_mensajes [message];
  bit [tama_de_paquete-9:0]cajon1[$];
  int tiempo_envio;
  
  string pa_la_hoja;
  real tiempo_simulacion;
  int counter[0:controladores];
  int contador;
  int control_de_tiempos;
  int suma_tiempos;
  int retrasos_dispositivo [0:controladores-1][0:message-1];
  int retraso_por_dispositivo [0:controladores];
  bit [tama_de_paquete-9:0]copia_de_seguridad[$];

  task sumador_de_mensajes();
    for (int i=0;i<message;i++)begin
      agente_al_checker.get(del_agente);
      suma_mensajes[i] = del_agente.contenido;
    end
  endtask

  contador = 0;


  task run();
    $display("t = %0t Checker: iniciado el proceso",$time);
      del_monitor=new;
      del_agente=new;
      
    
      for (int i=0;i<message;i++)begin
        agente_al_checker.get(del_agente);
        suma_mensajes[i] = del_agente.contenido;
      end





      $display("t = %0t Checker: Se han obtenido los mensajes del generador",$time);

      forever begin
        contador = contador + 1;
        copia_de_seguridad=suma_mensajes.find(x) with (x==del_monitor.D_push[tama_de_paquete-9:0]);
        monitor_al_checker.get(del_monitor);
        del_monitor.print("Checker: Mensaje a checkear:");
        repositorio_de_mensajes = arrayglobal.find_index with (message == del_monitor.D_push[tama_de_paquete-9:0]);
        ttime=del_monitor.retraso-tiempo_envio;
        control_de_tiempos=suma_tiempos;
        suma_tiempos=control_de_tiempos+ttime;
        retraso_por_dispositivo[del_monitor.numero_fifo]++;
        retrasos_dispositivo[del_monitor.numero_fifo][retraso_por_dispositivo[del_monitor.numero_fifo]]=ttime;

        //  Revision de la integridad de los mensajes //
        $display("t = %0t Checker: Mensaje fue enviado con un retraso de: %0d ns",$time,ttime);
        if (del_monitor.D_push[tama_de_paquete-1:tama_de_paquete-8]==broadcast)
          $display("t = %0t Checker: Mensaje enviado mediante broadcast",$time);
        else begin
          if(del_monitor.numero_fifo == del_monitor.D_push[tama_de_paquete-1:tama_de_paquete-8])
          $display("t = %0t Checker: El destino del mensaje es correcto", $time);
          else
          $display("t = %0t Checker: El mensaje llegó a un Fifo erroneo", $time);
        end
        
        //  verificacion de contenidos  //
        if(copia_de_seguridad.size == 0)
          begin
          $display("t = %0t Checker: El contenido del mensaje es incorrecto",$time);
          tiempo_simulacion = $time;
          end
        else 
          $display("t = %0t Checker: El contenido del mensaje es correcto", $time);



      end

  endtask
  string atraso_csv;
  string llegada_csv;
  string envio_csv;
  string mensaje;
  string dispositivo_csv;
  task envio_a_la_hoja();
    mensaje.hextoa(del_monitor.D_push);
    dispositivo_csv.itoa(del_monitor.numero_fifo);
    atraso_csv.itoa(ttime);
    llegada_csv.itoa(del_monitor.retraso);
    envio_csv.itoa(tiempo_envio);
    pa_la_hoja = {dspstv,",",mensaje,",",sndng,",",arrvng,",",rts};
    $system($sformatf("echo %0s >> simulacion.csv", pa_la_hoja));
  endtask


endclass 
