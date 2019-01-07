`include "defines.v"

module regfile
    (
        input   wire                clk,
        input   wire                rst,
        input   wire                rdy,

        input   wire                we,
        input   wire[`RegAddrBus]   waddr,
        input   wire[`RegBus]       wdata,

        input   wire                re1,
        input   wire[`RegAddrBus]   raddr1,
        output  reg [`RegBus]       rdata1,

        input   wire                re2,
        input   wire[`RegAddrBus]   raddr2,
        output  reg [`RegBus]       rdata2
    );

    reg [`RegBus]       regs[0 : `RegNum - 1];

    always @ (posedge clk)
    begin
        if (rst == `RstEnable)
        begin
            regs[5'b00000] <= 0;
            regs[5'b00001] <= 0;
            regs[5'b00010] <= 0;
            regs[5'b00011] <= 0;
            regs[5'b00100] <= 0;
            regs[5'b00101] <= 0;
            regs[5'b00110] <= 0;
            regs[5'b00111] <= 0;
            regs[5'b01000] <= 0;
            regs[5'b01001] <= 0;
            regs[5'b01010] <= 0;
            regs[5'b01011] <= 0;
            regs[5'b01100] <= 0;
            regs[5'b01101] <= 0;
            regs[5'b01110] <= 0;
            regs[5'b01111] <= 0;
            regs[5'b10000] <= 0;
            regs[5'b10001] <= 0;
            regs[5'b10010] <= 0;
            regs[5'b10011] <= 0;
            regs[5'b10100] <= 0;
            regs[5'b10101] <= 0;
            regs[5'b10110] <= 0;
            regs[5'b10111] <= 0;
            regs[5'b11000] <= 0;
            regs[5'b11001] <= 0;
            regs[5'b11010] <= 0;
            regs[5'b11011] <= 0;
            regs[5'b11100] <= 0;
            regs[5'b11101] <= 0;
            regs[5'b11110] <= 0;
            regs[5'b11111] <= 0;
        end
        else if (rdy == `Ready && we == `WriteEnable && waddr != `RegNumLog2'h0)
        begin
            regs[waddr] <= wdata;//$display("**************reg[%d]=%h",waddr,wdata);
        end
    end

    always @ (*)
    begin
        if (rst == `RstEnable || rdy == `ReadyNot || raddr1 == `RegNumLog2'h0 || re1 != `ReadEnable)
        begin
            rdata1 <= 0;
        end
        else if (raddr1 == waddr && we == `WriteEnable)
        begin
            rdata1 <= wdata;
        end
        else
        begin
            rdata1 <= regs[raddr1];
        end
    end

    always @ (*)
    begin
        if (rst == `RstEnable || rdy == `ReadyNot || raddr2 == `RegNumLog2'h0 || re2 != `ReadEnable)
        begin
            rdata2 <= 0;
        end
        else if (raddr2 == waddr && we == `WriteEnable)
        begin
            rdata2 <= wdata;
        end
        else
        begin
            rdata2 <= regs[raddr2];
        end
    end

endmodule