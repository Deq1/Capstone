`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/10/21 10:51:55
// Design Name: 
// Module Name: clock_generator
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


module clock_generator (
    input    i_clock,
    output   o_clock_100MHz,
    output   o_clock_45MHz
);

   

    // Clock Generator IP core for the Audio Codec
    wire clock_45MHZ;     // 44.1 KHz * 1024 = 45.169664 MHz, core generates 45.16765 MHz

    clk_wiz_0 clk_wiz_0_inst (
        .i_clock    (i_clock),
        .o_clock_1  (o_clock_100MHz),
        .o_clock_2  (clock_45MHZ)
    );

    // ODDR Primitive for the Output Clock
    oddr_0 oddr_0_inst (
        .clk_in     (clock_45MHZ),
        .clk_out    (o_clock_45MHz)
    );

endmodule
