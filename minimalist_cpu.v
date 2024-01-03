`include "code.v"
`include "mem.v"

module MinimalistCPU
#(
    parameter [31:0] RESET_SP = 512
)
(
    input CLK, RES, HLT,
    input [31:0] DATAI,
    output [31:0] DATAO, DADDR,
    output WR, RD, IDLE
);

wire [3:0] DEBUG, BE;
wire [31:0] IDATA, IADDR;

rom urom (
    .CLK ( CLK ) ,
    .Q ( IDATA ) , // instruction data bus
    .A ( IADDR )  // instruction addr bus
);

darkriscv #(
   .RESET_SP (RESET_SP)
) u_rvcpu(
    .CLK ( CLK ) ,   // clock
    .RES ( RES ) ,   // reset
    .HLT ( HLT ),   // halt
     
    .IDATA ( IDATA ) , // instruction data bus
    .IADDR ( IADDR ) , // instruction addr bus
    
    .DATAI (DATAI), // data bus (input)
    .DATAO (DATAO), // data bus (output)
    .DADDR (DADDR), // addr bus
   
    .BE (BE),   // byte enable
    .WR (WR),    // write enable
    .RD (RD),    // read enable 
   

    .IDLE (IDLE),   // idle output
    
    .DEBUG (DEBUG)       // old-school osciloscope based debug! :)
);

    
endmodule