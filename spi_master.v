module spi_master # (
    parameter integer SPI_CLOCK_DIVIDER_WIDTH   = 5,
    parameter integer SPI_DATA_WIDTH            = 32
) (
    // Clock, reset
    input    i_clock,
    input     i_reset,
    // Data, control and status interface
    input                                     i_enable,
    input                                     i_clock_polarity,
    input                                     i_clock_phase,
    input   [SPI_CLOCK_DIVIDER_WIDTH-1 : 0]   i_spi_clock_divider,
    input   [SPI_DATA_WIDTH-1 : 0]            i_data_in,
    output reg [SPI_DATA_WIDTH-1 : 0]            o_data_out,
    output                                     o_done,
    output  reg                                   o_busy,
    // SPI interface
    output    o_spi_cs_n,
    output    o_spi_clock,
    output     o_spi_mosi,
    input      i_spi_miso
);

  

    parameter    IDLE = 0,
                        PRE_DELAY = 1,
                        SETUP = 2,
                        TRANSMISSION = 3,
                        POST_DELAY = 4,
                        DONE = 5;
        reg [2:0]      fsm_state;
        
    reg [SPI_DATA_WIDTH-1 : 0] spi_data_counter;

    // Clock generation
    reg [SPI_CLOCK_DIVIDER_WIDTH-1 : 0] clock_counter;
    reg spi_clock;

    always@ (posedge i_clock) begin
        if (i_reset) begin
            spi_clock <= 1'b0;
            clock_counter <= 'b0;
        end else begin
            if ((fsm_state == TRANSMISSION) || (fsm_state == PRE_DELAY) || (fsm_state == POST_DELAY)) begin
                clock_counter <= clock_counter + 1;
                if (clock_counter == (i_spi_clock_divider)) begin
                    if (fsm_state == TRANSMISSION) begin
                        spi_clock <= ~ spi_clock;
                    end
                    clock_counter <= 'b0;
                end
            end else begin
                if (i_clock_polarity) begin
                    spi_clock <= 1'b1;
                end else begin
                    spi_clock <= 1'b0;
                end
                clock_counter <= 'b0;
            end
        end
    end
    assign o_spi_clock = spi_clock;

    // SPI clock edge detection
   reg spi_clock_falling;
   reg spi_clock_rising;
  reg  spi_clock_ff;

    always @(posedge i_clock) begin
        spi_clock_ff <= spi_clock;
        spi_clock_falling <= 1'b0;
        spi_clock_rising <= 1'b0;
        if ((spi_clock == 1'b1) && (spi_clock_ff == 1'b0)) begin   // Rising edge
            spi_clock_rising <= 1'b1;
        end
        if ((spi_clock == 1'b0) && (spi_clock_ff == 1'b1)) begin   // Falling edge
            spi_clock_falling <= 1'b1;
        end
    end

    // Main FSM
   reg  enable_delay1;
 reg    enable_delay2;
  reg  enable_rising;
  reg  spi_cs_n;
  reg   [SPI_DATA_WIDTH-1 : 0] data_out_shift;
  reg  [SPI_DATA_WIDTH-1 : 0] data_in_shift;
   reg  spi_mosi;
  reg   done;

    always @(posedge i_clock) begin
        if (i_reset) begin
            fsm_state <= IDLE;
            spi_data_counter <= 'b0;
            spi_cs_n <= 1'b1;
            data_out_shift <= 'b0;
            done <= 1'b0;
            spi_mosi <= 1'b0;
            data_out_shift <= 'b0;
            o_data_out <= 'b0;
            o_busy <= 'b0;
        end else begin
            // Detecting the rising edge of the 'i_enable' signal - BEGIN
            enable_delay1 <= i_enable;
            enable_delay2 <= enable_delay1;
            enable_rising <= 1'b0;
            if ((enable_delay2 == 1'b0) && (enable_delay1 == 1'b1)) begin
                enable_rising <= 1'b1;
            end
            // Detecting the rising edge of the 'i_enable' signal - END
            case (fsm_state)
                IDLE : begin
                    spi_cs_n <= 'b1;
                    o_busy <= 'b0;
                    if (enable_rising) begin
                        fsm_state <= PRE_DELAY;
                        data_out_shift <= i_data_in;
                        data_in_shift <= 'b0;
                        o_busy <= 'b1;
                    end
                end

                PRE_DELAY : begin
                    spi_cs_n <= 'b0;
                    if (clock_counter == (i_spi_clock_divider - 1)) begin
                        fsm_state <= SETUP;
                    end
                end

                SETUP : begin
                    if (~i_clock_phase) begin
                        spi_data_counter <= spi_data_counter + 1;
                        spi_mosi <= data_out_shift[SPI_DATA_WIDTH-1];
                        data_out_shift <= data_out_shift << 1;
                    end
                    fsm_state <= TRANSMISSION;
                end

                TRANSMISSION : begin
                    if (i_clock_phase && i_clock_polarity) begin
                        if (spi_clock_rising == 'b1) begin      // Capture MISO data
                            data_in_shift <= {data_in_shift[SPI_DATA_WIDTH-2:0], i_spi_miso};
                        end
                        if (spi_clock_falling == 'b1) begin
                            spi_data_counter <= spi_data_counter + 1;
                            spi_mosi <= data_out_shift[SPI_DATA_WIDTH-1];
                            data_out_shift <= data_out_shift << 1;
                        end
                        if ((spi_data_counter == SPI_DATA_WIDTH) && (clock_counter == (i_spi_clock_divider-1)) && (spi_clock)) begin
                            spi_data_counter <= 'b0;
                            fsm_state <= POST_DELAY;
                        end
                    end
                    if (i_clock_phase && (~i_clock_polarity)) begin
                        if (spi_clock_falling == 'b1) begin      // Capture MISO data
                            data_in_shift <= {data_in_shift[(SPI_DATA_WIDTH-1):0], i_spi_miso};
                        end
                        if (spi_clock_rising == 'b1) begin
                            spi_data_counter <= spi_data_counter + 1;
                            spi_mosi <= data_out_shift[SPI_DATA_WIDTH-1];
                            data_out_shift <= data_out_shift << 1;
                        end
                        if ((spi_data_counter == SPI_DATA_WIDTH) && (clock_counter == (i_spi_clock_divider-1)) && (~spi_clock)) begin
                            spi_data_counter <= 'b0;
                            fsm_state <= POST_DELAY;
                        end
                    end
                    if ((~i_clock_phase) && i_clock_polarity) begin
                        if (spi_clock_falling == 'b1) begin      // Capture MISO data
                            data_in_shift <= {data_in_shift[(SPI_DATA_WIDTH-2):0], i_spi_miso};
                        end
                        if (spi_clock_rising == 'b1) begin
                            spi_data_counter <= spi_data_counter + 1;
                            spi_mosi <= data_out_shift[SPI_DATA_WIDTH-1];
                            data_out_shift <= data_out_shift << 1;
                        end
                        if ((spi_data_counter == SPI_DATA_WIDTH) && (spi_clock_rising)) begin
                            spi_data_counter <= 'b0;
                            fsm_state <= POST_DELAY;
                        end
                    end
                    if ((~i_clock_phase) && (~i_clock_polarity)) begin
                        if (spi_clock_rising == 'b1) begin      // Capture MISO data
                            data_in_shift <= {data_in_shift[(SPI_DATA_WIDTH-1):0], i_spi_miso};
                        end
                        if (spi_clock_falling == 'b1) begin
                            spi_data_counter <= spi_data_counter + 1;
                            spi_mosi <= data_out_shift[SPI_DATA_WIDTH-1];
                            data_out_shift <= data_out_shift << 1;
                        end
                        if ((spi_data_counter == SPI_DATA_WIDTH) && (spi_clock_falling)) begin
                            spi_data_counter <= 'b0;
                            fsm_state <= POST_DELAY;
                        end
                    end
                end

                POST_DELAY : begin
                    if (clock_counter == (i_spi_clock_divider - 1)) begin
                        spi_cs_n <= 'b1;
                        fsm_state <= DONE;
                    end
                end

                DONE : begin
                    done <= 'b1;
                    o_data_out <= data_in_shift;
                    if (done) begin
                        done <= 'b0;
                        fsm_state <= IDLE;
                    end
                end

                default : begin
                    fsm_state <= IDLE;
                end
            endcase
        end
    end
    assign o_done = done;
    assign o_spi_cs_n = spi_cs_n;
    assign o_spi_mosi = spi_mosi;

endmodule


