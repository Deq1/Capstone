`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/10/18 18:03:52
// Design Name: 
// Module Name: spi_driver
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


module spi_driver # (
    parameter integer SPI_DATA_WIDTH = 8
) (
    // Clock, reset
    input   i_clock,
    input   i_reset,
    // Control
    input   i_enable,
    // SPI Master Control
    input   [SPI_DATA_WIDTH-1 : 0]    i_data,
    input                             i_done,
    input                              i_busy,
    output     reg                        o_enable,
    output  reg [SPI_DATA_WIDTH-1 : 0]    o_data
);



    // Edge detection for the 'i_enable' input
reg  enable_delay1;
reg   enable_delay2;
 reg  enable_rising;

    always @(posedge i_clock) begin : enable_edge_detection
        enable_delay1 <= i_enable;
        enable_delay2 <= enable_delay1;
        enable_rising <= 1'b0;
        if ((enable_delay2 == 1'b0) && (enable_delay1 == 1'b1)) begin
            enable_rising <= 1'b1;
        end
    end

    // Main FSM - Begin
   parameter           IDLE = 0,
                        DUMMY_WRITE_1 = 1,
                        DUMMY_WRITE_2 = 2,
                        DUMMY_WRITE_3 = 3,
                        WRITE_CLOCK_CONTROL_REG = 4,
                        WRITE_I2S_MASTER_MODE = 5,
                        LEFT_MIXER_ENABLE = 6,
                        LEFT_0_DB = 7,
                        RIGHT_MIXER_ENABLE = 8,
                        RIGHT_0_DB = 9,
                        PLAYBACK_LEFT_MIXER_UNMUTE_ENABLE = 10,
                       PLAYBACK_RIGHT_MIXER_UNMUTE_ENABLE = 11 ,
                        HEADPHONE_OUTPUT_LEFT_ENABLE = 12,
                        HEADPHONE_OUTPUT_RIGHT_ENABLE = 13,
                        PLAYBACK_RIGHT_MIXER_LINE_OUT_ENABLE = 14,
                        PLAYBACK_LEFT_MIXER_LINE_OUT_ENABLE = 15,
                        LINE_OUT_LEFT_ENABLE = 16,
                        LINE_OUT_RIGHT_ENABLE = 17,
                        ADCS_ENABLE = 18,
                        CHANNELS_PLAYBACK_ENABLE = 19,
                        DACS_ENABLE = 20,
                        SERIAL_INPUT_L0_R0_TO_DAC_LR = 21,
                        SERIAL_OUTPUT_ADC_LR_TO_SERIAL_OUTPUT_L0_R0 = 22,
                        CLOCK_ALL_ENGINES_ENABLE = 23,
                        CLOCK_GENERATORS_ENABLE = 24;
                        
      reg [4:0]  fsm_state = IDLE;       
      
      
      

    always @(posedge i_clock) begin
        case (fsm_state)
            IDLE : begin
                o_enable <= 1'b0;
                o_data <= 'b0;
                if (enable_rising == 1'b1) begin
                    fsm_state <= DUMMY_WRITE_1;
                end
            end

            DUMMY_WRITE_1 : begin
                o_enable <= 1'b1;
                if (i_done == 1'b1) begin
                    o_enable <= 1'b0;
                    fsm_state <= DUMMY_WRITE_2;
                end
            end

            DUMMY_WRITE_2 : begin
                o_enable <= 1'b1;
                if (i_done == 1'b1) begin
                    o_enable <= 1'b0;
                    fsm_state <= DUMMY_WRITE_3;
                end
            end

            DUMMY_WRITE_3 : begin
                o_enable <= 1'b1;
                if (i_done == 1'b1) begin
                    o_enable <= 1'b0;
                    fsm_state <= WRITE_CLOCK_CONTROL_REG;
                end
            end

            WRITE_CLOCK_CONTROL_REG : begin
                o_enable <= 1'b1;
                o_data <= 32'h00400007;
                if (i_done == 1'b1) begin
                    o_enable <= 1'b0;
                    fsm_state <= WRITE_I2S_MASTER_MODE;
                end
            end

            WRITE_I2S_MASTER_MODE : begin
                o_enable <= 1'b1;
                o_data <= 32'h00401501;
                if (i_done == 1'b1) begin
                    o_enable <= 1'b0;
                    fsm_state <= LEFT_MIXER_ENABLE;
                end
            end

            LEFT_MIXER_ENABLE : begin
                o_enable <= 1'b1;
                o_data <= 32'h00400A01;
                if (i_done == 1'b1) begin
                    o_enable <= 1'b0;
                    fsm_state <= LEFT_0_DB;
                end
            end

            LEFT_0_DB : begin
                o_enable <= 1'b1;
                o_data <= 32'h00400B05;
                if (i_done == 1'b1) begin
                    o_enable <= 1'b0;
                    fsm_state <= RIGHT_MIXER_ENABLE;
                end
            end

            RIGHT_MIXER_ENABLE : begin
                o_enable <= 1'b1;
                o_data <= 32'h00400C01;
                if (i_done == 1'b1) begin
                    o_enable <= 1'b0;
                    fsm_state <= RIGHT_0_DB;
                end
            end

            RIGHT_0_DB : begin
                o_enable <= 1'b1;
                o_data <= 32'h00400D05;
                if (i_done == 1'b1) begin
                    o_enable <= 1'b0;
                    fsm_state <= PLAYBACK_LEFT_MIXER_UNMUTE_ENABLE;
                end
            end

            PLAYBACK_LEFT_MIXER_UNMUTE_ENABLE : begin
                o_enable <= 1'b1;
                o_data <= 32'h00401C21;
                if (i_done == 1'b1) begin
                    o_enable <= 1'b0;
                    fsm_state <= PLAYBACK_RIGHT_MIXER_UNMUTE_ENABLE;
                end
            end

            PLAYBACK_RIGHT_MIXER_UNMUTE_ENABLE : begin
                o_enable <= 1'b1;
                o_data <= 32'h00401E41;
                if (i_done == 1'b1) begin
                    o_enable <= 1'b0;
                    fsm_state <= HEADPHONE_OUTPUT_LEFT_ENABLE;
                end
            end

            HEADPHONE_OUTPUT_LEFT_ENABLE : begin
                o_enable <= 1'b1;
                o_data <= 32'h004023E6;
                if (i_done == 1'b1) begin
                    o_enable <= 1'b0;
                    fsm_state <= HEADPHONE_OUTPUT_RIGHT_ENABLE;
                end
            end

            HEADPHONE_OUTPUT_RIGHT_ENABLE : begin
                o_enable <= 1'b1;
                o_data <= 32'h004024E6;
                if (i_done == 1'b1) begin
                    o_enable <= 1'b0;
                    fsm_state <= PLAYBACK_RIGHT_MIXER_LINE_OUT_ENABLE;
                end
            end

            PLAYBACK_RIGHT_MIXER_LINE_OUT_ENABLE : begin
                o_enable <= 1'b1;
                o_data <= 32'h00402109;
                if (i_done == 1'b1) begin
                    o_enable <= 1'b0;
                    fsm_state <= PLAYBACK_LEFT_MIXER_LINE_OUT_ENABLE;
                end
            end

            PLAYBACK_LEFT_MIXER_LINE_OUT_ENABLE : begin
                o_enable <= 1'b1;
                o_data <= 32'h00402003;
                if (i_done == 1'b1) begin
                    o_enable <= 1'b0;
                    fsm_state <= LINE_OUT_LEFT_ENABLE;
                end
            end

            LINE_OUT_LEFT_ENABLE : begin
                o_enable <= 1'b1;
                o_data <= 32'h004025E6;
                if (i_done == 1'b1) begin
                    o_enable <= 1'b0;
                    fsm_state <= LINE_OUT_RIGHT_ENABLE;
                end
            end

            LINE_OUT_RIGHT_ENABLE : begin
                o_enable <= 1'b1;
                o_data <= 32'h004026E6;
                if (i_done == 1'b1) begin
                    o_enable <= 1'b0;
                    fsm_state <= ADCS_ENABLE;
                end
            end

            ADCS_ENABLE : begin
                o_enable <= 1'b1;
                o_data <= 32'h00401903;
                if (i_done == 1'b1) begin
                    o_enable <= 1'b0;
                    fsm_state <= CHANNELS_PLAYBACK_ENABLE;
                end
            end

            CHANNELS_PLAYBACK_ENABLE : begin
                o_enable <= 1'b1;
                o_data <= 32'h00402903;
                if (i_done == 1'b1) begin
                    o_enable <= 1'b0;
                    fsm_state <= DACS_ENABLE;
                end
            end

            DACS_ENABLE : begin
                o_enable <= 1'b1;
                o_data <= 32'h00402A03;
                if (i_done == 1'b1) begin
                    o_enable <= 1'b0;
                    fsm_state <= SERIAL_INPUT_L0_R0_TO_DAC_LR;
                end
            end

            SERIAL_INPUT_L0_R0_TO_DAC_LR : begin
                o_enable <= 1'b1;
                o_data <= 32'h0040F201;
                if (i_done == 1'b1) begin
                    o_enable <= 1'b0;
                    fsm_state <= SERIAL_OUTPUT_ADC_LR_TO_SERIAL_OUTPUT_L0_R0;
                end
            end

            SERIAL_OUTPUT_ADC_LR_TO_SERIAL_OUTPUT_L0_R0 : begin
                o_enable <= 1'b1;
                o_data <= 32'h0040F301;
                if (i_done == 1'b1) begin
                    o_enable <= 1'b0;
                    fsm_state <= CLOCK_ALL_ENGINES_ENABLE;
                end
            end

            CLOCK_ALL_ENGINES_ENABLE : begin
                o_enable <= 1'b1;
                o_data <= 32'h0040F97F;
                if (i_done == 1'b1) begin
                    o_enable <= 1'b0;
                    fsm_state <= CLOCK_GENERATORS_ENABLE;
                end
            end

            CLOCK_GENERATORS_ENABLE : begin
                o_enable <= 1'b1;
                o_data <= 32'h0040FA03;
                if (i_done == 1'b1) begin
                    o_enable <= 1'b0;
                    fsm_state <= IDLE;
                end
            end

            default : begin
                fsm_state <= IDLE;
            end
        endcase
    end

endmodule
