// Inico del modulo para definir el bloque del checker del ambiente //


class Checker#(parameter tama_de_paquete,message,broadcast,controladores,caso,opcion);
    mailbox agente_al_checker;
    mailbox monitor_al_checker; 
  	TB_trans  #(.tama_de_paquete(tama_de_paquete))item_moni;
  	Bus_trans #(.tama_de_paquete(tama_de_paquete),.controladores(controladores),.caso(caso),.opcion(opcion)) item_score; 
  	bit [tama_de_paquete-1:tama_de_paquete-8] suma_mensajes [message];
  	event agen_listo;
  	string mensaje,dspstv,rts,arrvng,sndng;
  	real tiempo_simulacion;
    int tiempo_envio;
    int sumat;

  

  
endclass
