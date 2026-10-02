`timescale 1ns/1ps

module dot_product #(
    parameter N = 4
) (
    input  logic clk,
    input  logic rst,
    input  logic start,

    input  logic signed [7:0] a [N],
    input  logic signed [7:0] b [N],

    output logic signed [31:0] result,
    output logic done,
    output logic busy
);

    integer index;

    logic signed [31:0] accumulator;

    always_ff @(posedge clk) begin
        if (rst) begin
            index       <= 0;
            accumulator <= 32'sd0;
            result      <= 32'sd0;
            done        <= 1'b0;
            busy        <= 1'b0;
        end
        else begin
            done <= 1'b0;

            // Start a new dot-product operation.
            if (start && !busy) begin
                index       <= 0;
                accumulator <= 32'sd0;
                busy        <= 1'b1;
            end

            // Process one multiply-accumulate per clock.
            else if (busy) begin
                accumulator <= accumulator + (a[index] * b[index]);

                if (index == N - 1) begin
                    result <= accumulator + (a[index] * b[index]);
                    busy   <= 1'b0;
                    done   <= 1'b1;
                end
                else begin
                    index <= index + 1;
                end
            end
        end
    end

endmodule
