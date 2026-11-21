`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/13/2026 04:43:19 PM
// Design Name: 
// Module Name: async
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

module async_fifo #(parameter DSIZE = 8, ASIZE = 4)(
    input                wclk, wrst_n, winc,
    input  [DSIZE-1:0]   wdata,
    output               wfull,
    input                rclk, rrst_n, rinc,
    output [DSIZE-1:0]   rdata,
    output               rempty
);
    wire [ASIZE-1:0] waddr, raddr;
    wire [ASIZE:0]   wptr, rptr, wq2_rptr, rq2_wptr;

    sync #(ASIZE+1) sync_r2w (.clk(wclk), .rst_n(wrst_n), .d(rptr), .q(wq2_rptr));
    sync #(ASIZE+1) sync_w2r (.clk(rclk), .rst_n(rrst_n), .d(wptr), .q(rq2_wptr));

    fifo_mem #(DSIZE, ASIZE) mem (
        .wclk(wclk), .wen(winc & ~wfull),
        .waddr(waddr), .raddr(raddr),
        .wdata(wdata), .rdata(rdata)
    );

    wptr_full #(ASIZE) wptr_inst (
        .wclk(wclk), .wrst_n(wrst_n), .winc(winc),
        .wq2_rptr(wq2_rptr), .wfull(wfull), .waddr(waddr), .wptr(wptr)
    );

    rptr_empty #(ASIZE) rptr_inst (
        .rclk(rclk), .rrst_n(rrst_n), .rinc(rinc),
        .rq2_wptr(rq2_wptr), .rempty(rempty), .raddr(raddr), .rptr(rptr)
    );
endmodule
