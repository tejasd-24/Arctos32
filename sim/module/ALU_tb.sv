`timescale 1ns / 1ps

module ALU_tb;

logic        enable;
logic [3:0]  alu_opcode;
logic [31:0] A_data_in;
logic [31:0] B_data_in;
logic        alu_src_sel;
logic [31:0] shift_amt;
logic [31:0] alu_immediate_in;

logic        z_flag;
logic        carry_flag;
logic [63:0] data_out;

localparam ADD  = 4'b0000, SUB  = 4'b0001;
localparam MUL  = 4'b0010, AND  = 4'b0011;
localparam OR   = 4'b0100, NOT  = 4'b0101;
localparam NOR  = 4'b0110, NAND = 4'b0111;
localparam XOR  = 4'b1000, XNOR = 4'b1001;
localparam INC  = 4'b1010, DEC  = 4'b1011;
localparam SHL  = 4'b1100, SHR  = 4'b1101;

ALU dut (
    .enable           (enable),
    .alu_opcode       (alu_opcode),
    .A_data_in        (A_data_in),
    .B_data_in        (B_data_in),
    .alu_src_sel      (alu_src_sel),
    .shift_amt        (shift_amt),
    .alu_immediate_in (alu_immediate_in),
    .z_flag           (z_flag),
    .carry_flag       (carry_flag),
    .data_out         (data_out)
);


task apply_rrtype(input [3:0] op, input [31:0] a, input [31:0] b);
    alu_opcode    = op;
    A_data_in     = a;
    B_data_in     = b;
    alu_src_sel   = 1'b0;   
    shift_amt     = 32'd0;
    #10;                    
endtask

task apply_immtype(input [3:0] op, input [31:0] a, input [31:0] imm);
    alu_opcode       = op;
    A_data_in        = a;
    alu_immediate_in = imm;
    alu_src_sel      = 1'b1;  
    shift_amt        = 32'd0;
    #10;
endtask

task apply_shift(input [3:0] op, input [31:0] a, input [31:0] amt);
    alu_opcode  = op;
    A_data_in   = a;
    shift_amt   = amt;
    alu_src_sel = 1'b0;
    #10;
endtask


task check(input [63:0] expected, input string test_name);
    assert (data_out === expected)
    else $error("FAIL [%s]: Expected 0x%016h, Got 0x%016h", test_name, expected, data_out);

    if (data_out === expected)
        $display("PASS [%s]: 0x%016h", test_name, data_out);
endtask

task check_z_flag(input expected_z, input string test_name);
    assert (z_flag === expected_z)
    else $error("FAIL [%s] z_flag: Expected %b, Got %b", test_name, expected_z, z_flag);
endtask

initial begin
    enable        = 1'b1;
    alu_opcode    = 4'd0;
    A_data_in     = 32'd0;
    B_data_in     = 32'd0;
    alu_src_sel   = 1'b0;
    shift_amt     = 32'd0;
    alu_immediate_in = 32'd0;
    #5;

    $display("ALU Testbench Start");

    // RR-type 

    // ADD: 10 + 20 = 30
    apply_rrtype(ADD, 32'd10, 32'd20);
    check(64'd30, "ADD reg");

    // ADD: large values check for correct 64-bit output
    apply_rrtype(ADD, 32'hFFFFFFFF, 32'd1);
    check(64'h100000000, "ADD overflow, carry bit");
    assert(carry_flag === 1'b1)
    else $error("FAIL: carry_flag should be 1 on ADD overflow");

    // SUB: 50 - 30 = 20
    apply_rrtype(SUB, 32'd50, 32'd30);
    check(64'd20, "SUB reg");

    // SUB: borrow (A < B), carry_flag should be 0
    apply_rrtype(SUB, 32'd5, 32'd10);
    assert(carry_flag === 1'b0)
    else $error("FAIL: carry_flag should be 0 when A < B in SUB");

    // MUL: 6 × 7 = 42
    apply_rrtype(MUL, 32'd6, 32'd7);
    check(64'd42, "MUL reg");

    // MUL: large values — result needs full 64 bits
    apply_rrtype(MUL, 32'hFFFF, 32'hFFFF);
    check(64'(32'hFFFF * 32'hFFFF), "MUL large");

    // AND
    apply_rrtype(AND, 32'hF0F0F0F0, 32'h0F0F0F0F);
    check(64'h00000000, "AND reg → 0");

    apply_rrtype(AND, 32'hFFFFFFFF, 32'hABCD1234);
    check(64'hABCD1234, "AND reg passthrough");

    // OR
    apply_rrtype(OR, 32'hF0F0F0F0, 32'h0F0F0F0F);
    check(64'hFFFFFFFF, "OR reg → all 1s");

    // XOR
    apply_rrtype(XOR, 32'hAAAAAAAA, 32'h55555555);
    check(64'hFFFFFFFF, "XOR reg → all 1s");

    apply_rrtype(XOR, 32'hDEADBEEF, 32'hDEADBEEF);
    check(64'h00000000, "XOR with itself → 0");

    // NOT
    apply_rrtype(NOT, 32'h00000000, 32'd0);
    check(64'hFFFFFFFF, "NOT 0 → all 1s");

    apply_rrtype(NOT, 32'hFFFFFFFF, 32'd0);
    check(64'h00000000, "NOT all 1s → 0");

    // NOR
    apply_rrtype(NOR, 32'hF0F0F0F0, 32'h0F0F0F0F);
    check(64'h00000000, "NOR");

    // NAND
    apply_rrtype(NAND, 32'hFFFFFFFF, 32'hFFFFFFFF);
    check(64'h00000000, "NAND all 1s → 0");

    // XNOR
    apply_rrtype(XNOR, 32'hAAAAAAAA, 32'hAAAAAAAA);
    check(64'hFFFFFFFF, "XNOR equal → all 1s");

    // INC: A + 1
    apply_rrtype(INC, 32'd99, 32'd0);
    check(64'd100, "INC");

    // DEC: A - 1
    apply_rrtype(DEC, 32'd100, 32'd0);
    check(64'd99, "DEC");

    // Immediate mode 
    // ADD immediate: 10 + 5 = 15
    apply_immtype(ADD, 32'd10, 32'd5);
    check(64'd15, "ADD imm");

    //ADD immediate: 30 + (-3) = 27
    apply_immtype(ADD, 32'd30, -32'd3);
    check(64'd27, "ADD imm");

    // SUB immediate: 100 - 40 = 60
    apply_immtype(SUB, 32'd100, 32'd40);
    check(64'd60, "SUB imm");

    // MUL immediate: 4 × 8 = 32
    apply_immtype(MUL, 32'd4, 32'd8);
    check(64'd32, "MUL imm");

    // Shift operations

    // SHL: 1 << 4 = 16
    apply_shift(SHL, 32'd1, 32'd4);
    check(64'd16, "SHL by 4");

    // SHL: 0x1 << 31 = 0x80000000
    apply_shift(SHL, 32'd1, 32'd31);
    check(64'h80000000, "SHL by 31");

    // SHR: 0x80000000 >> 4 = 0x08000000
    apply_shift(SHR, 32'h80000000, 32'd4);
    check(64'h08000000, "SHR by 4");

    // Zero flag checks 

    apply_rrtype(XOR, 32'h12345678, 32'h12345678);
    check_z_flag(1'b1, "z_flag should be 1 (result is 0)");

    apply_rrtype(ADD, 32'd1, 32'd1);
    check_z_flag(1'b0, "z_flag should be 0 (result is 2)");

    $display(" ALU Testbench Done ");
    $finish;
end

endmodule
