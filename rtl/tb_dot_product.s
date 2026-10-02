`timescale 1ns/1ps

module tb_dot_product;

    localparam N = 16;

    logic clk;
    logic rst;
    logic start;

    logic signed [7:0] a [N];
    logic signed [7:0] b [N];

    logic signed [31:0] result;
    logic done;
    logic busy;

    integer cycle_count;

    dot_product #(
        .N(N)
    ) dut (
        .clk(clk),
        .rst(rst),
        .start(start),
        .a(a),
        .b(b),
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

        // Signed-value test vectors
        a[0]  = 8'sd1;
        a[1]  = -8'sd2;
        a[2]  = 8'sd3;
        a[3]  = -8'sd4;
        a[4]  = 8'sd5;
        a[5]  = -8'sd6;
        a[6]  = 8'sd7;
        a[7]  = -8'sd8;
        a[8]  = 8'sd9;
        a[9]  = -8'sd10;
        a[10] = 8'sd11;
        a[11] = -8'sd12;
        a[12] = 8'sd13;
        a[13] = -8'sd14;
        a[14] = 8'sd15;
        a[15] = -8'sd16;

        // B = [1,2,3,...,16]
        b[0]  = 8'sd1;
        b[1]  = 8'sd2;
        b[2]  = 8'sd3;
        b[3]  = 8'sd4;
        b[4]  = 8'sd5;
        b[5]  = 8'sd6;
        b[6]  = 8'sd7;
        b[7]  = 8'sd8;
        b[8]  = 8'sd9;
        b[9]  = 8'sd10;
        b[10] = 8'sd11;
        b[11] = 8'sd12;
        b[12] = 8'sd13;
        b[13] = 8'sd14;
        b[14] = 8'sd15;
        b[15] = 8'sd16;

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

        // Expected:
        // 1² - 2² + 3² - 4² + ... + 15² - 16² = -136
        if (result == -136)
            $display("SIGNED_DOT_PRODUCT_PASS result=%0d", result);
        else
            $display(
                "SIGNED_DOT_PRODUCT_FAIL result=%0d expected=-136",
                result
            );

        if (cycle_count == N)
            $display("LATENCY_PASS cycles=%0d", cycle_count);
        else
            $display(
                "LATENCY_FAIL cycles=%0d expected=%0d",
                cycle_count,
                N
            );

        $finish;
    end

endmodule
