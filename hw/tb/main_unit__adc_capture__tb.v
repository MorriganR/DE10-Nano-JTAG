// iverilog -y ../main_unit -o adc_capture main_unit__adc_capture__tb.v
// vvp adc_capture
// gtkwave -f main_unit__adc_capture__tb.vcd
`timescale 1ns/1ps

module main_unit__adc_capture__tb;

parameter PERIOD = 6.25; // 160MHz -> 6.25ns, half - 3.125ns :(
parameter DO_CYCLES = 320 * 6;

wire adc_convst;
wire adc_sck;
wire adc_sdi;
wire adc_sdo;
reg clk;

wire [11:0] adc_ram_addr;
reg [31:0] adc_ram_rd_data = 32'h1234;
wire adc_ram_we;
wire [31:0] adc_ram_wr_data;

reg [31:0] adc_config_odd = 32'b100000; // CH0
reg [31:0] adc_config_even = 32'b110000; // CH1
reg adc_start = 1'b1;
reg adc_sequence_one = 1'b0;

adc_capture adc_capture (
  .adc_convst( adc_convst ),            //output          adc_convst,
  .adc_sck( adc_sck ),                  //output          adc_sck,
  .adc_sdi( adc_sdi ),                  //output          adc_sdi,
  .adc_sdo( adc_sdo ),                  //input           adc_sdo,

  .clk( clk ),                          //input           clk,
  .adc_ram_addr( adc_ram_addr ),        //output  [11:0]  adc_ram_addr,
  .adc_ram_rd_data( adc_ram_rd_data ),  //input   [31:0]  adc_ram_rd_data,
  .adc_ram_we( adc_ram_we ),            //output          adc_ram_we,
  .adc_ram_wr_data( adc_ram_wr_data ),  //output  [31:0]  adc_ram_wr_data,

  .adc_config_odd( adc_config_odd ),    //input   [31:0]  adc_config_odd,
  .adc_config_even( adc_config_even ),  //input   [31:0]  adc_config_even,
  .adc_start( adc_start ),              //input           adc_start,
  .adc_sequence_one( adc_sequence_one ) //input           adc_sequence_one
);

ltc2308 ltc2308 (
  .adc_convst( adc_convst ),//input adc_convst,
  .adc_sck( adc_sck ),//input adc_sck,
  .adc_sdi( adc_sdi ),//input adc_sdi,
  .adc_sdo( adc_sdo ),//output adc_sdo
  .dbg_in_adat_CH0( 12'h111 ),// input [11:0] ,
  .dbg_in_adat_CH1( 12'h222 ),// input [11:0] ,
  .dbg_in_adat_CH2( 12'h333 ),// input [11:0] ,
  .dbg_in_adat_CH3( 12'h444 ),// input [11:0] ,
  .dbg_in_adat_CH4( 12'h555 ),// input [11:0] ,
  .dbg_in_adat_CH5( 12'h666 ),// input [11:0] ,
  .dbg_in_adat_CH6( 12'h777 ),// input [11:0] ,
  .dbg_in_adat_CH7( 12'h888 )// input [11:0]
);

initial begin
  $dumpfile( "./tb/main_unit__adc_capture__tb.vcd" );
  $dumpvars;
end

initial begin
  clk = 0;
  forever #( PERIOD / 2 ) clk = ~clk;
end

initial begin
  adc_start = 1'b1;
  #( PERIOD * 13 );
  adc_start = 1'b0;
  repeat ( DO_CYCLES ) @( posedge clk );
  $finish(0);
end

endmodule
