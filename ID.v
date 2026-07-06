module reg_bank (
    input         clk,
    input         reset,
    
    input  [4:0]  rs1,
    input  [4:0]  rs2,
    input  [4:0]  rd,
    input  [31:0] write_data,
    input         reg_write_en,

    output [31:0] read_data_1,
    output [31:0] read_data_2
);


    reg [31:0] registers [31:0];
integer i;
    always @(negedge clk or negedge reset) begin
        if (!reset) begin // Assuming active-low reset, adjust if active-high
        for (i = 0; i < 32; i = i + 1) begin
            registers[i] <= 32'd0;
        end 
        end
        else if(reg_write_en && rd != 5'b00000) begin
            registers[rd] <= write_data;
        end
    end

    assign read_data_1 = (rs1 == 5'b00000) ? 32'h0 : registers[rs1];
    assign read_data_2 = (rs2 == 5'b00000) ? 32'h0 : registers[rs2];

endmodule

module Imm_calc (
    input      [31:0] Ins,
    output reg [31:0] Imm 
);
    always @(*) begin
        case (Ins[6:0])
            // I-Type: ALU immediates
            7'b0010011: Imm = {{20{Ins[31]}}, Ins[31:20]};

            // I-Type: Loads (lb, lh, lw, lbu, lhu)
            7'b0000011: Imm = {{20{Ins[31]}}, Ins[31:20]};

            // I-Type: JALR
            7'b1100111: Imm = {{20{Ins[31]}}, Ins[31:20]};

            // S-Type: Stores
            7'b0100011: Imm = {{20{Ins[31]}}, Ins[31:25], Ins[11:7]};

            // B-Type: Branches
            7'b1100011: Imm = {{19{Ins[31]}}, Ins[31], Ins[7],
                                Ins[30:25], Ins[11:8], 1'b0};

            // U-Type: LUI
            7'b0110111: Imm = {Ins[31:12], 12'b0};

            // U-Type: AUIPC
            7'b0010111: Imm = {Ins[31:12], 12'b0};

            // J-Type: JAL
            7'b1101111: Imm = {{11{Ins[31]}}, Ins[31], Ins[19:12],
                                Ins[20], Ins[30:21], 1'b0};

            default:    Imm = 32'h0;
        endcase
    end
endmodule

module control (
    input  [31:0] Ins,
 
    output reg        mem_write,
    output reg        mem_read,
    output reg        reg_write,
    output reg [3:0]  ALUop,
    output reg [1:0]  ALUSrc_A,   // 00=rs1  01=PC   10=zero
    output reg [1:0]  ALUSrc_B,   // 00=rs2  01=imm  10=4
    output reg        Branch,
    output reg [1:0]  Jump,
    output     [2:0]  funct_3
);
    assign funct_3 = Ins[14:12];
 
    always @(*) begin
        // Safe defaults
        ALUSrc_A  = 2'b00;
        ALUSrc_B  = 2'b00;
        reg_write = 1'b0;
        mem_write = 1'b0;
        mem_read  = 1'b0;
        Branch    = 1'b0;
        Jump      = 2'b00;
        ALUop     = 4'd0;
 
        case (Ins[6:0])
 
            // R-type
            7'b0110011: begin
                ALUSrc_A  = 2'b00;
                ALUSrc_B  = 2'b00;
                reg_write = 1'b1;
                case (Ins[14:12])
                    3'd0: ALUop = (Ins[31:25] == 7'h20) ? 4'd1 : 4'd0; // SUB / ADD
                    3'd1: ALUop = 4'd5;   // SLL
                    3'd2: ALUop = 4'd8;   // SLT
                    3'd3: ALUop = 4'd9;   // SLTU
                    3'd4: ALUop = 4'd2;   // XOR
                    3'd5: ALUop = (Ins[31:25] == 7'h20) ? 4'd7 : 4'd6; // SRA / SRL
                    3'd6: ALUop = 4'd3;   // OR
                    3'd7: ALUop = 4'd4;   // AND
                endcase
            end
 
            // I-type ALU
            7'b0010011: begin
                ALUSrc_A  = 2'b00;
                ALUSrc_B  = 2'b01;
                reg_write = 1'b1;
                case (Ins[14:12])
                    3'h0: ALUop = 4'd0;   // ADDI
                    3'h1: ALUop = 4'd5;   // SLLI
                    3'h2: ALUop = 4'd8;   // SLTI
                    3'h3: ALUop = 4'd9;   // SLTIU
                    3'h4: ALUop = 4'd2;   // XORI
                    3'h5: ALUop = (Ins[31:25] == 7'h20) ? 4'd7 : 4'd6; // SRAI / SRLI
                    3'h6: ALUop = 4'd3;   // ORI
                    3'h7: ALUop = 4'd4;   // ANDI
                endcase
            end
 
            // Load — mem_read=1 signals write-back mux to select mem_data
            7'b0000011: begin
                ALUSrc_A  = 2'b00;
                ALUSrc_B  = 2'b01;
                reg_write = 1'b1;
                mem_read  = 1'b1;
                ALUop     = 4'd0;   // ADD: address = rs1 + imm
            end
 
            // Store
            7'b0100011: begin
                ALUSrc_A  = 2'b00;
                ALUSrc_B  = 2'b01;
                mem_write = 1'b1;
                ALUop     = 4'd0;   // ADD: address = rs1 + imm
            end
 
            // Branch
            7'b1100011: begin
                ALUSrc_A  = 2'b00;
                ALUSrc_B  = 2'b00;
                Branch    = 1'b1;
                case (Ins[14:12])
                    3'h0: ALUop = 4'd10;  // BEQ
                    3'h1: ALUop = 4'd11;  // BNE
                    3'h4: ALUop = 4'd8;   // BLT  (signed via SLT path)
                    3'h5: ALUop = 4'd12;  // BGE  (signed)
                    3'h6: ALUop = 4'd9;   // BLTU (unsigned via SLTU path)
                    3'h7: ALUop = 4'd13;  // BGEU (unsigned)
                endcase
            end
 
            // JAL — rd = PC+4, jump to PC+imm
            7'b1101111: begin
                ALUSrc_A  = 2'b01;   // PC
                ALUSrc_B  = 2'b10;   // 4
                reg_write = 1'b1;
                Jump      = 2'b01;
                ALUop     = 4'd0;    // ADD: PC+4
            end
 
            // JALR — rd = PC+4, jump to rs1+imm
            7'b1100111: begin
                ALUSrc_A  = 2'b01;   // PC
                ALUSrc_B  = 2'b10;   // 4
                reg_write = 1'b1;
                Jump      = 2'b10;
                ALUop     = 4'd0;    // ADD: PC+4
            end
 
            // LUI — rd = upper_imm  (0 + imm)
            7'b0110111: begin
                ALUSrc_A  = 2'b10;   // zero
                ALUSrc_B  = 2'b01;   // upper_imm
                reg_write = 1'b1;
                ALUop     = 4'd0;
            end
 
            // AUIPC — rd = PC + upper_imm
            7'b0010111: begin
                ALUSrc_A  = 2'b01;   // PC
                ALUSrc_B  = 2'b01;   // upper_imm
                reg_write = 1'b1;
                ALUop     = 4'd0;
            end
 
        endcase
    end
