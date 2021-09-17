`timescale 1ns/100ps
`default_nettype none
`define BITS 3
`define DEPTH 3
`define DRIVERS 3
`define PCKG 16
`define BROD 16
//`include "bs_gnrtr_n_rbtr"


module simbus;

    //entradas
    reg clk; //reloj del DUT
    reg reset; //reset del DUT


    //salidas
    reg pndng [`BITS-1:0][`DRIVERS-1:0];
    wire  push [`BITS-1:0][`DRIVERS-1:0];
    wire  pop [`BITS-1:0][`DRIVERS-1:0];
    reg [`PCKG-1:0] D_pop [`BITS-1:0][`DRIVERS-1:0];
    wire  [`PCKG-1:0] D_push [`BITS-1:0][`DRIVERS-1:0];
    
    /*wire bs_rqst;
    wire bus;
    wire bs_bsy;*/


    bs_gnrtr_n_rbtr #(`BITS, `DRIVERS, `PCKG, `BROD) uut (
        .clk(clk),
        .reset(reset),
        .pndng(pndng),
        .push(push),
        .pop(pop),
        .D_pop(D_pop),
        .D_push(D_push)
        //.bs_rqst(bs_rqst),
        //.bus(bus),
        //.bs_bsy(bs_bsy)
    );

    initial begin
      $dumpfile("dump.vcd"); $dumpvars(4, uut);
        //$dumpfile(uut);
        clk = 0;
        reset = 0;
    end

    always #1 clk=~clk;
    always@ (posedge clk)begin
        $display("prueba de funcionamiento");
        $monitor("Reloj: %g", clk);
        prueba();
    end

/////// Prograna que jecuta las pruebas y llama a la FIFO ///////

    task prueba();

    //// Se prueba el funcionamiento de la FIFO //////
      //$display ("Prueba de la fifo");
      
        int dato_out2, full2, empty2, rd2, wr2, c2;
        for (int c = 0; c < 10 ; c++) begin
            c2 = c + 23;
            wr2 = 1;
            rd2 = 0;
            fifo(c2, rd2, wr2, dato_out2, full2, empty2);
            $display ("Entrada de datos");
          $display ("Dato numero: %0d, Dato: %0d", c, c2);
        end
        
        for (int c = 0; c < 10 ; c++) begin
            c2 = c + 23;
            wr2 = 0;
            rd2 = 1;
            fifo(c2, rd2, wr2, dato_out2, full2, empty2);
          $display ("Salida de datos");
          $display ("Dato numero: %0d, Dato: %0d", c, dato_out2);
        end

    ///// Se prueba el funcionamiento del bus con 2 FIFOS///// 

      $display("Probando que el BUS se puede leer");
      //push[0][0] = 1;
      for(int c = 0; c<4; c++)begin
        for(int b = 0; b <4; b++)begin
          pndng[c][b] = 1;
          $display ("A ver que sale: %g", D_pop[c][b]);
          #10;
        end
      end
      
      
      
      

    ///// Si el tiempo se acaba se cancela la simulación
        if ($time > 20)begin
        $display("Prueba: Tiempo límite de prueba en el test_bench alcanzado");
        $finish;
        end
    endtask

/////// Declaración de la FIFO en software del sistema ////////

  task fifo(input int dato_in, rd, wr, output int dato_out, full, empty);
        int queue[$] = {};
        if (wr == 1 && rd == 0)begin
            queue.push_front(dato_in);
        end
      if (wr == 0 && rd == 1)begin
            dato_out = queue.pop_back;
        end
    endtask

endmodule