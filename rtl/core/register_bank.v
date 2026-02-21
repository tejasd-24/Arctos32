module register_bank(

    input clock, 
    input reset, 
    
    input reg_write, 
    input [4:0] rd_sel,
    input [4:0] rs1_sel, 
    input [4:0] rs2_sel, 
    input [31:0] write_data, 
     
    output [31:0] rs1_data,
    output [31:0] rs2_data  

    );
    
    reg [31:0] buffer [0:31];
    integer i;
    
    always@(posedge clock or negedge reset)
    begin
    
        if(!reset)
        begin
            for (i = 0; i < 32; i = i + 1) begin
                buffer[i] <= 32'd0;
            end
        end
    
   else if(reg_write)
        begin
            if(rd_sel)
                buffer[rd_sel] <= write_data;         
        end
    end

    assign rs1_data = buffer[rs1_sel];
    assign rs2_data = buffer[rs2_sel];  
    
endmodule

