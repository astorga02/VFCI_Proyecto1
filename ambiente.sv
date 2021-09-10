///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Ambiente: este módulo es el encargado de conectar todos los elementos del ambiente para que puedan ser usados por el test //
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
class ambiente #(parameter tama_de_paquete, controladores,BITS,message,tam_fifo,broadcast,caso,opcion);
  Generador #(.message(message),.tama_de_paquete(tama_de_paquete),.controladores(controladores),.caso(caso),.opcion(opcion),.broadcast(broadcast)) generador_instancia;
  Agente #(.tama_de_paquete(tama_de_paquete),.controladores(controladores),.caso(caso),.opcion(opcion)) agente_instancia;
  Monitor #(.controladores(controladores),.tam_fifo(tam_fifo),.BITS(BITS),.tama_de_paquete(tama_de_paquete)) monitor_instancia;
  Driver #(.controladores(controladores),.tam_fifo(tam_fifo),.BITS(BITS),.tama_de_paquete(tama_de_paquete),.caso(caso),.opcion(opcion)) controlador_instancia;
  Checker #(.tama_de_paquete(tama_de_paquete),.message(message),.broadcast(broadcast),.controladores(controladores),.caso(caso),.opcion(opcion)) checker_instancia;
  mailbox generador_al_agente;
  mailbox agente_al_driver;
  mailbox monitor_al_checker;
  mailbox agente_al_checker;
  mailbox driver_al_checker;
 

  function new();
    generador_al_agente=new();
    agente_al_checker=new();
    agente_al_driver=new();
    checker_instancia=new();
    monitor_al_checker=new();
    controlador_instancia=new();
    monitor_instancia=new;
    generador_instancia=new;
    agente_instancia=new;
    generador_instancia.generador_al_agente = generador_al_agente;
    agente_instancia.agente_al_driver=agente_al_driver;
    agente_instancia.agente_al_checker=agente_al_checker;
    monitor_instancia.monitor_al_checker=monitor_al_checker;
    agente_instancia.generador_al_agente = generador_al_agente;
    generador_instancia.agen_listo=agen_listo;
    agente_instancia.agen_listo=agen_listo;
    controlador_instancia.agente_al_driver=agente_al_driver;
    checker_instancia.monitor_al_checker=monitor_al_checker;
    checker_instancia.agente_al_checker=agente_al_checker;
    checker_instancia.agen_listo=agen_listo; 
  endfunction

 
  task run();
    fork
      generador_instancia.run();
      agente_instancia.run();
      controlador_instancia.run();
      monitor_instancia.run();
      checker_instancia.run();
    join
  endtask

endclass
