`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/13/2026 04:43:19 PM
// Design Name: 
// Module Name: mem
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module fifo_mem #(parameter DSIZE = 8, ASIZE = 4)(
    input                  wclk,
    input                  wen,
    input  [ASIZE-1:0]     waddr,
    input  [ASIZE-1:0]     raddr,
    input  [DSIZE-1:0]     wdata,
    output [DSIZE-1:0]     rdata
);
    reg [DSIZE-1:0] mem [0:(1<<ASIZE)-1];

    assign rdata = mem[raddr];           // read is combinational

    always @(posedge wclk)
        if (wen) mem[waddr] <= wdata;    // write is clocked
endmodule
