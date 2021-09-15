// Inico del modulo para definir el bloque del agente del ambiente //


class Agente#(parameter tama_de_paquete,controladores,caso,opcion);
  mailbox agente_al_driver;
  mailbox agente_al_checker;
  mailbox generador_al_agente;
  Bus_trans #(.tama_de_paquete(tama_de_paquete),.controladores(controladores),.caso(caso),.opcion(opcion)) mensaje;
  
  task run();
    mensaje=new;
    forever begin
      generador_al_agente.get(mensaje);
      $display("t = %0tAgente: Transacción ha llegado al agente",$time);
      mensaje.D_pop={mensaje.destino,mensaje.contenido};
      $display ("t = %0tAgente: Contenido de la transacción: Numero de Fifo=%0d,Mensaje %0d",$time,mensaje.numero_fifo,mensaje.D_pop);
      agente_al_driver.put(mensaje);
      $display("t = %0tAgente: Transacción enviada al Driver",$time);
      agente_al_checker.put(mensaje);
      $display("t = %0tAgente: Transacción enviada al Checker",$time);
      end
  endtask


endclass
