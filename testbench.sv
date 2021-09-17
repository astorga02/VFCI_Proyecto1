`include "Interface_de_transacciones.sv"
`include "agente.sv"
`include "driver.sv"
`include "checker.sv"
`include "monitor.sv"
`include "generador.sv"
`include "ambiente.sv"


module tb;


  parameter tama_de_paquete = 8; 				 
  parameter caso = llenado_aleatorio;
  parameter opcion = direccion_incorrecta; 	
  parameter dispositivos = 5;
  parameter BITS = 8;
  parameter message = 30;
  parameter tam_fifo = 8;
  parameter broadcast = {8{1'b1}};
  
  
  reg clk;
  real ancho_banda;
  real retraso_promedio;
  real resultado[0:dispositivos];
  real buffer[0:dispositivos];
  
  
  always #100 clk=~clk;
  Int_fifo #(.tama_de_paquete(tama_de_paquete),.controladores(dispositivos),.BITS(BITS)) interfaz_fifo(clk);
  bs_gnrtr_n_rbtr uut(.clk(clk),.reset(interfaz_fifo.reset),.pndng(interfaz_fifo.pndng),.push(interfaz_fifo.push),.pop(interfaz_fifo.pop),.D_pop(interfaz_fifo.D_pop),.D_push(interfaz_fifo.D_push));
  Ambiente #(.tama_de_paquete(tama_de_paquete),.controladores(dispositivos),.BITS(BITS),.message(message),.tam_fifo(tam_fifo),.broadcast(broadcast),.caso(caso),.opcion(opcion)) ambiente_instancia;
  

  initial begin
    {clk,interfaz_fifo.reset}<=0;
    ambiente_instancia = new();
    ambiente_instancia.interfaz_fifo = interfaz_fifo;
    ambiente_instancia.run();

    
    #150000 
    ancho_banda=(message*tama_de_paquete*1000)/ambiente_instancia.checker_instancia.tiempo_simulacion;
    retraso_promedio=ambiente_instancia.checker_instancia.suma_tiempos/ambiente_instancia.checker_instancia.contador;
    $display("[Ancho de banda] El ancho de banda total promedio fue de %0.1f x10^9 Hz,utilizando %0d dispositivos y una profundidad de Fifos de %0d",ancho_banda,dispositivos,tam_fifo);
    $display("Retraso: El retraso promedio de los mensajes que fueron recibidos fue de %0.1f ns, utilizando %0d dispositivos y una profundidad de Fifo de %0d",retraso_promedio,dispositivos,tam_fifo);
    for (int i=0;i<dispositivos;i++)begin
      for (int j=0;j<message;j++)begin
        buffer[i]=resultado[i];
        resultado[i]=buffer[i]+ambiente_instancia.checker_instancia.retrasos_dispositivo[i][j];
        end
      retraso_promedio=resultado[i]/ambiente_instancia.checker_instancia.retraso_por_dispositivo[i];
      $display("Retraso: El retraso promedio de los %0d mensajes dirigidos al dispositivo %0d fue de %0.1f ns, utilizando %0d dispositivos y una profundidad de Fifo de %0d",ambiente_instancia.checker_instancia.retraso_por_dispositivo[i],i,retraso_promedio,dispositivos,tam_fifo);
    end    
    
    $finish;
  end
 
  initial begin
    $dumpvars(0,bs_gnrtr_n_rbtr);
    $dumpfile("dump.vcd");
  end

endmodule

