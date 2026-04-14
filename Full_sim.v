`timescale 1ns / 1ps

module safe_lock_top_tb;

    reg        CLOCK_50;
    reg  [3:0] KEY;
    reg        programming;

    wire [6:0] HEX0, HEX1, HEX2, HEX3, HEX4;
    wire       LEDR;
    wire       LEDG;

    safe_lock_top #(.COUNT(20'd10)) DUT(
        .CLOCK_50(CLOCK_50),
        .KEY(KEY),
        .programming(programming),
        .HEX0(HEX0), .HEX1(HEX1), .HEX2(HEX2),
        .HEX3(HEX3), .HEX4(HEX4),
        .LEDR(LEDR),
        .LEDG(LEDG)
    );

    initial CLOCK_50 = 0;
    always #10 CLOCK_50 = ~CLOCK_50;

    task press_btn;
        input [1:0] btn_num;
        begin
            KEY[btn_num] = 1'b0;
            repeat(20) @(posedge CLOCK_50);
            KEY[btn_num] = 1'b1;
            repeat(10) @(posedge CLOCK_50);
        end
    endtask

    task increment_digit;
        input [3:0] times;
        integer i;
        begin
            for(i = 0; i < times; i = i + 1)
                press_btn(1);
        end
    endtask

    task confirm_digit;
        begin
            press_btn(3);
        end
    endtask

    task enter_password;
        input [3:0] d0, d1, d2, d3, d4;
        begin
            press_btn(3);  // wake from IDLE
            increment_digit(d0); confirm_digit;
            increment_digit(d1); confirm_digit;
            increment_digit(d2); confirm_digit;
            increment_digit(d3); confirm_digit;
            increment_digit(d4); confirm_digit;
        end
    endtask

    task wait_timeout;
        begin
            repeat(150) @(posedge CLOCK_50);
        end
    endtask

    initial begin
        KEY         = 4'b1111;
        programming = 1'b0;

        // reset
        $display("--- Reset ---");
        press_btn(0);
        repeat(20) @(posedge CLOCK_50);

        // TEST 1: correct password - green LED stays on until confirm pressed
        $display("--- Test 1: Correct password 1-2-3-4-5 ---");
        enter_password(4'd1, 4'd2, 4'd3, 4'd4, 4'd5);
        repeat(20) @(posedge CLOCK_50);
        $display("After entry: LEDG=%b LEDR=%b", LEDG, LEDR);
        if(LEDG == 1'b1 && LEDR == 1'b0)
            $display("PASS: Green LED on");
        else
            $display("FAIL: LEDG=%b LEDR=%b", LEDG, LEDR);

        // wait a long time - LED should stay on (no timeout)
        repeat(500) @(posedge CLOCK_50);
        $display("After long wait (no button): LEDG=%b LEDR=%b state=%b",
                  LEDG, LEDR, DUT.M7.state);
        if(LEDG == 1'b1)
            $display("PASS: Green LED still on after long wait");
        else
            $display("FAIL: Green LED turned off without button press");

        // press up/down - should NOT lock
        press_btn(1);  // KEY1 = btn_up
        repeat(10) @(posedge CLOCK_50);
        $display("After btn_up press: LEDG=%b state=%b", LEDG, DUT.M7.state);
        if(LEDG == 1'b1)
            $display("PASS: Up button did not lock");
        else
            $display("FAIL: Up button caused lock");

        press_btn(2);  // KEY2 = btn_down
        repeat(10) @(posedge CLOCK_50);
        $display("After btn_down press: LEDG=%b state=%b", LEDG, DUT.M7.state);
        if(LEDG == 1'b1)
            $display("PASS: Down button did not lock");
        else
            $display("FAIL: Down button caused lock");

        // press confirm - should lock and return to IDLE
        $display("--- Pressing confirm to lock ---");
        press_btn(3);  // KEY3 = btn_confirm
        repeat(20) @(posedge CLOCK_50);
        $display("After confirm press: LEDG=%b state=%b",
                  LEDG, DUT.M7.state);
        if(LEDG == 1'b0 && DUT.M7.state == 3'b000)
            $display("PASS: Confirm locked the safe, back to IDLE");
        else
            $display("FAIL: Safe did not lock on confirm");

        // TEST 2: wrong password - red LED, auto timeout still works
        $display("--- Test 2: Wrong password 9-9-9-9-9 ---");
        enter_password(4'd9, 4'd9, 4'd9, 4'd9, 4'd9);
        repeat(20) @(posedge CLOCK_50);
        if(LEDR == 1'b1 && LEDG == 1'b0)
            $display("PASS: Red LED on");
        else
            $display("FAIL: LEDG=%b LEDR=%b", LEDG, LEDR);

        wait_timeout;
        $display("After timeout: state=%b", DUT.M7.state);
        if(DUT.M7.state == 3'b000)
            $display("PASS: Returned to IDLE after timeout");
        else
            $display("FAIL: Did not return to IDLE");

        // TEST 3: program new password
        $display("--- Test 3: Unlock then program 5-4-3-2-1 ---");
        enter_password(4'd1, 4'd2, 4'd3, 4'd4, 4'd5);
        repeat(20) @(posedge CLOCK_50);
        if(LEDG != 1'b1) begin
            $display("FAIL: Could not unlock for programming");
        end else begin
            programming = 1'b1;
            repeat(10) @(posedge CLOCK_50);
            increment_digit(4'd5); confirm_digit;
            increment_digit(4'd4); confirm_digit;
            increment_digit(4'd3); confirm_digit;
            increment_digit(4'd2); confirm_digit;
            increment_digit(4'd1); confirm_digit;
            programming = 1'b0;
            repeat(30) @(posedge CLOCK_50);
            $display("New password programmed, stored=%h", DUT.stored);
        end

        wait_timeout;

        // old password should fail
        $display("--- Test 3a: Old password should fail ---");
        enter_password(4'd1, 4'd2, 4'd3, 4'd4, 4'd5);
        repeat(20) @(posedge CLOCK_50);
        if(LEDR == 1'b1 && LEDG == 1'b0)
            $display("PASS: Old password rejected");
        else
            $display("FAIL: Old password still accepted");

        wait_timeout;

        // new password should pass
        $display("--- Test 3b: New password should pass ---");
        enter_password(4'd5, 4'd4, 4'd3, 4'd2, 4'd1);
        repeat(20) @(posedge CLOCK_50);
        if(LEDG == 1'b1 && LEDR == 1'b0)
            $display("PASS: New password accepted");
        else
            $display("FAIL: New password rejected");

        // lock it with confirm
        press_btn(3);
        repeat(20) @(posedge CLOCK_50);
        if(DUT.M7.state == 3'b000)
            $display("PASS: Locked with confirm, back to IDLE");
        else
            $display("FAIL: Did not return to IDLE");

        repeat(50) @(posedge CLOCK_50);
        $display("--- Simulation complete ---");
        $finish;
    end

    initial begin
        $dumpfile("safe_lock_tb.vcd");
        $dumpvars(0, safe_lock_top_tb);
    end

endmodule