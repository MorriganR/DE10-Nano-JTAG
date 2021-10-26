#!/bin/bash

# Change directory to script dir
cd $(dirname "${0:?}")
pwd
ls -la

# Generate RTL from soc_system.qsys
qsys-generate soc_system.qsys --synthesis=VERILOG --part=5CSEBA6U23I7 || { echo "Generate RTL from soc_system.qsys - ERROR" ; exit 1 ; }

# Compile RTL design
quartus_sh --flow compile DE10_NANO_JTAG || { echo "Compile RTL design - ERROR" ; exit 1 ; }

# Generate RBF file
cd output_files
quartus_cpf -c -o bitstream_compression=on DE10_NANO_JTAG.sof DE10_NANO_JTAG.rbf || { echo "Generate RBF file - ERROR" ; exit 1 ; }
