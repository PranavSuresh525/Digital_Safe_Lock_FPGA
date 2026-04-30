`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 22.04.2026 11:11:50
// Design Name: 
// Module Name: Display_Mux
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

module Display_Mux(
    input  wire        clk,
    input  wire        reset,
    input  wire [15:0] digits,
    output reg  [6:0]  seg,
    output reg  [3:0]  an
);
    reg [16:0] refresh_cnt;
    reg [1:0]  digit_sel;

    always @(posedge clk) begin
        if(reset) begin
            refresh_cnt <= 0;
            digit_sel   <= 0;
        end else begin
            if(refresh_cnt == 17'd100_000) begin
                refresh_cnt <= 0;
                digit_sel   <= digit_sel + 1;
            end else
                refresh_cnt <= refresh_cnt + 1;
        end
    end

    reg [3:0] current_digit;

    always @(*) begin
        case(digit_sel)
            2'b00: begin an = 4'b0001; current_digit = digits[3:0];   end
            2'b01: begin an = 4'b0010; current_digit = digits[7:4];   end
            2'b10: begin an = 4'b0100; current_digit = digits[11:8];  end
            2'b11: begin an = 4'b1000; current_digit = digits[15:12]; end
            default: begin an = 4'b0000; current_digit = 4'd0; end
        endcase

        case(current_digit)
            4'd0: seg = 7'b0111111;
            4'd1: seg = 7'b0000110;
            4'd2: seg = 7'b1011011;
            4'd3: seg = 7'b1001111;
            4'd4: seg = 7'b1100110;
            4'd5: seg = 7'b1101101;
            4'd6: seg = 7'b1111101;
            4'd7: seg = 7'b0000111;
            4'd8: seg = 7'b1111111;
            4'd9: seg = 7'b1101111;
            default: seg = 7'b0000000;
        endcase
    end

endmodule