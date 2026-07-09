module Instruction_mem #(
    parameter MEM_SIZE = 1024 // 1024 Words * 4 Bytes = 4096 Bytes (4KB)
)(
    input  wire [31:0] Input_Address,
    output wire [31:0] Data_out
);
localparam WORDS = MEM_SIZE / 4;
    reg [31:0] imem [0:WORDS-1];

    initial begin
        $readmemh("imem_32.hex", imem); 
    end
    wire [29:0] word_index = Input_Address[31:2];

    assign Data_out = (word_index < WORDS) ? imem[word_index] : 32'h00000013;

endmodule

module Instruction_Fetch#(parameter MEM_SIZE = 2048)(
    input clk,
    input reset,
    input [31:0]PC_Imm,
    input [31:0]rs1_Imm,
    input [1:0]PC_Src,
    output [31:0]Ins,
    output reg[31:0]PC
);
always@(posedge clk or negedge reset)
begin
    if(!reset)
    PC <= 0;
    else
    begin
        case(PC_Src)
        2'b00 : PC <= PC + 4;
        2'b01 : PC <= PC_Imm;
        2'b10 : PC <= rs1_Imm;
        2'b11 : PC <= PC;
        endcase
    end
end
Instruction_mem #(.MEM_SIZE(MEM_SIZE))imem (.Input_Address(PC),.Data_out(Ins));
endmodule