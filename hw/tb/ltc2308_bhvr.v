`timescale 1ps/1ps

module ltc2308_bhvr #(
// SYMBOL     | PARAMETER                             | MIN TYP MAX | UNITS
// fSMPL(MAX) | Maximum Sampling Frequency            |         500 | kHz
// fSCK       | Shift Clock Frequency                 |         40  | MHz
parameter tWCLK = 25_000,
// tWHCONV    | CONVST High Time                      | 20          | ns
parameter tWHCONV = 20_000,
parameter tWHCONV_MAX = 40_000,
// tHD        | Hold Time SDI After SCK↑              | 2.5         | ns
// tSUDI      | Setup Time SDI Valid Before SCK↑      | 0           | ns
// tWHCLK     | SCK High Time                         | 10          | ns
parameter tWHCLK = 10_000,
// tWLCLK     | SCK Low Time                          | 10          | ns
parameter tWLCLK = 10_000,
// tWLCONVST  | CONVST Low Time During Data Transfer  | 410         | ns
// tHCONVST   | Hold Time CONVST Low After Last SCK↓  | 20          | ns
// tCONV      | Conversion Time                       |     1.3 1.6 | µs
parameter tCONV_MAX = 1_600_000,
// tACQ       | Acquisition Time 7th SCK↑ to CONVST↑  | 240         | ns
// tREFWAKE   | REFCOMP Wakeup Time                   |    200      | ms
// tdDO       | SDO Data Valid After SCK↓             |    10.8 12.5| ns
// thDO       | SDO Hold Time After SCK↓              | 4           | ns
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
  output adc_sdo
);

initial
  $timeformat(-9, 3, "ns", 0);



// adc_convst
time adc_convst_tpos = 0;
time adc_convst_tneg = 0;
event adc_convst_p;
event adc_convst_n;
always @( posedge adc_convst ) begin
  adc_convst_tpos <= $time;
  -> adc_convst_p;
end
always @( negedge adc_convst ) begin
  adc_convst_tneg <= $time;
  -> adc_convst_n;
end

// adc_sck
time adc_sck_tpos = 0;
time adc_sck_tneg = 0;
event adc_sck_p;
event adc_sck_n;
always @( posedge adc_sck ) begin
  adc_sck_tpos <= $time;
  -> adc_sck_p;
end
always @( negedge adc_sck ) begin
  adc_sck_tneg <= $time;
  -> adc_sck_n;
end

// adc_sdi
time adc_sdi_tpos = 0;
time adc_sdi_tneg = 0;
event adc_sdi_p;
event adc_sdi_n;
always @( posedge adc_sdi ) begin
  adc_sdi_tpos <= $time;
  -> adc_sdi_p;
end
always @( negedge adc_sdi ) begin
  adc_sdi_tneg <= $time;
  -> adc_sdi_n;
end

// checking tWHCONV
always @( adc_convst_n ) begin
  if ( ( $time - adc_convst_tpos < tWHCONV ) || ( $time - adc_convst_tpos > tWHCONV_MAX ) ) begin
    $display( "time = %t, tWHCONV = %t (should be more than %t & less then %t)",
        $time, $time - adc_convst_tpos, tWHCONV, tWHCONV_MAX );
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
        ( ( $time - adc_sck_tneg < tWLCLK ) || ( $time - adc_sck_tpos < tWCLK ) ) ) begin
    $display( "time = %t, tWLCLK = %t (should be more than %t), tWCLK = %t (should be more than %t)",
        $time, $time - adc_sck_tneg, tWLCLK, $time - adc_sck_tpos, tWCLK );
    $fatal(2);
  end
end
// checking tWHCLK, tWCLK (adc_sck: neg to neg time)
always @( adc_sck_n ) begin
  if ( ( adc_sck_tneg != 0 ) && ( adc_sck_tpos != 0 ) &&
        ( ( $time - adc_sck_tpos < tWHCLK ) || ( $time - adc_sck_tneg < tWCLK ) ) ) begin
    $display( "time = %t, tWHCLK = %t (should be more than %t), tWCLK = %t (should be more than %t)",
        $time, $time - adc_sck_tpos, tWHCLK, $time - adc_sck_tneg, tWCLK );
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

endmodule
