`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10.04.2026 14:26:35
// Design Name: 
// Module Name: Digit_selector
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


module Digit_selector(
    input  wire       clk,
    input  wire       reset,
    input  wire       btn_up,    // pulse from debouncer
    input  wire       btn_down,  // pulse from debouncer
    input  wire       en,        // enable from FSM (only active during ENTRY state)
    input  wire       clear,
    output reg  [3:0] digit  
    );
    always@(posedge clk) begin
    if(reset|| clear)
    digit<=4'b0;
    
    else if(en)begin
    if(btn_up && !btn_down)begin
    if(digit==4'b1001)
    digit<=4'b0;
    else
    digit<=digit+4'b1;
    end
    
    else if(btn_down && !btn_up)begin
    if(digit==4'b0000)
    digit<=4'b1001;
    else
    digit<=digit-4'b1;
    end
    end
    end
endmodule
