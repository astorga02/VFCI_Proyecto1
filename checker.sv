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
  int suma_timepo;
  string mensaje;
  string pa_la_hoja;
  real tiempo_simulacion;
  int counter[0:controladores];
  int contador;
  int control_de_tiempos;

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
      sumador_de_mensajes();
      $display("t = %0t Checker: Se han obtenido los mensajes del generador",$time);

      forever begin
        contador = contador + 1;
        monitor_al_checker.get(del_monitor);
        del_monitor.print("Checker: Mensaje a checkear:");
        repositorio_de_mensajes = arrayglobal.find_index with (message == del_monitor.D_push[tama_de_paquete-9:0]);
        ttime=del_monitor.retraso-tiempo_envio;
        sumat=control_de_tiempos+ttime;

        
      end

  endtask

endclass 
