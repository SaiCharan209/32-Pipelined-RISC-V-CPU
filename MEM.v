    // module data_mem #(
    //     parameter MEM_SIZE = 1024
    // )(
    //     input             clk,
    //     input             mem_write,
    //     input             mem_read,
    //     input      [31:0] address,
    //     input      [31:0] write_data,
    //     input      [2:0]  funct3,
    //     output reg [31:0] read_data
    // );

    //     reg [7:0] mem [MEM_SIZE-1:0];


    //     always @(*) begin
    //         read_data = 32'b0;
    //         if (mem_read) begin
    //             case (funct3)
    //                 3'h0: read_data = {{24{mem[address][7]}},
    //                                     mem[address]};


    //                 3'h1: read_data = {{16{mem[address+1][7]}},
    //                                     mem[address+1],
    //                                     mem[address]};


    //                 3'h2: read_data = {mem[address+3],
    //                                    mem[address+2],
    //                                    mem[address+1],
    //                                    mem[address]};

    //                 3'h4: read_data = {24'b0, mem[address]};

    //                 3'h5: read_data = {16'b0,
    //                                    mem[address+1],
    //                                    mem[address]};

    //                 default: read_data = 32'b0;
    //             endcase
    //         end
    //     end

    // //negedge write
    //     always @(negedge clk) begin
    //         if (mem_write) begin
    //             case (funct3)

    //                 3'h0: mem[address] <= write_data[7:0];

    //                 3'h1: begin
    //                     mem[address]   <= write_data[7:0];
    //                     mem[address+1] <= write_data[15:8];
    //                 end

    //                 3'h2: begin
    //                     mem[address]   <= write_data[7:0];
    //                     mem[address+1] <= write_data[15:8];
    //                     mem[address+2] <= write_data[23:16];
    //                     mem[address+3] <= write_data[31:24];
    //                 end
    //             endcase
    //         end
    //     end

    // endmodule


    // module data_mem #(
    //     parameter MEM_SIZE = 8192 // 8KB Data Memory
    // )(
    //     input         clk,
    //     input         mem_read,
    //     input         mem_write,
    //     input  [2:0]  funct3,
    //     input  [31:0] address,
    //     input  [31:0] write_data,
    //     output reg [31:0] read_data
    // );
    //     reg [7:0] mem [0:MEM_SIZE-1];

    //     // Optional: Load initial data (like pre-sorted arrays)
    //             integer i;
    //     initial begin
    //         // $readmemh("dmem.hex", mem); 
    //         // For C code, RAM usually starts uninitialized, but you can clear it
    //         for (i=0; i<MEM_SIZE; i=i+1) mem[i] = 8'h00;
    //     end

    //     // Synchronous Write
    //     always @(posedge clk) begin
    //         if (mem_write && (address < MEM_SIZE)) begin
    //             case (funct3)
    //                 3'b000: begin // SB (Store Byte)
    //                     mem[address] <= write_data[7:0];
    //                 end
    //                 3'b001: begin // SH (Store Halfword)
    //                     mem[address]   <= write_data[7:0];
    //                     mem[address+1] <= write_data[15:8];
    //                 end
    //                 3'b010: begin // SW (Store Word)
    //                     mem[address]   <= write_data[7:0];
    //                     mem[address+1] <= write_data[15:8];
    //                     mem[address+2] <= write_data[23:16];
    //                     mem[address+3] <= write_data[31:24];
    //                 end
    //             endcase
    //         end
    //     end

    //     // Combinational Read (Little-Endian with Sign Extension)
    //     always @(*) begin
    //         if (mem_read && (address < MEM_SIZE)) begin
    //             case (funct3)
    //                 3'b000: // LB (Load Byte Sign-Extended)
    //                     read_data = {{24{mem[address][7]}}, mem[address]};
    //                 3'b100: // LBU (Load Byte Unsigned)
    //                     read_data = {24'd0, mem[address]};
    //                 3'b001: // LH (Load Halfword Sign-Extended)
    //                     read_data = {{16{mem[address+1][7]}}, mem[address+1], mem[address]};
    //                 3'b101: // LHU (Load Halfword Unsigned)
    //                     read_data = {16'd0, mem[address+1], mem[address]};
    //                 3'b010: // LW (Load Word)
    //                     read_data = {mem[address+3], mem[address+2], mem[address+1], mem[address]};
    //                 default: 
    //                     read_data = 32'd0;
    //             endcase
    //         end else begin
    //             read_data = 32'd0;
    //         end
    //     end
    // endmodule

    // module data_mem #(
    //     parameter MEM_SIZE  = 4096,         // Physical Size: 4KB 
    //     parameter BASE_ADDR = 32'h00001000  // Software Base Address: 4096
    // )(
    //     input         clk,
    //     input         mem_read,
    //     input         mem_write,
    //     input  [2:0]  funct3,
    //     input  [31:0] address,
    //     input  [31:0] write_data,
    //     output reg [31:0] read_data
    // );

    //     // Byte-addressable physical memory array (Now strictly 4KB)
    //     reg [7:0] mem [0:MEM_SIZE-1];

    //     wire [31:0] true_index = address - BASE_ADDR;

    //     // Optional: Initialize RAM to zero
    //             integer i;
    //     initial begin

    //         for (i = 0; i < MEM_SIZE; i = i + 1) begin
    //             mem[i] = 8'h00;
    //         end
    //     end

    //     // Synchronous Write (Using true_index)
    //     always @(posedge clk) begin
    //         if (mem_write && (true_index < MEM_SIZE)) begin
    //             case (funct3)
    //                 3'b000: begin // SB (Store Byte)
    //                     mem[true_index] <= write_data[7:0];
    //                 end
    //                 3'b001: begin // SH (Store Halfword)
    //                     mem[true_index]   <= write_data[7:0];
    //                     mem[true_index+1] <= write_data[15:8];
    //                 end
    //                 3'b010: begin // SW (Store Word)
    //                     mem[true_index]   <= write_data[7:0];
    //                     mem[true_index+1] <= write_data[15:8];
    //                     mem[true_index+2] <= write_data[23:16];
    //                     mem[true_index+3] <= write_data[31:24];
    //                 end
    //             endcase
    //         end
    //     end

    //     // Combinational Read (Using true_index)
    //     always @(*) begin
    //         if (mem_read && (true_index < MEM_SIZE)) begin
    //             case (funct3)
    //                 3'b000: // LB (Load Byte Sign-Extended)
    //                     read_data = {{24{mem[true_index][7]}}, mem[true_index]};
    //                 3'b100: // LBU (Load Byte Unsigned)
    //                     read_data = {24'd0, mem[true_index]};
    //                 3'b001: // LH (Load Halfword Sign-Extended)
    //                     read_data = {{16{mem[true_index+1][7]}}, mem[true_index+1], mem[true_index]};
    //                 3'b101: // LHU (Load Halfword Unsigned)
    //                     read_data = {16'd0, mem[true_index+1], mem[true_index]};
    //                 3'b010: // LW (Load Word)
    //                     read_data = {mem[true_index+3], mem[true_index+2], mem[true_index+1], mem[true_index]};
    //                 default: 
    //                     read_data = 32'd0;
    //             endcase
    //         end else begin
    //             read_data = 32'd0;
    //         end
    //     end
    // endmodule


    module data_mem #(
        parameter MEM_SIZE = 1024,         // 1024 words = 4096 bytes (4KB)
        parameter BASE_ADDR = 32'h2000
    )(
        input         clk,
        input         mem_read,
        input         mem_write,
        input  [2:0]  funct3,
        input  [31:0] address,
        input  [31:0] write_data,
        output reg [31:0] read_data
    );
    localparam WORDS =MEM_SIZE/4 ;
        wire [31:0] true_address = address - BASE_ADDR;
        
        wire [29:0] word_index  = true_address[31:2];
        wire [1:0]  byte_offset = true_address[1:0];

        reg [7:0] bank0 [0:WORDS-1];
        reg [7:0] bank1 [0:WORDS-1];
        reg [7:0] bank2 [0:WORDS-1];
        reg [7:0] bank3 [0:WORDS-1];

        always @(negedge clk) begin
            
            if (mem_write && (word_index < WORDS)) begin
                case (funct3)
                    3'b000: begin 
                        if (byte_offset == 2'b00)bank0[word_index] <= write_data[7:0];
                        if (byte_offset == 2'b01)bank1[word_index] <= write_data[15:8];
                        if (byte_offset == 2'b10)bank2[word_index] <= write_data[23:16];
                        if (byte_offset == 2'b11) bank3[word_index] <= write_data[31:24];
                    end
                    3'b001: begin 
                        if (byte_offset == 2'b00) begin bank0[word_index] <= write_data[7:0];bank1[word_index] <= write_data[15:8]; end
                        if (byte_offset == 2'b10) begin bank2[word_index] <= write_data[23:16]; bank3[word_index] <= write_data[31:24]; end
                    end
                    3'b010: begin 
                        if (byte_offset == 2'b00) begin bank0[word_index] <= write_data[7:0]; bank1[word_index] <= write_data[15:8];bank2[word_index] <= write_data[23:16];bank3[word_index] <= write_data[31:24]; end
                    end
                endcase
            end
        end


        always @(*) begin
            read_data = 32'd0;
            if (mem_read && (word_index < WORDS)) begin
                case(funct3)
                3'd0:begin  
                    if(byte_offset == 2'b00) read_data = {{24{bank0[word_index][7]}},bank0[word_index]};
                    if(byte_offset == 2'b01) read_data = {{24{bank1[word_index][7]}},bank1[word_index]};  
                    if(byte_offset == 2'b10) read_data = {{24{bank2[word_index][7]}},bank2[word_index]};  
                    if(byte_offset == 2'b11) read_data = {{24{bank3[word_index][7]}},bank3[word_index]};          end
                3'd1:begin  if(byte_offset ==2'b00)read_data = {{16{bank1[word_index][7]}},bank1[word_index],bank0[word_index]};    
                            if(byte_offset ==2'b10)read_data = {{16{bank3[word_index][7]}},bank3[word_index],bank2[word_index]};   
                                                                                        end
                3'd2:begin if(byte_offset ==2'b00)read_data <= {bank3[word_index],bank2[word_index],bank1[word_index],bank0[word_index]}; end
                3'd4:begin                 
                    if(byte_offset == 2'b00) read_data = {24'd0,bank0[word_index]};
                    if(byte_offset == 2'b01) read_data = {24'd0,bank1[word_index]};  
                    if(byte_offset == 2'b10) read_data = {24'd0,bank2[word_index]};  
                    if(byte_offset == 2'b11) read_data = {24'd0,bank3[word_index]}; end
                3'd5:begin if(byte_offset ==2'b00)read_data = {16'd0,bank1[word_index],bank0[word_index]};    
                            if(byte_offset ==2'b10)read_data = {16'd0,bank3[word_index],bank2[word_index]};   end
                endcase
            end else begin
                read_data = 32'd0;
            end
        end

    endmodule