module ALU(

    input [3:0] alu_opcode, 
    input [31:0] A_data_in, 
    input [31:0] B_data_in, 
    input alu_src_sel,
    input [31:0] shift_amt,
    
    input [31:0] alu_immediate_in,
    
    output reg z_flag, 
    output reg carry_flag,  
    
    output reg [63:0] data_out 
        
    );
    
parameter ADD  =  4'b0000,
          SUB  =  4'b0001,
          MUL  =  4'b0010,
          AND  =  4'b0011,
          OR   =  4'b0100,
          NOT  =  4'b0101,
          NOR  =  4'b0110,
          NAND =  4'b0111,
          XOR  =  4'b1000,
          XNOR =  4'b1001,
          INC  =  4'b1010,
          DEC  =  4'b1011,
          SHL  =  4'b1100,
          SHR  =  4'b1101;

always@(*)  //ALU logic
begin
    case(alu_opcode)
    
        ADD     :     begin if(alu_src_sel == 1'b0)
                            data_out = A_data_in + B_data_in;
                      else data_out = A_data_in + alu_immediate_in;
                      end
        
        SUB     :     begin if(alu_src_sel == 1'b0)
                            data_out = (A_data_in - B_data_in);
                      else data_out = A_data_in - alu_immediate_in;
                      end
        
        MUL     :     begin if(alu_src_sel == 1'b0)
                            data_out = A_data_in * B_data_in;
                      else data_out = A_data_in * alu_immediate_in;
                      end
        
        AND     :     begin if(alu_src_sel == 1'b0)
                            data_out = A_data_in & B_data_in;
                      else data_out = A_data_in & alu_immediate_in;
                      end
        
        OR      :     begin if(alu_src_sel == 1'b0)
                            data_out = A_data_in | B_data_in;
                      else data_out = A_data_in | alu_immediate_in;
                      end
        
        NOT     :        data_out = {32'd0,~A_data_in};
       
        NOR     :     begin if(alu_src_sel == 1'b0)
                            data_out = {32'd0,~(A_data_in | B_data_in)};
                      else data_out = {32'd0,~(A_data_in | alu_immediate_in)};
                      end
        
        NAND    :     begin if(alu_src_sel == 1'b0)
                            data_out = {32'd0,~(A_data_in & B_data_in)};
                      else data_out = {32'd0,~(A_data_in & alu_immediate_in)};
                      end
        
        XOR     :     begin if(alu_src_sel == 1'b0)
                            data_out = (A_data_in ^ B_data_in);
                      else data_out = (A_data_in ^ alu_immediate_in);
                      end
        
        XNOR    :     begin if(alu_src_sel == 1'b0)
                            data_out = {32'd0,~(A_data_in ^ B_data_in)};
                      else data_out = {32'd0,~(A_data_in ^ alu_immediate_in)};
                      end
        
        SHL     :     data_out = A_data_in << shift_amt;
        
        SHR     :     data_out = A_data_in >> shift_amt;
        
        INC     :     data_out = A_data_in + 1;
        
        DEC     :     data_out = A_data_in - 1;
        
                default : data_out = 64'b0;
    endcase
end            
        
  always@(*) z_flag = (data_out == 64'd0) ? 1'b1 : 1'b0;
  
  always@(*)
  begin
     carry_flag = 1'b0;
     
  if(alu_opcode == ADD)
     carry_flag = (data_out[32] == 1'b1) ? 1'b1 : 1'b0;
  else if(alu_opcode == SUB)
     carry_flag = (A_data_in >= B_data_in) ? 1'b1 : 1'b0;
  end
        
endmodule  //end

