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
reg [31:0] a1, b1, a2, b2, a3, b3, a4, b4;

initial CLK = 0;
always #2 CLK = ~CLK;

integer clkcycle;
always @(posedge CLK) begin
    if(clkcycle==100) $stop;
    if(~RES) clkcycle <= clkcycle + 1;
end

initial begin
    clkcycle = 0;
    RES = 1;
    HLT = 0;
    a1 = 0;
    b1 = 0;
    a2 = 0;
    b2 = 0;
    a3 = 0;
    b3 = 0;
    a4 = 0;
    b4 = 0;
    
    #9 
    RES = 0;
    a1 = 1;
    b1 = 2;
    a2 = 3;
    b2 = 4;
    a3 = 5;
    b3 = 6;
    a4 = 7;
    b4 = 8;

end

GPU gpu
(
    .CLK ( CLK ) ,   // clock
    .GPU_RES ( RES ) ,   // reset
    .HLT ( HLT ) ,   // halt
    .a1 ( a1 ) ,
    .b1 ( b1 ) ,
    .a2 ( a2 ) ,
    .b2 ( b2 ) ,
    .a3 ( a3 ) ,
    .b3 ( b3 ) ,
    .a4 ( a4 ) ,
    .b4 ( b4 ) 
);

    
endmodule