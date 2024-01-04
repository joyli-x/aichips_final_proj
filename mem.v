`timescale 1ns / 1ns
// data
module ram (
    input CLK,
    input [31:0] D,
    output [31:0] Q,
    input [31:0] A,
    input WE // write enable
);

parameter LEN = 1024;

reg [31:0] mem_core [0:LEN-1];

// initial reset
integer i;
initial begin
    for(i=0;i<=LEN-1;i=i+1) begin
        mem_core[i] = 0;
    end
end

// read change the output whenever mem_core[A] change
assign Q = mem_core[A]; //change the output into reg form, then there is no 1-cycle read latency
// write
always @(posedge CLK) begin
    if(WE) begin
        mem_core[A] <= D;
    end
end
    
endmodule


// --------------------------------------------------------
// instruction data
module rom (
    input CLK,
    output reg [31:0] Q,
    input [31:0] A
);

parameter LEN = 10240;

reg [31:0] mem_core [0:LEN-1];

// initial reset
integer i;
initial begin
    for(i=0;i<=LEN-1;i=i+1) begin
        mem_core[i] = 0;
    end
    $readmemh("mat_code.hex",mem_core);
end

always @(posedge CLK) begin
    Q <= mem_core[(A>>2)];
end
    
endmodule