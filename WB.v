module write_back (
    input         mem_read,  
    input  [31:0] ALU_out,
    input  [31:0] mem_data,
    output reg [31:0] write_data
);
    always @(*) begin
        case (mem_read)
            1'b0: write_data = ALU_out;
            1'b1: write_data = mem_data;
        endcase
    end
endmodule