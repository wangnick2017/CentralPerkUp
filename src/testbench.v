// testbench top module file
// for simulation only

`timescale 1ns/1ps
module testbench;

    reg clk;
    reg rst;
    
    cpu_top #(.SIM(1)) top
    (
        .EXCLK(clk),
        .btnC(rst),
        .Tx(),
        .Rx(),
        .led()
    );
    
    initial
    begin
        clk=0;
        rst=1;
        repeat(50) #0.66 clk=!clk;
        rst=0; 
        forever #0.66 clk=!clk;
    
        $finish;
    end

endmodule