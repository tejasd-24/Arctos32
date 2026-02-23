module program_counter(
    input clock,
    input reset,
    input pc_load,
    input [26:0] pc_addr_in,
    input pc_inc,
    
    output reg [26:0] pc_addr_out
    
    );
    
always@(posedge clock or negedge reset)
begin

    if(!reset)
        pc_addr_out <= 27'd0;
        
    else if(pc_load)
        pc_addr_out <= pc_addr_in;
    
    else if(pc_inc)
        pc_addr_out <= pc_addr_out + 1'b1;
        
end
    
endmodule

