`include "minimalist_cpu.v"
`include "unified_multiport_ram.v"

// 修改栈指针sp，a_0, a_1, a_2

module GPU(
    input CLK,
    input GPU_RES,
    input HLT,
    input [31:0] a1, b1, a2, b2, a3, b3, a4, b4
    // intput [31:0] input_matrix_A [0:15][0:15],
    // intput [31:0] input_matrix_B [0:15][0:15],
    // output [31:0] result_matrix [0:15][0:15] // 输出为16*16矩阵，假设一次可以输出整个矩阵
);
    wire WR_0, WR_1, WR_2, WR_3;
    reg WR_GPU;
    wire IDLE_0, IDLE_1, IDLE_2, IDLE_3;
    wire [31:0] DATAI_0, DATAO_0, DADDR_0;
    wire [31:0] DATAI_1, DATAO_1, DADDR_1;
    wire [31:0] DATAI_2, DATAO_2, DADDR_2;
    wire [31:0] DATAI_3, DATAO_3, DADDR_3;
    reg [31:0] GPU_DATAO_0, GPU_DADDR_0, GPU_DATAO_1, GPU_DADDR_1;
    wire en = 1;
    wire RES = 0;

    reg datas_ready; // To control the reset signal.
    reg [3:0] cnt;
    assign RESET = GPU_RES | ~datas_ready;

    initial begin
        datas_ready = 0;
        cnt = 0;
        WR_GPU = 0;
    end

    // Initalize a0, a1
    always @(posedge CLK) begin
        if (!datas_ready && !GPU_RES) begin
            if (cnt==0) begin
                // reg a0
                GPU_DATAO_0 <= a1;
                GPU_DADDR_0 <= 236;
                // reg a1
                GPU_DATAO_1 <= b1;
                GPU_DADDR_1 <= 232;

                WR_GPU <= 1;
                cnt <= cnt + 1;
            end 
            else if (cnt==1) begin
                // reg a0
                GPU_DATAO_0 <= a2;
                GPU_DADDR_0 <= 492;
                // reg a1
                GPU_DATAO_1 <= b2;
                GPU_DADDR_1 <= 488;
                
                WR_GPU <= 1;
                cnt <= cnt + 1;
            end 
            else if (cnt==2) begin
                // reg a0
                GPU_DATAO_0 <= a3;
                GPU_DADDR_0 <= 748;
                // reg a1
                GPU_DATAO_1 <= b3;
                GPU_DADDR_1 <= 744;
                
                WR_GPU <= 1;
                cnt <= cnt + 1;
            end 
            else if (cnt==3) begin
                // reg a0
                GPU_DATAO_0 <= a4;
                GPU_DADDR_0 <= 1004;
                // reg a1
                GPU_DATAO_1 <= b4;
                GPU_DADDR_1 <= 1000;
                
                WR_GPU <= 1;
                cnt <= cnt + 1;
                datas_ready <= 1;
            end
        end
        else if (datas_ready) begin
            // Normal operation
            WR_GPU <= 0;  // Make sure to disable write after initialization is done
        end
    end

    // 临时变量储存结果矩阵
    reg [31:0] result_matrix_interim [0:3][0:15][0:15];

    MinimalistCPU #( 
        .RESET_SP (256)
    ) u0 
    (
        .CLK ( CLK ) ,   // clock
        .RES ( RES ) ,   // reset
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
        .RES ( RES ) ,   // reset
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
        .RES ( RES ) ,   // reset
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
        .RES ( RES ) ,   // reset
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
        .gpu_addr_0 (GPU_DADDR_0),

        .gpu_we_1 (WR_GPU),
        .gpu_d_1 (GPU_DATAO_1),
        .gpu_addr_1 (GPU_DADDR_1),

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
    
    // 需要编写代码来协调所有的CPU实例
    // 这包括提供指令和数据，启动它们的执行，检查它们的状态，以及将最终结果合并到result_matrix中

    // 暂不提供矩阵计算中断细节。你需要根据实际情况完善
    // always @(posedge CLK) begin
    //     if (RES) begin
    //         // 初始化逻辑
    //         // 清除或设置逻辑状态
    //     end else begin
    //         // 等待CPU准备好
    //         // 启动计算
    //         // 检查状态
    //         // 当所有CPU完成计算时，合并结果并输出
    //     end
    // end
    
    // // 根据最终的部分结果合并输出
    // always @(cpus_ready) begin
    //     // 此处添加逻辑以拼装计算结果
    // end

endmodule