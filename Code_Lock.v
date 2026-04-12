`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10.04.2026 11:46:48
// Design Name: 
// Module Name: Debounce_Edge_detector
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


module Debounce_Edge_detector#(parameter COUNT = 20'd1000000)(input x,input reset, input clk, output reg z);
reg [19:0] counter;
reg x_prev, x_sync0, x_sync1;
wire x_stable=x_sync1;

always @(posedge clk)begin
if(reset)begin
x_prev<=1'b0;
x_sync0<=1'b0;
x_sync1<=1'b0;
counter<=20'b0;
end 

else begin
x_sync0<=x;
x_sync1<=x_sync0;
z<=1'b0;
if(x_stable!=x_prev)begin
counter<=20'd0;
x_prev<=x_stable;
end 

else if(counter<COUNT-1)
counter<=counter+20'd1;
else if( counter==COUNT-1)begin
counter<=counter+20'd1;
z<=x_stable;
end
end
end
endmodule
