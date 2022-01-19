// TODO DRAFT
`timescale 1ps/1ps

module ltc2308 #(
// SYMBOL     | PARAMETER                             | MIN TYP MAX | UNITS
// fSMPL(MAX) | Maximum Sampling Frequency            |         500 | kHz
// fSCK       | Shift Clock Frequency                 |         40  | MHz
parameter tWCLK_MIN = 25_000,
// tWHCONV    | CONVST High Time                      | 20          | ns
parameter tWHCONV_MIN = 20_000,
parameter tWHCONV_MAX = 40_000,
// tHD        | Hold Time SDI After SCK↑              | 2.5         | ns
// tSUDI      | Setup Time SDI Valid Before SCK↑      | 0           | ns
// tWHCLK     | SCK High Time                         | 10          | ns
parameter tWHCLK_MIN = 10_000,
// tWLCLK     | SCK Low Time                          | 10          | ns
parameter tWLCLK_MIN = 10_000,
// tWLCONVST  | CONVST Low Time During Data Transfer  | 410         | ns
// tHCONVST   | Hold Time CONVST Low After Last SCK↓  | 20          | ns
// tCONV      | Conversion Time                       |     1.3 1.6 | µs
parameter tCONV_TYP = 1_300_000,
parameter tCONV_MAX = 1_600_000,
// tACQ       | Acquisition Time 7th SCK↑ to CONVST↑  | 240         | ns
// tREFWAKE   | REFCOMP Wakeup Time                   |    200      | ms
// tdDO       | SDO Data Valid After SCK↓             |    10.8 12.5| ns
parameter tdDO_TYP = 10_800,
parameter tdDO_MAX = 12_500,
// thDO       | SDO Hold Time After SCK↓              | 4           | ns
parameter thDO_MIN = 4_000,
// ten        | SDO Valid After CONVST↓               |     11 15   | ns
// tdis       | Bus Relinquish Time                   |     11 15   | ns
// tr         | SDO Rise Time                         |     4       | ns
// tf         | SDO Fall Time                         |     4       | ns
// tCYC       | Total Cycle Time                      |     2       | µs
parameter tCYC = 2_000_000
/*
For best performance, ensure that CONVST returns low
within 40ns after the conversion starts (i.e., before the first
bit decision) or after the conversion ends (tCONV).
(*) ATTENTION "LTC2308 Timing with a Long CONVST Pulse" - not supported in testbench
*/
)(
  input adc_convst,
  input adc_sck,
  input adc_sdi,
  output adc_sdo,

  input [11:0] dbg_in_adat_CH0,
  input [11:0] dbg_in_adat_CH1,
  input [11:0] dbg_in_adat_CH2,
  input [11:0] dbg_in_adat_CH3,
  input [11:0] dbg_in_adat_CH4,
  input [11:0] dbg_in_adat_CH5,
  input [11:0] dbg_in_adat_CH6,
  input [11:0] dbg_in_adat_CH7
);

reg adc_sdo = 1'bz;

initial
  $timeformat(-9, 3, "ns", 0);

// adc_convst
time adc_convst_tpos = 0;
time adc_convst_tneg = 0;
event adc_convst_p;
event adc_convst_n;
always @( posedge adc_convst )
  if ( $time != 0 ) begin
    adc_convst_tpos <= $time;
    -> adc_convst_p;
  end
always @( negedge adc_convst )
  if ( $time != 0 ) begin
    adc_convst_tneg <= $time;
    -> adc_convst_n;
  end

// adc_sck
time adc_sck_tpos = 0;
time adc_sck_tneg = 0;
event adc_sck_p;
event adc_sck_n;
always @( posedge adc_sck )
  if ( $time != 0 ) begin
    adc_sck_tpos <= $time;
    -> adc_sck_p;
  end
always @( negedge adc_sck )
  if ( $time != 0 ) begin
    adc_sck_tneg <= $time;
    -> adc_sck_n;
  end

// adc_sdi
time adc_sdi_tpos = 0;
time adc_sdi_tneg = 0;
event adc_sdi_p;
event adc_sdi_n;
always @( posedge adc_sdi )
  if ( $time != 0 ) begin
    adc_sdi_tpos <= $time;
    -> adc_sdi_p;
  end
always @( negedge adc_sdi )
  if ( $time != 0 ) begin
    adc_sdi_tneg <= $time;
    -> adc_sdi_n;
  end

// checking tWHCONV
always @( adc_convst_n ) begin
  if ( ( $time != 0 ) && ( ( $time - adc_convst_tpos < tWHCONV_MIN ) || ( $time - adc_convst_tpos > tWHCONV_MAX ) ) ) begin
    $display( "time = %t, tWHCONV = %t (should be more than %t & less then %t)",
        $time, $time - adc_convst_tpos, tWHCONV_MIN, tWHCONV_MAX );
    $fatal(2);
  end
end
// tCYC (adc_convst: pos to pos time)
always @( adc_convst_p ) begin
  if ( ( adc_convst_tpos != 0 ) && ( $time - adc_convst_tpos < tCYC ) ) begin
    $display( "time = %t, tCYC = %t (should be more than %t)",
        $time, $time - adc_convst_tpos, tCYC );
    $fatal(2);
  end
end
// checking tWLCLK, tWCLK (adc_sck: pos to pos time)
always @( adc_sck_p ) begin
  if ( ( adc_sck_tneg != 0 ) && ( adc_sck_tpos != 0 ) &&
        ( ( $time - adc_sck_tneg < tWLCLK_MIN ) || ( $time - adc_sck_tpos < tWCLK_MIN ) ) ) begin
    $display( "time = %t, tWLCLK = %t (should be more than %t), tWCLK = %t (should be more than %t)",
        $time, $time - adc_sck_tneg, tWLCLK_MIN, $time - adc_sck_tpos, tWCLK_MIN );
    $fatal(2);
  end
end
// checking tWHCLK, tWCLK (adc_sck: neg to neg time)
always @( adc_sck_n ) begin
  if ( ( adc_sck_tneg != 0 ) && ( adc_sck_tpos != 0 ) &&
        ( ( $time - adc_sck_tpos < tWHCLK_MIN ) || ( $time - adc_sck_tneg < tWCLK_MIN ) ) ) begin
    $display( "time = %t, tWHCLK = %t (should be more than %t), tWCLK = %t (should be more than %t)",
        $time, $time - adc_sck_tpos, tWHCLK_MIN, $time - adc_sck_tneg, tWCLK_MIN );
    $fatal(2);
  end
end
// checking tCONV_MAX
always @( adc_sck_p or adc_sck_n) begin
  if ( ( adc_convst_tpos != 0 ) && ( $time - adc_convst_tpos < tCONV_MAX ) ) begin
    $display( "time = %t, tCONV = %t (should be more than %t)",
        $time, $time - adc_convst_tpos, tCONV_MAX );
    $fatal(2);
  end
end

/*
[5] S/D = SINGLE-ENDED/DIFFERENTIAL BIT
[4] O/S = ODD/SIGN BIT
[3] S1  = ADDRESS SELECT BIT 1
[2] S0  = ADDRESS SELECT BIT 0
[1] UNI = UNIPOLAR/BIPOLAR BIT
[0] SLP = SLEEP MODE BIT
*/
reg [5:0] d_in_word = 6'b1000_00;
reg [11:0] dbg_in_adat_reg = 0;
integer adc_sck_counter = 0;

always @( adc_convst_p ) begin
  case ( d_in_word[5:2] )
    4'b0000 : dbg_in_adat_reg <= dbg_in_adat_CH0 - dbg_in_adat_CH1;
    4'b0001 : dbg_in_adat_reg <= dbg_in_adat_CH2 - dbg_in_adat_CH3;
    4'b0010 : dbg_in_adat_reg <= dbg_in_adat_CH4 - dbg_in_adat_CH5;
    4'b0011 : dbg_in_adat_reg <= dbg_in_adat_CH6 - dbg_in_adat_CH7;
    4'b0100 : dbg_in_adat_reg <= dbg_in_adat_CH1 - dbg_in_adat_CH0;
    4'b0101 : dbg_in_adat_reg <= dbg_in_adat_CH3 - dbg_in_adat_CH2;
    4'b0110 : dbg_in_adat_reg <= dbg_in_adat_CH5 - dbg_in_adat_CH4;
    4'b0111 : dbg_in_adat_reg <= dbg_in_adat_CH7 - dbg_in_adat_CH6;
    4'b1000 : dbg_in_adat_reg <= dbg_in_adat_CH0;
    4'b1001 : dbg_in_adat_reg <= dbg_in_adat_CH2;
    4'b1010 : dbg_in_adat_reg <= dbg_in_adat_CH4;
    4'b1011 : dbg_in_adat_reg <= dbg_in_adat_CH6;
    4'b1100 : dbg_in_adat_reg <= dbg_in_adat_CH1;
    4'b1101 : dbg_in_adat_reg <= dbg_in_adat_CH3;
    4'b1110 : dbg_in_adat_reg <= dbg_in_adat_CH5;
    4'b1111 : dbg_in_adat_reg <= dbg_in_adat_CH7;
    default: dbg_in_adat_reg <= dbg_in_adat_CH0;
  endcase
  adc_sck_counter <= 4'd0;
  // d_in_word <= 6'b1000_00;
  adc_sdo <= 1'bz;
  #tCONV_TYP adc_sdo <= dbg_in_adat_reg[11];
  dbg_in_adat_reg <= {dbg_in_adat_reg[10:0], 1'b0};
end

always @( adc_sck_p )
  if ( adc_sck_counter < 6 )
    d_in_word <= {d_in_word[4:0], adc_sdi};

always @( adc_sck_n ) begin
  adc_sck_counter = adc_sck_counter + 1;
  #thDO_MIN adc_sdo <= 1'bx;
  #( tdDO_MAX - thDO_MIN ) adc_sdo <= dbg_in_adat_reg[11];
  dbg_in_adat_reg <= {dbg_in_adat_reg[10:0], 1'b0};
end

endmodule
