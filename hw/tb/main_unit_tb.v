// iverilog -y ../main_unit -o main_unit_tb.vvp main_unit_tb.v
// vvp main_unit_tb.vvp
// gtkwave -f main_unit_tb.vcd
`timescale 1ns/1ps

module main_unit_tb;

parameter DO_CYCLES = 2**10;
parameter PERIOD_CLK_50 = 20;
parameter PERIOD_CLK_160 = 6.25;
parameter PERIOD_CLK_400 = 2.5;

initial begin
  $dumpfile( "./tb/main_unit_tb.vcd" );
  $dumpvars;
end

reg clk_50 = 0, clk_160 = 0, clk_400 = 0;
initial begin forever #( PERIOD_CLK_50 / 2 ) clk_50 = ~clk_50; end
initial begin forever #( PERIOD_CLK_160 / 2 ) clk_160 = ~clk_160; end
initial begin forever #( PERIOD_CLK_400 / 2 ) clk_400 = ~clk_400; end


initial begin
  repeat ( DO_CYCLES ) @( posedge clk_50 );
  $finish(0);
end

wire adc_convst, adc_sck, adc_sdi, adc_sdo;

wire        cpu_reset;       // input
reg  [11:0] cpu_address;     // input [11:0]
reg         cpu_chipselect;  // input
wire [31:0] cpu_readdata;    // output [31:0]
wire        cpu_read;        // input
reg  [31:0] cpu_writedata;   // input [31:0]
reg         cpu_write;       // input
reg   [3:0] cpu_byteenable;  // input [3:0]
initial begin
  cpu_address <= 12'b0100_0000_0000;
  cpu_writedata <= 32'h0000_0000;
  cpu_write <= 1'b0;
  cpu_byteenable <= 4'b1111;
  cpu_chipselect <= 1'b0;
  #( PERIOD_CLK_50 * 2 )
  repeat ( 2 )  @( negedge clk_50 );
  // 4'b0000 : tck_width[31:0]
  cpu_address <= 12'b0000_0000_0000;
  cpu_writedata <=32'd100; // 400MHz / 100 = 4MHz
  cpu_write <= 1'b1;
  cpu_byteenable <= 4'b1111;
  cpu_chipselect <= 1'b1;
  repeat ( 2 )  @( negedge clk_50 );
  // 4'b0001 : tck_delay[31:0]
  cpu_address <= 12'b0000_0000_0001;
  cpu_writedata <=32'h0000_0000;
  repeat ( 2 )  @( negedge clk_50 );
  // 4'b0010 : tms_delay[31:0]
  cpu_address <= 12'b0000_0000_0010;
  cpu_writedata <=32'h0000_0000;
  repeat ( 2 )  @( negedge clk_50 );
  // 4'b0011 : tdi_delay[31:0]
  cpu_address <= 12'b0000_0000_0011;
  cpu_writedata <=32'h0000_0000;
  repeat ( 2 )  @( negedge clk_50 );
  // 4'b0100 : tdo_delay[31:0]
  cpu_address <= 12'b0000_0000_0100;
  cpu_writedata <=32'h0000_0000;
  repeat ( 2 )  @( negedge clk_50 );

  // 4'b0101 : adc_start_delay[31:0]
  cpu_address <= 12'b0000_0000_0101;
  cpu_writedata <=32'd22;
  repeat ( 2 )  @( negedge clk_50 );
  // 4'b0110 : adc_config_odd[31:0]
  cpu_address <= 12'b0000_0000_0110;
  cpu_writedata <=32'b1000_00; // CH0
  repeat ( 2 )  @( negedge clk_50 );
  // 4'b0111 : adc_config_even[31:0]
  cpu_address <= 12'b0000_0000_0111;
  cpu_writedata <=32'b1100_00; // CH1
  repeat ( 2 )  @( negedge clk_50 );

  // 4'b1000 : vector_start[31:0]
  cpu_address <= 12'b0000_0000_1000;
  cpu_writedata <=32'd11;
  repeat ( 2 )  @( negedge clk_50 );
  // 4'b1001 : vector_end[31:0]
  cpu_address <= 12'b0000_0000_1001;
  cpu_writedata <=32'd33;
  repeat ( 2 )  @( negedge clk_50 );
  // 4'b1010 : vector_number_repeat[31:0]
  cpu_address <= 12'b0000_0000_1010;
  cpu_writedata <=32'd4;
  repeat ( 2 )  @( negedge clk_50 );

  cpu_write <= 1'b0;
  cpu_byteenable <= 4'b0000;
  cpu_chipselect <= 1'b0;
  cpu_address <= 12'b0100_0000_0000;

  repeat ( 500 ) begin
    @( negedge clk_50 );
    cpu_address <= cpu_address + 1;
    cpu_writedata <= cpu_writedata + 1;
    cpu_write <= 1'b1;
    cpu_byteenable <= 4'b1111;
    cpu_chipselect <= 1'b1;
    @( negedge clk_50 );
  end
end

wire tck, tms, tdi;
reg tdo;

main_unit mu(
  .clk(clk_160),
  .clk_max(clk_400),

  .adc_convst(adc_convst),
  .adc_sck(adc_sck),
  .adc_sdi(adc_sdi),
  .adc_sdo(adc_sdo),

  .clk_vector( 1'b0 ),             // input                   clk_vector,

  .cpu_clk(clk_50),                // input
  .cpu_reset(cpu_reset),            // input
  .cpu_address(cpu_address),        // input [11:0]
  .cpu_chipselect(cpu_chipselect),  // input
  .cpu_readdata(cpu_readdata),      // output [31:0]
  .cpu_read(cpu_read),              // input
  .cpu_writedata(cpu_writedata),    // input [31:0]
  .cpu_write(cpu_write),            // input
  .cpu_byteenable(cpu_byteenable),  // input [3:0]

  .tck(tck),
  .tms(tms),
  .tdi(tdi),
  .tdo_in(tdo)
);

endmodule
