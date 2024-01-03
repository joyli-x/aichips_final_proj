`timescale 1ns / 1ns

// macro
`define __RESETSP__ 32'd512
`define __RESETPC__ 32'd0

`include "gpu.v"

module TB;

initial begin            
    $dumpfile("wave.vcd");        //generate wave.vcd
    $dumpvars(0, TB);    //dump all of the TB module data
end

reg CLK, RES, HLT;

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
    
    #9 
    RES = 0;

end

GPU gpu
(
    .CLK ( CLK ) ,   // clock
    .RES ( RES ) ,   // reset
    .HLT ( HLT )   // halt
);

    
endmodule