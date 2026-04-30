`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12.04.2026 16:00:18
// Design Name: 
// Module Name: Top_Module
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module safe_lock_top #(parameter COUNT = 21'd2_000_000)(
    input  wire       CLOCK_100,      // 50 MHz clock on DE2
    input  wire [3:0] KEY,           // KEY[0]=reset, KEY[1]=btn_up
                                     // KEY[2]=btn_down, KEY[3]=btn_confirm
    input  wire       programming,   // SW[0] for example
    output wire [6:0] seg, 
    output wire [3:0] an, 
    output wire       LEDR,          // red LED
    output wire       LEDG           // green LED
);
wire btn_up_raw    = KEY[1];
wire btn_down_raw  = KEY[2];
wire btn_conf_raw  = KEY[3];
wire reset         = ~KEY[0];

wire        btn_up_pulse;    // debouncer → digit selector
wire        btn_down_pulse;  // debouncer → digit selector
wire        btn_conf_pulse;  // debouncer → FSM + shift register
wire        match;           // comparator → FSM
wire        en;              // FSM → digit selector
wire        shift;           // FSM → shift register + password store
wire        prog_en;         // FSM → password store
wire [3:0]  digit;           // digit selector → shift register + 7seg
wire [19:0] entered;         // shift register → comparator
wire [19:0] stored;          // password store → comparator
wire        btn_press;
wire clear_digit;


assign clear_digit = shift;
assign btn_press = btn_up_pulse | btn_down_pulse | btn_conf_pulse;

Debounce_Edge_detector #(.COUNT(COUNT)) M1(.clk(CLOCK_100), .reset(reset), .x(btn_up_raw),   .z(btn_up_pulse));
Debounce_Edge_detector #(.COUNT(COUNT)) M2(.clk(CLOCK_100), .reset(reset), .x(btn_down_raw), .z(btn_down_pulse));
Debounce_Edge_detector #(.COUNT(COUNT)) M3(.clk(CLOCK_100), .reset(reset), .x(btn_conf_raw), .z(btn_conf_pulse));
Digit_selector M4(.clear(clear_digit), .clk(CLOCK_100), .reset(reset), .btn_up(btn_up_pulse), .btn_down(btn_down_pulse), .en(en), .digit(digit));
Shift_Register M5(.shift(shift), .d(entered), .digit_in(digit), .reset(reset), .clk(CLOCK_100));
Password_Store M6(.shift(shift), .prog_en(prog_en), .reset(reset), .clk(CLOCK_100), .digit_in(digit), .password(stored));
Moore_FSM M7(.btn_press(btn_press), .clk(CLOCK_100), .reset(reset), .shift(shift), .en(en), .programming(programming), .error_led(LEDR), .unlock_led(LEDG), .match(match),.btn_confirm(btn_conf_pulse), .prog_en(prog_en));
Comparator M8(.entered(entered), .stored(stored), .match(match));

Display_Mux DISP(
    .clk(CLOCK_100),
    .reset(reset),
    .digits(entered[15:0]),   // show last 4 digits
    .seg(seg),
    .an(an)
);

endmodule


