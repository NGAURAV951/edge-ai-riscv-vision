`timescale 1ns/1ps

module tb_accelerator_regs;

    logic       clk;
    logic       rst;
    logic       wr_en;
    logic       rd_en;
    logic [3:0] addr;
    logic [7:0] wr_data;
    logic [7:0] rd_data;
    logic       busy;
    logic       done;

    accelerator_regs dut (
        .clk(clk),
        .rst(rst),
        .wr_en(wr_en),
        .rd_en(rd_en),
        .addr(addr),
        .wr_data(wr_data),
        .rd_data(rd_data),
        .busy(busy),
        .done(done)
    );

    always #5 clk = ~clk;

    task write_reg(input logic [3:0] address, input logic [7:0] data);
        begin
            @(negedge clk);
            addr = address;
            wr_data = data;
            wr_en = 1'b1;

            @(negedge clk);
            wr_en = 1'b0;
        end
    endtask

    task read_reg(input logic [3:0] address);
        begin
            @(negedge clk);
            addr = address;
            rd_en = 1'b1;

            @(negedge clk);
            $display("READ addr=%h data=%h", address, rd_data);

            rd_en = 1'b0;
        end
    endtask

    initial begin
        clk = 1'b0;
        rst = 1'b1;
        wr_en = 1'b0;
        rd_en = 1'b0;
        addr = 4'h0;
        wr_data = 8'h00;

        #20;
        rst = 1'b0;

        // A = [1, 2, 3, 4]
        write_reg(4'h0, 8'd1);
        write_reg(4'h1, 8'd2);
        write_reg(4'h2, 8'd3);
        write_reg(4'h3, 8'd4);

        // B = [10, 20, 30, 40]
        write_reg(4'h4, 8'd10);
        write_reg(4'h5, 8'd20);
        write_reg(4'h6, 8'd30);
        write_reg(4'h7, 8'd40);

        // Start accelerator
        write_reg(4'h8, 8'h01);

        #20;

        // Expected result:
        // 1*10 + 2*20 + 3*30 + 4*40 = 300
        read_reg(4'hA);

        if (rd_data == 8'd44)
            $display("ACCELERATOR_REGS_PASS result=%0d", rd_data);
        else
            $display("ACCELERATOR_REGS_FAIL result=%0d expected=44", rd_data);

        $finish;
    end

endmodule