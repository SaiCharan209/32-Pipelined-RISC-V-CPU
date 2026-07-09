module forwarding_unit(
    input [4:0]EXMEM_rd,
    input [4:0]MEMWB_rd,
    input [4:0]IDEX_rs1,
    input [4:0]IDEX_rs2,
    input EXMEM_reg_write,
    input MEMWB_reg_write,

    output reg[1:0]forward_A,
    output reg[1:0]forward_B
);


always@(*)
begin
if(EXMEM_reg_write && (EXMEM_rd != 0)&& (EXMEM_rd == IDEX_rs1))
forward_A = 2'b01;
else if(MEMWB_reg_write && (MEMWB_rd != 0) && (MEMWB_rd == IDEX_rs1))
forward_A = 2'b10;
else
forward_A =  2'b00;
if(EXMEM_reg_write && (EXMEM_rd != 0) && (EXMEM_rd == IDEX_rs2))
forward_B = 2'b01;
else if(MEMWB_reg_write && (MEMWB_rd != 0) && (MEMWB_rd == IDEX_rs2))
forward_B = 2'b10;
else
forward_B = 2'b00;
end
endmodule