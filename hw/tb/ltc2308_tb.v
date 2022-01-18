`timescale 1ns/1ps

module ltc2308_tb;

reg adc_convst = 1'b0;
reg adc_sck = 1'b0;
reg adc_sdi = 1'bz;
wire adc_sdo;
reg [11:0] dbg_in_adat_CH0 = 12'hFFF;
reg [11:0] dbg_in_adat_CH1 = 12'hEEE;
reg [11:0] dbg_in_adat_CH2 = 12'hDDD;
reg [11:0] dbg_in_adat_CH3 = 12'hCCC;
reg [11:0] dbg_in_adat_CH4 = 12'hBBB;
reg [11:0] dbg_in_adat_CH5 = 12'hAAA;
reg [11:0] dbg_in_adat_CH6 = 12'h999;
reg [11:0] dbg_in_adat_CH7 = 12'h888;

reg [11:0] get_adc_sd0;

ltc2308 ltc2308 (
  .adc_convst( adc_convst ),//input adc_convst,
  .adc_sck( adc_sck ),//input adc_sck,
  .adc_sdi( adc_sdi ),//input adc_sdi,
  .adc_sdo( adc_sdo ),//output adc_sdo

  .dbg_in_adat_CH0( dbg_in_adat_CH0 ),
  .dbg_in_adat_CH1( dbg_in_adat_CH1 ),
  .dbg_in_adat_CH2( dbg_in_adat_CH2 ),
  .dbg_in_adat_CH3( dbg_in_adat_CH3 ),
  .dbg_in_adat_CH4( dbg_in_adat_CH4 ),
  .dbg_in_adat_CH5( dbg_in_adat_CH5 ),
  .dbg_in_adat_CH6( dbg_in_adat_CH6 ),
  .dbg_in_adat_CH7( dbg_in_adat_CH7 )
);
`ifdef tWCLK_MIN
  defparam ltc2308.tWCLK_MIN = `tWCLK_MIN;
`endif
`ifdef tWHCONV_MIN
  defparam ltc2308.tWHCONV_MIN = `tWHCONV_MIN;
`endif
`ifdef tWHCONV_MAX
  defparam ltc2308.tWHCONV_MAX = `tWHCONV_MAX;
`endif

`ifdef get_vcd
  initial begin
    $dumpfile( "./tb/ltc2308_tb.vcd" );
    $dumpvars;
  end
`endif

reg [5:0] put_adc_sdi = 6'b1000_00;
// generate: adc_convst
time adc_conv_start_time = 0;
event adc_conv_start;
integer i;
initial begin
  adc_convst <= 1'b0;
  #100;
  for ( i = 0; i < 30; i = i + 1 ) begin
    adc_convst <= 1'b1;
    adc_conv_start_time <= $time;
    -> adc_conv_start;
    #30 adc_convst <= 1'b0;
    put_adc_sdi <= {1'b1, i[2:0], 2'b00};
    #( 2_000 - 30 );
  end
  $finish(0);
end

// generate: adc_sck, adc_sdi; collect: adc_sdo
parameter SCK_POS_TIME = 15;
parameter SCK_NEG_TIME = 10;
integer j;
always @( adc_conv_start ) begin
  #( 1_600 - SCK_NEG_TIME );
  for ( j = 0; j < 12; j = j + 1 ) begin
    if ( j < 6 )
      adc_sdi <= put_adc_sdi[ 5 - j ];
    else
      adc_sdi <= 1'bz;
    #SCK_NEG_TIME;
    adc_sck <= 1'b1;
    #SCK_POS_TIME;
    get_adc_sd0[ 11 - j ] <= adc_sdo;
    adc_sck <= 1'b0;
  end
end


endmodule