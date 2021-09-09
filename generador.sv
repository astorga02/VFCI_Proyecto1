//////////////////////////////////////////////////////////////////////////////////////////////////
// Agente/Generador: Este bloque se encarga de generar las secuencias de eventos para el driver //
// En este ejemplo se generarán 2 tipos de secuencias:                                          //
//    llenado_vaciado: En esta se genera un número parametrizable de tarnsacciones de lecturas  //
//                     y escrituras para llenar y vaciar la fifo.                               //
//    Aleatoria: En esta se generarán transacciones totalmente aleatorias                       //
//    Específica: en este tipo se generan trasacciones semi específicas para casos esquina      // 
//////////////////////////////////////////////////////////////////////////////////////////////////

typedef enum{llenado_aleatorio, llenado_especifico} tipos_de_transaccion;


typedef enum {ceros, unos, ceroyunos, direccion_incorrecta, broadcasttt} cas_esq;


class Generador#(parameter message, tama_de_paquete,controladores,caso,opcion,broadcast);
    mailbox generador_al_agente;
    tipos_de_transaccion tipo_llenado = caso;

task run();
    case(tipo_llenado)
        llenado_aleatorio: 
          begin 
            $display("t = %0t Generador: Se ha escogido la transaccion de llenado aleatorio", $time);
          end
    endcase
  endtask
endclass