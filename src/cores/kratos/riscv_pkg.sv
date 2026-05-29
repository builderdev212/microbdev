/***********************************/
/* riscv_pkg.sv: RISC-V constants. */
/***********************************/

package riscv_pkg;

  // General Parameters //
  localparam int DATA_WIDTH = 32;

  typedef logic [DATA_WIDTH-1:0] reg_t;

  // Register File Parameters //
  localparam int REG_FILE_REG_COUNT = 32;
  localparam int REG_FILE_ADDR_WIDTH = 5;

  typedef logic [REG_FILE_ADDR_WIDTH-1:0] reg_addr_t;

  // RV32I Opcodes //
  typedef enum logic [6:0] {
    // R Type //
    OPCODE_OP = 7'b0110011,
    // I Type //
    OPCODE_JALR = 7'b1100111,
    OPCODE_LOAD = 7'b0000011,
    OPCODE_MISC_MEM = 7'b0001111,
    OPCODE_OPIMM = 7'b0010011,
    OPCODE_SYSTEM = 7'b1110011,
    // S Type //
    OPCODE_STORE = 7'b0100011,
    // B Type //
    OPCODE_BRANCH = 7'b1100011,
    // U Type //
    OPCODE_AUIPC = 7'b0010111,
    OPCODE_LUI = 7'b0110111,
    // J Type //
    OPCODE_JAL = 7'b1101111
  } opcode_t;

  // RV32I Field Types //
  typedef logic [6:0] funct7_t;
  typedef logic [2:0] funct3_t;

  // RV32I Instruction Formats //
  typedef struct packed {
    funct7_t   funct7;
    reg_addr_t rs2;
    reg_addr_t rs1;
    funct3_t   funct3;
    reg_addr_t rd;
    opcode_t   opcode;
  } r_type_t;

  typedef struct packed {
    logic      [11:0] imm_11_0;
    reg_addr_t        rs1;
    funct3_t          funct3;
    reg_addr_t        rd;
    opcode_t          opcode;
  } i_type_t;

  typedef struct packed {
    logic      [6:0] imm_11_5;
    reg_addr_t       rs2;
    reg_addr_t       rs1;
    funct3_t         funct3;
    logic      [4:0] imm_4_0;
    opcode_t         opcode;
  } s_type_t;

  typedef struct packed {
    logic            imm_12;
    logic      [5:0] imm_10_5;
    reg_addr_t       rs2;
    reg_addr_t       rs1;
    funct3_t         funct3;
    logic      [3:0] imm_4_1;
    logic            imm_11;
    opcode_t         opcode;
  } b_type_t;

  typedef struct packed {
    logic      [19:0] imm_31_12;
    reg_addr_t        rd;
    opcode_t          opcode;
  } u_type_t;

  typedef struct packed {
    logic            imm_20;
    logic      [9:0] imm_10_1;
    logic            imm_11;
    logic      [7:0] imm_19_12;
    reg_addr_t       rd;
    opcode_t         opcode;
  } j_type_t;

  typedef union packed {
    logic [31:0] raw;

    r_type_t r;
    i_type_t i;
    s_type_t s;
    b_type_t b;
    u_type_t u;
    j_type_t j;
  } instr_t;

  // RV32I Instruction Type Helper Functions //
  function automatic logic r_type(instr_t instr);
    return (instr.r.opcode == OPCODE_OP);
  endfunction

  function automatic logic i_type(instr_t instr);
    return ((instr.i.opcode == OPCODE_JALR)
            || (instr.i.opcode == OPCODE_LOAD)
            || (instr.i.opcode == OPCODE_OPIMM)
            || (instr.i.opcode == OPCODE_MISC_MEM)
            || (instr.i.opcode == OPCODE_SYSTEM));
  endfunction

  function automatic logic s_type(instr_t instr);
    return (instr.s.opcode == OPCODE_STORE);
  endfunction

  function automatic logic b_type(instr_t instr);
    return (instr.b.opcode == OPCODE_BRANCH);
  endfunction

  function automatic logic u_type(instr_t instr);
    return ((instr.u.opcode == OPCODE_AUIPC)
            || (instr.u.opcode == OPCODE_LUI));
  endfunction

  function automatic logic j_type(instr_t instr);
    return (instr.j.opcode == OPCODE_JAL);
  endfunction

  // Control Signals //
  typedef enum logic [3:0] {
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
  } alu_op_t;

  typedef enum logic [2:0] {
    LD_NOP,
    LD_BYTE,
    LD_HALF,
    LD_WORD,
    LD_BYTE_U,
    LD_HALF_U
  } ld_op_t;

  typedef enum logic [1:0] {
    ST_NOP,
    ST_BYTE,
    ST_HALF,
    ST_WORD
  } st_op_t;

  typedef enum logic [2:0] {
    BR_NOP,
    BR_BEQ,
    BR_BNE,
    BR_BLT,
    BR_BGE,
    BR_BLTU,
    BR_BGEU
  } br_op_t;

  typedef struct packed {
    logic    rf_wr_en;
    logic    mem_rd_en;
    logic    mem_wr_en;
    logic    redirect_en;
    ld_op_t  ld_op;
    st_op_t  st_op;
    br_op_t  br_op;
    logic    alu_a_src; // 0 - rs1, 1 - pc
    logic    alu_b_src; // 0 - rs2, 1 - imm
    alu_op_t alu_op;
  } ctrl_t;

endpackage : riscv_pkg
