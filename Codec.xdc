set_property PACKAGE_PIN Y9 [get_ports i_clock]
set_property IOSTANDARD LVCMOS33 [get_ports i_clock]


set_property PACKAGE_PIN P16 [get_ports btnc]
set_property IOSTANDARD LVCMOS33 [get_ports btnc]


# SPI
set_property PACKAGE_PIN AB4 [get_ports o_spi_clock]
set_property IOSTANDARD LVCMOS33 [get_ports o_spi_clock]
set_property PACKAGE_PIN AB1 [get_ports o_spi_cs_n]
set_property IOSTANDARD LVCMOS33 [get_ports o_spi_cs_n]
set_property PACKAGE_PIN Y5 [get_ports o_spi_mosi]
set_property IOSTANDARD LVCMOS33 [get_ports o_spi_mosi]
set_property PACKAGE_PIN AB5 [get_ports i_spi_miso]
set_property IOSTANDARD LVCMOS33 [get_ports i_spi_miso]

# Audio Codec
set_property PACKAGE_PIN AA6 [get_ports i_codec_bit_clock]
set_property IOSTANDARD LVCMOS33 [get_ports i_codec_bit_clock]
set_property PACKAGE_PIN Y6 [get_ports i_codec_lr_clock]
set_property IOSTANDARD LVCMOS33 [get_ports i_codec_lr_clock]
set_property PACKAGE_PIN AA7 [get_ports i_codec_adc_data]
set_property IOSTANDARD LVCMOS33 [get_ports i_codec_adc_data]
set_property PACKAGE_PIN AB2 [get_ports o_codec_mclock]
set_property IOSTANDARD LVCMOS33 [get_ports o_codec_mclock]
set_property PACKAGE_PIN Y8 [get_ports o_codec_dac_data]
set_property IOSTANDARD LVCMOS33 [get_ports o_codec_dac_data]

