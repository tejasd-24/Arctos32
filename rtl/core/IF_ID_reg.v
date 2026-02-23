module if_id_reg(
    input reset,
    input [31:0] inst_in,

    output reg [31:0] inst_out
);

always@(*)
begin
    if(!reset)
        inst_out = 32'd0;
    else inst_out = inst_in;
end

endmodule