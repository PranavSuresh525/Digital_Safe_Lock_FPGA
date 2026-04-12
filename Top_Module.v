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


module safe_lock_top #(parameter COUNT = 20'd1_000_000)(
    input  wire       CLOCK_50,      // 50 MHz clock on DE2
    input  wire [3:0] KEY,           // KEY[0]=reset, KEY[1]=btn_up
                                     // KEY[2]=btn_down, KEY[3]=btn_confirm
    input  wire       programming,   // SW[0] for example
    output wire [6:0] HEX0, HEX1, HEX2, HEX3, HEX4,
    output wire       LEDR,          // red LED
    output wire       LEDG           // green LED
);
wire btn_up_raw    = ~KEY[1];
wire btn_down_raw  = ~KEY[2];
wire btn_conf_raw  = ~KEY[3];
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

Debounce_Edge_detector #(.COUNT(COUNT)) M1(.clk(CLOCK_50), .reset(reset), .x(btn_up_raw),   .z(btn_up_pulse));
Debounce_Edge_detector #(.COUNT(COUNT)) M2(.clk(CLOCK_50), .reset(reset), .x(btn_down_raw), .z(btn_down_pulse));
Debounce_Edge_detector #(.COUNT(COUNT)) M3(.clk(CLOCK_50), .reset(reset), .x(btn_conf_raw), .z(btn_conf_pulse));
Digit_selector M4(.clear(clear_digit), .clk(CLOCK_50), .reset(reset), .btn_up(btn_up_pulse), .btn_down(btn_down_pulse), .en(en), .digit(digit));
Shift_Register M5(.shift(shift), .d(entered), .digit_in(digit), .reset(reset), .clk(CLOCK_50));
Password_Store M6(.shift(shift), .prog_en(prog_en), .reset(reset), .clk(CLOCK_50), .digit_in(digit), .password(stored));
Moore_FSM M7(.btn_press(btn_press), .clk(CLOCK_50), .reset(reset), .shift(shift), .en(en), .programming(programming), .error_led(LEDR), .unlock_led(LEDG), .match(match),.btn_confirm(btn_conf_pulse), .prog_en(prog_en));
Comparator M8(.entered(entered), .stored(stored), .match(match));

Safe_Seven_Seg S0(.digit(entered[3:0]),   .seg(HEX0));
Safe_Seven_Seg S1(.digit(entered[7:4]),   .seg(HEX1));
Safe_Seven_Seg S2(.digit(entered[11:8]),  .seg(HEX2));
Safe_Seven_Seg S3(.digit(entered[15:12]), .seg(HEX3));
Safe_Seven_Seg S4(.digit(entered[19:16]), .seg(HEX4));

endmodule
