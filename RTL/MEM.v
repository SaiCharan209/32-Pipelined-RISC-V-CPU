
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