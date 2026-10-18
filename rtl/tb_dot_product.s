`timescale 1ns/1ps

module tb_dot_product;

    // Fail fast rather than hang forever if the DUT never completes.
    initial begin
        #100000;
        $fatal(1, "WATCHDOG_TIMEOUT: dot-product test did not finish within 100 us");
    end

    localparam integer N = 16;

    logic clk;
    logic rst;
    logic start;

    logic [N*8-1:0] a_bytes;
    logic [N*8-1:0] b_bytes;

    logic signed [31:0] result;
    logic done;
    logic busy;

    integer cycle_count;
    integer i;

    dot_product #(
        .N(N)
    ) dut (
        .clk(clk),
        .rst(rst),
        .start(start),
        .a_bytes(a_bytes),
        .b_bytes(b_bytes),
        .result(result),
        .done(done),
        .busy(busy)
    );

    always #5 clk = ~clk;

    initial begin
        clk = 1'b0;
        rst = 1'b1;
        start = 1'b0;
        cycle_count = 0;

        // A = [1, -2, 3, -4, ..., 15, -16], B = [1, 2, ..., 16].
        for (i = 0; i < N; i = i + 1) begin
            if (i % 2 == 0)
                a_bytes[i*8 +: 8] = i + 1;
            else
                a_bytes[i*8 +: 8] = -(i + 1);
            b_bytes[i*8 +: 8] = i + 1;
        end

        #20;
        rst = 1'b0;

        // Start accelerator
        @(negedge clk);
        start = 1'b1;

        @(negedge clk);
        start = 1'b0;

        // Count accelerator cycles
        while (done == 1'b0) begin
            @(posedge clk);
            if (busy)
                cycle_count = cycle_count + 1;
        end

        #1;

        $display("RESULT=%0d", result);
        $display("BUSY=%b", busy);
        $display("DONE=%b", done);
        $display("CYCLES=%0d", cycle_count);

        if (result == -136)
            $display("SIGNED_DOT_PRODUCT_PASS result=%0d", result);
        else
            $display("SIGNED_DOT_PRODUCT_FAIL result=%0d expected=-136", result);

        if (cycle_count == N)
            $display("LATENCY_PASS cycles=%0d", cycle_count);
        else
            $display("LATENCY_FAIL cycles=%0d expected=%0d", cycle_count, N);

        $finish;
    end

endmodule
