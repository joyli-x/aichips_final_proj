`include "minimalist_cpu.v"
`include "unified_multiport_ram.v"

module GPU(
    input CLK,
    input RES,
    input HLT
    // intput [31:0] input_matrix_A [0:15][0:15],
    // intput [31:0] input_matrix_B [0:15][0:15],
    // output [31:0] result_matrix [0:15][0:15] // 输出为16*16矩阵，假设一次可以输出整个矩阵
);
    wire cpus_ready;  // 用来指示所有CPU都准备好了
    wire WR_0, WR_1, WR_2, WR_3;
    wire IDLE_0, IDLE_1, IDLE_2, IDLE_3;
    wire [31:0] DATAI_0, DATAO_0, DADDR_0;
    wire [31:0] DATAI_1, DATAO_1, DADDR_1;
    wire [31:0] DATAI_2, DATAO_2, DADDR_2;
    wire [31:0] DATAI_3, DATAO_3, DADDR_3;
    wire en = 1;

    // 临时变量储存结果矩阵
    reg [31:0] result_matrix_interim [0:3][0:15][0:15];

    MinimalistCPU u0(
        .CLK ( CLK ) ,   // clock
        .RES ( RES ) ,   // reset
        .HLT ( HLT ),   // halt
        .IDLE (IDLE_0),  // idle
        
        .DATAI (DATAI_0), // data bus (input)
        .DATAO (DATAO_0), // data bus (output)
        .DADDR (DADDR_0), // addr bus

        .WR (WR_0)    // write enable
    );

    MinimalistCPU u1(
        .CLK ( CLK ) ,   // clock
        .RES ( RES ) ,   // reset
        .HLT ( HLT ),   // halt
        .IDLE (IDLE_1),  // idle
        
        .DATAI (DATAI_1), // data bus (input)
        .DATAO (DATAO_1), // data bus (output)
        .DADDR (DADDR_1), // addr bus

        .WR (WR_1)    // write enable
    );

    MinimalistCPU u2(
        .CLK ( CLK ) ,   // clock
        .RES ( RES ) ,   // reset
        .HLT ( HLT ),   // halt
        .IDLE (IDLE_2),  // idle
        
        .DATAI (DATAI_2), // data bus (input)
        .DATAO (DATAO_2), // data bus (output)
        .DADDR (DADDR_2), // addr bus

        .WR (WR_2)    // write enable
    );

    MinimalistCPU u3(
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