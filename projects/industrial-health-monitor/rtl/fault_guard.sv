// Combinational threshold guard using scaled fixed-point sensor values.
// voltage_dV: voltage in 0.1 V units; current_dA: current in 0.1 A units.
// vibration_centi_mm_s: vibration in 0.01 mm/s units.
// Demo thresholds only; this block is not safety-rated.
module fault_guard (
    input  logic [15:0] voltage_dV,
    input  logic [15:0] current_dA,
    input  logic [15:0] temperature_C,
    input  logic [15:0] vibration_centi_mm_s,
    output logic [2:0]  fault_code
);
    localparam logic [2:0] NORMAL           = 3'd0;
    localparam logic [2:0] UNDER_VOLTAGE    = 3'd1;
    localparam logic [2:0] OVER_VOLTAGE     = 3'd2;
    localparam logic [2:0] OVER_CURRENT     = 3'd3;
    localparam logic [2:0] OVER_TEMPERATURE = 3'd4;
    localparam logic [2:0] HIGH_VIBRATION   = 3'd5;

    always_comb begin
        fault_code = NORMAL;
        if (voltage_dV < 16'd1800)
            fault_code = UNDER_VOLTAGE;
        else if (voltage_dV > 16'd2500)
            fault_code = OVER_VOLTAGE;
        else if (current_dA > 16'd120)
            fault_code = OVER_CURRENT;
        else if (temperature_C > 16'd80)
            fault_code = OVER_TEMPERATURE;
        else if (vibration_centi_mm_s > 16'd300)
            fault_code = HIGH_VIBRATION;
    end
endmodule