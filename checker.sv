////////////////////////////////////////////////////////////////////////////////////////////////////
// Checker/scoreboard: este objeto es responsable de verificar que el comportamiento del DUT sea el esperado //
////////////////////////////////////////////////////////////////////////////////////////////////////

class checker #(parameter tama_de_paquete,message,broadcast,controladores,caso,opcion);
  mailbox monitor_al_checker; 
  mailbox agente_al_checker;
  trans_entrada_DUT #(.tama_de_paquete(tama_de_paquete),.controladores(controladores),.caso(caso),.opcion(opcion)) del_agente;
  trans_salida_DUT  #(.tama_de_paquete(tama_de_paquete))item_moni;
  bit [tama_de_paquete-1:tama_de_paquete-8] suma_mensajes [message];
  bit [tama_de_paquete-9:0]cajon1[$];
  int tiempo_envio;
  int suma_timepo;
  string mensaje;
  string pa_la_hoja;
  real tiempo_simulacion;
  int counter[0:controladores];
  

  task sumador_de_mensajes();
    for (int i=0;i<message;i++)begin
      agente_al_checker.get(del_agente);
      suma_mensajes[i] = del_agente.contenido;
    end
  endtask




  task run();
    $display("t = %0t Checker: iniciado el proceso",$time);
      del_monitor=new;
      del_agente=new;
      sumador_de_mensajes();
      $display("t = %0t Checker: Se han obtenido los mensajes del generador",$time);

      forever begin
        


       end

  endtask

endclass 
