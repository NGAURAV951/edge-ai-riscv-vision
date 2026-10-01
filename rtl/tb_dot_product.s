`timescale 1ns/1ps

module tb_dot_product;
    localparam N = 4;

    logic clk = 0;
    logic rst = 1;
    logic start = 0;
    logic signed [7:0] a [N];
    logic signed [7:0] b [N];
    logic signed [19:0] result;
    logic done;

    dot_product #(.N(N)) dut (
        .clk(clk), .rst(rst), .start(start),
        .a(a), .b(b), .result(result), .done(done)
    );

    always #5 clk = ~clk;

    initial begin
        a[0]=1; a[1]=2; a[2]=3; a[3]=4;
        b[0]=5; b[1]=6; b[2]=7; b[3]=8;

        #12 rst = 0;
        #8 start = 1;
        #10 start = 0;

        #1;
        if (result !== 70) begin
            $display("DOT_PRODUCT_FAIL result=%0d", result);
            $finish(1);
        end

        $display("DOT_PRODUCT_PASS result=%0d", result);
        $finish(0);
    end
endmodule
