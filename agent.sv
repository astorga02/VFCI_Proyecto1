// Inico del modulo para definir el bloque del agente del ambiente //


class Agente#(parameter tama_de_paquete,controladores,caso,opcion);
  event agen_listo;
  mailbox agente_al_driver;
  mailbox agente_al_checker;
  mailbox generador_al_agente;
  Bus_trans #(.tama_de_paquete(tama_de_paquete),.controladores(controladores),.caso(caso),.opcion(opcion)) mensaje;
  

  task run();
    mensaje=new;
    begin
      generador_al_agente.get(mensaje);
      $display("t = %0tAgente: Transacción ha llegado al agente",$time);

      agente_al_driver.put(mensaje);
      $display("t = %0tAgente: Transacción enviada al Driver",$time);

      end
  endtask


endclass
