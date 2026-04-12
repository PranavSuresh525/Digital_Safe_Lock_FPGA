# Digital Safe Lock FPGA
Digital Safe Lock System on FPGA
Design and implement a fully synchronous 5-digit programmable digital safe lock system using RTL methodology on the DE2 FPGA Board.
The system must allow a user to enter a 5-digit numeric password using push-button inputs, verify the entered sequence against a stored programmable code, and indicate lock/unlock status through hardware outputs.
The design should:
Operate synchronously using a 50 MHz system clock
Include debounced push-button input conditioning
Implement a custom up/down digit selection mechanism
Store entered digits using a 5-stage shift register
Support programmable password storage
Perform digit-by-digit comparison between entered and stored codes
Use a Moore Finite State Machine (FSM) for control logic
Provide real-time feedback through 7-segment displays
Indicate system state using LED status outputs
The system must be described at the Register Transfer Level (RTL) in Verilog, synthesized, and validated on physical FPGA hardware. Proper separation between datapath and control logic must be maintained to ensure modularity, scalability, and reliable hardware operation.
