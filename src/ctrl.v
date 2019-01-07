`include "defines.v"
module ctrl
    (
        input   wire                rst,
        input   wire                rdy,
        input   wire                stallreq_from_earlier,
        input   wire                stallreq_from_if,
        input   wire                stallreq_from_id,
        input   wire                stallreq_from_ex,
        input   wire                stallreq_from_mac,
        input   wire                stallreq_from_last,
        output  reg [5 : 0]         stall
    );

    always @ (*)
    begin
        if (rst == `RstEnable || rdy == `ReadyNot)
        begin
            stall <= 6'b000000;
        end
        else if (stallreq_from_last == `Stop)
        begin
            stall <= 6'b111111;
        end
        else if (stallreq_from_mac == `Stop)
        begin
            stall <= 6'b011111;
        end
        else if (stallreq_from_ex == `Stop)
        begin
            stall <= 6'b001111;
        end
        else if (stallreq_from_id == `Stop)
        begin
            stall <= 6'b000111;
        end
        else if (stallreq_from_if == `Stop)
        begin
            stall <= 6'b000011;
        end
        else if (stallreq_from_earlier == `Stop)
        begin
            stall <= 6'b000001;
        end
        else begin
            stall <= 6'b000000;
        end
    end
endmodule