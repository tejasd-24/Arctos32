module instr_decoder(

    input reset,
    input [31:0] instr,

    output [2:0] opcode,
    output reg [31:0] imm_value,

    output reg [4:0] rd_sel,
    output reg [4:0] rs1_sel,
    output reg [4:0] rs2_sel,

    output reg [3:0] alu_func, 
    output reg [31:0] alu_imm,

    output reg mem_rw,
    output reg [22:0] mem_addr,    
    output reg [1:0] branch_type,

    output reg [26:0] inst_addr
);

localparam [2:0] RR = 3'b000;
localparam [2:0] IMM = 3'b001;
localparam [2:0] LOADIMM = 3'b010;
localparam [2:0] MEM = 3'b011;
localparam [2:0] BRANCH = 3'b100;


//Remaining 3 opcodes reserved for future upgrades

assign opcode = instr[31:29];

always@(*)
begin

    if(!reset)
    begin
        alu_func    = 4'd0;
        rd_sel      = 5'd0;
        rs1_sel     = 5'd0;
        rs2_sel     = 5'd0;
        alu_imm     = 32'd0;
        mem_rw      = 1'b0;
        mem_addr    = 23'd0;
        branch_type = 2'd0;
        inst_addr   = 27'd0;
        imm_value   = 32'd0;
    end

    else
    begin

        alu_func    = 4'd0;
        rd_sel      = 5'd0;
        rs1_sel     = 5'd0;
        rs2_sel     = 5'd0;
        alu_imm     = 32'd0;
        mem_rw      = 1'b0;
        mem_addr    = 23'd0;
        branch_type = 2'd0;
        inst_addr   = 27'd0;
        imm_value   = 32'd0;

        case (opcode)

        RR           :       begin
                                alu_func = instr[28:25];
                                rd_sel = instr[24:20];
                                rs1_sel = instr[19:15];
                                rs2_sel = instr[14:10];
                             end

        IMM          :       begin
                                alu_func = instr[28:25];
                                rd_sel = instr[24:20];
                                rs1_sel = instr[19:15];
                                alu_imm[14:0] = instr[14:0];
                                    if(instr[14])
                                        alu_imm[31:15] = 17'b11111111111111111;
                                    else alu_imm[31:15] = 17'd0;

                             end
                             
        LOADIMM      :       begin
                                rd_sel = instr[28:24];                                
                                imm_value[23:0] = instr[23:0]; 

                                if(instr[23])
                                    imm_value[31:24] = 8'b11111111;
                                else imm_value[31:24] = 8'd0;           
                             end 

        MEM          :       begin
                                mem_rw = instr[28];

                                if(instr[28])
                                    rs1_sel = instr[27:23];
                                else rd_sel = instr[27:23];

                                mem_addr = instr[22:0];
                             end

        BRANCH       :       begin
                                branch_type = instr[28:27];
                                inst_addr = instr[26:0];
                             end

        //other opcodes are unused for now                    
         
        endcase
    end
end

endmodule