    // Inico del modulo para definir el ambiente //

class Ambiente#(parameter profundidad, controladores,BITS,message,broadcast);
  Generador #(.message(message),.profundidad(profundidad),.controladores(controladores),.broadcast(broadcast)) generador_instancia;
  Agente #(.profundidad(profundidad),.controladores(controladores)) agente_instancia;
  Monitor #(.controladores(controladores),.BITS(BITS),.profundidad(profundidad)) monitor_instancia;
  Driver #(.controladores(controladores),.BITS(BITS),.profundidad(profundidad)) controlador_instancia;
  Checker #(.profundidad(profundidad),.message(message),.broadcast(broadcast),.controladores(controladores)) checker_instancia;
  mailbox generador_al_agente;
  mailbox agente_al_driver;
  mailbox monitor_al_checker;
  mailbox agente_al_checker;
  mailbox driver_al_checker;
  //mailbox test_al_generador;
  //mailbox test_al_checker;
  
  event agen_listo;
  virtual Int_fifo #(.profundidad(profundidad),.controladores(controladores),.BITS(BITS))interfaz_fifo;
 
  
  function new();
    //test_al_generador = new();
    //test_al_checker = new();
    generador_al_agente=new();
    agente_al_driver=new();
    agente_al_checker=new();
    monitor_al_checker=new();
    generador_instancia=new;
    generador_instancia.generador_al_agente = generador_al_agente;
    agente_instancia=new;
    agente_instancia.generador_al_agente = generador_al_agente;
    agente_instancia.agente_al_driver=agente_al_driver;
    agente_instancia.agente_al_checker=agente_al_checker;
    monitor_instancia=new;
    monitor_instancia.monitor_al_checker=monitor_al_checker;
    generador_instancia.agen_listo=agen_listo;
    agente_instancia.agen_listo=agen_listo;
    controlador_instancia=new();
    controlador_instancia.agente_al_driver=agente_al_driver;
    checker_instancia=new();
    checker_instancia.monitor_al_checker=monitor_al_checker;
    checker_instancia.agente_al_checker=agente_al_checker;
    checker_instancia.agen_listo=agen_listo; 
  endfunction
  
  
  task run();
    
    monitor_instancia.interfaz_fifo = interfaz_fifo;
    controlador_instancia.interfaz_fifo=interfaz_fifo;
    fork
      generador_instancia.run();
      agente_instancia.run();
      controlador_instancia.run();
      monitor_instancia.run();
      checker_instancia.run();
    join_none
  endtask
  
endclass

    // Fin del modulo para definir el ambiente //