`include "defines.v"

module iff
    (
        input   wire                clk,
        input   wire                rst,
        input   wire                rdy,
        input   wire[`InstrAddrBus] pc,
        input   wire                mem_busy,
        input   wire                mem_done,
        input   wire[`InstrBus]     mem_din,
        input   wire                missed,

        output  reg [`MemAddrBus]   mem_a,
        output  reg [`InstrBus]     if_instr,
        output  wire                stallreq,
        output  wire                stallearlier
    );

    reg [`MemAddrBus]   mem_a_old;
    reg [`InstrBus]     if_instr_old;
    reg [`InstrAddrBus] pc_old;

    always @ (posedge clk)
    begin
        if (rst == `RstEnable)
        begin
            mem_a_old <= 0;
            if_instr_old <= 0;
            pc_old <= 0;
        end
        else
        begin
            mem_a_old <= mem_a;
            if_instr_old <= if_instr;
            pc_old <= pc;
        end
    end

    always @ (*)
    begin
        if (rst == `RstEnable)
        begin
            mem_a <= 0;
            if_instr <= 0;
        end
        else if (rdy == `Ready)
        begin
            mem_a <= pc;
            if_instr <= (mem_busy != `MemBusy && mem_done == `MemDone) ? mem_din : if_instr_old;
        end
        else
        begin
            mem_a <= mem_a_old;
            if_instr <= if_instr_old;
        end
    end

    assign stallreq = ((mem_done == `MemDone) ? `NoStop : `Stop);
    assign stallearlier = ((mem_done == `MemDone && if_instr[6 : 4] == 3'b110) ? `Stop : `NoStop);

endmodule // if