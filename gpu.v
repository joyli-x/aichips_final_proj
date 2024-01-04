`include "minimalist_cpu.v"
`include "unified_multiport_ram.v"


module GPU(
    input CLK,
    input GPU_RES,
    input HLT,
    input [256*32-1:0] input_matrix_A,
    input [256*32-1:0] input_matrix_B,
    output [256*32-1:0] result_matrix  // 输出为16*16矩阵，假设一次可以输出整个矩阵
);
    wire WR_0, WR_1, WR_2, WR_3;
    reg WR_GPU;
    wire IDLE_0, IDLE_1, IDLE_2, IDLE_3;
    wire [31:0] DATAI_0, DATAO_0, DADDR_0;
    wire [31:0] DATAI_1, DATAO_1, DADDR_1;
    wire [31:0] DATAI_2, DATAO_2, DADDR_2;
    wire [31:0] DATAI_3, DATAO_3, DADDR_3;
    reg [31:0] GPU_DATAO_0, GPU_DADDR_0, GPU_DATAO_1, GPU_DADDR_1, GPU_DATAO_2, GPU_DADDR_2;
    wire [31:0] GPU_DATAI_0;
    wire en = 1;
    
    parameter [31:0] start_a_addr = 2048;
    parameter [31:0] start_b_addr = 4096;
    parameter [31:0] start_result_addr = 6144;

    reg reg_ready; // To control the reset signal.
    reg matrice_ready; // To control the matrice initialization.
    reg [31:0] matrice_cnt;
    reg [128:0] cnt_clk;
    reg [3:0] cnt;
    assign RESET = GPU_RES | (!reg_ready);

    initial begin
        matrice_ready = 0;
        reg_ready = 0;
        matrice_cnt = 0;
        cnt_clk = 0;
        cnt = 0;
        WR_GPU = 0;
    end

    // initialize the matrice
    always @(posedge CLK) begin
        if (!GPU_RES && !matrice_ready) begin
            // A
            GPU_DATAO_0 <= input_matrix_A[(matrice_cnt*32+31) -: 32];
            GPU_DADDR_0 <= matrice_cnt * 4 + start_a_addr; //这里有点奇怪
            // B
            GPU_DATAO_1 <= input_matrix_B[(matrice_cnt*32+31) -: 32];
            GPU_DADDR_1 <= matrice_cnt * 4 + start_b_addr;

            WR_GPU <= 1;

            matrice_cnt <= matrice_cnt + 1;
            if (matrice_cnt == 255) begin
                matrice_ready <= 1;
            end
        end
    end

    // Initalize a0, a1, a2
    always @(posedge CLK) begin
        if (matrice_ready && !reg_ready && !GPU_RES) begin
            // reg a0
            GPU_DATAO_0 <= start_a_addr + cnt*4*16*4;
            GPU_DADDR_0 <= (256-20) + 256*cnt;
            // reg a1
            GPU_DATAO_1 <= start_b_addr;
            GPU_DADDR_1 <= (256-24) + 256*cnt;
            // reg a2
            GPU_DATAO_2 <= start_result_addr + cnt*4*16*4;
            GPU_DADDR_2 <= (256-28) + 256*cnt;

            WR_GPU <= 1;
            cnt <= cnt + 1;
            if (cnt==3) begin
                reg_ready <= 1;
            end
        end
        else if (reg_ready) begin
            // Normal operation
            WR_GPU <= 0;  // Make sure to disable write after initialization is done
        end
    end

    integer clkcycle = 0;
    parameter [31:0] start_load = 9000;
    reg signed [31:0] temp_res [0:256];
    integer file, i; // Variables for file I/O and loop counter

    // File operation for simulation only, not synthesizable
    initial begin
        file = $fopen("result.txt", "w"); // Open file for writing
    end

    always @(posedge CLK) begin
        if(RESET) begin // Corrected RESET condition
            clkcycle <= 0;
        end 
        else begin
            if(clkcycle >= start_load && clkcycle < (start_load+257))begin
                GPU_DADDR_0 <= start_result_addr + 4*(clkcycle-start_load);
                temp_res[clkcycle-start_load] <= GPU_DATAI_0; // Load temp_res, assuming GPU_DATAI_0 is available
            end
            clkcycle <= clkcycle + 1;

            // After all modifications are done OR halt signal is asserted, output the results
            if(clkcycle >= (start_load+257)) begin
                for(i = 1; i < 257; i = i + 1) begin
                    // Check if the file is open, since the $fwrite can only be executed if the file is available
                    if(file) begin
                        $fwrite(file, "%d\n", temp_res[i]); // Write each integer on a new line
                    end
                end
                $fclose(file); // Close the file
                // $finish; // End the simulation, if necessary
            end
        end
    end

    MinimalistCPU #( 
        .RESET_SP (256)
    ) u0 
    (
        .CLK ( CLK ) ,   // clock
        .RES ( RESET ) ,   // reset
        .HLT ( HLT ),   // halt
        .IDLE (IDLE_0),  // idle
        
        .DATAI (DATAI_0), // data bus (input)
        .DATAO (DATAO_0), // data bus (output)
        .DADDR (DADDR_0), // addr bus

        .WR (WR_0)    // write enable
    );

    MinimalistCPU #( 
        .RESET_SP (512)
    ) u1
    (
        .CLK ( CLK ) ,   // clock
        .RES ( RESET ) ,   // reset
        .HLT ( HLT ),   // halt
        .IDLE (IDLE_1),  // idle
        
        .DATAI (DATAI_1), // data bus (input)
        .DATAO (DATAO_1), // data bus (output)
        .DADDR (DADDR_1), // addr bus

        .WR (WR_1)    // write enable
    );

    MinimalistCPU #( 
        .RESET_SP (768)
    ) u2
    (
        .CLK ( CLK ) ,   // clock
        .RES ( RESET ) ,   // reset
        .HLT ( HLT ),   // halt
        .IDLE (IDLE_2),  // idle
        
        .DATAI (DATAI_2), // data bus (input)
        .DATAO (DATAO_2), // data bus (output)
        .DADDR (DADDR_2), // addr bus

        .WR (WR_2)    // write enable
    );

    MinimalistCPU #( 
        .RESET_SP (1024)
    ) u3   
    (
        .CLK ( CLK ) ,   // clock
        .RES ( RESET ) ,   // reset
        .HLT ( HLT ),   // halt
        .IDLE (IDLE_3),  // idle
        
        .DATAI (DATAI_3), // data bus (input)
        .DATAO (DATAO_3), // data bus (output)
        .DADDR (DADDR_3), // addr bus

        .WR (WR_3)    // write enable
    );

    // 实例化RAM
    Unified_MultiPort_RAM uut (
        .clock (CLK),
        .en (en),

        .gpu_we_0 (WR_GPU),
        .gpu_d_0 (GPU_DATAO_0),
        .gpu_q_0 (GPU_DATAI_0),
        .gpu_addr_0 (GPU_DADDR_0),

        .gpu_we_1 (WR_GPU),
        .gpu_d_1 (GPU_DATAO_1),
        .gpu_addr_1 (GPU_DADDR_1),

        .gpu_we_2 (WR_GPU),
        .gpu_d_2 (GPU_DATAO_2),
        .gpu_addr_2 (GPU_DADDR_2),

        .we0 (WR_0),
        .d0 (DATAO_0),
        .q0 (DATAI_0),
        .addr0 (DADDR_0),

        .we1 (WR_1),
        .d1 (DATAO_1),
        .q1 (DATAI_1),
        .addr1 (DADDR_1),

        .we2 (WR_2),
        .d2 (DATAO_2),
        .q2 (DATAI_2),
        .addr2 (DADDR_2),

        .we3 (WR_3),
        .d3 (DATAO_3),
        .q3 (DATAI_3),
        .addr3 (DADDR_3)
    );

endmodule