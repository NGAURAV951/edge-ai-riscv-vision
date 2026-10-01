
`timescale 1ns/1ps

module accelerator_regs #(
    parameter N = 4
) (
    input  logic         clk,
    input  logic         rst,

    // Simple memory-mapped interface
    input  logic         wr_en,
    input  logic         rd_en,
    input  logic [3:0]   addr,
    input  logic [7:0]   wr_data,
    output logic [7:0]   rd_data,

    // Accelerator status
    output logic         busy,
    output logic         done
);

    // Input vectors stored in memory-mapped registers
    logic signed [7:0] a [N];
    logic signed [7:0] b [N];

    // Control signals for the actual accelerator
    logic start;
    logic accel_done;

    // Result from dot_product accelerator
    logic signed [19:0] result;

    integer i;

    // Register map
    localparam ADDR_A0     = 4'h0;
    localparam ADDR_A1     = 4'h1;
    localparam ADDR_A2     = 4'h2;
    localparam ADDR_A3     = 4'h3;

    localparam ADDR_B0     = 4'h4;
    localparam ADDR_B1     = 4'h5;
    localparam ADDR_B2     = 4'h6;
    localparam ADDR_B3     = 4'h7;

    localparam ADDR_CTRL   = 4'h8;
    localparam ADDR_STATUS = 4'h9;
    localparam ADDR_RESULT = 4'hA;

    // Actual hardware accelerator
    dot_product #(
        .N(N)
    ) accelerator (
        .clk(clk),
        .rst(rst),
        .start(start),
        .a(a),
        .b(b),
        .result(result),
        .done(accel_done)
    );

    // Register writes and control
    always_ff @(posedge clk) begin
        if (rst) begin
            start <= 1'b0;
            busy  <= 1'b0;
            done  <= 1'b0;

            for (i = 0; i < N; i = i + 1) begin
                a[i] <= 8'sd0;
                b[i] <= 8'sd0;
            end
        end
        else begin
            // Default: done is a one-cycle pulse
            done <= 1'b0;

            // Write input/control registers
            if (wr_en) begin
                case (addr)
                    ADDR_A0: a[0] <= $signed(wr_data);
                    ADDR_A1: a[1] <= $signed(wr_data);
                    ADDR_A2: a[2] <= $signed(wr_data);
                    ADDR_A3: a[3] <= $signed(wr_data);

                    ADDR_B0: b[0] <= $signed(wr_data);
                    ADDR_B1: b[1] <= $signed(wr_data);
                    ADDR_B2: b[2] <= $signed(wr_data);
                    ADDR_B3: b[3] <= $signed(wr_data);

                    ADDR_CTRL: begin
                        if (wr_data[0] && !busy) begin
                            start <= 1'b1;
                            busy  <= 1'b1;
                        end
                    end

                    default: ;
                endcase
            end

            // Start is a one-cycle pulse
            if (start)
                start <= 1'b0;

            // Accelerator has completed
            if (accel_done) begin
                busy <= 1'b0;
                done <= 1'b1;
            end
        end
    end

    // Register reads
    always_comb begin
        rd_data = 8'h00;

        if (rd_en) begin
            case (addr)
                ADDR_STATUS:
                    rd_data = {6'd0, done, busy};

                ADDR_RESULT:
                    rd_data = result[7:0];

                default:
                    rd_data = 8'h00;
            endcase
        end
    end

endmodule
