`include "defines.v"
module mac_wb
    (
        input   wire                clk,
        input   wire                rst,
        input   wire                rdy,
        input   wire[5 : 0]         stall,

        input   wire[`RegAddrBus]   mac_wd,
        input   wire                mac_wreg,
        input   wire[`RegBus]       mac_wdata,

        output reg  [`RegAddrBus]   wb_wd,
        output reg                  wb_wreg,
        output reg  [`RegBus]       wb_wdata
    );

    always @ (posedge clk)
    begin
        if ((rst == `RstEnable) || (stall[4] == `Stop))
        begin
            wb_wd <= `NopRegAddr;
            wb_wreg <= `WriteDisable;
            wb_wdata <= 0;
        end
        else if (stall[4] == `NoStop)
        begin
            wb_wd <= mac_wd;
            wb_wreg <= mac_wreg;
            wb_wdata <= mac_wdata;
        end
    end
endmodule