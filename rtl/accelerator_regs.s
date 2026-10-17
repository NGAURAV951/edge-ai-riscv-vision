
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

    // Register addresses
    localparam ADDR_A0          = 6'h00;
    localparam ADDR_B0          = 6'h10;
    localparam ADDR_CTRL        = 6'h20;
    localparam ADDR_STATUS      = 6'h21;

    // Full 32-bit result registers
    localparam ADDR_RESULT      = 6'h22;
    localparam ADDR_RESULT_HIGH = 6'h23;
    localparam ADDR_RESULT_2    = 6'h24;
    localparam ADDR_RESULT_3    = 6'h25;

    // Dot-product accelerator
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

    // Write registers and control the accelerator
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
                // Write input vector A: addresses 0x00-0x0F
                if (addr >= ADDR_A0 && addr < ADDR_B0) begin
                    a[addr - ADDR_A0] <= $signed(wr_data);
                end

                // Write input vector B: addresses 0x10-0x1F
                else if (addr >= ADDR_B0 && addr < ADDR_CTRL) begin
                    b[addr - ADDR_B0] <= $signed(wr_data);
                end

                // Start command: write bit 0 to address 0x20
                else if (addr == ADDR_CTRL) begin
                    if (wr_data[0] && !accel_busy) begin
                        start <= 1'b1;
                        done  <= 1'b0;
                    end
                end
            end

            // Record accelerator completion
            if (accel_done) begin
                done <= 1'b1;
            end
        end
    end

    // Read register logic
    always @(*) begin
        rd_data = 8'h00;

        if (rd_en) begin
            case (addr)
                // Status: bit 0 = busy, bit 1 = done
                ADDR_STATUS:
                    rd_data = {6'd0, done, busy};

                // Result bits [7:0]
                ADDR_RESULT:
                    rd_data = result[7:0];

                // Result bits [15:8]
                ADDR_RESULT_HIGH:
                    rd_data = result[15:8];

                // Result bits [23:16]
                ADDR_RESULT_2:
                    rd_data = result[23:16];

                // Result bits [31:24]
                ADDR_RESULT_3:
                    rd_data = result[31:24];

                default:
                    rd_data = 8'h00;
            endcase
        end
    end

endmodule
