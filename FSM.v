`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12.04.2026 12:47:32
// Design Name: 
// Module Name: FSM
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


    module Moore_FSM(
        // inputs
        input  wire       clk,
        input  wire       reset,
        input  wire       btn_press,    // any debounced button pulse (up/down/confirm)
        input  wire       btn_confirm,  // specifically the confirm button pulse
        input  wire       match,        // from Comparator
        input  wire       programming,  // allows user to change thir password
        // outputs — Moore: depend only on current state
        output reg        en,           // to Digit_Selector: allow input
        output reg        shift,        // to Shift_Register + Password_Store: shift in digit
        output reg        prog_en,      // to Password_Store: programming mode
        output reg        unlock_led,   // green LED
        output reg        error_led     // red LED
    );
    reg [2:0]  digit_count;    // 0–5, tracks confirmed digits in ENTERING
    reg [26:0] timeout_cnt;    // counts up to 100,000,000 for 2s timeout
    reg [2:0]  state, next_state;  // current and next state registers
    wire clear_digit;
    assign clear_digit=shift;
    // 000=IDLE
    //001=Entering
    //010=Verify
    //011=Unlocked
    //100=Locked
    //101=programming
    always @(posedge clk) begin
    if(reset) begin
        state       <= 3'b0;
        digit_count <= 3'b0;
        timeout_cnt <= 27'd0;
    end
    else begin
        state <= next_state;

        if(state == 3'b100)
            timeout_cnt <= timeout_cnt + 27'd1;
        else
            timeout_cnt <= 27'd0;

        if(state == 3'b000 || state == 3'b011)
            digit_count <= 3'b0;
        else if(shift)
            digit_count <= digit_count + 1'b1;
    end
end
    
    always@(*)begin
    case(state)
    3'b000: begin
    next_state= btn_press? 3'b001: 3'b000;
    en=1'b0;
    shift=1'b0;
    prog_en=1'b0;
    unlock_led=1'b0;
    error_led=1'b0;
    end
    
    3'b001: begin
    next_state= (digit_count==3'b101)? 3'b010:3'b001;
    en=1'b1;
    shift= btn_confirm? 1'b1:1'b0;
    prog_en=1'b0;
    unlock_led=1'b0;
    error_led=1'b0;
    end
    
    3'b010: begin
    next_state= match? 3'b011:3'b100;
    en=1'b0;
    shift=1'b0;
    prog_en=1'b0;
    unlock_led=1'b0;
    error_led=1'b1;
    end
    
   
   3'b011: begin
    next_state= programming? 3'b101:btn_confirm? 3'b000: 3'b011;
    en=1'b0;
    shift=1'b0;
    prog_en=1'b0;
    unlock_led=1'b1;
    error_led=1'b0;
    end
    
    3'b100: begin
    next_state=(timeout_cnt>=27'd100_000_000)?3'b000:3'b100;
    en=1'b0;
    shift=1'b0;
    prog_en=1'b0;
    unlock_led=1'b0;
    error_led=1'b1;
    end
    
    3'b101: begin
    next_state = (digit_count == 3'b101) ? 3'b000 : 3'b101;
    en=1'b1;
    shift= btn_confirm? 1'b1:1'b0;
    prog_en=1'b1;
    unlock_led=1'b0;
    error_led=1'b0;
    end
    
    default: begin
    next_state = 3'b000;
    en         = 1'b0;
    shift      = 1'b0;
    prog_en    = 1'b0;
    unlock_led = 1'b0;
    error_led  = 1'b0;
    end
    
    endcase
    end
    endmodule
