`include "defines.v"

module mcu
    (
        input   wire                clk,
        input   wire                rst,
        input   wire                rdy,
        input   wire[5 : 0]         stall,

        //for ram
        input   wire[`MemDataBus]   mem_din,



        //for if
        //input   wire
        input   wire[`MemAddrBus]   if_a,
        //for mac
        input   wire                mac_req,
        input   wire[`MacDataBus]   mac_dout,
        input   wire[`MemAddrBus]   mac_a,
        input   wire                mac_wr,
        input   wire[3 : 0]         mac_kind,
        input   wire[`InstrAddrBus] mac_pc_i,


        //for cache
        input   wire                missed,
        input   wire[`InstrBus]     cache_instr_i,
        output  reg                 cache_we,
        output  reg [`InstrBus]     cache_instr_o,



        //for ram
        output  reg [`MemDataBus]   mem_dout,
        output  wire[`MemAddrBus]   mem_a,
        output  wire                mem_wr,



        //for if
        output  wire                if_busy,
        output  wire                if_done,
        output  wire[`InstrBus]     if_instr,
        //for mac
        output  wire                mac_busy,
        output  wire                mac_done,
        output  wire[`MacDataBus]   mac_din,
        output  wire[`InstrAddrBus] mac_pc_o
    );

    reg                 pointer;
    reg [3 : 0]         part_filled;
    reg [3 : 0]         part_finished;

    reg [`MemDataBus]   part0;
    reg [`MemDataBus]   part1;
    reg [`MemDataBus]   part2;
    reg [`MemDataBus]   part3;
    reg [`MemDataBus]   part0_old;
    reg [`MemDataBus]   part1_old;
    reg [`MemDataBus]   part2_old;

    reg [`InstrAddrBus] mac_pc;
    

    always @ (posedge clk)
    begin
        mem_dout <= 0;
        if (rdy == `ReadyNot)
        begin
        end
        else if (rst == `RstEnable)
        begin
            part_filled <= 4'b1111;
            part_finished <= 4'b1111;
            pointer <= 0;
            cache_we <= 1'b0;
            cache_instr_o <= 0;
            mac_pc <= 0;
        end
        else if ((part_filled == part_finished) || (part_filled != part_finished && pointer == `PointToIf && ~missed))
        begin
            pointer <= mac_req;
            if (missed && pointer == `PointToIf && part_finished != 4'b1111)
            begin
                cache_we <= 1'b1;
                cache_instr_o <= {part3, part2, part1, part0};
            end
            else
            begin
                cache_we <= 1'b0;
            end
            if (mac_req == 1'b1)
            begin
                part_finished <= mac_kind;
                part_filled <= 0;
                mem_dout <= mac_dout[7 : 0];
                mac_pc <= mac_pc_i;
            end
            else if (stall[0] == stall[1])
            begin
                part_finished <= 4'b0100;
                part_filled <= 0;
            end
            else
            begin
                part_filled <= 4'b1111;
                part_finished <= 4'b1111;
            end
        end
        else begin
            cache_we <= 1'b0;
            case (part_filled)
                4'b0000:
                begin
                    mem_dout <= mac_dout[15 : 8];
                    part_filled <= 4'b0001;
                end
                4'b0001:
                begin
                    mem_dout <= mac_dout[23 : 16];
                    part_filled <= 4'b0010;
                end
                4'b0010:
                begin
                    mem_dout <= mac_dout[31 : 24];
                    part_filled <= 4'b0011;
                end
                4'b0011:
                begin
                    part_filled <= 4'b0100;
                end
                default:
                begin
                end
            endcase
        end
    end

    
    always @ (posedge clk)
    begin
        part0_old <= part0;
        part1_old <= part1;
        part2_old <= part2;
    end

    always @ (*)
    begin
        if (rst == `RstEnable)
        begin
            part0 <= 8'b00000000;
            part1 <= 8'b00000000;
            part2 <= 8'b00000000;
            part3 <= 8'b00000000;
        end
        else
        begin
            case (part_filled)
                4'b0001:
                begin
                    part0 <= mem_din;
                    part1 <= 8'b00000000;
                    part2 <= 8'b00000000;
                    part3 <= 8'b00000000;
                end 
                4'b0010:
                begin
                    part0 <= part0_old;
                    part1 <= mem_din;
                    part2 <= 8'b00000000;
                    part3 <= 8'b00000000;
                end
                4'b0011:
                begin
                    part0 <= part0_old;
                    part1 <= part1_old;
                    part2 <= mem_din;
                    part3 <= 8'b00000000;
                end
                4'b0100:
                begin
                    part0 <= part0_old;
                    part1 <= part1_old;
                    part2 <= part2_old;
                    part3 <= mem_din;
                end
                default:
                begin
                    part0 <= 8'b00000000;
                    part1 <= 8'b00000000;
                    part2 <= 8'b00000000;
                    part3 <= 8'b00000000;
                end
            endcase
        end
    end

    assign if_instr = (pointer == `PointToIf && ~missed) ? cache_instr_i : {part3, part2, part1, part0};
    assign if_busy = pointer;
    assign if_done = (part_filled == part_finished) ? 1'b1 : (pointer == `PointToIf ? ~missed : 1'b0);
    assign mac_din = {part3, part2, part1, part0};
    assign mac_busy = ~pointer;
    assign mac_done = (part_filled == part_finished) ? 1'b1 : (pointer == `PointToIf ? ~missed : 1'b0);
    assign mac_pc_o = (~mac_busy && mac_done) ? mac_pc : 0;

    assign mem_a = (pointer == `PointToIf) ?
        (if_done ? if_a + part_finished - 1'b1 : if_a + part_filled) :
        (mac_done ? mac_a + part_finished - 1'b1 : mac_a + part_filled);
    assign mem_wr = (pointer == `PointToMac) ? mac_wr : `ReadMode;
    
endmodule // mcu