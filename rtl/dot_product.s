`timescale 1ns/1ps

module dot_product #(
    parameter N = 4
) (
    input  logic clk,
    input  logic rst,
    input  logic start,
    input  logic signed [7:0] a [N],
    input  logic signed [7:0] b [N],
    output logic signed [19:0] result,
    output logic done
);

    integer i;
    logic signed [19:0] accumulator;

    always_ff @(posedge clk) begin
        if (rst) begin
            accumulator <= '0;
            result <= '0;
            done <= 1'b0;
        end else begin
            done <= 1'b0;
            if (start) begin
                accumulator = '0;
                for (i = 0; i < N; i = i + 1)
                    accumulator = accumulator + a[i] * b[i];
                result <= accumulator;
                done <= 1'b1;
            end
        end
    end
endmodule
