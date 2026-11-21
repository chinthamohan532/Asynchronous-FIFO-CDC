`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/13/2026 04:43:19 PM
// Design Name: 
// Module Name: Wptr_full
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

module wptr_full #(parameter ASIZE = 4)(
    input                  wclk,
    input                  wrst_n,
    input                  winc,
    input  [ASIZE:0]       wq2_rptr,     // read pointer (Gray), synced into write clock
    output reg             wfull,
    output [ASIZE-1:0]     waddr,
    output reg [ASIZE:0]   wptr          // write pointer (Gray) sent to the read side
);
    reg  [ASIZE:0] wbin;
    wire [ASIZE:0] wbin_next  = wbin + (winc & ~wfull);
    wire [ASIZE:0] wgray_next = (wbin_next >> 1) ^ wbin_next;

    // full: next write Gray pointer equals read Gray pointer with top 2 bits inverted
    wire wfull_val = (wgray_next == {~wq2_rptr[ASIZE:ASIZE-1], wq2_rptr[ASIZE-2:0]});

    always @(posedge wclk or negedge wrst_n) begin
        if (!wrst_n) begin
            wbin  <= 0;
            wptr  <= 0;
            wfull <= 1'b0;
        end else begin
            wbin  <= wbin_next;
            wptr  <= wgray_next;
            wfull <= wfull_val;
        end
    end

    assign waddr = wbin[ASIZE-1:0];   // memory address uses binary, without the extra bit
endmodule
