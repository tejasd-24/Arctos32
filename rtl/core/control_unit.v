module control_unit(

    //reset
    input reset,

    //opcode
    input [2:0] opcode,

    //Flags from ALU
    input z_flag,
    input carry_flag,
    
    //Branch type input from ID
    input [1:0] branch_type,

    //Input from mem
    input mem_rw,

    //PC logic
    output reg pc_load,
    output reg pc_inc,

    //ALU Signals
    output reg alu_src_sel,

    //Register bank write
    output reg reg_write,

    //Flash memory
    output reg flash_read,

    //Dual port RAM
    output reg wr_en_A,
    output reg wr_en_B,
    output reg mem_rw_out,

    //Write back mux
    output reg [2:0] reg_src_sel

);

    localparam RR       = 3'd0;
    localparam IMM      = 3'd1;
    localparam LOADIMM  = 3'd2;
    localparam MEM      = 3'd3;
    localparam BRANCH   = 3'd4;

    localparam UNB      = 2'd0;
    localparam BIZ      = 2'd1;
    localparam BINZ     = 2'd2;
    localparam BIC      = 2'd3;
    

always@(*)
begin
    if(!reset)
    begin
            pc_load     = 1'b0;
            pc_inc      = 1'b0;
            alu_src_sel = 1'b0;
            reg_src_sel = 3'd0;
            reg_write   = 1'b0;
            flash_read  = 1'b0;
            wr_en_A     = 1'b0;
            wr_en_B     = 1'b0;
            mem_rw_out  = 1'b0;
    end

    else begin

            pc_load     = 1'b0;
            pc_inc      = 1'b0;
            alu_src_sel = 1'b0;
            reg_src_sel = 3'd0;
            reg_write   = 1'b0;
            flash_read  = 1'b0;
            wr_en_A     = 1'b0;
            wr_en_B     = 1'b0;
            mem_rw_out  = 1'b0;
            
        case(opcode)
                RR          :       begin
                                        alu_src_sel = 1'b0;
                                        reg_src_sel = 3'd0;
                                        flash_read  = 1'b1;
                                        pc_inc      = 1'b1;
                                        reg_write   = 1'b1;                                        
                                    end

                IMM         :       begin
                                        alu_src_sel = 1'b1;
                                        reg_src_sel = 3'b0;
                                        flash_read  = 1'b1;
                                        pc_inc      = 1'b1;
                                        reg_write   = 1'b1;                    
                                    end 

                LOADIMM     :       begin
                                        reg_write   = 1'b1;
                                        reg_src_sel = 3'd2;
                                        pc_inc      = 1'b1;
                                        flash_read  = 1'b1;                    
                                    end

                MEM         :       begin
                                        mem_rw_out = mem_rw;
                                        
                                        if(mem_rw)                                       
                                            reg_write = 1'b0;
                                        else 
                                        begin
                                            reg_src_sel = 3'd1;                                       
                                            reg_write = 1'b1;
                                        end

                                        flash_read  = 1'b1;
                                        pc_inc      = 1'b1;

                                    end

                BRANCH      :       begin
                                        case(branch_type)

                                            UNB     :   pc_load = 1'b1;

                                            BIZ     :   pc_load = z_flag;

                                            BINZ    :   pc_load = ~z_flag;

                                            BIC     :   pc_load = carry_flag;

                                                default : pc_load = 1'b0;

                                        endcase

                                        pc_inc = ~pc_load;
                                        flash_read = 1'b1;
                                    end
        endcase
    end
end

endmodule