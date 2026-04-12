`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10.04.2026 14:41:15
// Design Name: 
// Module Name: Shift_Register
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


module Shift_Register(
    input  wire        clk,
    input  wire        reset,
    input  wire        shift,      // pulse from FSM: "confirm this digit"
    input  wire [3:0]  digit_in,   // current digit from Digit_Selector
    output reg  [19:0]  d  // all 5 stored digits
    );
    // d[3:0]   = digit 4 (last entered)
    // d[7:4]   = digit 3
    // d[11:8]  = digit 2
    // d[15:12] = digit 1
    // d[19:16] = digit 0 (first entered)
    always @(posedge clk) begin
        if (reset) begin
            d<= 20'b0;
        end else if (shift) begin
            d <= {d[15:0], digit_in};
        end
    end
    
    
endmodule
