`timescale 1ns / 1ps

module Serializer ( 
    input              i_clock,
    // I2S Interface
    input            i_codec_bit_clock,
    input             i_codec_lr_clock,
    output            o_codec_dac_data,
    // Parallel Data Input
    input     [23 : 0]  i_data_left,
    input     [23 : 0]  i_data_right,
    input              i_data_valid
);

    reg o_codec_dac_data_register;
    
    assign o_codec_dac_data = o_codec_dac_data_register;
   
   
    

    reg codec_bit_clock_meta;
    reg codec_bit_clock_stable;
    reg codec_bit_clock_delay;
    reg codec_bit_clock_rising;
    reg codec_bit_clock_falling;
    reg codec_lr_clock_meta;
    reg codec_lr_clock_stable;
    reg codec_lr_clock_delay;
    reg codec_lr_clock_rising;
    reg codec_lr_clock_falling;
    reg [4 : 0] bit_counter;
    reg signed [23 : 0] shift_register_left;
    reg signed [23 : 0] shift_register_right;

    // Edge detection for the bit and lr clocks
    always @(posedge i_clock) begin
        // Synchronize the audio signals to i_clock, delay the codec lr and bit clock signals
        codec_bit_clock_meta <= i_codec_bit_clock;
        codec_bit_clock_stable <= codec_bit_clock_meta;
        codec_bit_clock_delay <= codec_bit_clock_stable;
        codec_lr_clock_meta <= i_codec_lr_clock;
        codec_lr_clock_stable <= codec_lr_clock_meta;
        codec_lr_clock_delay <= codec_lr_clock_stable;
        // Detect bit clock rising/falling
        if ((codec_bit_clock_stable == 1'b1) & (codec_bit_clock_delay == 1'b0)) begin
            codec_bit_clock_rising <= 1'b1;
        end else begin
            codec_bit_clock_rising <= 1'b0;
        end
        if ((codec_bit_clock_stable == 1'b0) & (codec_bit_clock_delay == 1'b1)) begin
            codec_bit_clock_falling <= 1'b1;
        end else begin
            codec_bit_clock_falling <= 1'b0;
        end
        // Detect lr clock rising/falling
        if ((codec_lr_clock_stable == 1'b1) & (codec_lr_clock_delay == 1'b0)) begin
            codec_lr_clock_rising <= 1'b1;
        end else begin
            codec_lr_clock_rising <= 1'b0;
        end
        if ((codec_lr_clock_stable == 1'b0) & (codec_lr_clock_delay == 1'b1)) begin
            codec_lr_clock_falling <= 1'b1;
        end else begin
            codec_lr_clock_falling <= 1'b0;
        end
    end

    // Main FSM
     parameter IDLE = 0,
                WAIT_LR_CLOCK_FALLING = 1,
               LR_CLOCK_FALLING = 2,
               LEFT_DATA_SHIFT = 3,
               WAIT_LR_CLOCK_RISING= 4,
                LR_CLOCK_RISING = 5,
               RIGHT_DATA_SHIFT= 6;
                
      reg [2:0] fsm_state;       

    always @(posedge i_clock) begin
        case (fsm_state)
            IDLE : begin
                bit_counter <= 'b0;
                shift_register_left <= 'b0;
                shift_register_right <= 'b0;
                o_codec_dac_data_register <= 'b0;
                if (i_data_valid == 1'b1) begin
                    fsm_state <= WAIT_LR_CLOCK_FALLING;
                    shift_register_left <= i_data_left;
                    shift_register_right <= i_data_right;
                end
            end

            WAIT_LR_CLOCK_FALLING : begin
                if (codec_lr_clock_falling == 1'b1) begin
                    fsm_state <= LR_CLOCK_FALLING;
                end
            end

            LR_CLOCK_FALLING : begin
                if (codec_bit_clock_rising == 1'b1) begin
                    fsm_state <= LEFT_DATA_SHIFT;
                end
            end

            LEFT_DATA_SHIFT : begin
                o_codec_dac_data_register <= shift_register_left[23];
                if (codec_bit_clock_rising == 1'b1) begin
                    bit_counter <= bit_counter + 1'b1;
                    if (bit_counter != 0) begin
                        shift_register_left <= {shift_register_left[22:0], 1'b0};
                    end
                end
                if (bit_counter == 24) begin
                    bit_counter <= 'b0;
                    fsm_state <= WAIT_LR_CLOCK_RISING;
                end
            end

            WAIT_LR_CLOCK_RISING : begin
                if (codec_lr_clock_rising == 1'b1) begin
                    fsm_state <= LR_CLOCK_RISING;
                end
            end

            LR_CLOCK_RISING : begin
                if (codec_bit_clock_rising == 1'b1) begin
                    fsm_state <= RIGHT_DATA_SHIFT;
                end
            end

            RIGHT_DATA_SHIFT : begin
                o_codec_dac_data_register <= shift_register_right[23];
                if (codec_bit_clock_rising == 1'b1) begin
                    bit_counter <= bit_counter + 1;
                    if (bit_counter != 0) begin
                        shift_register_right <= {shift_register_right[22:0], 1'b0};
                    end
                end
                if (bit_counter == 24) begin
                    bit_counter <= 'b0;
                    fsm_state <= IDLE;
                end
            end

            default : begin
                fsm_state <= IDLE;
                o_codec_dac_data_register <= 1'b0;
            end
        endcase
    end

endmodule
