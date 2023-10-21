`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/10/08 13:12:26
// Design Name: 
// Module Name: Audio_Processor_Top
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


module Audio_Processor_Top (
    input            i_clock,
    // Audio Interface
    input           i_codec_bit_clock,
    input              i_codec_lr_clock,
    input              i_codec_adc_data,
    output             o_codec_dac_data
   
);

  
    // Audio Deserializer
    wire [23 : 0]  deser_data_left;
    wire [23 : 0]  deser_data_right;
    wire           deser_data_valid;
    
    
    Deserializer audio_deserializer_inst (
        .i_clock            (i_clock),
        // I2S Interface
        .i_codec_bit_clock  (i_codec_bit_clock),
        .i_codec_lr_clock   (i_codec_lr_clock),
        .i_codec_adc_data   (i_codec_adc_data),
        // Parallel Data Output
        .o_data_left        (deser_data_left),
        .o_data_right       (deser_data_right),
        .o_data_valid       (deser_data_valid)
    );
   
    // Fixed-point FIR Filter
    wire [23 : 0]  fir_filter_fixed_data_left;
    wire [23 : 0]  fir_filter_fixed_data_right;
    wire           fir_filter_fixed_data_valid;
//    fir_filter_fixed fir_filter_fixed_inst (
//        .i_clock        (i_clock),
//        // Audio Input
//        .i_data_valid   (deser_data_valid),
//        .i_data_left    (deser_data_left),
//        .i_data_right   (deser_data_right),
//        // Audio Output
//        .o_data_valid   (fir_filter_fixed_data_valid),
//        .o_data_left    (fir_filter_fixed_data_left),
//        .o_data_right   (fir_filter_fixed_data_right)
//    );

  
 

    // Audio Serializer
   
     assign    fix_filter_fixed_data_left = deser_data_left;
     assign    fir_filter_fixed_data_right = deser_data_right;
     assign    fir_filter_fixed_data_valid = deser_data_valid;
    
    Serializer audio_serializer_inst (
        .i_clock            (i_clock),
        // I2S Interface
        .i_codec_bit_clock  (i_codec_bit_clock),
        .i_codec_lr_clock   (i_codec_lr_clock),
        .o_codec_dac_data   (o_codec_dac_data),
        // Parallel Data Input
        .i_data_left        (fir_filter_fixed_data_left),
        .i_data_right       (fir_filter_fixed_data_right),
        .i_data_valid       (fir_filter_fixed_data_valid)
    );

endmodule
