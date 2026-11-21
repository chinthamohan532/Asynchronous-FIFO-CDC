`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/13/2026 04:43:19 PM
// Design Name: 
// Module Name: rptr_emp
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
module rptr_empty #(parameter ASIZE = 4)(
    input                  rclk,
    input                  rrst_n,
    input                  rinc,
    input  [ASIZE:0]       rq2_wptr,     // write pointer (Gray), synced into read clock
    output reg             rempty,
    output [ASIZE-1:0]     raddr,
    output reg [ASIZE:0]   rptr
);
    reg  [ASIZE:0] rbin;
    wire [ASIZE:0] rbin_next  = rbin + (rinc & ~rempty);
    wire [ASIZE:0] rgray_next = (rbin_next >> 1) ^ rbin_next;

    // empty: next read Gray pointer equals the synced write Gray pointer
    wire rempty_val = (rgray_next == rq2_wptr);

    always @(posedge rclk or negedge rrst_n) begin
        if (!rrst_n) begin
            rbin   <= 0;
            rptr   <= 0;
            rempty <= 1'b1;           // FIFO starts empty
        end else begin
            rbin   <= rbin_next;
            rptr   <= rgray_next;
            rempty <= rempty_val;
        end
    end

    assign raddr = rbin[ASIZE-1:0];
endmodule
