`timescale 1ns/1ps

module tb_ro_puf_top;

    // ------------------------
    // Testbench signals
    // ------------------------
    reg         sys_clk;
    reg         rst;
    reg         start;
    reg [3:0]   challenge;
    wire        response;

    // ------------------------
    // Instantiate DUT
    // ------------------------
    ro_puf_top DUT (
        .sys_clk(sys_clk),
        .rst(rst),
        .start(start),
        .challenge(challenge),
        .response(response)
    );

    // ------------------------
    // System clock generation
    // ------------------------
    initial begin
        sys_clk = 0;
        forever #5 sys_clk = ~sys_clk;   // 100 MHz clock
    end

    // ------------------------
    // Stimulus
    // ------------------------
    initial begin
        // Initial values
        rst       = 1'b1;
        start     = 1'b0;
        challenge = 4'b0000;

        // Hold reset
        #50;
        rst = 1'b0;

        // ------------------------
        // First challenge
        // ------------------------
        #20;
        challenge = 4'b0011;

        // Open measurement window
        #10;
        start = 1'b1;

        // Keep window open
        #1000;

        // Close window (IMPORTANT)
        start = 1'b0;

        // Wait for response to latch
        #200;

        // ------------------------
        // Second challenge
        // ------------------------
        challenge = 4'b1101;

        #10;
        start = 1'b1;

        #1000;
        start = 1'b0;

        #200;

        // ------------------------
        // Third challenge
        // ------------------------
        challenge = 4'b0101;

        #10;
        start = 1'b1;

        #1000;
        start = 1'b0;

        #200;

        // End simulation
        $finish;
    end

    // ------------------------
    // Monitor (optional)
    // ------------------------
    initial begin
        $monitor(
            "Time=%0t | challenge=%b | start=%b | response=%b",
            $time, challenge, start, response
        );
    end

endmodule
