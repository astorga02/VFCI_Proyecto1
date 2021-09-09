// Inico del modulo para definir el bloque del checker del ambiente //


class Checker#(parameter tama_de_paquete,message,broadcast,controladores,caso,opcion);
    mailbox agente_al_checker;
    mailbox monitor_al_checker; 
  	TB_trans  #(.tama_de_paquete(tama_de_paquete))item_moni;
  	Bus_trans #(.tama_de_paquete(tama_de_paquete),.controladores(controladores),.caso(caso),.opcion(opcion)) item_score; 
  	bit [tama_de_paquete-1:tama_de_paquete-8] suma_mensajes [message];
  	bit [tama_de_paquete-9:0]cajon1[$];
  	event agen_listo;
  	string mensaje,dspstv,rts,arrvng,sndng;
  	string pa_la_hoja;
  	real tiempo_simulacion;
  	int cajon2[$];
  	int t,tiempo_envio,sumat,buffer;
  	int counter[0:controladores];
  	int colaDispo [0:controladores-1][0:message-1];
  

  
endclass
