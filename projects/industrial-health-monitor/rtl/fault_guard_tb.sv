`timescale 1ns/1ps
module fault_guard_tb;
    logic [15:0] voltage_dV, current_dA, temperature_C, vibration_centi_mm_s;
    logic [2:0] fault_code;

    localparam logic [2:0] NORMAL = 3'd0;
    localparam logic [2:0] UNDER_VOLTAGE = 3'd1;
    localparam logic [2:0] OVER_VOLTAGE = 3'd2;
    localparam logic [2:0] OVER_CURRENT = 3'd3;
    localparam logic [2:0] OVER_TEMPERATURE = 3'd4;
    localparam logic [2:0] HIGH_VIBRATION = 3'd5;

    fault_guard dut (
        .voltage_dV(voltage_dV),
        .current_dA(current_dA),
        .temperature_C(temperature_C),
        .vibration_centi_mm_s(vibration_centi_mm_s),
        .fault_code(fault_code)
    );

    task automatic check(input logic [2:0] expected, input string label);
        #1;
        if (fault_code !== expected) begin
            $display("FAIL: %s expected=%0d got=%0d", label, expected, fault_code);
            $fatal(1);
        end
        $display("PASS: %s", label);
    endtask

    initial begin
        voltage_dV = 16'd2300; current_dA = 16'd40;
        temperature_C = 16'd42; vibration_centi_mm_s = 16'd110;
        check(NORMAL, "nominal readings");
        voltage_dV = 16'd1700;
        check(UNDER_VOLTAGE, "under-voltage threshold");
        voltage_dV = 16'd2600;
        check(OVER_VOLTAGE, "over-voltage threshold");
        voltage_dV = 16'd2300; current_dA = 16'd130;
        check(OVER_CURRENT, "over-current threshold");
        current_dA = 16'd40; temperature_C = 16'd81;
        check(OVER_TEMPERATURE, "over-temperature threshold");
        temperature_C = 16'd42; vibration_centi_mm_s = 16'd350;
        check(HIGH_VIBRATION, "high-vibration threshold");
        $display("FAULT_GUARD_PASS");
        $finish;
    end
endmodule