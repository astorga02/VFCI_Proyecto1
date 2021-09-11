// Inico del modulo para definir el bloque del agente del ambiente //


class Agente#(parameter tama_de_paquete,controladores,caso,opcion);
  event agen_listo;
  mailbox agente_al_driver;
  mailbox agente_al_checker;
  mailbox generador_al_agente;
  

  task run();
    mensaje=new;
    begin
      generador_al_agente.get(mensaje);
      $display("t = %0tAgente: Transacción ha llegado al agente",$time);

      end
  endtask


endclass
