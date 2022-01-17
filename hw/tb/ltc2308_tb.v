`timescale 1ns/1ps

module ltc2308_tb;

reg adc_convst = 1'b0;
reg adc_sck = 1'b0;
reg adc_sdi = 1'b0;
wire adc_sdo;

ltc2308 ltc2308 (
  .adc_convst( adc_convst ),//input adc_convst,
  .adc_sck( adc_sck ),//input adc_sck,
  .adc_sdi( adc_sdi ),//input adc_sdi,
  .adc_sdo( adc_sdo )//output adc_sdo
);
`ifdef tWHCONV_MIN
  defparam ltc2308.tWHCONV_MIN = `tWHCONV_MIN;
`endif
`ifdef tWHCONV_MAX
  defparam ltc2308.tWHCONV_MAX = `tWHCONV_MAX;
`endif

initial begin
  adc_convst = 1'b0;
  adc_sck = 1'b0;
  adc_sdi = 1'b0;
  #100;
  adc_convst = 1'b1;
  #30;
  adc_convst = 1'b0;
end

endmodule