`include "Interface_de_transacciones.sv"
`include "agente.sv"
`include "driver.sv"
`include "checker.sv"
`include "monitor.sv"
`include "generador.sv"
`include "ambiente.sv"

//  Modulo para prueba  //
module tb;

  parameter profundidad = 8;
  parameter dispositivos = 5;
  parameter BITS = 9;
  parameter message = 2;
  parameter broadcast = 145;
  parameter destino = 2;
  
  tipos_de_transaccion caso;
  cas_esq opcion;
  solicitud_checker sol_checker;
  reg clk;
  real ancho_banda;
  real retraso_promedio;
  mailbox test_al_generador = new();
  mailbox test_al_checker = new();
  
  initial begin
    $dumpvars(0,bs_gnrtr_n_rbtr);
    $dumpfile("dump.vcd");
  end
  
  always #100 clk=~clk;
  Int_fifo #(.profundidad(profundidad),.controladores(dispositivos),.BITS(BITS)) interfaz_fifo(clk);
  bs_gnrtr_n_rbtr uut(.clk(clk),.reset(interfaz_fifo.reset),.pndng(interfaz_fifo.pndng),.push(interfaz_fifo.push),.pop(interfaz_fifo.pop),.D_pop(interfaz_fifo.D_pop),.D_push(interfaz_fifo.D_push));
  Ambiente #(.profundidad(profundidad),.controladores(dispositivos),.BITS(BITS),.message(message),.broadcast(broadcast)) ambiente_instancia;

  initial begin
    
    {clk,interfaz_fifo.reset} <= 0;
    ambiente_instancia = new();
    ambiente_instancia.interfaz_fifo = interfaz_fifo;
    ambiente_instancia.run();
    
    caso = llenado_especifico;
    opcion = broadcasttt;
    test_al_generador.put(caso);
    test_al_generador.put(opcion);
    //test_al_generador.get(opcion); //saco la instruccion de la prueba
    
    
    #1500000 
    sol_checker = reporte;
    test_al_generador.put(sol_checker);
    
    estadisticas();
    
    $finish;
  end


endmodule


task estadisticas ();
	real ancho_banda;
  	real retraso_promedio;
  ancho_banda=(tb.message*tb.profundidad*1000)/tb.ambiente_instancia.checker_instancia.tiempo_simulacion; //calculo el ancho de banda
    retraso_promedio=tb.ambiente_instancia.checker_instancia.suma_tiempos/tb.ambiente_instancia.checker_instancia.contador;//calculo el retraso promedio total
  $display ("Tiempo de simulación: %0d", tb.ambiente_instancia.checker_instancia.tiempo_simulacion);
    $display("Ancho de banda: El ancho de banda total promedio fue de %0.1f x10^9 Hz,utilizando %0d dispositivos y una profundidad de Fifos de %0d",ancho_banda,tb.dispositivos,tb.profundidad);
    $display("Retraso: El retraso promedio de los mensajes que fueron recibidos fue de %0.1f ns, utilizando %0d dispositivos y una profundidad de Fifo de %0d",retraso_promedio,tb.dispositivos,tb.profundidad);
    lector_csv();
  
endtask


task lector_csv();
  int fd;
  int tiempo_envio [$];
  int tiempo_llegada [$];
  int atraso [$];
  int mensaje [$];
  int dispositivo [$];
  int imprimible [$];
  int counter = 0;
  int contador_de_total_mensajes[$];
  string pa_la_hoja;
  string ms, dis, te, tl, at;
  int promedio, suma;

  fd = $fopen("./simulacion.csv", "r");
  if(fd) $display ("Archivo encontrado y abierto en modo lectura");
  else $display ("Archivo no encontrado");

  for(int i = 0; i < tb.message; i++) begin
    $fscanf(fd, "%0d,%0d,%0d,%0d,%0d", dispositivo[i], mensaje[i], tiempo_envio[i], tiempo_llegada[i], atraso[i]);
  end
  $fclose(fd);
  
  for (int i = 1; i < mensaje.size(); i++)begin
    tiempo_envio[i] = tiempo_llegada[i-1];
    atraso[i] = tiempo_llegada[i] - tiempo_envio[i];
    ms.itoa(mensaje[i]);
    dis.itoa(dispositivo[i]);
    tl.itoa(tiempo_llegada[i]);
    te.itoa(tiempo_envio[i]);
    at.itoa(atraso[i]);
    pa_la_hoja = {dis,",",ms,",",te,",",tl,",",at};
    $system($sformatf("echo %0s >> simulacion2.csv", pa_la_hoja));
  end

  for (int i = 0; i < tb.dispositivos; i++) begin
    contador_de_total_mensajes = dispositivo.find_index with (item == i);
    $display ("Dispositivo: %0d, Cantidad de mensajes enviados a ese dispositivo: %0d", i, contador_de_total_mensajes.size());
    if (contador_de_total_mensajes.size() != 0)begin
      for(int c = 0; c < contador_de_total_mensajes.size; c++) begin
        suma = atraso[contador_de_total_mensajes[c]]++;
      end
      promedio = suma/contador_de_total_mensajes.size;
      $display ("Retraso promedio para ese dispositivo: %0d ns", promedio);
    end
  end
endtask