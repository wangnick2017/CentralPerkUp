`include "defines.v"
module ex
    (
        input   wire                rst,
        input   wire                rdy,
        input   wire[`AluOpBus]     aluop_i,
        input   wire[`AluSelBus]    alusel_i,
        input   wire[`RegBus]       reg1_i,
        input   wire[`RegBus]       reg2_i,
        input   wire[`RegAddrBus]   wd_i,
        input   wire                wreg_i,

        input   wire[`RegBus]       link_address_i,
        input   wire[`InstrBus]     instr_i,
        input   wire[`InstrAddrBus] pc_i,

        output  reg [`RegAddrBus]   wd_o,
        output  reg                 wreg_o,
        output  reg [`RegBus]       wdata_o,

        output  wire[`AluOpBus]     aluop_o,
        output  wire[`RegBus]       mem_addr_o,
        output  wire[`RegBus]       reg2_o,
        output  wire[`InstrAddrBus] pc_o,

        output  wire                stallreq
    );

    reg [`RegBus]       logicOut;
    reg [`RegBus]       shiftRes;
    reg [`RegBus]       arithmeticres;

    wire                reg1_lt_reg2;
    wire[`RegBus]       reg2_i_mux;
    wire[`RegBus]       reg1_i_not;
    wire[`RegBus]       result_sum;

    assign aluop_o = (instr_i[0]) ? aluop_i : `Exe_Nop_Op;
    assign pc_o = pc_i;
    assign reg2_o = reg2_i;
    assign mem_addr_o = (alusel_i == `Exe_Res_Store) ? (reg1_i + {{20{instr_i[31]}}, instr_i[31 : 25], instr_i[11 : 8], instr_i[7]}) : (reg1_i + reg2_i);

    assign stallreq = `NoStop;

    assign reg2_i_mux = ((aluop_i == `Exe_Sub_Op) || (aluop_i == `Exe_Slt_Op)) ? (~reg2_i) + 1 : reg2_i;

    assign result_sum = reg1_i + reg2_i_mux;

    assign reg1_i_not = ~reg1_i;

    assign reg1_lt_reg2 =  ((aluop_i == `Exe_Slt_Op)) ? ((reg1_i[31] && !reg2_i[31]) || (!reg1_i[31] && !reg2_i[31] && result_sum[31]) || (reg1_i[31] && reg2_i[31] && result_sum[31])) : (reg1_i < reg2_i);

    always @ (*)
    begin
        if (rst == `RstEnable || rdy == `ReadyNot)
        begin
            logicOut <= 0;
        end
        else
        begin
            case (aluop_i)
                `Exe_Lui_Op:
                begin
                    logicOut <= reg1_i;
                end
                `Exe_Or_Op:
                begin
                    logicOut <= reg1_i | reg2_i;
                end
                `Exe_Xor_Op:
                begin
                    logicOut <= reg1_i ^ reg2_i;
                end
                `Exe_And_Op:
                begin
                    logicOut <= reg1_i & reg2_i;
                end
                default:
                begin
                    logicOut <= 0;
                end
            endcase
        end
    end

    always @ (*)
    begin
        if (rst == `RstEnable || rdy == `ReadyNot)
        begin
            shiftRes <= 0;
        end
        else
        begin
            case (aluop_i)
                `Exe_Sll_Op:
                begin
                    shiftRes <= reg1_i << reg2_i[4 : 0];
                end
                `Exe_Srl_Op:
                begin
                    shiftRes <= reg1_i >> reg2_i[4 : 0];
                end
                `Exe_Sra_Op:
                begin
                    shiftRes <= ({32{reg1_i[31]}} << (6'd32 - {1'b0, reg2_i[4 : 0]})) | (reg1_i >> reg2_i[4 : 0]);
                end
                default:
                begin
                    shiftRes <= 0;
                end
            endcase
        end
    end

    always @ (*)
    begin
        if (rst == `RstEnable || rdy == `ReadyNot)
        begin
            arithmeticres <= 0;
        end
        else
        begin
            case (aluop_i)
                `Exe_Slt_Op, `Exe_Sltu_Op:
                begin
                    arithmeticres <= reg1_lt_reg2;
                end
                `Exe_Add_Op, `Exe_Sub_Op:
                begin
                    arithmeticres <= result_sum;
                end
                default:
                begin
                    arithmeticres <= 0;
                end
            endcase
        end
    end

    always @ (*)
    begin
        wd_o <= wd_i;
        wreg_o <= wreg_i;
        case (alusel_i)
            `Exe_Res_Logic:
            begin
                wdata_o <= logicOut;
            end
            `Exe_Res_Shift:
            begin
                wdata_o <= shiftRes;
            end
            `Exe_Res_Arithmetic:
            begin
                wdata_o <= arithmeticres;
            end
            `Exe_Res_JumpBranch:
            begin
                wdata_o <= link_address_i;
            end
            default:
            begin
                wdata_o <= 0;
            end
        endcase
    end
endmodule