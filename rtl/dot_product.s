`timescale 1ns/1ps

// One signed INT8 multiply-accumulate per cycle.
// Each operand is a packed byte vector; element i occupies bits [8*i +: 8].
module dot_product #(
    parameter integer N = 4
) (
    input  logic clk,
    input  logic rst,
    input  logic start,

    input  logic [N*8-1:0] a_bytes,
    input  logic [N*8-1:0] b_bytes,

    output logic signed [31:0] result,
    output logic done,
    output logic busy
);

    integer index;
    logic signed [31:0] accumulator;
    logic signed [7:0] operand_a;
    logic signed [7:0] operand_b;
    logic signed [15:0] product;
    logic signed [31:0] product_extended;

    // Packed-vector slices keep the module interface portable to common
    // synthesis tools while preserving explicit signed INT8 arithmetic.
    always_comb begin
        operand_a = $signed(a_bytes[index*8 +: 8]);
        operand_b = $signed(b_bytes[index*8 +: 8]);
        product = operand_a * operand_b;
        product_extended = {{16{product[15]}}, product};
    end

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
                accumulator <= accumulator + product_extended;

                if (index == N - 1) begin
                    result <= accumulator + product_extended;
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
