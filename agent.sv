//////////////////////////////////////////////////////////////////////////////////////////////////
// Agente: Este bloque se encarga de generar las secuencias de eventos para el driver //
// En este ejemplo se generarán 2 tipos de secuencias:                                          //
//    llenado_vaciado: En esta se genera un número parametrizable de tarnsacciones de lecturas  //
//                     y escrituras para llenar y vaciar la fifo.                               //
//    Aleatoria: En esta se generarán transacciones totalmente aleatorias                       //
//    Específica: en este tipo se generan trasacciones semi específicas para casos esquina      // 
//////////////////////////////////////////////////////////////////////////////////////////////////

// Inico del modulo para definir el bloque del agente del ambiente //
class Agente#(parameter tama_de_paquete,controladores,caso,opcion);
  event agen_listo;
  mailbox generador_al_agente;
  mailbox agente_al_driver;
  mailbox agente_al_checker;
  trans_entrada_DUT #(.tama_de_paquete(tama_de_paquete),.controladores(controladores),.caso(caso),.opcion(opcion)) mensaje;
  
  task run();
    mensaje=new;
    forever begin
      generador_al_agente.get(mensaje);
      $display("t = %0t Agente: Transacción ha llegado al agente",$time);
      mensaje.D_push={mensaje.destino,mensaje.contenido};
      $display ("t = %0t Agente: Contenido de la transacción: numero de la FIFO = %0d, Mensaje: %0d",$time,mensaje.numero_fifo,mensaje.D_push);
      agente_al_checker.put(mensaje);
      $display("t = %0t Agente: Transacción enviada al Checker",$time);
      agente_al_driver.put(mensaje);
      $display("t = %0t Agente: Transacción enviada al Driver",$time);
      -> agen_listo;
      end
  endtask
endclass
