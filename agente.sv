//////////////////////////////////////////////////////////////////////////////////////////////////
// Agente: Este módulo se encarga de recibir las transacciones del generador y de enviar el     //
//         contenido de estas transacciones al scoreboard/checker y al driver por medio         //
//         de mailbox.                                                                          //
//////////////////////////////////////////////////////////////////////////////////////////////////
class Agente#(parameter profundidad,controladores);
  event agen_listo;
  mailbox generador_al_agente;
  mailbox agente_al_driver;
  mailbox agente_al_checker;
  trans_entrada_DUT #(.profundidad(profundidad),.controladores(controladores)) mensaje;

  
  task run(); //task donde correrá el agente
    mensaje=new; //se inicializa mensaje
    forever begin //se crea un ciclo repetitivo
      generador_al_agente.get(mensaje); //se obtiene la transacción que se haya enviado del generador
      $display("t = %0t Agente: Transacción ha llegado al agente",$time); //se imprime mensaje y tiempo
      mensaje.D_push={mensaje.destino,mensaje.contenido}; //se concatena el destino y contenido y se guarda en mensaje
      $display ("t = %0t Agente: Contenido de la transacción: numero de la FIFO = %0d, Mensaje: %0d",$time,mensaje.numero_fifo,mensaje.D_push); //se imprime el contenido ya concatenado
      agente_al_checker.put(mensaje); //envío la transacción mensaje hacia el checker
      $display("t = %0t Agente: Transacción enviada al Checker",$time); //se imprime mensaje y tiempo
      agente_al_driver.put(mensaje); //envío la transacccion hacia el driver
      $display("t = %0t Agente: Transacción enviada al Driver",$time); //se imprime mensaje y tiempo
      -> agen_listo; //se activa el evento
      end
  endtask
endclass
