`timescale 1ns/1ps

// Deterministic directed + pseudo-random tests for signed INT8 dot products.
module tb_dot_product_random;
    localparam integer N = 16;
    localparam integer RANDOM_CASES = 100;
    localparam integer DIRECTED_CASES = 5;
    localparam integer TOTAL_CASES = RANDOM_CASES + DIRECTED_CASES;

    logic clk;
    logic rst;
    logic start;
    logic [N*8-1:0] a_bytes;
    logic [N*8-1:0] b_bytes;
    logic signed [31:0] result;
    logic done;
    logic busy;

    integer case_id;
    integer j;
    integer tests_passed;
    integer expected_result;
    integer operand_a;
    integer operand_b;
    integer seed_state;
    logic [31:0] random_word;

    dot_product #(.N(N)) dut (
        .clk(clk), .rst(rst), .start(start),
        .a_bytes(a_bytes), .b_bytes(b_bytes), .result(result), .done(done), .busy(busy)
    );

    always #5 clk = ~clk;

    // Small deterministic LCG: the same seed gives the same test vectors.
    function automatic [31:0] next_random;
        begin
            seed_state = seed_state * 32'd1664525 + 32'd1013904223;
            next_random = seed_state;
        end
    endfunction

    initial begin
        #1000000;
        $fatal(1, "WATCHDOG_TIMEOUT: randomized dot-product test exceeded 1 ms");
    end

    task automatic run_case(input integer this_case);
        integer k;
        begin
            expected_result = 0;

            for (k = 0; k < N; k = k + 1) begin
                case (this_case)
                    0: begin // all-zero inputs
                        a_bytes[k*8 +: 8] = 8'sd0;
                        b_bytes[k*8 +: 8] = 8'sd0;
                    end
                    1: begin // maximum positive operands
                        a_bytes[k*8 +: 8] = 8'sd127;
                        b_bytes[k*8 +: 8] = 8'sd127;
                    end
                    2: begin // minimum negative operands
                        a_bytes[k*8 +: 8] = -8'sd128;
                        b_bytes[k*8 +: 8] = -8'sd128;
                    end
                    3: begin // alternating opposite signs and extremes
                        a_bytes[k*8 +: 8] = (k % 2 == 0) ? -8'sd128 : 8'sd127;
                        b_bytes[k*8 +: 8] = (k % 2 == 0) ? 8'sd127 : -8'sd128;
                    end
                    4: begin // boundary values mixed across each vector
                        case (k % 4)
                            0: begin a_bytes[k*8 +: 8] = -8'sd128; b_bytes[k*8 +: 8] = 8'sd127; end
                            1: begin a_bytes[k*8 +: 8] = -8'sd1;   b_bytes[k*8 +: 8] = -8'sd128; end
                            2: begin a_bytes[k*8 +: 8] = 8'sd0;    b_bytes[k*8 +: 8] = 8'sd127; end
                            3: begin a_bytes[k*8 +: 8] = 8'sd127;  b_bytes[k*8 +: 8] = -8'sd1; end
                        endcase
                    end
                    default: begin
                        random_word = next_random();
                        a_bytes[k*8 +: 8] = random_word[31:24];
                        random_word = next_random();
                        b_bytes[k*8 +: 8] = random_word[31:24];
                    end
                endcase

                // Widen operands before multiplication to avoid 8-bit math.
                operand_a = $signed(a_bytes[k*8 +: 8]);
                operand_b = $signed(b_bytes[k*8 +: 8]);
                expected_result = expected_result + (operand_a * operand_b);
            end

            // Start request, aligned to the falling edge to avoid races.
            @(negedge clk);
            start = 1'b1;
            @(negedge clk);
            start = 1'b0;

            // Catch the one-cycle completion pulse without a posedge race.
            // The global watchdog above prevents this wait from hanging forever.
            wait (done === 1'b1);
            #1;

            if (done !== 1'b1)
                $fatal(1, "RANDOM_CASE_FAIL case=%0d: done timeout", this_case);
            if (busy !== 1'b0)
                $fatal(1, "RANDOM_CASE_FAIL case=%0d: busy remained high", this_case);
            if ($signed(result) !== expected_result)
                $fatal(1,
                    "RANDOM_CASE_FAIL case=%0d got=%0d expected=%0d",
                    this_case, $signed(result), expected_result);

            tests_passed = tests_passed + 1;
            if (this_case < DIRECTED_CASES)
                $display("DIRECTED_CASE_PASS case=%0d result=%0d", this_case, $signed(result));
            else
                $display("RANDOM_CASE_PASS case=%0d result=%0d", this_case, $signed(result));
        end
    endtask

    initial begin
        clk = 1'b0;
        rst = 1'b1;
        start = 1'b0;
        tests_passed = 0;
        seed_state = 32'h51A7E123;
        for (j = 0; j < N; j = j + 1) begin
            a_bytes[j*8 +: 8] = 8'sd0;
            b_bytes[j*8 +: 8] = 8'sd0;
        end

        repeat (3) @(negedge clk);
        rst = 1'b0;

        for (case_id = 0; case_id < TOTAL_CASES; case_id = case_id + 1)
            run_case(case_id);

        if (tests_passed != TOTAL_CASES)
            $fatal(1, "RANDOM_TEST_COUNT_FAIL passed=%0d expected=%0d", tests_passed, TOTAL_CASES);

        $display("RANDOMIZED_DOT_PRODUCT_PASS cases=%0d random_cases=%0d directed_cases=%0d",
            tests_passed, RANDOM_CASES, DIRECTED_CASES);
        $finish;
    end
endmodule
