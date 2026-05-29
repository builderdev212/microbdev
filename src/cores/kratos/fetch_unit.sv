/*****************************************/
/* fetch_unit.sv: Fetch stage of Kratos. */
/*****************************************/

import rsicv_pkg::*;

module fetch_unit #(
  parameter int INSTR_ADDR_WIDTH = 32,
  parameter int PC_INCR = 4,
  parameter int DEFAULT_PC_ADDR = 0
)(
  input logic clk,
  input logic rstn,

  // Instruction Memory Access //
  output logic                        instr_ren,
  output logic [INSTR_ADDR_WIDTH-1:0] instr_raddr,
  input  reg_t                        instr_rdata,

  // Branch Control //
  input  logic                        redirect_en,
  input  logic [INSTR_ADDR_WIDTH-1:0] redirect_addr,

  // Outputs //
  output logic [INSTR_ADDR_WIDTH-1:0] pc,
  output reg_t                        instr
);

  // Program Counter Logic //
  reg [INSTR_ADDR_WIDTH-1:0] pc_reg = DEFAULT_PC_ADDR;
  assign pc = pc_reg;

  always_ff @(posedge clk or negedge rstn) begin
    if (redirect_en) begin
      pc_reg <= redirect_addr;
    end
    else begin
      pc_reg <= pc_reg + PC_INCR;
    end

    if (!rstn) begin
      pc_reg <= DEFAULT_PC_ADDR;
    end
  end

  // Instruction Fetch Logic //
  assign instr_ren = !stall;
  assign instr_raddr = pc_reg;
  assign instr = instr_rdata;

endmodule
