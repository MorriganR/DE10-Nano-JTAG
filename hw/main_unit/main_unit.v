module main_unit #(
  parameter J_D_WIDTH = 8,  // max jtag vector VECTOR_DATA_WIDTH*2^VECTOR_ADDR_WIDTH
  parameter J_A_WIDTH = 12  // 10*2^8=8192 - one M10k memory block
)(
  input                   clk,
  input                   clk_max,

  output                  adc_convst,
  output                  adc_sck,
  output                  adc_sdi,
  input                   adc_sdo,

  input                   clk_vector,

  input wire         cpu_clk,            //  extram.cpu_clk
  input wire         cpu_reset,          //        .cpu_reset
  input wire [11:0]  cpu_address,        //        .cpu_address
  input wire         cpu_chipselect,     //        .cpu_chipselect
  output wire [31:0] cpu_readdata,       //        .cpu_readdata
  input wire         cpu_read,           //        .cpu_read
  input wire [31:0]  cpu_writedata,      //        .cpu_writedata
  input wire         cpu_write,          //        .cpu_write
  input wire  [3:0]  cpu_byteenable,     //        .cpu_byteenable

  output                  tck,
  output                  tms,
  output                  tdi,
  input                   tdo_in
);

wire [31:0] tck_width;
wire [31:0] tck_delay;
wire [31:0] tms_delay;
wire [31:0] tdi_delay;
wire [31:0] tdo_delay;

wire [31:0] adc_start_delay;
wire [31:0] adc_config_odd;
wire [31:0] adc_config_even;
wire adc_start;
wire adc_sequence_one;
wire tdo;

wire adc_ram_clk;
wire [9:0] adc_ram_addr;
wire [31:0] adc_ram_rd_data;
wire adc_ram_we;
wire [31:0] adc_ram_wr_data;

wire vector_ram_clk;
wire [11:0] vector_1_addr;
wire [7:0] vector_1_rd_data;
wire vector_1_we;
wire [7:0] vector_1_wr_data;

wire [11:0] vector_2_addr;
wire [7:0] vector_2_rd_data;
wire vector_2_we;
wire [7:0] vector_2_wr_data;

assign vector_ram_clk = clk;
assign adc_ram_clk = clk;

main_ram main_ram(
  .clk(cpu_clk),               //input  wire          clock.clk
  .reset(cpu_reset),          //input  wire          reset.reset
  .address(cpu_address),      //input  wire [11:0]      s1.address
  .chipselect(cpu_chipselect),//input  wire               .chipselect
  .readdata(cpu_readdata),    //output wire [31:0]        .readdata
  .read(cpu_read),            //input  wire               .read
  .writedata(cpu_writedata),  //input  wire [31:0]        .writedata
  .write(cpu_write),          //input  wire               .write
  .byteenable(cpu_byteenable),//input  wire  [3:0]        .byteenable

  .tck_width(tck_width),      //output reg   [7:0]  calibrate.tck_width
  .tck_delay(tck_delay),      //output reg   [7:0]           .tck_delay
  .tms_delay(tms_delay),      //output reg   [7:0]           .tms_delay
  .tdi_delay(tdi_delay),      //output reg   [7:0]           .tdi_delay
  .tdo_delay(tdo_delay),      //output reg   [7:0]           .tdo_delay

  .adc_start_delay(adc_start_delay),
  .adc_config_odd(adc_config_odd),
  .adc_config_even(adc_config_even),

  .adc_ram_clk(adc_ram_clk),          //input              adcdata.adc_ram_clk
  .adc_ram_addr(adc_ram_addr),        //input     [9:0]           .adc_ram_addr
  .adc_ram_rd_data(adc_ram_rd_data),  //output   [31:0]           .adc_ram_rd_data
  .adc_ram_we(adc_ram_we),            //input                     .adc_ram_we
  .adc_ram_wr_data(adc_ram_wr_data),  //input    [31:0]           .adc_ram_wr_data

  .vector_ram_clk(vector_ram_clk),    //input             jtagdata.vector_ram_clk
  .vector_1_addr(vector_1_addr),      //input    [11:0]           .vector_1_addr
  .vector_1_rd_data(vector_1_rd_data),//output    [7:0]           .vector_1_rd_data
  .vector_1_we(vector_1_we),          //input                     .vector_1_we
  .vector_1_wr_data(vector_1_wr_data),//input     [7:0]           .vector_1_wr_data
  .vector_2_addr(vector_2_addr),      //input    [11:0]           .vector_2_addr
  .vector_2_rd_data(vector_2_rd_data),//output    [7:0]           .vector_2_rd_data
  .vector_2_we(vector_2_we),          //input                     .vector_2_we
  .vector_2_wr_data(vector_2_wr_data),//input     [7:0]           .vector_2_wr_data

  .jtag_rst(jtag_rst),                //output             control.jtag_rst
  .jtag_rd(jtag_rd),                  //output                    .jtag_rd
  .jtag_wr(jtag_wr)                   //output                    .jtag_wr
);

