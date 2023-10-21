`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/10/18 20:24:23
// Design Name: 
// Module Name: Top_level
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


module Top_Level (
    // Clock
    input i_clock,
    input btnc,
    // SPI Interface
    output   o_spi_cs_n,
    output   o_spi_clock,
    output  o_spi_mosi,
    input    i_spi_miso,
    // Audio Codec
    input   i_codec_bit_clock,
    input    i_codec_lr_clock,
    input    i_codec_adc_data,
    output   o_codec_mclock,
    output   o_codec_dac_data
);

  

    parameter integer SPI_CLOCK_DIVIDER_WIDTH = 5;
    parameter integer SPI_DATA_WIDTH = 32;

    // Clock Generator
   wire clock_100MHz;
 
    clock_generator clock_generator_inst (
        .i_clock        (i_clock),
        .o_clock_100MHz (clock_100MHz),
        .o_clock_45MHz  (o_codec_mclock)
    );
   
   
   
    // SPI Controller
    spi_controller # (
        .SPI_CLOCK_DIVIDER_WIDTH    (SPI_CLOCK_DIVIDER_WIDTH),
        .SPI_DATA_WIDTH             (SPI_DATA_WIDTH)
    ) spi_controller_inst (
        // Clock, reset
        .i_clock        (clock_100MHz),
        .i_reset        (1'b0),
        // Control
        .i_enable       (btnc),
        // SPI interface
        .o_spi_cs_n     (o_spi_cs_n),
        .o_spi_clock    (o_spi_clock),
        .o_spi_mosi     (o_spi_mosi),
        .i_spi_miso     (i_spi_miso)
    );

    // Audio Processor
   Audio_Processor_Top Audio_Processor_inst (
        .i_clock            (clock_100MHz),
        // Audio Interface
        .i_codec_bit_clock  (i_codec_bit_clock),
        .i_codec_lr_clock   (i_codec_lr_clock),
        .i_codec_adc_data   (i_codec_adc_data),
        .o_codec_dac_data   (o_codec_dac_data)
           
    );

endmodule