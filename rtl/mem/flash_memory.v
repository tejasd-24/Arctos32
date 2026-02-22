`timescale 1ns / 1ps

module flash_memory #(
    parameter WIDTH = 32,
    parameter DEPTH = 2**27
)(
    input [26:0] pc_addr,
    input read,
    input clock,
    input reset,
  
    output reg [31:0] inst_out

    );
    

reg [WIDTH-1 : 0] inst_buffer [0 : DEPTH-1];

initial
    $readmemh("<Hex-file-location>", inst_buffer);
    
always@(posedge clock or negedge reset)
begin

    if(!reset)
        inst_out <= 32'd0;

    else if(read)
         inst_out <= inst_buffer[pc_addr];
end
      
endmodule

