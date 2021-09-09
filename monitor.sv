// Modulo para definir el bloque del monitor del ambiente //

class Monitor#(parameter controladores,tam_fifo,BITS,tama_de_paquete);
  virtual Int_fifo #(
      .tama_de_paquete(tama_de_paquete),
      .controladores(controladores),
      .BITS(BITS)) interfaz_fifo;

  TB_trans #(.tama_de_paquete(tama_de_paquete)) item[controladores-1:0];
  Fifo #(.tama_de_paquete(tama_de_paquete)) f2[controladores-1:0];
  mailbox monitor_al_checker;

  


  
endclass