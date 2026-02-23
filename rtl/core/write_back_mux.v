module write_back_mux(

    input [31:0] alu_data_in,
    input [31:0] mem_data_in,
    input [31:0] imm_data_in,
//    input [31:0] acc1_data_in, 
//    input [31:0] acc2_data_in, 
    input [2:0] reg_src_sel,
    
    output reg [31:0] write_data
    
    
    );
    
    always@(*)
    begin
        case(reg_src_sel)
        
            3'b000 :  write_data = alu_data_in;
            3'b001 :  write_data = mem_data_in;
            3'b010 :  write_data = imm_data_in;
            //3'b011 :  write_data = acc1_data_in;
            //3'b100 :  write_data = acc2_data_in;

                default : write_data = 32'd0;    
        endcase

    end
    
endmodule
