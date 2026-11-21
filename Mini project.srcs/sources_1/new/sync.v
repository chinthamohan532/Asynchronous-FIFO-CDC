`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/13/2026 04:41:11 PM
// Design Name: 
// Module Name: sync
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

module sync #(parameter W = 5)(
    input          clk,
    input          rst_n,
    input  [W-1:0] d,
    output [W-1:0] q
);
    (* ASYNC_REG = "TRUE" *) reg [W-1:0] q1;
    (* ASYNC_REG = "TRUE" *) reg [W-1:0] q2;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            q1 <= 0;
            q2 <= 0;
        end else begin
            q1 <= d;
            q2 <= q1;
        end
    end

    assign q = q2;
endmodule