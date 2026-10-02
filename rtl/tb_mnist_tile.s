`timescale 1ns/1ps

module tb_mnist_tile;

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

        /*
         * Representative signed INT8 MNIST tile.
         *
         * These values model the kind of signed
         * quantized weights used by the classifier.
         */

        a[0]  = 8'sd12;
        a[1]  = -8'sd7;
        a[2]  = 8'sd25;
        a[3]  = -8'sd3;
        a[4]  = 8'sd18;
        a[5]  = -8'sd11;
        a[6]  = 8'sd5;
        a[7]  = 8'sd9;
        a[8]  = -8'sd14;
        a[9]  = 8'sd21;
        a[10] = -8'sd6;
        a[11] = 8'sd4;
        a[12] = -8'sd19;
        a[13] = 8'sd8;
        a[14] = 8'sd16;
        a[15] = -8'sd10;

        b[0]  = 8'sd3;
        b[1]  = 8'sd5;
        b[2]  = -8'sd2;
        b[3]  = 8'sd7;
        b[4]  = -8'sd4;
        b[5]  = 8'sd6;
        b[6]  = 8'sd9;
        b[7]  = -8'sd3;
        b[8]  = 8'sd5;
        b[9]  = -8'sd2;
        b[10] = 8'sd8;
        b[11] = -8'sd6;
        b[12] = 8'sd4;
        b[13] = -8'sd5;
        b[14] = 8'sd3;
        b[15] = 8'sd7;

        #20;
        rst = 1'b0;

        @(negedge clk);
        start = 1'b1;

        @(negedge clk);
        start = 1'b0;

        while (done == 1'b0) begin
            @(posedge clk);

            if (busy)
                cycle_count = cycle_count + 1;
        end

        #1;

        $display("MNIST_TILE_RESULT=%0d", result);
        $display("MNIST_TILE_BUSY=%b", busy);
        $display("MNIST_TILE_DONE=%b", done);
        $display("MNIST_TILE_CYCLES=%0d", cycle_count);

        /*
         * Expected signed dot product:
         *
         * Sum(a[i] * b[i]) = 174
         */

         if (result == -512)
            $display(
                "MNIST_TILE_PASS result=%0d",
                result
            );
        else
            $display(
                "MNIST_TILE_FAIL result=%0d expected=-512",
                result
            );

        if (cycle_count == N)
            $display(
                "MNIST_TILE_LATENCY_PASS cycles=%0d",
                cycle_count
            );
        else
            $display(
                "MNIST_TILE_LATENCY_FAIL cycles=%0d expected=%0d",
                cycle_count,
                N
            );

        $finish;
    end

endmodule
