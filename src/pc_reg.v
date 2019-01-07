`include "defines.v"
module pc_reg
    (
        input   wire                clk,
        input   wire                rst,
        input   wire                rdy,
        input   wire[5 : 0]         stall,
        input   wire                branch_flag_i,
        input   wire[`RegBus]       branch_target_address_i,
        output  reg [`InstrAddrBus] pc,
        output  wire[`InstrAddrBus] npc
    );

    assign npc = (rst == `RstEnable || rdy == `ReadyNot) ? 0 : ((branch_flag_i == `Branch) ? branch_target_address_i : pc + 4'h4);

    always @ (posedge clk)
    begin
        if (rst == `RstEnable)
        begin
            pc <= 32'b11111111111111111111111111111100;
        end
        else if (rdy == `Ready && stall[0] == `NoStop)
        begin
            pc <= npc;//$display("%h",pc);
        end
    end
    
endmodule