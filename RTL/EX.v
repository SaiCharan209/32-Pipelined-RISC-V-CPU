module ALU(
input [31:0] A,
input [31:0] B,
input [3:0] ALUop,
output reg Cond,
output reg [31:0]ALU_out
);


always@(*)
begin
    ALU_out = 0;
    Cond = 0;
case(ALUop)
4'd0: ALU_out = A + B;
4'd1: ALU_out = A - B;
4'd2: ALU_out = A ^ B;
4'd3: ALU_out = A | B;
4'd4: ALU_out = A & B;
4'd5: ALU_out = A << (B[4:0]);
4'd6: ALU_out = A >> B[4:0];
4'd7: ALU_out = $signed(A) >>> B[4:0];
4'd8:begin  ALU_out = ($signed(A) < $signed(B)) ? 32'd1 : 32'd0;   Cond    = ALU_out[0];    end
4'd9:begin  ALU_out = (A < B)?32'd1:32'd0;   Cond    = ALU_out[0]; end
4'd10: Cond = (A == B);
4'd11: Cond = (A != B);
4'd12:  Cond = ($signed(A) >= $signed(B));
4'd13: Cond = A>=B;
endcase
end
endmodule



module EX (
    input  [31:0] PC,
    input  [31:0] A,
    input  [31:0] B,
    input  [31:0] Imm,
    input  [1:0]  ALUSrc_A,
    input  [1:0]  ALUSrc_B,
    input  [3:0]  ALUop,
    input  [1:0] forward_A,
    input  [1:0] forward_B,
    input  [31:0] EXMEM_ALU_out,
    input  [31:0] WB_write_data,
 
    output        Cond,
    output [31:0] ALU_out,
    output [31:0] PC_Imm,    
    output [31:0] rs1_Imm,   
    output reg [31:0] op_2_fwd
);
    reg [31:0] op_1,op_1_fwd,op_2;
   always @(*) begin
    // Stage 1 — forwarding mux
    case (forward_A)
        2'b01:   op_1_fwd = EXMEM_ALU_out;
        2'b10:   op_1_fwd = WB_write_data;
        default: op_1_fwd = A;  
    endcase

    case (forward_B)
        2'b01:   op_2_fwd = EXMEM_ALU_out;
        2'b10:   op_2_fwd = WB_write_data;
        default: op_2_fwd = B;            
    endcase

    case (ALUSrc_A)
        2'b00:   op_1 = op_1_fwd;   
        2'b01:   op_1 = PC;          
        2'b10:   op_1 = 32'd0;       
        default: op_1 = op_1_fwd;
    endcase

    case (ALUSrc_B)
        2'b00:   op_2 = op_2_fwd;   
        2'b01:   op_2 = Imm;        
        2'b10:   op_2 = 32'd4;       
        default: op_2 = op_2_fwd;
    endcase
end 
 
 
    ALU alu1 (
        .A       (op_1),
        .B       (op_2),
        .ALUop   (ALUop),
        .Cond    (Cond),
        .ALU_out (ALU_out)
    );
 
    assign rs1_Imm = op_1_fwd   + Imm;   // JALR jump target
    assign PC_Imm  = PC  + Imm;   // JAL / branch target
endmodule