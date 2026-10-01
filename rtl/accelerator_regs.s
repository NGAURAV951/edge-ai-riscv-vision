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

    logic [7:0] a [0:N-1];
    logic [7:0] b [0:N-1];

    logic        start;
    logic [15:0] result;

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

    // Register writes
    always_ff @(posedge clk) begin
        if (rst) begin
            start <= 1'b0;
            busy  <= 1'b0;
            done  <= 1'b0;
            result <= 16'd0;

            for (i = 0; i < N; i = i + 1) begin
                a[i] <= 8'd0;
                b[i] <= 8'd0;
            end
        end
        else begin
            done <= 1'b0;

            if (wr_en) begin
                case (addr)
                    ADDR_A0: a[0] <= wr_data;
                    ADDR_A1: a[1] <= wr_data;
                    ADDR_A2: a[2] <= wr_data;
                    ADDR_A3: a[3] <= wr_data;

                    ADDR_B0: b[0] <= wr_data;
                    ADDR_B1: b[1] <= wr_data;
                    ADDR_B2: b[2] <= wr_data;
                    ADDR_B3: b[3] <= wr_data;

                    ADDR_CTRL: begin
                        if (wr_data[0] && !busy) begin
                            start <= 1'b1;
                            busy  <= 1'b1;
                        end
                    end

                    default: ;
                endcase
            end

            if (start) begin
                result <=
                    (a[0] * b[0]) +
                    (a[1] * b[1]) +
                    (a[2] * b[2]) +
                    (a[3] * b[3]);

                start <= 1'b0;
                busy  <= 1'b0;
                done  <= 1'b1;
            end
        end
    end

    // Register reads
    always_comb begin
        rd_data = 8'd0;

        if (rd_en) begin
            case (addr)
                ADDR_STATUS: rd_data = {6'd0, done, busy};
                ADDR_RESULT: rd_data = result[7:0];

                default: rd_data = 8'd0;
            endcase
        end
    end

endmodule