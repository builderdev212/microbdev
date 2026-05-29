/*****************************************/
/* regfile.sv: Register file for Kratos. */
/*****************************************/

import riscv_pkg::*;

module regfile #(
  parameter int READ_PORTS = 2
)(
  input logic clk,
  input logic rstn,

  // Write Interface //
  input logic      wr_en,
  input reg_addr_t wr_addr,
  input reg_t      wr_data,

  // Read Interface //
  input  reg_addr_t rd_addr [READ_PORTS],
  output reg_t      rd_data [READ_PORTS]
);

  // Register Handling //
  reg_t regs [REG_FILE_REG_COUNT-1];

  // Read Logic //
  genvar i;
  generate
    for (i = 0; i < READ_PORTS; i++) begin : gen_rd_data
      assign rd_data[i] = (rd_addr[i] == 0) ? 0 : regs[rd_addr[i]-1];
    end
  endgenerate

  // Write Logic //
  integer j;
  always_ff @(posedge clk or negedge rstn) begin
    if (wr_en && (wr_addr != 0)) begin
      regs[wr_addr - 1] <= wr_data;
    end

    if (!rstn) begin
      for (j = 0; j < REG_FILE_REG_COUNT-1; j++) begin
        regs[j] <= 0;
      end
    end
  end

endmodule
