`timescale 1ns/1ps

module accelerator_regs #(
    parameter N = 16
) (
    input  logic clk,
    input  logic rst,

    input  logic wr_en,
    input  logic rd_en,
    input  logic [5:0] addr,
    input  logic [7:0] wr_data,
    output logic [7:0] rd_data,

    output logic busy,
    output logic done
);

    logic signed [7:0] a [N];
    logic signed [7:0] b [N];

    logic start;
    logic accel_done;
    logic accel_busy;

    logic signed [31:0] result;

    integer i;

    localparam ADDR_A0          = 6'h00;
    localparam ADDR_B0          = 6'h10;
    localparam ADDR_CTRL        = 6'h20;
    localparam ADDR_STATUS      = 6'h21;
    localparam ADDR_RESULT      = 6'h22;
    localparam ADDR_RESULT_HIGH = 6'h23;

    dot_product #(
        .N(N)
    ) accelerator (
        .clk(clk),
        .rst(rst),
        .start(start),
        .a(a),
        .b(b),
        .result(result),
        .done(accel_done),
        .busy(accel_busy)
    );

    assign busy = accel_busy;

    always_ff @(posedge clk) begin

        if (rst) begin

            start <= 1'b0;
            done  <= 1'b0;

            for (i = 0; i < N; i = i + 1) begin
                a[i] <= 8'sd0;
                b[i] <= 8'sd0;
            end

        end
        else begin

            start <= 1'b0;

            if (wr_en) begin

                if (addr >= ADDR_A0 && addr < ADDR_B0) begin
                    a[addr - ADDR_A0] <= $signed(wr_data);
                end

                else if (addr >= ADDR_B0 && addr < ADDR_CTRL) begin
                    b[addr - ADDR_B0] <= $signed(wr_data);
                end

                else if (addr == ADDR_CTRL) begin

                    if (wr_data[0] && !accel_busy) begin
                        start <= 1'b1;
                        done  <= 1'b0;
                    end

                end

            end

            if (accel_done) begin
                done <= 1'b1;
            end

        end

    end

    /*
     * Register read logic.
     *
     * Use always @(*) instead of always_comb because
     * Icarus Verilog handles this form without the
     * constant-select warning for result[31:0].
     */
    always @(*) begin

        rd_data = 8'h00;

        if (rd_en) begin

            case (addr)

                ADDR_STATUS:
                    rd_data = {6'd0, done, busy};

                ADDR_RESULT:
                    rd_data = result[7:0];

                ADDR_RESULT_HIGH:
                    rd_data = result[15:8];

                default:
                    rd_data = 8'h00;

            endcase

        end

    end

endmodule
