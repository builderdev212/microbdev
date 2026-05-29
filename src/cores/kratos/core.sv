/****************************
*                           *
****************************/

module core #(
  parameter int INSTR_ADDR_WIDTH = 32,
  parameter int INSTR_WIDTH = 32,
  parameter int DATA_ADDR_WIDTH = 32,
  parameter int DATA_WIDTH = 32
)(
  input wire clk,
  input wire rst,

  // Instruction Memory Access //
  output wire                        instr_mem_ren,
  output wire [INSTR_ADDR_WIDTH-1:0] instr_mem_raddr,
  input  wire [INSTR_WIDTH-1:0]      instr_mem_rdata,
  input  wire                        instr_mem_rdata_v,

  // Data Memory Access //
  output wire                       data_mem_wen,
  output wire [DATA_ADDR_WIDTH-1:0] data_mem_waddr,
  output wire [DATA_WIDTH-1:0]      data_mem_wdata,
  output wire                       data_mem_wdata_v,
  output wire                       data_mem_ren,
  output wire [DATA_ADDR_WIDTH-1:0] data_mem_raddr,
  input  wire [DATA_WIDTH-1:0]      data_mem_rdata,
  input  wire                       data_mem_rdata_v
);

endmodule
