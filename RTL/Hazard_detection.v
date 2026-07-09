    module hazard_detection_unit (
        input        IDEX_mem_read, 
        input  [4:0] IDEX_rd,     
        input  [4:0] IFID_rs1,         
        input  [4:0] IFID_rs2,        
        input  [1:0] IFID_ALUSrc_B,    
        input  [1:0] IFID_ALUSrc_A,
        input        IFID_mem_write,   
        output reg   stall            
    );
        always @(*) begin

            if (IDEX_mem_read && IDEX_rd != 5'd0 &&
            ((IDEX_rd == IFID_rs1 && (IFID_ALUSrc_A == 2'b00 )) ||
            (IDEX_rd == IFID_rs2 && (IFID_ALUSrc_B == 2'b00 || IFID_mem_write))))
                stall = 1'b1;
            else
                stall = 1'b0;
        end
endmodule