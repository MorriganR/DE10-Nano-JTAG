// jtag_adc.v

// `timescale 1 ps / 1 ps
module jtag_adc #(
  parameter AUTO_CLOCK_CLOCK_RATE = "-1"
)(
  input  wire         clk,            // clock.clk
  input  wire         reset,          // reset.reset
  input  wire [11:0]  address,        //    s1.address
  input  wire         chipselect,     //      .chipselect
  output wire [31:0]  readdata,       //      .readdata
  input  wire         read,           //      .read
  input  wire [31:0]  writedata,      //      .writedata
  input  wire         write,          //      .write
  input  wire  [3:0]  byteenable,     //      .byteenable

  output wire         cpu_clk,            //  extram.cpu_clk
  output wire         cpu_reset,          //        .cpu_reset
  output wire [11:0]  cpu_address,        //        .cpu_address
  output wire         cpu_chipselect,     //        .cpu_chipselect
  input  wire [31:0]  cpu_readdata,       //        .cpu_readdata
  output wire         cpu_read,           //        .cpu_read
  output wire [31:0]  cpu_writedata,      //        .cpu_writedata
  output wire         cpu_write,          //        .cpu_write
  output wire  [3:0]  cpu_byteenable     //        .cpu_byteenable

);

  assign cpu_clk = clk;
  assign cpu_reset = reset;
  assign cpu_address = address;
  assign cpu_chipselect = chipselect;
  assign readdata = cpu_readdata;
  assign cpu_read = read;
  assign cpu_writedata = writedata;
  assign cpu_write = write;
  assign cpu_byteenable = byteenable;

endmodule
