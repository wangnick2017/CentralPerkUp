`include "defines.v"

module cache
    (
        input   wire                clk,
        input   wire                rst,
        input   wire                rdy,
        input   wire[5 : 0]         stall,

        input   wire[`InstrAddrBus] pc,
        input   wire[`InstrAddrBus] npc,
        input   wire                we,
        input   wire[`InstrBus]     instr_i,
        
        output  reg                 missed,
        output  reg [`InstrBus]     instr_o
    );

    reg [`CacheBus]     maps[0 : 63];
    reg [`InstrAddrBus] pc_old;
    wire[5 : 0]         npc_select  = npc[7 : 2];
    
    always @ (posedge clk)
    begin
        if (rst == `RstEnable)
        begin
            missed <= 1'b1;
            instr_o <= 0;
            pc_old <= 0;
            maps[6'b000000] <= 0;
            maps[6'b000001] <= 0;
            maps[6'b000010] <= 0;
            maps[6'b000011] <= 0;
            maps[6'b000100] <= 0;
            maps[6'b000101] <= 0;
            maps[6'b000110] <= 0;
            maps[6'b000111] <= 0;
            maps[6'b001000] <= 0;
            maps[6'b001001] <= 0;
            maps[6'b001010] <= 0;
            maps[6'b001011] <= 0;
            maps[6'b001100] <= 0;
            maps[6'b001101] <= 0;
            maps[6'b001110] <= 0;
            maps[6'b001111] <= 0;
            maps[6'b010000] <= 0;
            maps[6'b010001] <= 0;
            maps[6'b010010] <= 0;
            maps[6'b010011] <= 0;
            maps[6'b010100] <= 0;
            maps[6'b010101] <= 0;
            maps[6'b010110] <= 0;
            maps[6'b010111] <= 0;
            maps[6'b011000] <= 0;
            maps[6'b011001] <= 0;
            maps[6'b011010] <= 0;
            maps[6'b011011] <= 0;
            maps[6'b011100] <= 0;
            maps[6'b011101] <= 0;
            maps[6'b011110] <= 0;
            maps[6'b011111] <= 0;
            maps[6'b100000] <= 0;
            maps[6'b100001] <= 0;
            maps[6'b100010] <= 0;
            maps[6'b100011] <= 0;
            maps[6'b100100] <= 0;
            maps[6'b100101] <= 0;
            maps[6'b100110] <= 0;
            maps[6'b100111] <= 0;
            maps[6'b101000] <= 0;
            maps[6'b101001] <= 0;
            maps[6'b101010] <= 0;
            maps[6'b101011] <= 0;
            maps[6'b101100] <= 0;
            maps[6'b101101] <= 0;
            maps[6'b101110] <= 0;
            maps[6'b101111] <= 0;
            maps[6'b110000] <= 0;
            maps[6'b110001] <= 0;
            maps[6'b110010] <= 0;
            maps[6'b110011] <= 0;
            maps[6'b110100] <= 0;
            maps[6'b110101] <= 0;
            maps[6'b110110] <= 0;
            maps[6'b110111] <= 0;
            maps[6'b111000] <= 0;
            maps[6'b111001] <= 0;
            maps[6'b111010] <= 0;
            maps[6'b111011] <= 0;
            maps[6'b111100] <= 0;
            maps[6'b111101] <= 0;
            maps[6'b111110] <= 0;
            maps[6'b111111] <= 0;
        end
        else
        begin
            pc_old <= pc;
            if (we & pc[12])
            begin
                maps[pc_old[7 : 2]] <= {1'b1, instr_i, pc_old[11 : 8]};
            end
            if (stall[0] == `NoStop && npc[12] == 1'b1 && maps[npc_select][36] == 1'b1 && maps[npc_select][3 : 0] == npc[11 : 8])
            begin
                missed <= 1'b0;
                instr_o <= maps[npc_select][35 : 4];
            end
            else
            begin
                missed <= 1'b1;
                instr_o <= 0;
            end
        end
    end

endmodule