/** @module : fetch_receive
 *  @author : Adaptive & Secure Computing Systems (ASCS) Laboratory

 *  Copyright (c) 2021 STAM Center (ASCS Lab/CAES Lab/STAM Center/ASU)
 *  Permission is hereby granted, free of charge, to any person obtaining a copy
 *  of this software and associated documentation files (the "Software"), to deal
 *  in the Software without restriction, including without limitation the rights
 *  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 *  copies of the Software, and to permit persons to whom the Software is
 *  furnished to do so, subject to the following conditions:
 *  The above copyright notice and this permission notice shall be included in
 *  all copies or substantial portions of the Software.

 *  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 *  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 *  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 *  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 *  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 *  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 *  THE SOFTWARE.
 */

module fetch_receive #(
  parameter DATA_WIDTH      =   32,
  parameter SCAN_CYCLES_MIN =    0,
  parameter SCAN_CYCLES_MAX = 1000
)(
  // Control signals
  input  flush,

  // Instruction memory interface
  input  [DATA_WIDTH-1  :0] i_mem_data,

  // Outputs to with decode
  output reg [DATA_WIDTH-1  :0] instruction,

  //scan signal
  input scan
);

reg trigger;
wire [6:0] opcode;
wire is_read;
wire is_write;

reg [DATA_WIDTH-1  :0] lastInstruction;
assign opcode = i_mem_data[6:0];

assign is_read = (opcode == 7'b0000011); // Load instructions (e.g., LB, LH, LW)
assign is_write = (opcode == 7'b0100011); // Store instructions (e.g., SB, SH, SW)

localparam NOP = 32'h00000013;

always @(i_mem_data) begin
  if (trigger)begin
    if(lastInstruction != i_mem_data)begin
      instruction = 32'b10011; // addi x0, x0, 0
    end else begin
      trigger = 1'b0;
      instruction = flush ? NOP : i_mem_data;
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
 if (!trigger)begin
  instruction = flush ? NOP : i_mem_data;
 end
end

endmodule
