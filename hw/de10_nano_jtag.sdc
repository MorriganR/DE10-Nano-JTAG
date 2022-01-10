#**************************************************************
# This .sdc file is created by Terasic Tool.
# Users are recommended to modify this file to match users logic.
#**************************************************************

#**************************************************************
# Create Clock
#**************************************************************
create_clock -period "50.0 MHz" [get_ports FPGA_CLK1_50]
create_clock -period "50.0 MHz" [get_ports FPGA_CLK2_50]
create_clock -period "50.0 MHz" [get_ports FPGA_CLK3_50]

# for the HPS ports
create_clock -period "1 MHz" [get_ports HPS_I2C0_SCLK]
create_clock -period "1 MHz" [get_ports HPS_I2C1_SCLK]
create_clock -period "48 MHz" [get_ports HPS_USB_CLKOUT]

# for enhancing USB BlasterII to be reliable, 25MHz
create_clock -name {altera_reserved_tck} -period 40 {altera_reserved_tck}
set_input_delay -clock altera_reserved_tck -clock_fall 3 [get_ports altera_reserved_tdi]
set_input_delay -clock altera_reserved_tck -clock_fall 3 [get_ports altera_reserved_tms]
set_output_delay -clock altera_reserved_tck 3 [get_ports altera_reserved_tdo]

#**************************************************************
# Create Generated Clock
#**************************************************************
derive_pll_clocks

# JTAG
# tck
set_false_path -from * -to [get_ports {GPIO_1[4]}]
# tms
set_false_path -from * -to [get_ports {GPIO_1[5]}]
# tdi
set_false_path -from * -to [get_ports {GPIO_1[7]}]
# tdo
set_false_path -from [get_ports {GPIO_1[8]}] -to *

set_false_path -from [get_registers "main_unit:mu|main_ram:main_ram|*_delay[*]"] -to *
set_false_path -from [get_registers "main_unit:mu|main_ram:main_ram|tck_width[*]"] -to *
set_false_path -from [get_registers "main_unit:mu|main_ram:main_ram|adc_config_*"] -to *

set_false_path -from {main_unit:mu|play_jtag_vector:play_jtag|vector_data[*]} -to {main_unit:mu|jtag_signal_out:jtag_out|vector_data_reg[*]}
set_false_path -from {main_unit:mu|jtag_signal_out:jtag_out|get_next_data} -to {main_unit:mu|play_jtag_vector:play_jtag|get_next_data_reg[0]}

#**************************************************************
# Set Clock Latency
#**************************************************************



#**************************************************************
# Set Clock Uncertainty
#**************************************************************
derive_clock_uncertainty



#**************************************************************
# Set Input Delay
#**************************************************************



#**************************************************************
# Set Output Delay
#**************************************************************



#**************************************************************
# Set Clock Groups
#**************************************************************



#**************************************************************
# Set False Path
#**************************************************************
set_false_path -from * -to [get_ports LED[*]]
set_false_path -from [get_ports KEY[*]] -to *
set_false_path -from [get_ports SW[*]] -to *

set_false_path -from * -to [get_ports ADC_*]
set_false_path -from [get_ports ADC_*] -to *

#**************************************************************
# Set Multicycle Path
#**************************************************************



#**************************************************************
# Set Maximum Delay
#**************************************************************



#**************************************************************
# Set Minimum Delay
#**************************************************************



#**************************************************************
# Set Input Transition
#**************************************************************



#**************************************************************
# Set Load
#**************************************************************



