`include "defines.v"
module ex_mac
    (
        input   wire                clk,
        input   wire                rst,
        input   wire                rdy,
        input   wire[5 : 0]         stall,

        input   wire[`RegAddrBus]   ex_wd,
        input   wire                ex_wreg,
        input   wire[`RegBus]       ex_wdata,
        input   wire[`AluOpBus]     ex_aluop,
        input   wire[`RegBus]       ex_mem_addr,
        input   wire[`RegBus]       ex_reg2,
        input   wire[`InstrAddrBus] ex_pc,
        
        output  reg [`InstrAddrBus] mac_pc,
        output  reg [`RegAddrBus]   mac_wd,
        output  reg                 mac_wreg,
        output  reg [`RegBus]       mac_wdata,
        output  reg [`AluOpBus]     mac_aluop,
        output  reg [`RegBus]       mac_mem_addr,
        output  reg [`RegBus]       mac_reg2
    );

    always @ (posedge clk)
    begin
        if (rst == `RstEnable)
        begin
            mac_wd <= `NopRegAddr;
            mac_wreg <= `WriteDisable;
            mac_wdata <= 0;
            mac_aluop <= `Exe_Nop_Op;
            mac_mem_addr <= 0;
            mac_reg2 <= 0;
            mac_pc <= 0;
        end
        else if (stall[3] == `Stop && stall[4] == `NoStop)
        begin
            mac_wd <= `NopRegAddr;
            mac_wreg <= `WriteDisable;
            mac_wdata <= 0;
            mac_aluop <= `Exe_Nop_Op;
            mac_mem_addr <= 0;
            mac_reg2 <= 0;
            mac_pc <= 0;
        end
        else if (stall[3] == `NoStop)
        begin
            mac_wd <= ex_wd;
            mac_wreg <= ex_wreg;
            mac_wdata <= ex_wdata;
            mac_aluop <= ex_aluop;
            mac_mem_addr <= ex_mem_addr;
            mac_reg2 <= ex_reg2;
            mac_pc <= ex_pc;
        end
    end
endmodule