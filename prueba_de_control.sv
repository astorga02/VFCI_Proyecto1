`timescale 1ns/100ps
`default_nettype none
`define BITS 2
`define DEPTH 2
`define DRIVERS 2
`define PCKG 16
`define BROD 16
'include bs_gnrtr_n_rbtr


module simbus;

    //entradas
    reg clk; //reloj del DUT
    reg rst; //reset del DUT


    //salidas
    wire [`BITS-1:0] salida;


    bs_gnrtr_n_rbtr #(`BITS, `DRIVERS, `PCKG, `BROD) uut (
        .clk(clk),
        .reset(reset),
    )

    initial begin
        $dumpfile(grafica.vcd);
        $dumpfile(2, uut);
        clk = 0;
        rst = 0;
    end

    always #1 clk=~clk;
    always@ (posedge clk)begin
        prueba();
    end

    task prueba();
        $display("prueba de funcionamiento");
        $display("Reloj: %g", clk);
        
        if ($time > 10)begin
        $display("Prueba: Tiempo límite de prueba en el test_bench alcanzado");
        $finish;
    endtask

endmodule