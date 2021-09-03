`timescale 1ns/100ps
`default_nettype none
`define BITS 2
`define DEPTH 2
`define DRIVERS 2
`define PCKG 2
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
    wire [`PCKG-1:0] D_pop [`BITS-1:0][`DRIVERS-1:0];
    wire [`PCKG-1:0] D_push [`BITS-1:0][`DRIVERS-1:0];


    bs_gnrtr_n_rbtr #(`BITS, `DRIVERS, `PCKG, `BROD) uut (
        .clk(clk),
        .reset(reset),
        .pndng(pndng),
        .push(push),
        .pop(pop),
        .D_pop(D_pop),
        .D_push(D_push)
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

/////// Prograna que jecuta las pruebas y llama a la FIFO ///////

    task prueba();

        int dato_out2, full2, empty2, rd2, wn2, c2;
        for (int c = 0; c < 10 ; c++) begin
            c2 = c + 23;
            fifo(c2, rd2, wn2, dato_out2, full2, empty2);
            $display ("Entrada de datos");
            $monitor ("Dato numero: %g, Dato: %g", c, c2);
        end
        
        if ($time > 20)begin
        $display("Prueba: Tiempo límite de prueba en el test_bench alcanzado");
        $finish;
        end
    endtask

/////// Declaración de la FIFO en software del sistema ////////

    task fifo(input int dato_in, rd, wn, output dato_out, full, empty);
        queue[$] = {};
        if (wn == 1 && rd == 0)begin
            queue.push_front(dato_in);
        end
        if (wn = 0 && rd == 1)begin
            dato_out = queue.pop_front(dato_in);
        end
    endtask


endmodule