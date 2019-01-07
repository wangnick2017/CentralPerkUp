`include "defines.v"
module mac
    (
        input   wire                clk,
        input   wire                rst,
        input   wire                rdy,
        input   wire[`RegAddrBus]   wd_i,
        input   wire                wreg_i,
        input   wire[`RegBus]       wdata_i,
        input   wire[`AluOpBus]     aluop_i,
        input   wire[`RegBus]       mem_addr_i,
        input   wire[`RegBus]       reg2_i,
        input   wire[`InstrAddrBus] pc_i,

        input   wire                mem_busy,
        input   wire                mem_done,
        input   wire[`MacDataBus]   mem_din,

        output  reg [`RegAddrBus]   wd_o,
        output  reg                 wreg_o,
        output  reg [`RegBus]       wdata_o,

        output  reg                 mem_req,
        output  reg [`MacDataBus]   mem_dout,
        output  reg [`MemAddrBus]   mem_a,
        output  reg                 mem_wr,
        output  reg [3 : 0]         mem_kind,
        output  reg [`InstrAddrBus] mem_pc,

        output  wire                stallreq,
        output  reg                 stalllast
    );

    
    reg [`RegAddrBus]   tp_wd;
    reg                 tp_wreg;
    reg [`AluOpBus]     tp_alu;

    reg [`RegAddrBus]   tp_wd_old;
    reg                 tp_wreg_old;
    reg [`AluOpBus]     tp_alu_old;

    reg                 tp_req;
    reg [`MacDataBus]   tp_dout;
    reg [`MemAddrBus]   tp_a;
    reg                 tp_wr;
    reg [3 : 0]         tp_kind;
    reg [`InstrAddrBus] tp_pc;

    assign stallreq = (tp_req == 1'b1 && (mem_busy == `MemBusy || mem_done == `MemNotDone)) ? `Stop : `NoStop;


    always @ (posedge clk)
    begin
        tp_req <= mem_req;
        tp_dout <= mem_dout;
        tp_a <= mem_a;
        tp_wr <= mem_wr;
        tp_kind <= mem_kind;
        tp_pc <= mem_pc;
        if (rst == `RstEnable)
        begin
            tp_wd_old <= 0;
            tp_wreg_old <= 0;
            tp_alu_old <= 0;
        end
        else
        begin
            tp_wd_old <= tp_wd;
            tp_wreg_old <= tp_wreg;
            tp_alu_old <= tp_alu;
        end
    end

    always @ (*)
    begin
        stalllast <= `NoStop;
        if (rst == `RstEnable)
        begin
            wd_o <= `NopRegAddr;
            wreg_o <= `WriteDisable;
            wdata_o <= 0;
            mem_req <= 1'b0;
            mem_dout <= 0;
            mem_a <= 0;
            mem_wr <= 0;
            mem_kind <= 0;
            mem_pc <= 0;
            tp_wd <= 0;
            tp_wreg <= 0;
            tp_alu <= 0;
        end
        else if (rdy == `ReadyNot || stallreq == `Stop)
        begin
            wd_o <= `NopRegAddr;
            wreg_o <= `WriteDisable;
            wdata_o <= 0;
            mem_req <= tp_req;
            mem_dout <= tp_dout;
            mem_a <= tp_a;
            mem_wr <= tp_wr;
            mem_kind <= tp_kind;
            mem_pc <= tp_pc;
            tp_wd <= tp_wd_old;
            tp_wreg <= tp_wreg_old;
            tp_alu <= tp_alu_old;
        end
        else if (tp_req == 1'b1)
        begin
            tp_wd <= tp_wd_old;
            tp_wreg <= tp_wreg_old;
            tp_alu <= tp_alu_old;
            mem_req <= 1'b0;
            mem_dout <= tp_dout;
            mem_a <= tp_a;
            mem_wr <= 0;
            mem_kind <= tp_kind;
            mem_pc <= tp_pc;
            wd_o <= tp_wd;
            wreg_o <= tp_wreg;
            case (tp_alu)
                `Exe_Lb_Op:
                begin
                    wdata_o <= {{24{mem_din[7]}}, mem_din[7 : 0]};
                end
                `Exe_Lh_Op:
                begin
                    wdata_o <= {{16{mem_din[15]}}, mem_din[15 : 0]};
                end
                `Exe_Lw_Op:
                begin
                    wdata_o <= mem_din;
                end
                `Exe_Lbu_Op:
                begin
                    wdata_o <= {24'b000000000000000000000000, mem_din[7 : 0]};
                end
                `Exe_Lhu_Op:
                begin
                    wdata_o <= {16'b0000000000000000, mem_din[15 : 0]};
                end
                default:
                begin
                    wdata_o <= 0;
                end
            endcase
        end
        else
        begin
            tp_wd <= wd_i;
            tp_wreg <= wreg_i;
            tp_alu <= aluop_i;
            case (aluop_i)
                `Exe_Lb_Op:
                begin
                    mem_req <= 1'b1;
                    mem_a <= mem_addr_i;
                    mem_dout <= 0;
                    mem_wr <= `ReadMode;
                    mem_kind <= 4'b0001;
                    mem_pc <= pc_i;
                    wd_o <= 0;
                    wreg_o <= `WriteDisable;
                    wdata_o <= 0;
                    stalllast <= `Stop;
                end
                `Exe_Lh_Op:
                begin
                    mem_req <= 1'b1;
                    mem_a <= mem_addr_i;
                    mem_dout <= 0;
                    mem_wr <= `ReadMode;
                    mem_kind <= 4'b0010;
                    mem_pc <= pc_i;
                    wd_o <= 0;
                    wreg_o <= `WriteDisable;
                    wdata_o <= 0;
                    stalllast <= `Stop;
                end
                `Exe_Lw_Op:
                begin
                    mem_req <= 1'b1;
                    mem_a <= mem_addr_i;
                    mem_dout <= 0;
                    mem_wr <= `ReadMode;
                    mem_kind <= 4'b0100;
                    mem_pc <= pc_i;
                    wd_o <= 0;
                    wreg_o <= `WriteDisable;
                    wdata_o <= 0;
                    stalllast <= `Stop;
                end
                `Exe_Lbu_Op:
                begin
                    mem_req <= 1'b1;
                    mem_a <= mem_addr_i;
                    mem_dout <= 0;
                    mem_wr <= `ReadMode;
                    mem_kind <= 4'b0001;
                    mem_pc <= pc_i;
                    wd_o <= 0;
                    wreg_o <= `WriteDisable;
                    wdata_o <= 0;
                    stalllast <= `Stop;
                end
                `Exe_Lhu_Op:
                begin
                    mem_req <= 1'b1;
                    mem_a <= mem_addr_i;
                    mem_dout <= 0;
                    mem_wr <= `ReadMode;
                    mem_kind <= 4'b0010;
                    mem_pc <= pc_i;
                    wd_o <= 0;
                    wreg_o <= `WriteDisable;
                    wdata_o <= 0;
                    stalllast <= `Stop;
                end
                `Exe_Sb_Op:
                begin
                    mem_req <= 1'b1;
                    mem_a <= mem_addr_i;
                    mem_dout <= reg2_i;
                    mem_wr <= `WriteMode;
                    mem_kind <= 4'b0001;
                    mem_pc <= pc_i;
                    wd_o <= 0;
                    wreg_o <= `WriteDisable;
                    wdata_o <= 0;
                    stalllast <= `Stop;
                end
                `Exe_Sh_Op:
                begin
                    mem_req <= 1'b1;
                    mem_a <= mem_addr_i;
                    mem_dout <= reg2_i;
                    mem_wr <= `WriteMode;
                    mem_kind <= 4'b0010;
                    mem_pc <= pc_i;
                    wd_o <= 0;
                    wreg_o <= `WriteDisable;
                    wdata_o <= 0;
                    stalllast <= `Stop;
                end
                `Exe_Sw_Op:
                begin
                    mem_req <= 1'b1;
                    mem_a <= mem_addr_i;
                    mem_dout <= reg2_i;
                    mem_wr <= `WriteMode;
                    mem_kind <= 4'b0100;
                    mem_pc <= pc_i;
                    wd_o <= 0;
                    wreg_o <= `WriteDisable;
                    wdata_o <= 0;
                    stalllast <= `Stop;
                end
                default:
                begin
                    mem_req <= 1'b0;
                    mem_a <= 0;
                    mem_dout <= 0;
                    mem_wr <= 0;
                    mem_kind <= 0;
                    mem_pc <= 0;
                    wd_o <= wd_i;
                    wreg_o <= wreg_i;
                    wdata_o <= wdata_i;
                end
            endcase
        end
    end
endmodule