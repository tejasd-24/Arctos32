`timescale 1ns / 1ps

module control_unit_tb;


logic        reset;
logic [2:0]  opcode;
logic        z_flag;
logic        carry_flag;
logic [1:0]  branch_type;
logic        mem_rw;

// Outputs
logic        pc_load;
logic        pc_inc;
logic        alu_src_sel;
logic        reg_write;
logic        flash_read;
logic        wr_en_A;
logic        wr_en_B;
logic        mem_rw_out;
logic [2:0]  reg_src_sel;


localparam RR       = 3'd0;
localparam IMM      = 3'd1;
localparam LOADIMM  = 3'd2;
localparam MEM      = 3'd3;
localparam BRANCH   = 3'd4;

localparam UNB  = 2'd0;
localparam BIZ  = 2'd1;
localparam BINZ = 2'd2;
localparam BIC  = 2'd3;


control_unit dut (
    .reset       (reset),
    .opcode      (opcode),
    .z_flag      (z_flag),
    .carry_flag  (carry_flag),
    .branch_type (branch_type),
    .mem_rw      (mem_rw),
    .pc_load     (pc_load),
    .pc_inc      (pc_inc),
    .alu_src_sel (alu_src_sel),
    .reg_write   (reg_write),
    .flash_read  (flash_read),
    .wr_en_A     (wr_en_A),
    .wr_en_B     (wr_en_B),
    .mem_rw_out  (mem_rw_out),
    .reg_src_sel (reg_src_sel)
);


task automatic set_opcode(input [2:0] op);
    opcode = op;
    #5; 
endtask


task automatic check_signals(
    input        exp_pc_load,
    input        exp_pc_inc,
    input        exp_alu_src_sel,
    input        exp_reg_write,
    input        exp_flash_read,
    input [2:0]  exp_reg_src_sel,
    input string test_name
);
    assert (pc_load     === exp_pc_load)
        else $error("FAIL [%s] pc_load:     exp=%b got=%b", test_name, exp_pc_load,     pc_load);
    assert (pc_inc      === exp_pc_inc)
        else $error("FAIL [%s] pc_inc:      exp=%b got=%b", test_name, exp_pc_inc,      pc_inc);
    assert (alu_src_sel === exp_alu_src_sel)
        else $error("FAIL [%s] alu_src_sel: exp=%b got=%b", test_name, exp_alu_src_sel, alu_src_sel);
    assert (reg_write   === exp_reg_write)
        else $error("FAIL [%s] reg_write:   exp=%b got=%b", test_name, exp_reg_write,   reg_write);
    assert (flash_read  === exp_flash_read)
        else $error("FAIL [%s] flash_read:  exp=%b got=%b", test_name, exp_flash_read,  flash_read);
    assert (reg_src_sel === exp_reg_src_sel)
        else $error("FAIL [%s] reg_src_sel: exp=%b got=%b", test_name, exp_reg_src_sel, reg_src_sel);

    $display("PASS [%s]", test_name);
endtask

initial begin
    // Default inputs
    reset       = 1'b1;
    opcode      = 3'd0;
    z_flag      = 1'b0;
    carry_flag  = 1'b0;
    branch_type = 2'd0;
    mem_rw      = 1'b0;

    $display("Control Unit Testbench Start");

    //Test 1: Reset
    $display(" Test 1: Reset ");
    reset = 1'b0;  // assert active-low reset
    #5;
    assert (pc_load    === 1'b0) else $error("FAIL reset: pc_load");
    assert (pc_inc     === 1'b0) else $error("FAIL reset: pc_inc");
    assert (reg_write  === 1'b0) else $error("FAIL reset: reg_write");
    assert (flash_read === 1'b0) else $error("FAIL reset: flash_read");
    assert (wr_en_A    === 1'b0) else $error("FAIL reset: wr_en_A");
    assert (mem_rw_out === 1'b0) else $error("FAIL reset: mem_rw_out");
    $display("PASS [reset - all signals zeroed]");

    reset = 1'b1;  // deassert reset
    #5;

    // Test 2: R-type (RR) 
    $display(" Test 2: RR (R-type) ");
    set_opcode(RR);
    //               pc_load pc_inc alu_src reg_w flash reg_src
    check_signals(  0,      1,     0,      1,    1,    3'd0,   "RR opcode");

    // Test 3: I-type (IMM) 
    $display(" Test 3: IMM (I-type) ");
    set_opcode(IMM);
    check_signals(  0,      1,     1,      1,    1,    3'd0,   "IMM opcode");

    // Test 4: Load Immediate 
    $display(" Test 4: LOADIMM ");
    set_opcode(LOADIMM);
    check_signals(  0,      1,     0,      1,    1,    3'd2,   "LOADIMM opcode");

    // Test 5: MEM — LOAD (mem_rw = 0)
    $display(" Test 5: MEM LOAD (mem_rw=0) ");
    mem_rw = 1'b0;
    set_opcode(MEM);
    check_signals(  0,      1,     0,      1,    1,    3'd1,   "MEM LOAD");
    assert (mem_rw_out === 1'b0) else $error("FAIL MEM LOAD: mem_rw_out should be 0");

    // Test 6: MEM — STORE (mem_rw = 1) 
    $display(" Test 6: MEM STORE (mem_rw=1) ");
    mem_rw = 1'b1;
    set_opcode(MEM);
    check_signals(  0,      1,     0,      0,    1,    3'd0,   "MEM STORE");
    assert (mem_rw_out === 1'b1) else $error("FAIL MEM STORE: mem_rw_out should be 1");
    $display("PASS [MEM STORE mem_rw_out]");
    mem_rw = 1'b0;

    // Test 7: BRANCH — Unconditional 
    $display(" Test 7: BRANCH unconditional ");
    branch_type = UNB;
    set_opcode(BRANCH);
    assert (pc_load === 1'b1) else $error("FAIL UNB: pc_load should be 1");
    assert (pc_inc  === 1'b0) else $error("FAIL UNB: pc_inc should be 0 (inverted pc_load)");
    $display("PASS [BRANCH UNB: pc_load=1, pc_inc=0]");

    // Test 8: BRANCH — Branch if Zero, z_flag=1 
    $display(" Test 8: BIZ z_flag=1 (should branch) ");
    branch_type = BIZ;
    z_flag      = 1'b1;
    set_opcode(BRANCH);
    assert (pc_load === 1'b1) else $error("FAIL BIZ (z=1): pc_load should be 1");
    assert (pc_inc  === 1'b0) else $error("FAIL BIZ (z=1): pc_inc should be 0");
    $display("PASS [BIZ z=1: branch taken]");

    // Test 9: BRANCH — Branch if Zero, z_flag=0
    $display(" Test 9: BIZ z_flag=0 (should NOT branch) ");
    z_flag = 1'b0;
    set_opcode(BRANCH);
    assert (pc_load === 1'b0) else $error("FAIL BIZ (z=0): pc_load should be 0");
    assert (pc_inc  === 1'b1) else $error("FAIL BIZ (z=0): pc_inc should be 1");
    $display("PASS [BIZ z=0: branch not taken, PC increments]");

    // Test 10: BRANCH — Branch if Not Zero, z_flag=0
    $display(" Test 10: BINZ z_flag=0 (should branch) ");
    branch_type = BINZ;
    z_flag      = 1'b0;
    set_opcode(BRANCH);
    assert (pc_load === 1'b1) else $error("FAIL BINZ (z=0): pc_load should be 1");
    assert (pc_inc  === 1'b0) else $error("FAIL BINZ (z=0): pc_inc should be 0");
    $display("PASS [BINZ z=0: branch taken]");

    // Test 11: BRANCH — Branch if Not Zero, z_flag=1 
    $display(" Test 11: BINZ z_flag=1 (should NOT branch) ");
    z_flag = 1'b1;
    set_opcode(BRANCH);
    assert (pc_load === 1'b0) else $error("FAIL BINZ (z=1): pc_load should be 0");
    assert (pc_inc  === 1'b1) else $error("FAIL BINZ (z=1): pc_inc should be 1");
    $display("PASS [BINZ z=1: branch not taken]");

    // Test 12: BRANCH — Branch if Carry, carry=1 
    $display(" Test 12: BIC carry=1 (should branch) ");
    branch_type = BIC;
    carry_flag  = 1'b1;
    z_flag      = 1'b0;
    set_opcode(BRANCH);
    assert (pc_load === 1'b1) else $error("FAIL BIC (c=1): pc_load should be 1");
    assert (pc_inc  === 1'b0) else $error("FAIL BIC (c=1): pc_inc should be 0");
    $display("PASS [BIC carry=1: branch taken]");

    // ── Test 13: BRANCH — Branch if Carry, carry=0 ──────
    $display(" Test 13: BIC carry=0 (should NOT branch) ");
    carry_flag = 1'b0;
    set_opcode(BRANCH);
    assert (pc_load === 1'b0) else $error("FAIL BIC (c=0): pc_load should be 0");
    assert (pc_inc  === 1'b1) else $error("FAIL BIC (c=0): pc_inc should be 1");
    $display("PASS [BIC carry=0: branch not taken]");

    // ── Test 14: Unknown opcode — all signals should be default ──
    $display(" Test 14: Unknown opcode (no latch) ");
    set_opcode(3'd7);  // unused opcode
    assert (reg_write  === 1'b0) else $error("FAIL unknown: reg_write should be 0");
    assert (pc_load    === 1'b0) else $error("FAIL unknown: pc_load should be 0");
    assert (wr_en_A    === 1'b0) else $error("FAIL unknown: wr_en_A should be 0");
    $display("PASS [unknown opcode - all safe defaults]");

    $display("Control Unit Testbench Done");
    $finish;
end

endmodule
