 `timescale 1ns / 1ps


module Deserializer (
    input             i_clock,
    // I2S Interface
    input            i_codec_bit_clock,
    input            i_codec_lr_clock,
    input            i_codec_adc_data,
    // Parallel Data Output
    output   [23 : 0]  o_data_left,
    output   [23 : 0]  o_data_right,
    output            o_data_valid
);

  
   reg [23:0] o_data_left_register;
   reg [23:0] o_data_right_register;
   reg   o_data_valid_register;
   
   assign  o_data_left = o_data_left_register;
   assign o_data_right = o_data_right_register;
   assign o_data_valid = o_data_valid_register;
  
    
 
    reg codec_adc_data_meta;
    reg codec_adc_data_stable;
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
    reg data_valid;

    // Edge detection for the bit and lr clocks
    always @(posedge i_clock) begin
        // Synchronize the audio signals to i_clock, delay the codec lr and bit clock signals
        codec_adc_data_meta <= i_codec_adc_data;
        codec_adc_data_stable <= codec_adc_data_meta;
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
               LR_CLOCK_FALLING = 1,
               LEFT_DATA_SHIFT = 2,
               WAIT_LR_CLOCK_RISING = 3,
               LR_CLOCK_RISING = 4,
               RIGHT_DATA_SHIFT = 5,
               OUTPUT_GEN = 6;
                
                
      reg [2:0] fsm_state  =IDLE;          

    always @(posedge i_clock) begin
        case (fsm_state)
            IDLE : begin
                bit_counter <= 'b0;
                shift_register_left <= 'b0;
                shift_register_right <= 'b0;
                o_data_left_register <= 'b0;
                o_data_right_register <= 'b0;
                o_data_valid_register <= 1'b0;
                data_valid <= 1'b0;
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
                if (codec_bit_clock_rising == 1'b1) begin
                    bit_counter <= bit_counter + 1;
                    shift_register_left <= {shift_register_left[22:0], codec_adc_data_stable};
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
                if (codec_bit_clock_rising == 1'b1) begin
                    bit_counter <= bit_counter + 1;
                    shift_register_right <= {shift_register_right[22:0], codec_adc_data_stable};
                end
                if (bit_counter == 24) begin
                    bit_counter <= 'b0;
                    fsm_state <= OUTPUT_GEN;
                end
            end

            OUTPUT_GEN : begin
                o_data_left_register <= shift_register_left;
                o_data_right_register <= shift_register_right;
                o_data_valid_register <= 1'b1;
                data_valid <= 1'b1;
                fsm_state <= IDLE;
            end

            default : begin
                fsm_state <= IDLE;
                o_data_left_register <= 'b0;
                o_data_right_register <= 'b0;
                o_data_valid_register <= 1'b0;
                data_valid <= 1'b0;
            end
        endcase
    end

endmodule