endmodule



module Instruction_Decode (
    input         clk,
    input         reset,
    input  [31:0] Ins,
    input  [31:0] write_data,
    input         reg_write_en,
    input [4:0]   rd,

    output [31:0] read_data_1,
    output [31:0] read_data_2,
    output [31:0] Imm,
    output        mem_write,
    output        mem_read,
    output        reg_write,
    output [3:0]  ALUop,
    output [1:0] ALUSrc_A,
    output [1:0] ALUSrc_B,
    output        Branch,
    output [1:0]  Jump,
    output [2:0]  funct_3
);

    reg_bank reg_bank_inst (
        .clk          (clk),
        .reset        (reset),
        .rs1          (Ins[19:15]),
        .rs2          (Ins[24:20]),
        .rd           (rd),
        .write_data   (write_data),
        .reg_write_en (reg_write_en),
        .read_data_1  (read_data_1),
        .read_data_2  (read_data_2)
    );

    Imm_calc Imm_calc_inst (
        .Ins (Ins),
        .Imm (Imm)
    );

    control control_inst (
        .Ins       (Ins),
        .mem_write (mem_write),
        .mem_read  (mem_read),
        .reg_write (reg_write),
        .ALUop     (ALUop),
        .ALUSrc_A    (ALUSrc_A),
        .ALUSrc_B   (ALUSrc_B),
        .Branch    (Branch),
        .Jump      (Jump),
        .funct_3   (funct_3)
    );

endmodule