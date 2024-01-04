`timescale 1ns / 1ns

// macro
// `define __RESETSP__ 32'd512
`define __RESETPC__ 32'd0

`include "gpu.v"

module TB;

initial begin            
    $dumpfile("wave.vcd");        //generate wave.vcd
    $dumpvars(0, TB);    //dump all of the TB module data
end

reg CLK, RES, HLT;
reg [256*32-1:0] input_matrix_A; //注意矩阵是倒着存的
reg [256*32-1:0] input_matrix_B;
wire [256*32-1:0] result_matrix;


initial CLK = 0;
always #2 CLK = ~CLK;

integer clkcycle;
always @(posedge CLK) begin
    if(clkcycle==10240) $stop;
    if(~RES) clkcycle <= clkcycle + 1;
end

// 通过外部文件初始化的数组，用于中转读取数据
reg signed [31:0] input_A_array[0:255];
reg signed [31:0] input_B_array[0:255];

integer i;
initial begin
    clkcycle = 0;
    RES = 1;
    HLT = 0;

    // 读入input_A.hex和input_B.hex文件
    $readmemh("input_A.hex", input_A_array);
    $readmemh("input_B.hex", input_B_array);

    // for (i = 0; i < 256; i = i + 1) begin
    //     input_matrix_A[(i*32+31) -: 32] = 0;
    //     input_matrix_B[(i*32+31) -: 32] = 0;
    // end

    // 初始化input_matrix_A和input_matrix_B
    for (i = 0; i < 256; i = i + 1) begin
        input_matrix_A[i*32 +: 32] = input_A_array[i];
        input_matrix_B[i*32 +: 32] = input_B_array[i];
    end

    
    #9 
    RES = 0;
    // input_matrix_A[(0*32+31) -: 32] = -4;
    // input_matrix_A[((1*4*16+0)*32+31) -: 32] = 4;
    // input_matrix_A[(1*32+31) -: 32] = 12;
    // input_matrix_B[(0*32+31) -: 32] = 1;
    // input_matrix_B[(1*32+31) -: 32] = 23;

end

GPU gpu
(
    .CLK ( CLK ) ,   // clock
    .GPU_RES ( RES ) ,   // reset
    .HLT ( HLT ) ,   // halt
    .input_matrix_A ( input_matrix_A ) ,
    .input_matrix_B ( input_matrix_B ) ,
    .result_matrix ( result_matrix )
);

    
endmodule