`timescale 1ns/1ps
module bellman_tb;
    reg clk, reset;

    // 8KB Instruction Memory, 4KB Data Memory
    rv32i_top #(.I_MEM_SIZE(8192), .D_MEM_SIZE(4096)) dut (
        .clk(clk),
        .reset(reset)
    );

    parameter HALF_PERIOD = 5;
    parameter CLOCK_PERIOD = 10;

    initial clk = 0;
    always #HALF_PERIOD clk = ~clk;

    // Helper task to read 32-bit words from the 4-Bank Data Memory
    reg [31:0] actual_val;
    task check_result;
        input [31:0] physical_idx; // Physical Byte Address
        input [31:0] expected;
        input [8*15:1] label;
        integer word_idx;
    begin
        word_idx = physical_idx / 4;
        actual_val = { dut.MEM_stage.bank3[word_idx], 
                       dut.MEM_stage.bank2[word_idx], 
                       dut.MEM_stage.bank1[word_idx], 
                       dut.MEM_stage.bank0[word_idx] };
                       
        if (actual_val === expected)
            $display("  [PASS] %0s | Got %0d", label, $signed(actual_val));
        else
            $display("  [FAIL] %0s | Expected %0d, Got %0d", label, $signed(expected), $signed(actual_val));
    end
    endtask

    integer cycles_taken;
    reg [31:0] flag_val;

    initial begin
        $display("==================================================");
        $display(" Booting Bellman-Ford (Stack & Harvard Safe)...");
        $display("==================================================");
        
        cycles_taken = 0;
        reset = 0;
        #15 reset = 1;

        // Magic flag is at 0x2180 (Software) -> 384 (Physical Byte) -> 96 (Word Index)
        flag_val = { dut.MEM_stage.bank3[96], dut.MEM_stage.bank2[96], 
                     dut.MEM_stage.bank1[96], dut.MEM_stage.bank0[96] };

        while (flag_val !== 32'hDEADBEEF && cycles_taken < 50000) begin
            @(posedge clk);
            cycles_taken = cycles_taken + 1;
            flag_val = { dut.MEM_stage.bank3[96], dut.MEM_stage.bank2[96], 
                         dut.MEM_stage.bank1[96], dut.MEM_stage.bank0[96] };
        end

        if (cycles_taken >= 50000) begin
            $display("\n  [WARN] Timeout! The C code never wrote 0xDEADBEEF.");
        end else begin
            repeat(5) @(posedge clk);
            cycles_taken = cycles_taken + 5;
        end

        $display("\n--- PERFORMANCE METRICS ---");
        $display("  [TIME]  Total Clock Cycles : %0d", cycles_taken);

$display("\n--- VERIFICATION RESULTS ---");
        // Output array starts at 0x2100 (Software) -> 256 (Physical Byte)
        check_result(256, 0, "Node 0 Dist");
        check_result(260, 1, "Node 1 Dist");
        check_result(264, 3, "Node 2 Dist");
        check_result(268, 6, "Node 3 Dist");
        
        $display("==================================================");
        $finish;
    end
endmodule