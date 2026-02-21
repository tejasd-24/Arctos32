`timescale 1ns / 1ps

module register_bank_tb;

    logic        clock;
    logic        reset;
    logic        reg_write;
    logic [4:0]  rd_sel;
    logic [4:0]  rs1_sel;
    logic [4:0]  rs2_sel;
    logic [31:0] write_data;
    logic [31:0] rs1_data;   
    logic [31:0] rs2_data;


    register_bank DUT (
        .clock(clock),
        .reset(reset),
        .reg_write(reg_write),
        .rd_sel(rd_sel),
        .rs1_sel(rs1_sel),
        .rs2_sel(rs2_sel),
        .write_data(write_data),
        .rs1_data(rs1_data),
        .rs2_data(rs2_data)
    );


    initial clock = 0;
    always #5 clock = ~clock;


    task write_reg(input [4:0] reg_addr, input [31:0] data);
        @(posedge clock);       
        reg_write  = 1;
        rd_sel     = reg_addr;
        write_data = data;
        @(posedge clock);        
        reg_write  = 0;        
    endtask


    task read_and_check(
        input [4:0]  rs1_addr,
        input [4:0]  rs2_addr,
        input [31:0] expected_rs1,
        input [31:0] expected_rs2
    );
        rs1_sel = rs1_addr;
        rs2_sel = rs2_addr;
        #1; 

        assert (rs1_data === expected_rs1)
            $display("  PASS: R%0d = 0x%08h (expected 0x%08h)", rs1_addr, rs1_data, expected_rs1);
        else
            $error("  FAIL: R%0d = 0x%08h, expected 0x%08h", rs1_addr, rs1_data, expected_rs1);

        assert (rs2_data === expected_rs2)
            $display("  PASS: R%0d = 0x%08h (expected 0x%08h)", rs2_addr, rs2_data, expected_rs2);
        else
            $error("  FAIL: R%0d = 0x%08h, expected 0x%08h", rs2_addr, rs2_data, expected_rs2);
    endtask


    initial begin


        reg_write  = 0;
        rd_sel     = 0;
        rs1_sel    = 0;
        rs2_sel    = 0;
        write_data = 0;

        $display("\n TEST 1: Reset"); 
        reset = 0;      // Active low             
        #20;
        reset = 1;                    
        #10;

    
        read_and_check(5'd0, 5'd1, 32'd0, 32'd0);

        $display("\n TEST 2: Write R1 = 0xDEADBEEF");
        write_reg(5'd1, 32'hDEAD_BEEF);

        read_and_check(5'd1, 5'd0, 32'hDEAD_BEEF, 32'd0);

        $display("\n TEST 3: Write to R0 (should be ignored)");
        write_reg(5'd0, 32'hFFFF_FFFF);  

        read_and_check(5'd0, 5'd1, 32'd0, 32'hDEAD_BEEF);


        $display("\n TEST 4: Write R2=0xAAAA, R3=0xBBBB, R31=0xCCCC");
        write_reg(5'd2,  32'h0000_AAAA);
        write_reg(5'd3,  32'h0000_BBBB);
        write_reg(5'd31, 32'h0000_CCCC);

        read_and_check(5'd2,  5'd3,  32'h0000_AAAA, 32'h0000_BBBB);
        read_and_check(5'd31, 5'd0,  32'h0000_CCCC, 32'd0);

        $display("\n TEST 5: Overwrite R1 ");
        write_reg(5'd1, 32'hCAFE_BABE);

        read_and_check(5'd1, 5'd2, 32'hCAFE_BABE, 32'h0000_AAAA);
        // R1 should be updated, R2 unchanged


        $display("\n TEST 6: No write when reg_write=0 ");
        @(posedge clock);
        reg_write  = 0;               // write disabled
        rd_sel     = 5'd1;
        write_data = 32'h1111_1111;
        @(posedge clock);

        read_and_check(5'd1, 5'd0, 32'hCAFE_BABE, 32'd0);

        $display("\n ALL TESTS COMPLETE \n");

        #20;
        $finish;
    end

endmodule

