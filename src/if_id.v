`include "defines.v"
module if_id
    (
        input   wire                clk,
        input   wire                rst,
        input   wire                rdy,
        input   wire[5 : 0]         stall,
    
        input   wire[`InstrAddrBus] if_pc,
        input   wire[`InstrBus]     if_instr,
    
        output  reg [`InstrAddrBus] id_pc,
        output  reg [`InstrBus]     id_instr
    );

    always @ (posedge clk)
    begin
        if (rst == `RstEnable || stall[1] == `Stop && stall[2] == `NoStop)
        begin
            id_pc <= 0;
            id_instr <= 0;
        end
        else if (rdy == `Ready && stall[1] == `NoStop)
        begin
            id_pc <= if_pc;
            id_instr <= if_instr;
        end
    end
    
endmodule