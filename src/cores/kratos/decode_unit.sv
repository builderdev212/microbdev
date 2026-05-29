/*****************************************/
/* decode_unit.sv: Decode unit for RV32I */
/*****************************************/

import riscv_pkg::*;

module decode_unit (
  // Instruction Signals //
  input reg_t instr,

  // Control Signals //
  output ctrl_t ctrl,

  // Writeback Input //
  input logic      wb_wr_en,
  input reg_addr_t wb_wr_addr,
  input reg_t      wb_wr_data
);

  // Instruction Handling //
  instr_t decoded_instr;
  assign decoded_instr.raw = instr;

  // Instruction Parsing //
  reg_t      imm = 0;
  reg_addr_t rs1 = 0;
  reg_addr_t rs2 = 0;
  reg_addr_t rd = 0;
  funct7_t   funct7 = 0;
  funct3_t   funct3 = 0;

  always_comb begin
    imm = 0;
    rs1 = 0;
    rs2 = 0;
    rd = 0;
    funct7 = 0;
    funct3 = 0;

    if (r_type(decoded_instr)) begin
      rs1 = decoded_instr.r.rs1;
      rs2 = decoded_instr.r.rs2;
      rd = decoded_instr.r.rd;
      funct7 = decoded_instr.r.funct7;
      funct3 = decoded_instr.r.funct3;
    end
    else if (i_type(decoded_instr)) begin
      imm = {
        {20{decoded_instr.i.imm_11_0[11]}},
        decoded_instr.i.imm_11_0
      };
      rs1 = decoded_instr.i.rs1;
      rd = decoded_instr.i.rd;
      funct3 = decoded_instr.i.funct3;
    end
    else if (s_type(decoded_instr)) begin
      imm = {
        {20{decoded_instr.s.imm_11_5[6]}},
        decoded_instr.s.imm_11_5,
        decoded_instr.s.imm_4_0
      };
      rs1 = decoded_instr.s.rs1;
      rs2 = decoded_instr.s.rs2;
      funct3 = decoded_instr.s.funct3;
    end
    else if (b_type(decoded_instr)) begin
      imm = {
        {19{decoded_instr.b.imm_12}},
        decoded_instr.b.imm_12,
        decoded_instr.b.imm_11,
        decoded_instr.b.imm_10_5,
        decoded_instr.b.imm_4_1,
        1'b0
      };
      rs1 = decoded_instr.b.rs1;
      rs2 = decoded_instr.b.rs2;
      funct3 = decoded_instr.b.funct3;
    end
    else if (u_type(decoded_instr)) begin
      imm = {
        decoded_instr.u.imm_31_12,
        12'b0
      };
      rd = decoded_instr.u.rd;
    end
    else if (j_type(decoded_instr)) begin
      imm = {
        {12{decoded_instr.j.imm_20}},
        decoded_instr.j.imm_20,
        decoded_instr.j.imm_19_12,
        decoded_instr.j.imm_11,
        decoded_instr.j.imm_10_1,
        1'b0
      };
      rd = decoded_instr.j.rd;
    end
  end

  // Control Signal Generation //
  always_comb begin
    ctrl.rf_wr_en = 0;
    ctrl.mem_rd_en = 0;
    ctrl.mem_wr_en = 0;
    ctrl.redirect_en = 0;
    ctrl.ld_op = LD_NOP;
    ctrl.st_op = ST_NOP;
    ctrl.br_op = BR_NOP;
    ctrl.alu_a_src = 0;
    ctrl.alu_b_src = 0;
    ctrl.alu_op = ALU_NOP;

    if (r_type(decoded_instr)) begin
      ctrl.rf_wr_en = 1;
      ctrl.alu_a_src = 0;
      ctrl.alu_b_src = 0;
      unique case ({funct7, funct3})
        {7'b0000000, 3'b000}:
          ctrl.alu_op = ALU_ADD;
        {7'b0100000, 3'b000}:
          ctrl.alu_op = ALU_SUB;
        {7'b0000000, 3'b001}:
          ctrl.alu_op = ALU_SLL;
        {7'b0000000, 3'b010}:
          ctrl.alu_op = ALU_SLT;
        {7'b0000000, 3'b011}:
          ctrl.alu_op = ALU_SLTU;
        {7'b0000000, 3'b100}:
          ctrl.alu_op = ALU_XOR;
        {7'b0000000, 3'b101}:
          ctrl.alu_op = ALU_SRL;
        {7'b0100000, 3'b101}:
          ctrl.alu_op = ALU_SRA;
        {7'b0000000, 3'b110}:
          ctrl.alu_op = ALU_OR;
        {7'b0000000, 3'b111}:
          ctrl.alu_op = ALU_AND;
        default:
          ctrl.alu_op = ALU_NOP;
      endcase
    end
    else if (i_type(decoded_instr)) begin
      unique case (decoded_instr.i.opcode)
        OPCODE_JALR:
          begin
            ctrl.rf_wr_en = 1;
            ctrl.redirect_en = 1;
            ctrl.alu_a_src = 0;
            ctrl.alu_b_src = 1;0010011
            ctrl.alu_op = ALU_ADD;
          end
        OPCODE_LOAD:
          begin
            ctrl.rf_wr_en = 1;
            ctrl.mem_rd_en = 1;

            unique case (funct3)
              3'b000:
                ctrl.ld_op = LD_BYTE;
              3'b001:
                ctrl.ld_op = LD_HALF;
              3'b010:
                ctrl.ld_op = LD_WORD;
              3'b100:
                ctrl.ld_op = LD_BYTE_U;
              3'b101:
                ctrl.ld_op = LD_HALF_U;
              default:
                ctrl.ld_op = LD_NOP;
            endcase

            ctrl.alu_a_src = 0;
            ctrl.alu_b_src = 1;
            ctrl.alu_op = ALU_ADD;
          end
        OPCODE_MISC_MEM:
          begin
            ctrl.alu_op = ALU_NOP; // COME BACK TO THIS ONCE THE CORE IS WORKING
          end
        OPCODE_OPIMM:
          begin
            ctrl.rf_wr_en = 1;
            ctrl.alu_a_src = 0;
            ctrl.alu_b_src = 1;

            unique case (funct3)
              3'b000:
                ctrl.alu_op = ALU_ADD;
              3'b001:
                ctrl.alu_op = ALU_SLL;
              3'b010:
                ctrl.alu_op = ALU_SLT;
              3'b011:
                ctrl.alu_op = ALU_SLTU;
              3'b100:
                ctrl.alu_op = ALU_XOR;
              3'b101:
                begin
                  if (imm_11_0[10]) ctrl.alu_op = ALU_SRA;
                  else ctrl.alu_op = ALU_SRL;
                end
              3'b110:
                ctrl.alu_op = ALU_OR;
              3'b111:
                ctrl.alu_op = ALU_AND;
            endcase
          end
        OPCODE_SYSTEM:
          begin
            ctrl.alu_op = ALU_NOP; // COME BACK TO THIS ONCE THE CORE IS WORKING
          end
      endcase
    end
    else if (s_type(decoded_instr)) begin
      ctrl.mem_wr_en = 1;

      unique case (funct3)
        3'b000:
          ctrl.st_op = ST_BYTE;
        3'b001:
          ctrl.st_op = ST_HALF;
        3'b010:
          ctrl.st_op = ST_WORD;
        default:
          ctrl.st_op = ST_NOP;
      endcase

      ctrl.alu_a_src = 0;
      ctrl.alu_b_src = 1;
      ctrl.alu_op = ALU_ADD;
    end
    else if (b_type(decoded_instr)) begin
      ctrl.redirect_en = 1;

      unique case (funct3)
        3'b000:
          ctrl.br_op = BR_BEQ;
        3'b001:
          ctrl.br_op = BR_BNE;
        3'b100:
          ctrl.br_op = BR_BLT;
        3'b101:
          ctrl.br_op = BR_BGE;
        3'b110:
          ctrl.br_op = BR_BLTU;
        3'b111:
          ctrl.br_op = BR_BGEU;
        default:
          ctrl.br_op = BR_NOP;
      endcase
    end
    else if (u_type(decoded_instr)) begin
      unique case (decoded_instr.u.opcode)
        OPCODE_AUIPC:
          begin
            ctrl.rf_wr_en = 1;
            ctrl.alu_a_src = 1;
            ctrl.alu_b_src = 1;
            ctrl.alu_op = ALU_ADD;
          end
        OPCODE_LUI:
          begin
            ctrl.rf_wr_en = 1;
          end
      endcase
    end
    else if (j_type(decoded_instr)) begin
      ctrl.rf_wr_en = 1;
      ctrl.redirect_en = 1;
      ctrl.alu_a_src = 1;
      ctrl.alu_b_src = 1;
      ctrl.alu_op = ALU_ADD;
    end
  end

endmodule
