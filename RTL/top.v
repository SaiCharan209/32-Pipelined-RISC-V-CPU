    module rv32i_top #(parameter I_MEM_SIZE = 4096,parameter D_MEM_SIZE = 8192)
    (
        input clk,
        input reset
    );

        localparam NOP = 32'h00000013;


        wire        IF_ID_NOP;
        wire        ID_EX_NOP;
        wire [1:0]  PC_Src;


        wire        stall;
        wire [1:0]  final_PC_Src;


        wire [1:0]  forward_A;
        wire [1:0]  forward_B;

    
        wire [31:0] IF_Ins;
        wire [31:0] IF_PC;


        reg [31:0]  IFID_Ins;
        reg [31:0]  IFID_PC;


        wire [31:0] ID_read_data_1;
        wire [31:0] ID_read_data_2;
        wire [31:0] ID_Imm;
        wire        ID_mem_write;
        wire        ID_mem_read;
        wire        ID_reg_write;
        wire [3:0]  ID_ALUop;
        wire [1:0]  ID_ALUSrc_A;
        wire [1:0]  ID_ALUSrc_B;
        wire        ID_Branch;
        wire [1:0]  ID_Jump;
        wire [2:0]  ID_funct3;


        reg [31:0]  IDEX_PC;
        reg [31:0]  IDEX_read_data_1;
        reg [31:0]  IDEX_read_data_2;
        reg [31:0]  IDEX_Imm;
        reg         IDEX_mem_write;
        reg         IDEX_mem_read;
        reg         IDEX_reg_write;
        reg [3:0]   IDEX_ALUop;
        reg [1:0]   IDEX_ALUSrc_A;
        reg [1:0]   IDEX_ALUSrc_B;
        reg [2:0]   IDEX_funct3;
        reg [1:0]   IDEX_Jump;
        reg [4:0]   IDEX_rd;
        reg [4:0]   IDEX_rs1;      
        reg [4:0]   IDEX_rs2;      


        wire        EX_Cond;
        wire [31:0] EX_ALU_out;
        wire [31:0] EX_PC_Imm;
        wire [31:0] EX_rs1_Imm;
        wire [31:0] op_2;


        reg [31:0]  EXMEM_ALU_out;
        reg [31:0]  EXMEM_op_2;
        reg [2:0]   EXMEM_funct3;
        reg [4:0]   EXMEM_rd;
        reg         EXMEM_mem_write;
        reg         EXMEM_mem_read;
        reg         EXMEM_reg_write;


        wire [31:0] MEM_read_data;


        reg [31:0]  MEMWB_ALU_out;
        reg [31:0]  MEMWB_read_data;
        reg [4:0]   MEMWB_rd;
        reg         MEMWB_mem_read;
        reg         MEMWB_reg_write;


        wire [31:0] WB_write_data;


        assign final_PC_Src = (stall && PC_Src == 2'b00) ? 2'b11 : PC_Src;


        Instruction_Fetch#(.MEM_SIZE(I_MEM_SIZE)) IF_stage (
            .clk     (clk),
            .reset   (reset),
            .PC_Imm  (EX_PC_Imm),
            .rs1_Imm (EX_rs1_Imm),
            .PC_Src  (final_PC_Src),
            .Ins     (IF_Ins),
            .PC      (IF_PC)
        );


        always @(posedge clk or negedge reset) begin
            if (!reset) begin
                IFID_Ins <= NOP;
                IFID_PC  <= 32'd0;
            end
            else if (IF_ID_NOP) begin      
                IFID_Ins <= NOP;
                IFID_PC  <= IFID_PC;
            end
            else if (stall) begin          
                IFID_Ins <= IFID_Ins;
                IFID_PC  <= IFID_PC;
            end
            else begin
                IFID_Ins <= IF_Ins;
                IFID_PC  <= IF_PC;
            end
        end


        Instruction_Decode ID_stage (
            .clk          (clk),
            .reset        (reset),
            .Ins          (IFID_Ins),
            .write_data   (WB_write_data),
            .reg_write_en (MEMWB_reg_write),
            .rd           (MEMWB_rd),

            .read_data_1  (ID_read_data_1),
            .read_data_2  (ID_read_data_2),
            .Imm          (ID_Imm),
            .mem_write    (ID_mem_write),
            .mem_read     (ID_mem_read),
            .reg_write    (ID_reg_write),
            .ALUop        (ID_ALUop),
            .ALUSrc_A     (ID_ALUSrc_A),
            .ALUSrc_B     (ID_ALUSrc_B),
            .Branch       (ID_Branch),
            .Jump         (ID_Jump),
            .funct_3      (ID_funct3)
        );


        always @(posedge clk or negedge reset) begin
            if (!reset) begin
                IDEX_PC          <= 32'd0;
                IDEX_read_data_1 <= 32'd0;
                IDEX_read_data_2 <= 32'd0;
                IDEX_Imm         <= 32'd0;
                IDEX_mem_write   <= 1'b0;
                IDEX_mem_read    <= 1'b0;
                IDEX_reg_write   <= 1'b0;
                IDEX_ALUop       <= 4'd0;
                IDEX_ALUSrc_A    <= 2'b00;
                IDEX_ALUSrc_B    <= 2'b00;
                IDEX_funct3      <= 3'd0;
                IDEX_Jump        <= 2'b00;
                IDEX_rd          <= 5'd0;
                IDEX_rs1         <= 5'd0;
                IDEX_rs2         <= 5'd0;
            end
            else if (ID_EX_NOP || stall) begin  
                IDEX_PC          <= IDEX_PC;
                IDEX_read_data_1 <= 32'd0;
                IDEX_read_data_2 <= 32'd0;
                IDEX_Imm         <= 32'd0;
                IDEX_mem_write   <= 1'b0;
                IDEX_mem_read    <= 1'b0;
                IDEX_reg_write   <= 1'b0;
                IDEX_ALUop       <= 4'd0;
                IDEX_ALUSrc_A    <= 2'b00;
                IDEX_ALUSrc_B    <= 2'b00;
                IDEX_funct3      <= 3'd0;
                IDEX_Jump        <= 2'b00;
                IDEX_rd          <= 5'd0;
                IDEX_rs1         <= 5'd0;   
                IDEX_rs2         <= 5'd0;
            end
            else begin
                IDEX_PC          <= IFID_PC;
                IDEX_read_data_1 <= ID_read_data_1;
                IDEX_read_data_2 <= ID_read_data_2;
                IDEX_Imm         <= ID_Imm;
                IDEX_mem_write   <= ID_mem_write;
                IDEX_mem_read    <= ID_mem_read;
                IDEX_reg_write   <= ID_reg_write;
                IDEX_ALUop       <= ID_ALUop;
                IDEX_ALUSrc_A    <= ID_ALUSrc_A;
                IDEX_ALUSrc_B    <= ID_ALUSrc_B;
                IDEX_funct3      <= ID_funct3;
                IDEX_Jump        <= ID_Jump;
                IDEX_rd          <= IFID_Ins[11:7];
                IDEX_rs2         <= IFID_Ins[24:20];  // rs2 address
                IDEX_rs1         <= IFID_Ins[19:15];  // rs1 address
            end
        end

        EX EX_stage (
            .PC            (IDEX_PC),
            .A             (IDEX_read_data_1),
            .B             (IDEX_read_data_2),
            .Imm           (IDEX_Imm),
            .ALUSrc_A      (IDEX_ALUSrc_A),
            .ALUSrc_B      (IDEX_ALUSrc_B),
            .ALUop         (IDEX_ALUop),
            .forward_A     (forward_A),
            .forward_B     (forward_B),
            .EXMEM_ALU_out (EXMEM_ALU_out),
            .WB_write_data (WB_write_data),
            .Cond          (EX_Cond),
            .ALU_out       (EX_ALU_out),
            .PC_Imm        (EX_PC_Imm),
            .rs1_Imm       (EX_rs1_Imm),
            .op_2_fwd          (op_2)
        );


        always @(posedge clk or negedge reset) begin
            if (!reset) begin
                EXMEM_ALU_out   <= 32'd0;
                EXMEM_op_2      <= 32'd0;
                EXMEM_funct3    <= 3'd0;
                EXMEM_rd        <= 5'd0;
                EXMEM_mem_write <= 1'b0;
                EXMEM_mem_read  <= 1'b0;
                EXMEM_reg_write <= 1'b0;
            end
            else begin
                EXMEM_ALU_out   <= EX_ALU_out;
                EXMEM_op_2      <= op_2;
                EXMEM_funct3    <= IDEX_funct3;
                EXMEM_rd        <= IDEX_rd;
                EXMEM_mem_write <= IDEX_mem_write;
                EXMEM_mem_read  <= IDEX_mem_read;
                EXMEM_reg_write <= IDEX_reg_write;
            end
        end


        data_mem #(.MEM_SIZE(D_MEM_SIZE)) MEM_stage (
            .clk        (clk),
            .mem_write  (EXMEM_mem_write),
            .mem_read   (EXMEM_mem_read),
            .address    (EXMEM_ALU_out),
            .write_data (EXMEM_op_2),
            .funct3     (EXMEM_funct3),
            .read_data  (MEM_read_data)
        );


        always @(posedge clk or negedge reset) begin
            if (!reset) begin
                MEMWB_ALU_out   <= 32'd0;
                MEMWB_read_data <= 32'd0;
                MEMWB_rd        <= 5'd0;
                MEMWB_mem_read  <= 1'b0;
                MEMWB_reg_write <= 1'b0;
            end
            else begin
                MEMWB_ALU_out   <= EXMEM_ALU_out;
                MEMWB_read_data <= MEM_read_data;
                MEMWB_rd        <= EXMEM_rd;
                MEMWB_mem_read  <= EXMEM_mem_read;
                MEMWB_reg_write <= EXMEM_reg_write;
            end
        end


        write_back WB_stage (
            .mem_read   (MEMWB_mem_read),
            .ALU_out    (MEMWB_ALU_out),
            .mem_data   (MEMWB_read_data),
            .write_data (WB_write_data)
        );


        branch_controller BC (
            .clk             (clk),
            .reset           (reset),
            .stall           (stall),
            .ID_Branch       (ID_Branch),
            .ID_Jump         (ID_Jump),
            .EX_Branch_taken (EX_Cond),
            .EX_Jump         (IDEX_Jump),
            .IF_ID_NOP       (IF_ID_NOP),
            .ID_EX_NOP       (ID_EX_NOP),
            .PC_Src          (PC_Src)
        );


    hazard_detection_unit HDU (
            .IDEX_mem_read  (IDEX_mem_read),
            .IDEX_rd        (IDEX_rd),
            .IFID_rs1       (IFID_Ins[19:15]),
            .IFID_rs2       (IFID_Ins[24:20]),
            .IFID_ALUSrc_B  (ID_ALUSrc_B),
            .IFID_ALUSrc_A  (ID_ALUSrc_A),
            .IFID_mem_write (ID_mem_write),
            .stall          (stall)
        );


        forwarding_unit FWD (
            .EXMEM_rd        (EXMEM_rd),
            .MEMWB_rd        (MEMWB_rd),
            .IDEX_rs1        (IDEX_rs1),
            .IDEX_rs2        (IDEX_rs2),
            .EXMEM_reg_write (EXMEM_reg_write),
            .MEMWB_reg_write (MEMWB_reg_write),
            .forward_A       (forward_A),
            .forward_B       (forward_B)
        );

    endmodule
