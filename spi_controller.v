`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/10/18 18:00:53
// Design Name: 
// Module Name: spi_controller
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


module spi_controller # (
    parameter integer SPI_CLOCK_DIVIDER_WIDTH = 5,
    parameter integer SPI_DATA_WIDTH          = 32
) (
    // Clock, reset
    input    i_clock,
    input    i_reset,
    // Control
    input    i_enable,
    // SPI Interface
    output   o_spi_cs_n,
    output   o_spi_clock,
    output   o_spi_mosi,
    input    i_spi_miso
);

   
    // SPI Driver <-> SPI Core connecting signals
    wire                           spi_enable;
    wire [SPI_DATA_WIDTH-1 : 0]    spi_data_in;
    wire [SPI_DATA_WIDTH-1 : 0]    spi_data_out;
    wire                           spi_done;
    wire                           spi_busy;

    // SPI Driver
    spi_driver # (
        .SPI_DATA_WIDTH (SPI_DATA_WIDTH) 
    ) spi_driver_inst (
        // Clock, reset
        .i_clock    (i_clock),
        .i_reset    (1'b0),
        // Control
        .i_enable   (i_enable),
        // SPI Master Control
        .i_data     (spi_data_out),
        .i_done     (spi_done),
        .i_busy     (spi_busy),
        .o_enable   (spi_enable),
        .o_data     (spi_data_in)
    );

    // SPI Core
    spi_master # (
        .SPI_CLOCK_DIVIDER_WIDTH    (SPI_CLOCK_DIVIDER_WIDTH),
        .SPI_DATA_WIDTH             (SPI_DATA_WIDTH)
    ) spi_master_inst (
        // Clock, reset
        .i_clock                (i_clock),
        .i_reset                (1'b0),
        // Data, control and status interface
        .i_enable               (spi_enable),
        .i_clock_polarity       (1'b0),
        .i_clock_phase          (1'b0),
        .i_spi_clock_divider    (5'b10000),
        .i_data_in              (spi_data_in),
        .o_data_out             (spi_data_out),
        .o_done                 (spi_done),
        .o_busy                 (spi_busy),
        // SPI interface
        .o_spi_cs_n             (o_spi_cs_n),
        .o_spi_clock            (o_spi_clock),
        .o_spi_mosi             (o_spi_mosi),
        .i_spi_miso             (i_spi_miso)
    );

endmodule