// module Unified_MultiPort_RAM (
//     input clock,
//     input en,

//     input we0,
//     input [31:0] d0,
//     output reg [31:0] q0,
//     input [31:0] addr0,

//     input we1,
//     input [31:0] d1,
//     output reg [31:0] q1,
//     input [31:0] addr1,

//     input we2,
//     input [31:0] d2,
//     output reg [31:0] q2,
//     input [31:0] addr2,
    
//     input we3,
//     input [31:0] d3,
//     output reg [31:0] q3,
//     input [31:0] addr3
// );

module Unified_MultiPort_RAM (
    input clock,
    input en,

    input we0,
    input [31:0] d0,
    output [31:0] q0,
    input [31:0] addr0,

    input we1,
    input [31:0] d1,
    output [31:0] q1,
    input [31:0] addr1,

    input we2,
    input [31:0] d2,
    output [31:0] q2,
    input [31:0] addr2,
    
    input we3,
    input [31:0] d3,
    output [31:0] q3,
    input [31:0] addr3
);

parameter LEN = 1024;

reg [31:0] mem [LEN-1:0];

// initial reset
integer i;
initial begin
    for(i=0;i<=LEN-1;i=i+1) begin
        mem[i] = 0;
    end
end

always @(posedge clock) begin
    if(en) begin
        if(we0 | we1 | we2 | we3) begin
            // if write_enable is asserted, push the data into the address
            if(we0)
                mem[addr0] = d0 ;
            if(we1)
                mem[addr1] = d1 ;
            if(we2)
                mem[addr2] = d2 ;
            if(we3)
                mem[addr3] = d3 ;
        end
    end
end


// read change the output whenever mem_core[A] change
assign q0 = mem[addr0] ;
assign q1 = mem[addr1] ;
assign q2 = mem[addr2] ;
assign q3 = mem[addr3] ;

// always @(posedge clock) begin
//     if(en) begin
//         // if write_enable is deasserted, pop the stored data to the port q
//         q0 = mem[addr0] ;
//         q1 = mem[addr1] ;
//         q2 = mem[addr2] ;
//         q3 = mem[addr3] ;
//     end
// end
    
endmodule