wire [1:0] vector_data;
wire get_next_data;
wire data_ready;
wire wait_state;
wire [15:0] vector_start;
wire [15:0] vector_end;
wire [15:0] vector_number_repeat;
play_jtag_vector play_jtag(
  .clk(clk),
  .vector_1_addr(vector_1_addr),
  .vector_1_rd_data(vector_1_rd_data),
  .vector_1_we(vector_1_we),
  .vector_1_wr_data(vector_1_wr_data),

  .vector_data(vector_data),
  .get_next_data(get_next_data),
  .data_ready(data_ready),
  .wait_state(wait_state),

  .vector_start(vector_start),
  .vector_end(vector_end),
  .vector_number_repeat(vector_number_repeat),
  .adc_start_delay(adc_start_delay),
  .adc_start(adc_start),
  .adc_sequence_one(adc_sequence_one),

  .tdo(tdo)
);

adc_capture adc_capture (
  .adc_convst(adc_convst),//output  adc_convst,
  .adc_sck(adc_sck),//output  adc_sck,
  .adc_sdi(adc_sdi),//output  adc_sdi,
  .adc_sdo(adc_sdo),//input   adc_sdo,

  .clk(clk),//input          clk,
  .adc_ram_addr(adc_ram_addr),//output  [11:0] adc_ram_addr,
  .adc_ram_rd_data(adc_ram_rd_data),//input   [31:0] adc_ram_rd_data,
  .adc_ram_we(adc_ram_we),//output         adc_ram_we,
  .adc_ram_wr_data(adc_ram_wr_data),//output  [31:0] adc_ram_wr_data,

  .adc_config_odd(adc_config_odd),//input   [31:0] adc_config_odd,
  .adc_config_even(adc_config_even),//input   [31:0] adc_config_even,
  .adc_start(adc_start),//input adc_start
  .adc_sequence_one(adc_sequence_one)//input adc_sequence_one
);

jtag_signal_out jtag_out (
  .clk_max(clk_max),//input wire clk_max,
  .vector_data(vector_data),//input wire [1:0] vector_data,
  .get_next_data(get_next_data),//output wire get_next_data,
  .data_ready(data_ready),//input wire data_ready,
  .wait_state(wait_state),//input wire wait_state,
  .tck_width(tck_width),//input wire [31:0] tck_width,
  .tck_delay(tck_delay),//input wire [31:0] tck_delay,
  .tms_delay(tms_delay),//input wire [31:0] tms_delay,
  .tdi_delay(tdi_delay),//input wire [31:0] tdi_delay,
  .tck(tck),//output wire tck,
  .tms(tms),//output wire tms,
  .tdi(tdi),//output wire tdi,
  .tdo_in(tdo_in),//input wire tdo
  .tdo(tdo)//output wire tdo
);

endmodule
