`include "defines.v"
module id_ex
    (
        input   wire                clk,
        input   wire                rst,
        input   wire                rdy,
        input   wire[5 : 0]         stall,

        input   wire[`AluOpBus]     id_aluop,
        input   wire[`AluSelBus]    id_alusel,
        input   wire[`RegBus]       id_reg1,
        input   wire[`RegBus]       id_reg2,
        input   wire[`RegAddrBus]   id_wd,
        input   wire                id_wreg,
        input   wire[`RegBus]       id_link_address,
        input   wire[`InstrBus]     id_instr,
        input   wire[`InstrAddrBus] id_pc,

        output  reg [`AluOpBus]     ex_aluop,
        output  reg [`AluSelBus]    ex_alusel,
        output  reg [`RegBus]       ex_reg1,
        output  reg [`RegBus]       ex_reg2,
        output  reg [`RegAddrBus]   ex_wd,
        output  reg                 ex_wreg,
        output  reg [`RegBus]       ex_link_address,
        output  reg [`InstrBus]     ex_instr,
        output  reg [`InstrAddrBus] ex_pc
    );

    always @ (posedge clk)
    begin
        if (rst == `RstEnable)
        begin
            ex_aluop <= `Exe_Nop_Op;
            ex_alusel <= `Exe_Res_Nop;
            ex_reg1 <= 0;
            ex_reg2 <= 0;
            ex_wd <= `NopRegAddr;
            ex_wreg <= `WriteDisable;
            ex_link_address <= 0;
            ex_instr <= 0;
            ex_pc <= 0;
        end
        else if (stall[2] == `Stop && stall[3] == `NoStop)
        begin
            //ex_aluop <= `Exe_Nop_Op;
            //ex_alusel <= `Exe_Res_Nop;
            ex_reg1 <= 0;
            ex_reg2 <= 0;
            //ex_wd <= `NopRegAddr;
            ex_wreg <= `WriteDisable;
            ex_link_address <= 0;
            ex_instr <= 0;
        end
        else if (stall[2] == `NoStop)
        begin
            ex_aluop <= id_aluop;
            ex_alusel <= id_alusel;
            ex_reg1 <= id_reg1;
            ex_reg2 <= id_reg2;
            ex_wd <= id_wd;
            ex_wreg <= id_wreg;
            ex_link_address <= id_link_address;
            ex_instr <= id_instr;
            ex_pc <= id_pc;
        end
    end

endmodule