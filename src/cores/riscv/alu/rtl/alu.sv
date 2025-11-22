`timescale 1ns / 1ps
`default_nettype none

typedef enum wire [3:0] {
  ALU_NOP,
  ALU_ADD,
  ALU_SUB,
  ALU_AND,
  ALU_OR,
  ALU_XOR,
  ALU_SLL,
  ALU_SRL,
  ALU_SRA,
  ALU_SLT,
  ALU_SLTU
} alu_cmd_riscv32i;

module alu #(
  parameter XLEN = 32
)(
  input  wire clk,
  input  wire rst_n,

  // Request I/O //
  input  wire                                req_valid,
  output wire                                req_ready,
  input  alu_cmd_riscv32i                    cmd,
  input  wire             [XLEN-1:0]         rs1,
  input  wire             [XLEN-1:0]         rs2,
  input  logic            [$clog2(XLEN)-1:0] shift_amount,

  // Response I/O //
  output wire            resp_valid,
  input  wire            resp_ready,
  output wire [XLEN-1:0] result,
  output wire            illegal
);

  // Combinational ALU Logic //
  reg [XLEN-1:0] comb_result = 0;
  reg            comb_illegal = 0;
  always_comb begin
    comb_illegal = 0;
    case (cmd)
      ALU_NOP:  comb_result = 0;
      ALU_ADD:  comb_result = rs1 + rs2;
      ALU_SUB:  comb_result = rs1 - rs2;
      ALU_AND:  comb_result = rs1 & rs2;
      ALU_OR:   comb_result = rs1 | rs2;
      ALU_XOR:  comb_result = rs1 ^ rs2;
      ALU_SLL:  comb_result = rs1 << shift_amount;
      ALU_SRL:  comb_result = rs1 >> shift_amount;
      ALU_SRA:  comb_result = $signed(rs1) >>> shift_amount;
      ALU_SLT:  comb_result = ($signed(rs1) < $signed(rs2)) ? 1 : 0;
      ALU_SLTU: comb_result = (rs1 < rs2) ? 1 : 0;
      default:
        begin
          comb_result = 0;
          comb_illegal = 1;
        end
    endcase
  end

  // Pipeline ALU Response //
  reg [XLEN-1:0] result_reg = 0;
  reg            valid_reg = 0;
  reg            illegal_reg = 0;
  reg            busy_reg = 0;

  assign req_ready = !busy_reg;
  assign result = result_reg;
  assign resp_valid = valid_reg;
  assign illegal = illegal_reg;

  always_ff @(posedge clk or negedge rst_n) begin
    if (req_valid && req_ready) begin
      busy_reg <= 1;
      result_reg <= comb_result;
      illegal_reg <= comb_illegal;
      valid_reg <= 0;
    end

    if (resp_valid && resp_ready) begin
      busy_reg <= 0;
      valid_reg  <= 0;
    end

    if (!rst_n) begin
      result_reg = 0;
      ready_reg = 0;
      illegal_reg = 0;
    end
  end

endmodule
