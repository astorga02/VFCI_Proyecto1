// Inico del modulo para definir el bloque del agente del ambiente //


class Agente#(parameter tama_de_paquete,controladores,caso,opcion);
  event agen_listo;
  mailbox agente_al_driver;
  mailbox agente_al_checker;
  mailbox generador_al_agente;
  Bus_trans #(.tama_de_paquete(tama_de_paquete),.controladores(controladores),.caso(caso),.opcion(opcion)) mensaje;
  


endclass
