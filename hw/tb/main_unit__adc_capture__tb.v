// iverilog -y ../main_unit -o adc_capture main_unit__adc_capture__tb.v
// vvp adc_capture
// gtkwave -f main_unit__adc_capture__tb.vcd
`timescale 1ns/10ps

module main_unit__adc_capture__tb;

parameter PERIOD = 6.25; // 160MHz -> 6.25ns, half - 3.125ns :(
parameter DO_CYCLES = 320 * 3;

wire adc_convst;
wire adc_sck;
wire adc_sdi;
wire adc_sdo;
reg clk;

wire [11:0] adc_ram_addr;
reg [31:0] adc_ram_rd_data = 32'h1234;
wire adc_ram_we;
wire [31:0] adc_ram_wr_data;

reg [31:0] adc_config_odd = 32'b101010;
reg [31:0] adc_config_even = 32'b010101;
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

prbs_generate adc_sdo_generate (
  .clk( adc_sck ),
  .prbs( adc_sdo )
);

initial begin
  $dumpfile( "main_unit__adc_capture__tb.vcd" );
  $dumpvars( 1,
    adc_convst,
    adc_sck,
    adc_sdi,
    adc_sdo,

    clk,
    adc_ram_addr,
    adc_ram_rd_data,
    adc_ram_we,
    adc_ram_wr_data,

    adc_config_odd,
    adc_config_even,
    adc_start,
    adc_sequence_one
  );
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
  $finish;
end

endmodule

module prbs_generate (
  input clk,
  output prbs
  );

  reg [30:0] prbs_state = 31'h34013FF7;
  wire prbs;
  assign prbs = prbs_state[30];
  always @( posedge clk )
    prbs_state <= { prbs_state, prbs_state[30] ^ prbs_state[27] };

endmodule
