module tdual_port_ram #(
    parameter DEPTH = 8388608,
    parameter WIDTH = 32
)(
    input clock,
    input reset,

//PORT-A
    input [31:0] data_in_A,
    input [22:0] addr_bus_A,
    input wr_en_A,

    output reg [31:0] data_out_A,

//PORT-B
    input [31:0] data_in_B,
    input [22:0] addr_bus_B,
    input wr_en_B,

    output reg [31:0] data_out_B
  
);


reg [WIDTH-1:0] mem_buffer [0:DEPTH-1];

//PORT-A
always@(posedge clock or negedge reset)
begin
    if(!reset)
    begin
        data_out_A <= 32'd0;
    end

    else if(wr_en_A)
        mem_buffer[addr_bus_A] <= data_in_A;
    else data_out_A <= mem_buffer[addr_bus_A];
end

//PORT-B
always@(posedge clock or negedge reset)
begin
    if(!reset)
    begin
        data_out_B <= 32'd0;
    end

    else if(wr_en_B)
        mem_buffer[addr_bus_B] <= data_in_B;
    else data_out_B <= mem_buffer[addr_bus_B];
end


endmodule