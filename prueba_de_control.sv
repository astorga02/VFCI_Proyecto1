`timescale 1ns/100ps
`default_nettype none
`define BITS 2
`define DEPTH 2
`define DRIVERS 2
`define PCKG 16
`define BROD 16
//`include "bs_gnrtr_n_rbtr"


module simbus;

    //entradas
    reg clk; //reloj del DUT
    reg reset; //reset del DUT


    //salidas
    wire [`BITS-1:0] salida;
    wire pndng [`BITS-1:0][`DRIVERS-1:0];
    wire push [`BITS-1:0][`DRIVERS-1:0];
    wire pop [`BITS-1:0][`DRIVERS-1:0];


    bs_gnrtr_n_rbtr #(`BITS, `DRIVERS, `PCKG, `BROD) uut (
        .clk(clk),
        .reset(reset),
        .pndng(pndng),
        .push(push),
        .pop(pop)
    );

    initial begin
        $dumpfile("dump.vcd");
        $dumpfile(uut);
        clk = 0;
        reset = 0;
    end

    always #1 clk=~clk;
    always@ (posedge clk)begin
        $display("prueba de funcionamiento");
        $monitor("Reloj: %g", clk);
        prueba();
    end

    task prueba();
        
        
        if ($time > 10)begin
        $display("Prueba: Tiempo límite de prueba en el test_bench alcanzado");
        $finish;
        end
    endtask

endmodule