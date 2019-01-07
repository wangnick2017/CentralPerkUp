//Global
`define RstEnable           1'b1 //Reset Signal Enable
`define RstDisable          1'b0
`define Ready               1'b1
`define ReadyNot            1'b0
`define WriteEnable         1'b1
`define WriteDisable        1'b0
`define ReadEnable          1'b1
`define ReadDisable         1'b0
`define AluOpBus            5 : 0 //Output the width of aluop_o when decoding
`define AluSelBus           2 : 0
`define InstrValid          1'b0
`define InstrInvalid        1'b1
`define Stop                1'b1
`define NoStop              1'b0
`define Branch              1'b1
`define NotBranch           1'b0
`define True                1'b1
`define False               1'b0




//Opcodes
`define Exe_Lui             7'b0110111
`define Exe_Auipc           7'b0010111

`define Exe_RegImm          7'b0010011
`define Exe_RegImm_Addi     3'b000
`define Exe_RegImm_Slti     3'b010
`define Exe_RegImm_Sltiu    3'b011
`define Exe_RegImm_Xori     3'b100
`define Exe_RegImm_Ori      3'b110
`define Exe_RegImm_Andi     3'b111
`define Exe_RegImm_Slli     3'b001
`define Exe_RegImm_SrliSrai 3'b101

`define Exe_RegReg          7'b0110011
`define Exe_RegReg_AddSub   3'b000
`define Exe_RegReg_Sll      3'b001
`define Exe_RegReg_Slt      3'b010
`define Exe_RegReg_Sltu     3'b011
`define Exe_RegReg_Xor      3'b100
`define Exe_RegReg_SrlSra   3'b101
`define Exe_RegReg_Or       3'b110
`define Exe_RegReg_And      3'b111

`define Exe_Jal             7'b1101111
`define Exe_Jalr            7'b1100111

`define Exe_B               7'b1100011
`define Exe_B_Beq           3'b000
`define Exe_B_Bne           3'b001
`define Exe_B_Blt           3'b100
`define Exe_B_Bge           3'b101
`define Exe_B_Bltu          3'b110
`define Exe_B_Bgeu          3'b111

`define Exe_Load            7'b0000011
`define Exe_Load_Lb         3'b000
`define Exe_Load_Lh         3'b001
`define Exe_Load_Lw         3'b010
`define Exe_Load_Lbu        3'b100
`define Exe_Load_Lhu        3'b101

`define Exe_Store           7'b0100011
`define Exe_Store_Sb        3'b000
`define Exe_Store_Sh        3'b001
`define Exe_Store_Sw        3'b010

`define Exe_NOP             7'b0000000


//AluOp
`define Exe_Lui_Op          6'b000000
`define Exe_Or_Op           6'b000001
`define Exe_Xor_Op          6'b000010
`define Exe_And_Op          6'b000011
`define Exe_Sll_Op          6'b000100
`define Exe_Srl_Op          6'b000101
`define Exe_Sra_Op          6'b000110
`define Exe_Add_Op          6'b000111
`define Exe_Sub_Op          6'b001000
`define Exe_Slt_Op          6'b001001
`define Exe_Sltu_Op         6'b001010
`define Exe_Beq_Op          6'b001011
`define Exe_Bne_Op          6'b001100
`define Exe_Blt_Op          6'b001101
`define Exe_Bge_Op          6'b001110
`define Exe_Bltu_Op         6'b001111
`define Exe_Bgeu_Op         6'b010000
`define Exe_Jal_Op          6'b010001
`define Exe_Jalr_Op         6'b010010
`define Exe_Lb_Op           6'b010011
`define Exe_Lh_Op           6'b010100
`define Exe_Lw_Op           6'b010101
`define Exe_Lbu_Op          6'b010110
`define Exe_Lhu_Op          6'b010111
`define Exe_Sb_Op           6'b011000
`define Exe_Sh_Op           6'b011001
`define Exe_Sw_Op           6'b011010

`define Exe_Nop_Op          6'b111111

//AluSel
`define Exe_Res_Logic       3'b000
`define Exe_Res_Shift       3'b001
`define Exe_Res_Arithmetic  3'b010
`define Exe_Res_JumpBranch  3'b011
`define Exe_Res_Load        3'b100
`define Exe_Res_Store       3'b101

`define Exe_Res_Nop         3'b111


//指令存储器Instr_rom
`define InstrAddrBus        31 : 0
`define InstrBus            31 : 0


//通用寄存器regfile
`define RegAddrBus          4 : 0
`define RegBus              31 : 0
`define RegWidth            32
`define RegNum              32
`define RegNumLog2          5
`define NopRegAddr          5'b00000

`define MemDataBus          7 : 0
`define MemAddrBus          31 : 0
`define MemBusy             1'b1
`define MemNotDone          1'b0
`define MemDone             1'b1
`define PointToIf           1'b0
`define PointToMac          1'b1
`define ReadMode            1'b0
`define WriteMode           1'b1

`define MacDataBus          31 : 0

`define InvalidPc           32'b11111111111111111111111111111111

`define CacheBus            36 : 0