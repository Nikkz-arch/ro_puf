`timescale 1ns/1ps
module ring_oscillator #(
    parameter integer DELAY = 1
)(
    input  wire enable,
    output wire ro_out
);
    wire n1, n2, n3, n4, n5;

    assign n1 = enable & n5;
    assign #DELAY n2 = ~n1;
    assign #DELAY n3 = ~n2;
    assign #DELAY n4 = ~n3;
    assign #DELAY n5 = ~n4;

    assign ro_out = n5;
endmodule

module mux4 (
    input  wire in0, in1, in2, in3,
    input  wire [1:0] sel,
    output wire out
);
    assign out = (sel == 2'b00) ? in0 :
                 (sel == 2'b01) ? in1 :
                 (sel == 2'b10) ? in2 :
                                  in3;
endmodule
module edge_counter (
    input  wire clk_in,
    input  wire rst,
    input  wire enable,
    output reg  [31:0] count
);
    always @(posedge clk_in or posedge rst) begin
        if (rst)
            count <= 0;
        else if (enable)
            count <= count + 1;
    end
endmodule
module window_timer (
    input  wire clk,
    input  wire rst,
    input  wire start,
    output reg  enable
);
    reg [15:0] timer;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            timer  <= 0;
            enable <= 0;
        end
        else if (start) begin
            timer  <= timer + 1;
            enable <= 1;
        end
        else begin
            timer  <= 0;
            enable <= 0;
        end
    end
endmodule
module comparator (
    input  wire [31:0] c1,
    input  wire [31:0] c2,
    output wire result
);
    assign result = (c1 > c2);
endmodule
module ro_puf_top (
    input  wire        sys_clk,
    input  wire        rst,
    input  wire        start,
    input  wire [3:0]  challenge,
    output reg         response
);

    wire [7:0] ro_sig;
    wire mux_a, mux_b;
    wire count_en;
    wire [31:0] cnt_a, cnt_b;

    window_timer WT (
        .clk(sys_clk),
        .rst(rst),
        .start(start),
        .enable(count_en)
    );

    ring_oscillator #(.DELAY(1)) RO0 (.enable(count_en), .ro_out(ro_sig[0]));
    ring_oscillator #(.DELAY(2)) RO1 (.enable(count_en), .ro_out(ro_sig[1]));
    ring_oscillator #(.DELAY(3)) RO2 (.enable(count_en), .ro_out(ro_sig[2]));
    ring_oscillator #(.DELAY(4)) RO3 (.enable(count_en), .ro_out(ro_sig[3]));

    ring_oscillator #(.DELAY(5)) RO4 (.enable(count_en), .ro_out(ro_sig[4]));
    ring_oscillator #(.DELAY(6)) RO5 (.enable(count_en), .ro_out(ro_sig[5]));
    ring_oscillator #(.DELAY(7)) RO6 (.enable(count_en), .ro_out(ro_sig[6]));
    ring_oscillator #(.DELAY(8)) RO7 (.enable(count_en), .ro_out(ro_sig[7]));

    mux4 MUX1 (
        .in0(ro_sig[0]), .in1(ro_sig[1]),
        .in2(ro_sig[2]), .in3(ro_sig[3]),
        .sel(challenge[1:0]),
        .out(mux_a)
    );

    mux4 MUX2 (
        .in0(ro_sig[4]), .in1(ro_sig[5]),
        .in2(ro_sig[6]), .in3(ro_sig[7]),
        .sel(challenge[3:2]),
        .out(mux_b)
    );

    edge_counter C1 (
        .clk_in(mux_a),
        .rst(rst),
        .enable(count_en),
        .count(cnt_a)
    );

    edge_counter C2 (
        .clk_in(mux_b),
        .rst(rst),
        .enable(count_en),
        .count(cnt_b)
    );

    always @(posedge sys_clk or posedge rst) begin
        if (rst)
            response <= 1'b0;
        else if (!count_en)
            response <= (cnt_a > cnt_b);
        else
            response <= response;
    end

endmodule
