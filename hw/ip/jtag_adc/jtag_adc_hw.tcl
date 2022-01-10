#
# request TCL package from ACDS 16.1
#
package require -exact qsys 16.1


#
# module jtag_adc
#
set_module_property DESCRIPTION ""
set_module_property NAME jtag_adc
set_module_property VERSION 1.1
set_module_property INTERNAL false
set_module_property OPAQUE_ADDRESS_MAP true
set_module_property AUTHOR MorriganR
set_module_property DISPLAY_NAME jtag_adc
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE true
set_module_property REPORT_TO_TALKBACK false
set_module_property ALLOW_GREYBOX_GENERATION false


#
# file sets
#
add_fileset QUARTUS_SYNTH QUARTUS_SYNTH "" ""
set_fileset_property QUARTUS_SYNTH TOP_LEVEL jtag_adc
set_fileset_property QUARTUS_SYNTH ENABLE_RELATIVE_INCLUDE_PATHS false
add_fileset_file jtag_adc.v VERILOG PATH jtag_adc.v TOP_LEVEL_FILE


#
# parameters
#


#
# display items
#


#
# connection point clock
#
add_interface clock clock end
set_interface_property clock clockRate 0
set_interface_property clock ENABLED true
set_interface_property clock EXPORT_OF ""
set_interface_property clock PORT_NAME_MAP ""
set_interface_property clock CMSIS_SVD_VARIABLES ""
set_interface_property clock SVD_ADDRESS_GROUP ""

add_interface_port clock clk clk Input 1


#
# connection point reset
#
add_interface reset reset end
set_interface_property reset associatedClock clock
set_interface_property reset synchronousEdges DEASSERT
set_interface_property reset ENABLED true
set_interface_property reset EXPORT_OF ""
set_interface_property reset PORT_NAME_MAP ""
set_interface_property reset CMSIS_SVD_VARIABLES ""
set_interface_property reset SVD_ADDRESS_GROUP ""

add_interface_port reset reset reset Input 1


#
# connection point s1
#
add_interface s1 avalon end
set_interface_property s1 addressUnits WORDS
set_interface_property s1 associatedClock clock
set_interface_property s1 associatedReset reset
set_interface_property s1 bitsPerSymbol 8
set_interface_property s1 bridgedAddressOffset 0
set_interface_property s1 burstOnBurstBoundariesOnly false
set_interface_property s1 burstcountUnits WORDS
set_interface_property s1 explicitAddressSpan 0
set_interface_property s1 holdTime 1
set_interface_property s1 linewrapBursts false
set_interface_property s1 maximumPendingReadTransactions 0
set_interface_property s1 maximumPendingWriteTransactions 0
set_interface_property s1 readLatency 0
set_interface_property s1 readWaitTime 1
set_interface_property s1 setupTime 0
set_interface_property s1 timingUnits Cycles
#set_interface_property s1 writeWaitStates 2
set_interface_property s1 writeWaitTime 0
set_interface_property s1 ENABLED true
set_interface_property s1 EXPORT_OF ""
set_interface_property s1 PORT_NAME_MAP ""
set_interface_property s1 CMSIS_SVD_VARIABLES ""
set_interface_property s1 SVD_ADDRESS_GROUP ""

add_interface_port s1 address address Input 12
add_interface_port s1 chipselect chipselect Input 1
add_interface_port s1 readdata readdata Output 32
add_interface_port s1 read read Input 1
add_interface_port s1 writedata writedata Input 32
add_interface_port s1 write write Input 1
add_interface_port s1 byteenable byteenable Input 4
set_interface_assignment s1 embeddedsw.configuration.isFlash 0
set_interface_assignment s1 embeddedsw.configuration.isMemoryDevice 0
set_interface_assignment s1 embeddedsw.configuration.isNonVolatileStorage 0
set_interface_assignment s1 embeddedsw.configuration.isPrintableDevice 0

#
# connection point extram
#
add_interface extram conduit end
set_interface_property extram associatedClock clock
set_interface_property extram associatedReset reset
set_interface_property extram ENABLED true
set_interface_property extram EXPORT_OF jtag_adc.extram
set_interface_property extram PORT_NAME_MAP ""
set_interface_property extram CMSIS_SVD_VARIABLES ""
set_interface_property extram SVD_ADDRESS_GROUP ""

add_interface_port extram cpu_clk cpu_clk Output 1
add_interface_port extram cpu_reset cpu_reset Output 1
add_interface_port extram cpu_address cpu_address Output 12
add_interface_port extram cpu_chipselect cpu_chipselect Output 1
add_interface_port extram cpu_readdata cpu_readdata Input 32
add_interface_port extram cpu_read cpu_read Output 1
add_interface_port extram cpu_writedata cpu_writedata Output 32
add_interface_port extram cpu_write cpu_write Output 1
add_interface_port extram cpu_byteenable cpu_byteenable Output 4
