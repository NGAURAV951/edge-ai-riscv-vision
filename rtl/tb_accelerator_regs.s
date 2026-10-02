`timescale 1ns/1ps

module tb_accelerator_regs;

    logic clk;
    logic rst;

    logic wr_en;
    logic rd_en;
    logic [5:0] addr;
    logic [7:0] wr_data;
    logic [7:0] rd_data;

    logic busy;
    logic done;

    integer cycle_count;

    logic [7:0] status_value;
    logic [7:0] result_low;
    logic [7:0] result_high;

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

    // 100 MHz clock
    always #5 clk = ~clk;

    // ------------------------------------------------------------
    // Register write
    // ------------------------------------------------------------

    task write_reg(
        input logic [5:0] address,
        input logic [7:0] data
    );
        begin
            @(negedge clk);

            addr    = address;
            wr_data = data;
            wr_en   = 1'b1;

            @(negedge clk);

            wr_en = 1'b0;
        end
    endtask

    // ------------------------------------------------------------
    // Register read
    // ------------------------------------------------------------

    task read_reg(
        input logic [5:0] address,
        output logic [7:0] data
    );
        begin
            @(negedge clk);

            addr  = address;
            rd_en = 1'b1;

            #1;

            data = rd_data;

            rd_en = 1'b0;
        end
    endtask

    // ------------------------------------------------------------
    // Test
    // ------------------------------------------------------------

    initial begin

        clk = 1'b0;
        rst = 1'b1;

        wr_en   = 1'b0;
        rd_en   = 1'b0;
        addr    = 6'h00;
        wr_data = 8'h00;

        cycle_count = 0;

        // --------------------------------------------------------
        // Reset
        // --------------------------------------------------------

        #20;
        rst = 1'b0;

        // --------------------------------------------------------
        // Vector A
        //
        // [1, -2, 3, -4, 5, -6, 7, -8,
        //  9, -10, 11, -12, 13, -14, 15, -16]
        // --------------------------------------------------------

        write_reg(6'h00, 8'h01);
        write_reg(6'h01, 8'hFE);
        write_reg(6'h02, 8'h03);
        write_reg(6'h03, 8'hFC);
        write_reg(6'h04, 8'h05);
        write_reg(6'h05, 8'hFA);
        write_reg(6'h06, 8'h07);
        write_reg(6'h07, 8'hF8);
        write_reg(6'h08, 8'h09);
        write_reg(6'h09, 8'hF6);
        write_reg(6'h0A, 8'h0B);
        write_reg(6'h0B, 8'hF4);
        write_reg(6'h0C, 8'h0D);
        write_reg(6'h0D, 8'hF2);
        write_reg(6'h0E, 8'h0F);
        write_reg(6'h0F, 8'hF0);

        // --------------------------------------------------------
        // Vector B
        //
        // [1, 2, 3, 4, 5, 6, 7, 8,
        //  9, 10, 11, 12, 13, 14, 15, 16]
        // --------------------------------------------------------

        write_reg(6'h10, 8'h01);
        write_reg(6'h11, 8'h02);
        write_reg(6'h12, 8'h03);
        write_reg(6'h13, 8'h04);
        write_reg(6'h14, 8'h05);
        write_reg(6'h15, 8'h06);
        write_reg(6'h16, 8'h07);
        write_reg(6'h17, 8'h08);
        write_reg(6'h18, 8'h09);
        write_reg(6'h19, 8'h0A);
        write_reg(6'h1A, 8'h0B);
        write_reg(6'h1B, 8'h0C);
        write_reg(6'h1C, 8'h0D);
        write_reg(6'h1D, 8'h0E);
        write_reg(6'h1E, 8'h0F);
        write_reg(6'h1F, 8'h10);

        // --------------------------------------------------------
        // Start
        // --------------------------------------------------------

        write_reg(6'h20, 8'h01);

        // --------------------------------------------------------
        // Wait until accelerator becomes busy
        // --------------------------------------------------------

        wait (busy === 1'b1);

        // --------------------------------------------------------
        // Count actual accelerator computation cycles
        // --------------------------------------------------------

        while (busy === 1'b1) begin
            @(posedge clk);
            cycle_count = cycle_count + 1;
        end

        // --------------------------------------------------------
        // Wait for DONE
        // --------------------------------------------------------

        wait (done === 1'b1);

        // --------------------------------------------------------
        // Read registers
        // --------------------------------------------------------

        read_reg(6'h21, status_value);
        read_reg(6'h22, result_low);
        read_reg(6'h23, result_high);

        // --------------------------------------------------------
        // Display
        // --------------------------------------------------------

        $display("STATUS=0x%02X", status_value);
        $display("BUSY=%b", busy);
        $display("DONE=%b", done);
        $display("CYCLES=%0d", cycle_count);

        $display(
            "RESULT=0x%02X%02X",
            result_high,
            result_low
        );

        // --------------------------------------------------------
        // Verify status
        // DONE = bit 1
        // BUSY = bit 0
        //
        // Expected status = 0x02
        // --------------------------------------------------------

        if (status_value == 8'h02)
            $display("STATUS_PASS");
        else
            $display(
                "STATUS_FAIL value=0x%02X expected=0x02",
                status_value
            );

        // --------------------------------------------------------
        // Verify result
        //
        // Expected:
        //
        // 1*1 + (-2)*2 + 3*3 + (-4)*4 + ...
        // + 15*15 + (-16)*16
        //
        // = -136
        //
        // 32-bit result = 0xFFFFFF78
        // Lower 16 bits = 0xFF78
        // --------------------------------------------------------

        if (result_low == 8'h78 &&
            result_high == 8'hFF) begin

            $display(
                "RESULT_PASS result=0x%02X%02X signed=-136",
                result_high,
                result_low
            );

        end
        else begin

            $display(
                "RESULT_FAIL result=0x%02X%02X expected=0xFF78",
                result_high,
                result_low
            );

        end

        // --------------------------------------------------------
        // Verify exact accelerator latency
        // --------------------------------------------------------

        if (cycle_count == 17)
            $display(
                "REGISTER_LATENCY_PASS cycles=%0d",
                cycle_count
            );
        else
            $display(
                "REGISTER_LATENCY_FAIL cycles=%0d expected=17",
                cycle_count
            );

        $finish;

    end

endmodule
