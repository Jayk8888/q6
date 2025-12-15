`timescale 1ns/1ps
// Single-file testbench with DUTs

// Negative-edge triggered T flip-flop with asynchronous active-high reset
module t_flipflop (
    input  wire clk,
    input  wire t,
    input  wire rst,
    output reg  q
);
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

// Asynchronous counter skeleton for sequence: 0 → 2 → 5 → 7 → 8 → 10 → 9 → 11 → 8 → ...
// External clock feeds only tff1; all other stages use q1 as their clock.
module async_counter (
    input  wire rst,
    input  wire clk,
    output wire [3:0] q
);
    // Individual bit wires
    wire q0;
    wire q1;
    wire q2;
    wire q3;

    // Derived T controls
    wire t0_sig;
    wire t1_sig;
    wire t2_sig;
    wire t3_sig;

    assign t3_sig = q0;                 // for q3 stage
    assign t2_sig = ~q3;                // for q2 stage
    assign t1_sig = 1'b1;               // for q1 stage
    assign t0_sig = (~q3) | (~q2);      // for q0 stage

    // Bit 0 (clocked by q1)
    t_flipflop ff0 (
        .clk (q1), // driven by q1
        .rst (rst),
        .t   (t0_sig),   // derived T for bit 0
        .q   (q0)
    );

    // Bit 1 (driven by external clock)
    t_flipflop ff1 (
        .clk (clk), // external clock
        .rst (rst),
        .t   (t1_sig), // derived T for bit 1
        .q   (q1)
    );

    // Bit 2 (clocked by q1)
    t_flipflop ff2 (
        .clk (q1), // driven by q1
        .rst (rst),
        .t   (t2_sig), // derived T for bit 2
        .q   (q2)
    );

    // Bit 3 (clocked by q1)
    t_flipflop ff3 (
        .clk (q1), // driven by q1
        .rst (rst),
        .t   (t3_sig), // derived T for bit 3
        .q   (q3)
    );

    // Concatenate bit outputs
    assign q = {q3, q2, q1, q0};

endmodule

module async_counter_tb;
    // Drive signals
    reg clk;
    reg rst;

    // DUT outputs
    wire [3:0] q;

    integer i; // loop counter

    // Device under test
    async_counter dut (
        .rst (rst),
        .clk (clk),
        .q   (q)
    );

    initial begin
        // Initialize drives
        clk = 1'b0;
        rst = 1'b1;

        // Hold reset for two clock edges to start at q=0
        repeat (2) begin
            #5 clk = ~clk;
        end

        rst = 1'b0;

        // Run 200 clock toggles and report
        for (i = 0; i < 200; i = i + 1) begin
            #5  clk = ~clk; // posedge
            #5  clk = ~clk; // negedge (t_ff active edge)
            $display("cycle %0d: q=%0d (%b)", i, q, q);
        end
        $finish;
    end
endmodule

