module branch_controller (
    input         clk,
    input         reset,
    input         stall,          // Hazard unit tells us if we need to stall

    input         ID_Branch,
    input  [1:0]  ID_Jump,
    input         EX_Branch_taken,
    input  [1:0]  EX_Jump,

    output reg        IF_ID_NOP,
    output reg        ID_EX_NOP,
    output reg [1:0]  PC_Src
);

    parameter IDLE   = 2'b00,
              BRANCH = 2'b01,
              JUMP   = 2'b10;
              
    reg [1:0] state, next_state;

    always @(posedge clk or negedge reset) begin
        if (!reset) state <= IDLE;
        else        state <= next_state;
    end


    always @(*) begin
        case (state)
            IDLE:
                if (stall)          next_state = IDLE;  // if load-store hazard comes we shouldn't take a branch
                else if (|ID_Jump)  next_state = JUMP;
                else if (ID_Branch) next_state = BRANCH;
                else                next_state = IDLE;
                
            BRANCH:  next_state = IDLE;
            JUMP:    next_state = IDLE;
            default: next_state = IDLE;
        endcase
    end

    always @(*) begin
        IF_ID_NOP = 1'b0;
        ID_EX_NOP = 1'b0;
        PC_Src    = 2'b00;

        case (state)
            IDLE: begin
                if ((|ID_Jump)) begin
                    PC_Src = 2'b11; // as jump is always taken it is unnecessary to send the instructions in the pipline so stall PC 
                end
                if(ID_Branch)
                begin
                    PC_Src = 2'b00;
                end
            end

            BRANCH: begin
                if (EX_Branch_taken) begin
                    IF_ID_NOP = 1'b1;
                    ID_EX_NOP = 1'b1;    
                    PC_Src = 2'b01;   // goes to PC_Imm 
                end
                else begin
                    ID_EX_NOP = 1'b0;
                    IF_ID_NOP = 1'b0; 
                    PC_Src = 2'b00;    
                end
            end

            JUMP: begin
                ID_EX_NOP = 1'b1; 
                IF_ID_NOP = 1'b1; 
                
                if (EX_Jump == 2'b10) PC_Src = 2'b10; // JALR
                else                  PC_Src = 2'b01; // JAL
            end

            default: begin
                IF_ID_NOP = 1'b0;
                ID_EX_NOP = 1'b0;
                PC_Src    = 2'b00;
            end
        endcase
    end
endmodule