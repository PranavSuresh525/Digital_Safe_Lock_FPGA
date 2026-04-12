`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10.04.2026 16:08:57
// Design Name: 
// Module Name: Password_Store
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


module Password_Store(
    input  wire        clk,
    input  wire        reset,
    input  wire        shift,       // pulse from FSM: shift in new digit
    input  wire        prog_en,     // FSM: 1 = programming mode, 0 = normal
    input  wire [3:0]  digit_in,    // from Digit_Selector
    output reg  [19:0] password     // stored password, read by comparator
);
always@(posedge clk)begin
if(reset)
password<=20'h12345;

else if(prog_en && shift)
 password<= {password[15:0], digit_in};
 end
endmodule
