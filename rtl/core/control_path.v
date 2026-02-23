module control_path(

    input reset,
    input clock,
    input z_flag,
    input carry_flag,

    output mem_rw,
    output alu_src_sel,
    output reg_write,


    output [31:0] imm_value,
    output [4:0] rd_sel,
    output [4:0] rs1_sel,
    output [4:0] rs2_sel,
    output [3:0] alu_func,
    output [31:0] alu_imm,
    output [22:0] mem_addr,
    output [2:0] reg_src_sel

);

//Internal wires/buses

wire [31:0] inst_fm_id_in, inst_ifid_id;
wire [2:0] opcode_w;
wire [1:0] branch_type_w;
wire mem_rw_w, pc_load_w, pc_inc_w, flash_read_w;
wire [26:0] inst_addr_w, pc_addr_out_w;

flash_memory FM (.clock(clock), .pc_addr(pc_addr_out_w), .read(flash_read_w), .reset(reset), .inst_out(inst_fm_id_in));

if_id_reg IFIDreg (.reset(reset), .inst_in(inst_fm_id_in), .inst_out(inst_ifid_id));

instr_decoder ID (.reset(reset), .instr(inst_ifid_id), .opcode(opcode_w), .mem_rw(mem_rw_w),
                  .branch_type(branch_type_w), .inst_addr(inst_addr_w), .imm_value(imm_value),
                  .rs1_sel(rs1_sel), .rs2_sel(rs2_sel), .rd_sel(rd_sel), .mem_addr(mem_addr),
                  .alu_func(alu_func), .alu_imm(alu_imm));

control_unit CU (.reset(reset), .opcode(opcode_w), .mem_rw(mem_rw_w), .branch_type(branch_type_w), .z_flag(z_flag), .carry_flag(carry_flag),
                 .pc_load(pc_load_w), .pc_inc(pc_inc_w), .alu_src_sel(alu_src_sel), .reg_write(reg_write), .flash_read(flash_read_w), 
                 .mem_rw_out(mem_rw), .reg_src_sel(reg_src_sel));

program_counter PC (.clock(clock), .reset(reset), .pc_addr_in(inst_addr_w), .pc_inc(pc_inc_w), .pc_load(pc_load_w), .pc_addr_out(pc_addr_out_w));

endmodule