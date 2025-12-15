// Negative-edge triggered T flip-flop with asynchronous active-high reset
module t_flipflop (
    input  wire clk,
    input  wire t,
    input  wire rst,
    output reg  q
);
    // Start from a known state in simulation
    // Asynchronous reset, toggle on falling edge of clk when T is asserted
    always @(negedge clk or posedge rst) begin
        if (rst) begin
            q <= 1'b0;
        end else if (t) begin
            q <= ~q;
        end else begin
            q <= q;
        end
    end
endmodule

