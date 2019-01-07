`include "defines.v"
module id
    (
        input   wire                rst,
        input   wire                rdy,
        input   wire[`InstrAddrBus] pc_i,
        input   wire[`InstrBus]     instr_i,

        input   wire[`RegBus]       reg1_data_i,
        input   wire[`RegBus]       reg2_data_i,

        input   wire                ex_wreg_i,
        input   wire[`RegBus]       ex_wdata_i,
        input   wire[`RegAddrBus]   ex_wd_i,
        input   wire[`AluSelBus]    ex_alusel_i,
        input   wire[`InstrAddrBus] ex_pc_i,

        input   wire                mac_wreg_i,
        input   wire[`RegBus]       mac_wdata_i,
        input   wire[`RegAddrBus]   mac_wd_i,
        input   wire[`InstrAddrBus] mac_pc_i,

        output  wire[`InstrBus]     instr_o,
        output  wire[`InstrAddrBus] pc_o,

        output  reg                 reg1_read_o,
        output  reg                 reg2_read_o,
        output  reg [`RegAddrBus]   reg1_addr_o,
        output  reg [`RegAddrBus]   reg2_addr_o,

        output  reg [`AluOpBus]     aluop_o,
        output  reg [`AluSelBus]    alusel_o,
        output  reg [`RegBus]       reg1_o,
        output  reg [`RegBus]       reg2_o,
        output  reg [`RegAddrBus]   wd_o,
        output  reg                 wreg_o,

        output  reg                 branch_flag_o,
        output  reg [`RegBus]       branch_target_address_o,
        output  reg [`RegBus]       link_addr_o,

        output  wire                stallreq
    );

    assign instr_o = instr_i;
    assign pc_o = pc_i;

    wire[`RegBus]       pc_plus_4;
    wire[`RegBus]       pc_plus_8;
    assign pc_plus_4 = pc_i + 4;
    assign pc_plus_8 = pc_plus_4 + 4;

    wire[6 : 0]         opcode  = instr_i[6 : 0];
    wire[4 : 0]         rd      = instr_i[11 : 7];
    wire[2 : 0]         funct3  = instr_i[14 : 12];
    wire[4 : 0]         rs1     = instr_i[19 : 15];
    wire[4 : 0]         rs2     = instr_i[24 : 20];
    wire[6 : 0]         funct7  = instr_i[31 : 25];

    reg [`RegBus]       imm;
    reg [`RegBus]       imm2;

    reg                 instrValid;

    reg                 stall_for_reg1;
    reg                 stall_for_reg2;
    wire                pre_load;
    assign pre_load = (ex_alusel_i == `Exe_Res_Load) ? `True : `False;
    assign stallreq = stall_for_reg1 | stall_for_reg2;

    always @ (*)
    begin
        if (rst == `RstEnable || rdy == `ReadyNot)
        begin
            aluop_o <= `Exe_Nop_Op;
            alusel_o <= `Exe_Res_Nop;
            wd_o <= `NopRegAddr;
            wreg_o <= `WriteDisable;
            instrValid <= `InstrValid;
            reg1_read_o <= 1'b0;
            reg2_read_o <= 1'b0;
            reg1_addr_o <= `NopRegAddr;
            reg2_addr_o <= `NopRegAddr;
            imm <= 0;
            imm2 <= 0;
            link_addr_o <= 0;
            branch_target_address_o <= 0;
            branch_flag_o <= `NotBranch;
        end
        else
        begin
            aluop_o <= `Exe_Nop_Op;
            alusel_o <= `Exe_Res_Nop;
            wd_o <= instr_i[11 : 7];
            wreg_o <= `WriteDisable;
            instrValid <= `InstrInvalid;
            reg1_read_o <= 1'b0;
            reg2_read_o <= 1'b0;
            reg1_addr_o <= instr_i[19 : 15];
            reg2_addr_o <= instr_i[24 : 20];
            imm <= 0;
            imm2 <= 0;
            link_addr_o <= 0;
            branch_target_address_o <= 0;
            branch_flag_o <= `NotBranch;

            case (opcode)
                `Exe_Lui:
                begin
                    wreg_o <= `WriteEnable;
                    aluop_o <= `Exe_Lui_Op;
                    alusel_o <= `Exe_Res_Logic;
                    reg1_read_o <= 1'b0;
                    reg2_read_o <= 1'b0;
                    imm <= {instr_i[31 : 12], 12'b000000000000};
                    imm2 <= 0;
                    instrValid <= `InstrValid;
                end
                `Exe_Auipc:
                begin
                    wreg_o <= `WriteEnable;
                    aluop_o <= `Exe_Add_Op;
                    alusel_o <= `Exe_Res_Arithmetic;
                    reg1_read_o <= 1'b0;
                    reg2_read_o <= 1'b0;
                    imm <= {instr_i[31 : 12], 12'b000000000000};
                    imm2 <= pc_i;
                    instrValid <= `InstrValid;
                end
                `Exe_Jal:
                begin
                    wreg_o <= `WriteEnable;
                    aluop_o <= `Exe_Jal_Op;
                    alusel_o <= `Exe_Res_JumpBranch;
                    reg1_read_o <= 1'b0;
                    reg2_read_o <= 1'b0;
                    link_addr_o <= pc_plus_4;
                    branch_flag_o <= `Branch;
                    branch_target_address_o <= pc_i + {{12{instr_i[31]}}, instr_i[19 : 12], instr_i[20], instr_i[30 : 21], 1'b0};
                    instrValid <= `InstrValid;
                end
                `Exe_Jalr:
                begin
                    wreg_o <= `WriteEnable;
                    aluop_o <= `Exe_Jalr_Op;
                    alusel_o <= `Exe_Res_JumpBranch;
                    reg1_read_o <= 1'b1;
                    reg2_read_o <= 1'b0;
                    imm2 <= {{20{instr_i[31]}}, instr_i[31 : 20]};
                    link_addr_o <= pc_plus_4;
                    branch_target_address_o <= reg1_data_i + {{20{instr_i[31]}}, instr_i[31 : 20]};
                    branch_flag_o <= `Branch;
                    instrValid <= `InstrValid;
                end
                `Exe_B:
                begin
                    case (funct3)
                        `Exe_B_Beq:
                        begin
                            wreg_o <= `WriteDisable;
                            aluop_o <= `Exe_Beq_Op;
                            alusel_o <= `Exe_Res_JumpBranch;
                            reg1_read_o <= 1'b1;
                            reg2_read_o <= 1'b1;
                            if (reg1_o == reg2_o)
                            begin
                                branch_flag_o <= `Branch;
                                branch_target_address_o <= pc_i + {{20{instr_i[31]}}, instr_i[7], instr_i[30 : 25], instr_i[11 : 8], 1'b0};
                            end
                            instrValid <= `InstrValid;
                        end
                        `Exe_B_Bne:
                        begin
                            wreg_o <= `WriteDisable;
                            aluop_o <= `Exe_Bne_Op;
                            alusel_o <= `Exe_Res_JumpBranch;
                            reg1_read_o <= 1'b1;
                            reg2_read_o <= 1'b1;
                            if (reg1_o != reg2_o)
                            begin
                                branch_flag_o <= `Branch;
                                branch_target_address_o <= pc_i + {{20{instr_i[31]}}, instr_i[7], instr_i[30 : 25], instr_i[11 : 8], 1'b0};
                            end
                            instrValid <= `InstrValid;
                        end
                        `Exe_B_Blt:
                        begin
                            wreg_o <= `WriteDisable;
                            aluop_o <= `Exe_Blt_Op;
                            alusel_o <= `Exe_Res_JumpBranch;
                            reg1_read_o <= 1'b1;
                            reg2_read_o <= 1'b1;
                            if (reg1_o[31] == 1'b1 && reg2_o[31] == 1'b1 && reg1_o > reg2_o ||
                                reg1_o[31] == 1'b0 && reg2_o[31] == 1'b0 && reg1_o < reg2_o ||
                                reg1_o[31] == 1'b1 && reg2_o[31] == 1'b0)
                            begin
                                branch_flag_o <= `Branch;
                                branch_target_address_o <= pc_i + {{20{instr_i[31]}}, instr_i[7], instr_i[30 : 25], instr_i[11 : 8], 1'b0};
                            end
                            instrValid <= `InstrValid;
                        end
                        `Exe_B_Bge:
                        begin
                            wreg_o <= `WriteDisable;
                            aluop_o <= `Exe_Bge_Op;
                            alusel_o <= `Exe_Res_JumpBranch;
                            reg1_read_o <= 1'b1;
                            reg2_read_o <= 1'b1;
                            if (reg1_o[31] == 1'b1 && reg2_o[31] == 1'b1 && reg1_o <= reg2_o ||
                                reg1_o[31] == 1'b0 && reg2_o[31] == 1'b0 && reg1_o >= reg2_o ||
                                reg1_o[31] == 1'b0 && reg2_o[31] == 1'b1)
                            begin
                                branch_flag_o <= `Branch;
                                branch_target_address_o <= pc_i + {{20{instr_i[31]}}, instr_i[7], instr_i[30 : 25], instr_i[11 : 8], 1'b0};
                            end
                            instrValid <= `InstrValid;
                        end
                        `Exe_B_Bltu:
                        begin
                            wreg_o <= `WriteDisable;
                            aluop_o <= `Exe_Bltu_Op;
                            alusel_o <= `Exe_Res_JumpBranch;
                            reg1_read_o <= 1'b1;
                            reg2_read_o <= 1'b1;
                            if (reg1_o < reg2_o)
                            begin
                                branch_flag_o <= `Branch;
                                branch_target_address_o <= pc_i + {{20{instr_i[31]}}, instr_i[7], instr_i[30 : 25], instr_i[11 : 8], 1'b0};
                            end
                            instrValid <= `InstrValid;
                        end
                        `Exe_B_Bgeu:
                        begin
                            wreg_o <= `WriteDisable;
                            aluop_o <= `Exe_Bgeu_Op;
                            alusel_o <= `Exe_Res_JumpBranch;
                            reg1_read_o <= 1'b1;
                            reg2_read_o <= 1'b1;
                            if (reg1_o >= reg2_o)
                            begin
                                branch_flag_o <= `Branch;
                                branch_target_address_o <= pc_i + {{20{instr_i[31]}}, instr_i[7], instr_i[30 : 25], instr_i[11 : 8], 1'b0};
                            end
                            instrValid <= `InstrValid;
                        end
                    endcase
                end
                `Exe_RegImm:
                begin
                    case (funct3)
                        `Exe_RegImm_Ori:
                        begin
                            wreg_o <= `WriteEnable;
                            aluop_o <= `Exe_Or_Op;
                            alusel_o <= `Exe_Res_Logic;
                            reg1_read_o <= 1'b1;
                            reg2_read_o <= 1'b0;
                            imm2 <= {{20{instr_i[31]}}, instr_i[31 : 20]};
                            instrValid <= `InstrValid;
                        end
                        `Exe_RegImm_Xori:
                        begin
                            wreg_o <= `WriteEnable;
                            aluop_o <= `Exe_Xor_Op;
                            alusel_o <= `Exe_Res_Logic;
                            reg1_read_o <= 1'b1;
                            reg2_read_o <= 1'b0;
                            imm2 <= {{20{instr_i[31]}}, instr_i[31 : 20]};
                            instrValid <= `InstrValid;
                        end
                        `Exe_RegImm_Andi:
                        begin
                            wreg_o <= `WriteEnable;
                            aluop_o <= `Exe_And_Op;
                            alusel_o <= `Exe_Res_Logic;
                            reg1_read_o <= 1'b1;
                            reg2_read_o <= 1'b0;
                            imm2 <= {{20{instr_i[31]}}, instr_i[31 : 20]};
                            instrValid <= `InstrValid;
                        end
                        `Exe_RegImm_Slli:
                        begin
                            wreg_o <= `WriteEnable;
                            aluop_o <= `Exe_Sll_Op;
                            alusel_o <= `Exe_Res_Shift;
                            reg1_read_o <= 1'b1;
                            reg2_read_o <= 1'b0;
                            imm2 <= {27'b000000000000000000000000000, instr_i[24 : 20]};
                            instrValid <= `InstrValid;
                        end
                        `Exe_RegImm_SrliSrai:
                        begin
                            wreg_o <= `WriteEnable;
                            if (instr_i[30] == 1'b0)
                            begin
                                aluop_o <= `Exe_Srl_Op;
                            end
                            else begin
                                aluop_o <= `Exe_Sra_Op;
                            end
                            alusel_o <= `Exe_Res_Shift;
                            reg1_read_o <= 1'b1;
                            reg2_read_o <= 1'b0;
                            imm2 <= {27'b000000000000000000000000000, instr_i[24 : 20]};
                            instrValid <= `InstrValid;
                        end
                        `Exe_RegImm_Addi:
                        begin
                            wreg_o <= `WriteEnable;
                            aluop_o <= `Exe_Add_Op;
                            alusel_o <= `Exe_Res_Arithmetic;
                            reg1_read_o <= 1'b1;
                            reg2_read_o <= 1'b0;
                            imm2 <= {{20{instr_i[31]}}, instr_i[31 : 20]};
                            instrValid <= `InstrValid;
                        end
                        `Exe_RegImm_Slti:
                        begin
                            wreg_o <= `WriteEnable;
                            aluop_o <= `Exe_Slt_Op;
                            alusel_o <= `Exe_Res_Arithmetic;
                            reg1_read_o <= 1'b1;
                            reg2_read_o <= 1'b0;
                            imm2 <= {{20{instr_i[31]}}, instr_i[31 : 20]};
                            instrValid <= `InstrValid;
                        end
                        `Exe_RegImm_Sltiu:
                        begin
                            wreg_o <= `WriteEnable;
                            aluop_o <= `Exe_Sltu_Op;
                            alusel_o <= `Exe_Res_Arithmetic;
                            reg1_read_o <= 1'b1;
                            reg2_read_o <= 1'b0;
                            imm2 <= {{20{instr_i[31]}}, instr_i[31 : 20]};
                            instrValid <= `InstrValid;
                        end
                        default:
                        begin
                        end
                    endcase
                end
                `Exe_RegReg:
                begin
                    case (funct3)
                        `Exe_RegReg_Or:
                        begin
                            wreg_o <= `WriteEnable;
                            aluop_o <= `Exe_Or_Op;
                            alusel_o <= `Exe_Res_Logic;
                            reg1_read_o <= 1'b1;
                            reg2_read_o <= 1'b1;
                            instrValid <= `InstrValid;
                        end
                        `Exe_RegReg_Xor:
                        begin
                            wreg_o <= `WriteEnable;
                            aluop_o <= `Exe_Xor_Op;
                            alusel_o <= `Exe_Res_Logic;
                            reg1_read_o <= 1'b1;
                            reg2_read_o <= 1'b1;
                            instrValid <= `InstrValid;
                        end
                        `Exe_RegReg_And:
                        begin
                            wreg_o <= `WriteEnable;
                            aluop_o <= `Exe_And_Op;
                            alusel_o <= `Exe_Res_Logic;
                            reg1_read_o <= 1'b1;
                            reg2_read_o <= 1'b1;
                            instrValid <= `InstrValid;
                        end
                        `Exe_RegReg_Sll:
                        begin
                            wreg_o <= `WriteEnable;
                            aluop_o <= `Exe_Sll_Op;
                            alusel_o <= `Exe_Res_Shift;
                            reg1_read_o <= 1'b1;
                            reg2_read_o <= 1'b1;
                            instrValid <= `InstrValid;
                        end
                        `Exe_RegReg_SrlSra:
                        begin
                            wreg_o <= `WriteEnable;
                            if (instr_i[30] == 1'b0)
                            begin
                                aluop_o <= `Exe_Srl_Op;
                            end
                            else begin
                                aluop_o <= `Exe_Sra_Op;
                            end
                            alusel_o <= `Exe_Res_Shift;
                            reg1_read_o <= 1'b1;
                            reg2_read_o <= 1'b1;
                            instrValid <= `InstrValid;
                        end
                        `Exe_RegReg_AddSub:
                        begin
                            wreg_o <= `WriteEnable;
                            if (instr_i[30] == 1'b0)
                            begin
                                aluop_o <= `Exe_Add_Op;
                            end
                            else begin
                                aluop_o <= `Exe_Sub_Op;
                            end
                            alusel_o <= `Exe_Res_Arithmetic;
                            reg1_read_o <= 1'b1;
                            reg2_read_o <= 1'b1;
                            instrValid <= `InstrValid;
                        end
                        `Exe_RegReg_Slt:
                        begin
                            wreg_o <= `WriteEnable;
                            aluop_o <= `Exe_Slt_Op;
                            alusel_o <= `Exe_Res_Arithmetic;
                            reg1_read_o <= 1'b1;
                            reg2_read_o <= 1'b1;
                            instrValid <= `InstrValid;
                        end
                        `Exe_RegReg_Sltu:
                        begin
                            wreg_o <= `WriteEnable;
                            aluop_o <= `Exe_Sltu_Op;
                            alusel_o <= `Exe_Res_Arithmetic;
                            reg1_read_o <= 1'b1;
                            reg2_read_o <= 1'b1;
                            instrValid <= `InstrValid;
                        end
                        default:
                        begin
                        end
                    endcase
                end
                `Exe_Load:
                begin
                    case (funct3)
                        `Exe_Load_Lb:
                        begin
                            wreg_o <= `WriteEnable;
                            aluop_o <= `Exe_Lb_Op;
                            alusel_o <= `Exe_Res_Load;
                            reg1_read_o <= 1'b1;
                            reg2_read_o <= 1'b0;
                            imm2 <= {{20{instr_i[31]}}, instr_i[31 : 20]};
                            instrValid <= `InstrValid;
                        end
                        `Exe_Load_Lh:
                        begin
                            wreg_o <= `WriteEnable;
                            aluop_o <= `Exe_Lh_Op;
                            alusel_o <= `Exe_Res_Load;
                            reg1_read_o <= 1'b1;
                            reg2_read_o <= 1'b0;
                            imm2 <= {{20{instr_i[31]}}, instr_i[31 : 20]};
                            instrValid <= `InstrValid;
                        end
                        `Exe_Load_Lw:
                        begin
                            wreg_o <= `WriteEnable;
                            aluop_o <= `Exe_Lw_Op;
                            alusel_o <= `Exe_Res_Load;
                            reg1_read_o <= 1'b1;
                            reg2_read_o <= 1'b0;
                            imm2 <= {{20{instr_i[31]}}, instr_i[31 : 20]};
                            instrValid <= `InstrValid;
                        end
                        `Exe_Load_Lbu:
                        begin
                            wreg_o <= `WriteEnable;
                            aluop_o <= `Exe_Lbu_Op;
                            alusel_o <= `Exe_Res_Load;
                            reg1_read_o <= 1'b1;
                            reg2_read_o <= 1'b0;
                            imm2 <= {{20{instr_i[31]}}, instr_i[31 : 20]};
                            instrValid <= `InstrValid;
                        end
                        `Exe_Load_Lhu:
                        begin
                            wreg_o <= `WriteEnable;
                            aluop_o <= `Exe_Lhu_Op;
                            alusel_o <= `Exe_Res_Load;
                            reg1_read_o <= 1'b1;
                            reg2_read_o <= 1'b0;
                            imm2 <= {{20{instr_i[31]}}, instr_i[31 : 20]};
                            instrValid <= `InstrValid;
                        end
                        default:
                        begin
                        end
                    endcase
                end
                `Exe_Store:
                begin
                    case (funct3)
                        `Exe_Store_Sb:
                        begin
                            wreg_o <= `WriteDisable;
                            aluop_o <= `Exe_Sb_Op;
                            alusel_o <= `Exe_Res_Store;
                            reg1_read_o <= 1'b1;
                            reg2_read_o <= 1'b1;
                            instrValid <= `InstrValid;
                        end
                        `Exe_Store_Sh:
                        begin
                            wreg_o <= `WriteDisable;
                            aluop_o <= `Exe_Sh_Op;
                            alusel_o <= `Exe_Res_Store;
                            reg1_read_o <= 1'b1;
                            reg2_read_o <= 1'b1;
                            instrValid <= `InstrValid;
                        end
                        `Exe_Store_Sw:
                        begin
                            wreg_o <= `WriteDisable;
                            aluop_o <= `Exe_Sw_Op;
                            alusel_o <= `Exe_Res_Store;
                            reg1_read_o <= 1'b1;
                            reg2_read_o <= 1'b1;
                            instrValid <= `InstrValid;
                        end
                        default:
                        begin
                        end
                    endcase
                end
            endcase
        end
    end

    always @ (*)
    begin
        if (rst == `RstEnable || rdy == `ReadyNot)
        begin
            reg1_o <= 0;
            stall_for_reg1 <= `NoStop;
        end
        else
        begin
            stall_for_reg1 <= `NoStop;
            if (pre_load == `True && ex_wd_i == reg1_addr_o && reg1_read_o == 1'b1 && ex_pc_i != mac_pc_i)
            begin
                stall_for_reg1 <= `Stop;
                reg1_o <= 0;
            end
            else if ((reg1_read_o == 1'b1) && (ex_wreg_i == 1'b1) && (ex_wd_i == reg1_addr_o))
            begin
                reg1_o <= (reg1_addr_o == `RegNumLog2'h0) ? 0 : ex_wdata_i;
            end
            else if ((reg1_read_o == 1'b1) && (mac_wreg_i == 1'b1) && (mac_wd_i == reg1_addr_o))
            begin
                reg1_o <= (reg1_addr_o == `RegNumLog2'h0) ? 0 : mac_wdata_i;
            end
            else if (reg1_read_o == 1'b1)
            begin
                reg1_o <= reg1_data_i;
            end
            else if (reg1_read_o == 1'b0)
            begin
                reg1_o <= imm;
            end
            else begin
                reg1_o <= 0;
            end
        end
    end

    always @ (*)
    begin
        if (rst == `RstEnable || rdy == `ReadyNot)
        begin
            reg2_o <= 0;
            stall_for_reg2 <= `NoStop;
        end
        else
        begin
            stall_for_reg2 <= `NoStop;
            if (pre_load == `True && ex_wd_i == reg2_addr_o && reg2_read_o == 1'b1 && ex_pc_i != mac_pc_i)
            begin
                stall_for_reg2 <= `Stop;
                reg2_o <= 0;
            end
            else if ((reg2_read_o == 1'b1) && (ex_wreg_i == 1'b1) && (ex_wd_i == reg2_addr_o))
            begin
                reg2_o <= (reg2_addr_o == `RegNumLog2'h0) ? 0 : ex_wdata_i;
            end
            else if ((reg2_read_o == 1'b1) && (mac_wreg_i == 1'b1) && (mac_wd_i == reg2_addr_o))
            begin
                reg2_o <= (reg2_addr_o == `RegNumLog2'h0) ? 0 : mac_wdata_i;
            end
            else if (reg2_read_o == 1'b1)
            begin
                reg2_o <= reg2_data_i;
            end
            else if (reg2_read_o == 1'b0)
            begin
                reg2_o <= imm2;
            end
            else begin
                reg2_o <= 0;
            end
        end
    end
endmodule