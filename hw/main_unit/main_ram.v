// main_ram.v

// `timescale 1 ps / 1 ps
module main_ram (
  input  wire         clk,            // clock.clk
  input  wire         reset,          // reset.reset
  input  wire [11:0]  address,        //    s1.address
  input  wire         chipselect,     //      .chipselect
  output wire [31:0]  readdata,       //      .readdata
  input  wire         read,           //      .read
  input  wire [31:0]  writedata,      //      .writedata
  input  wire         write,          //      .write
  input  wire  [3:0]  byteenable,     //      .byteenable

  output reg   [31:0] tck_width,      // calibrate.tck_width
  output reg   [31:0] tck_delay,      //          .tck_delay
  output reg   [31:0] tms_delay,      //          .tms_delay
  output reg   [31:0] tdi_delay,      //          .tdi_delay
  output reg   [31:0] tdo_delay,      //          .tdo_delay

  output reg   [31:0] adc_start_delay,
  output reg   [31:0] adc_config_odd,
  output reg   [31:0] adc_config_even,

  input           adc_ram_clk,    //   adcdata.adc_ram_clk
  input     [9:0] adc_ram_addr,   //          .adc_ram_addr
  output   [31:0] adc_ram_rd_data,//          .adc_ram_rd_data
  input           adc_ram_we,     //          .adc_ram_we
  input    [31:0] adc_ram_wr_data,//          .adc_ram_wr_data

  input           vector_ram_clk,   //  jtagdata.vector_ram_clk
  input    [11:0] vector_1_addr,    //          .vector_1_addr
  output    [7:0] vector_1_rd_data, //          .vector_1_rd_data
  input           vector_1_we,      //          .vector_1_we
  input     [7:0] vector_1_wr_data, //          .vector_1_wr_data
  input    [11:0] vector_2_addr,    //          .vector_2_addr
  output    [7:0] vector_2_rd_data, //          .vector_2_rd_data
  input           vector_2_we,      //          .vector_2_we
  input     [7:0] vector_2_wr_data, //          .vector_2_wr_data
  
  output          jtag_rst,       //   control.jtag_rst
  output          jtag_rd,        //          .jtag_rd
  output          jtag_wr         //          .jtag_wr
);

// temp assign
wire [31:0] vector_1_readdata;
wire [31:0] vector_2_readdata;
wire [31:0] adc_ram_readdata;
wire vector_1_ram_cs;
wire vector_2_ram_cs;
wire adc_ram_cs;
wire ram_cs;

assign vector_1_ram_cs = chipselect && !address[11] && address[10];
assign vector_2_ram_cs = chipselect && address[11] && !address[10];
assign adc_ram_cs = chipselect && address[11] && address[10];
assign ram_cs = vector_1_ram_cs || vector_2_ram_cs || adc_ram_cs;

assign readdata = ( address[11] ) ?
                  ( address[10] ? adc_ram_readdata : vector_2_readdata ) :
                  ( address[10] ? vector_1_readdata : 32'h87654321 );

vector_ram vector_1_ram(
  //cpu
 .clk(clk),
 .address(address),
 .writedata(writedata),
 .vector_readdata(vector_1_readdata),
 .write(write && vector_1_ram_cs),
 .byteenable(byteenable),
 //mu
 .vector_ram_clk(vector_ram_clk),
 .vector_addr(vector_1_addr),
 .vector_rd_data(vector_1_rd_data),
 .vector_we(vector_1_we),
 .vector_wr_data(vector_1_wr_data)
);

vector_ram vector_2_ram(
  //cpu
 .clk(clk),
 .address(address),
 .writedata(writedata),
 .vector_readdata(vector_2_readdata),
 .write(write && vector_2_ram_cs),
 .byteenable(byteenable),
 //mu
 .vector_ram_clk(vector_ram_clk),
 .vector_addr(vector_2_addr),
 .vector_rd_data(vector_2_rd_data),
 .vector_we(vector_2_we),
 .vector_wr_data(vector_2_wr_data)
);

adc_ram adc_ram(
  //cpu
  .clk(clk),
  .address(address),
  .writedata(writedata),
  .readdata(adc_ram_readdata),
  .write(write && adc_ram_cs),
  .byteenable(byteenable),
  //mu
  .adc_ram_clk(adc_ram_clk),
  .adc_ram_addr(adc_ram_addr),
  .adc_ram_rd_data(adc_ram_rd_data),
  .adc_ram_we(adc_ram_we),
  .adc_ram_wr_data(adc_ram_wr_data)
);

always @(posedge clk) begin
  if ( !ram_cs && write ) begin
    case (address[2:0])
      3'b000 : tck_width[31:0] <= writedata[31:0];
      3'b001 : tck_delay[31:0] <= writedata[31:0];
      3'b010 : tms_delay[31:0] <= writedata[31:0];
      3'b011 : tdi_delay[31:0] <= writedata[31:0];
      3'b100 : tdo_delay[31:0] <= writedata[31:0];
      3'b101 : adc_start_delay[31:0] <= writedata[31:0];
      3'b110 : adc_config_odd[31:0] <= writedata[31:0];
      3'b111 : adc_config_even[31:0] <= writedata[31:0];
      default: tck_width[31:0] <= writedata[31:0];
    endcase
  end
end

endmodule


module vector_ram (
  //cpu
  input wire clk,
  input wire [9:0] address,
  input wire [31:0] writedata,
  output wire [31:0] vector_readdata,
  input wire write,
  input wire [3:0] byteenable,
  //mu
  input wire vector_ram_clk,
  input wire [11:0] vector_addr,
  output wire [7:0] vector_rd_data,
  input wire vector_we,
  input wire [7:0] vector_wr_data
);

  wire [7:0] vector_readdata_b [3:0];
  assign vector_rd_data[7:0] = vector_readdata_b[vector_addr[1:0]][7:0];

  ram8x1024 RAM_0 (
    .clock_a    (clk),
    .address_a  (address[9:0]),
    .data_a     (writedata[7:0]),
    .q_a        (vector_readdata[7:0]),
    .wren_a     (write && byteenable[0]),
    .clock_b    (vector_ram_clk),
    .address_b  (vector_addr[11:2]),
    .data_b     (vector_wr_data),
    .q_b        (vector_readdata_b[0][7:0]),
    .wren_b     (vector_we && !vector_addr[1] && !vector_addr[0])
  );
  ram8x1024 RAM_1 (
    .clock_a    (clk),
    .address_a  (address[9:0]),
    .data_a     (writedata[15:8]),
    .q_a        (vector_readdata[15:8]),
    .wren_a     (write && byteenable[1]),
    .clock_b    (vector_ram_clk),
    .address_b  (vector_addr[11:2]),
    .data_b     (vector_wr_data),
    .q_b        (vector_readdata_b[1][7:0]),
    .wren_b     (vector_we && !vector_addr[1] && vector_addr[0])
  );
  ram8x1024 RAM_2 (
    .clock_a    (clk),
    .address_a  (address[9:0]),
    .data_a     (writedata[23:16]),
    .q_a        (vector_readdata[23:16]),
    .wren_a     (write && byteenable[2]),
    .clock_b    (vector_ram_clk),
    .address_b  (vector_addr[11:2]),
    .data_b     (vector_wr_data),
    .q_b        (vector_readdata_b[2][7:0]),
    .wren_b     (vector_we && vector_addr[1] && !vector_addr[0])
  );
  ram8x1024 RAM_3 (
    .clock_a    (clk),
    .address_a  (address[9:0]),
    .data_a     (writedata[31:24]),
    .q_a        (vector_readdata[31:24]),
    .wren_a     (write && byteenable[3]),
    .clock_b    (vector_ram_clk),
    .address_b  (vector_addr[11:2]),
    .data_b     (vector_wr_data),
    .q_b        (vector_readdata_b[3][7:0]),
    .wren_b     (vector_we && vector_addr[1] && vector_addr[0])
  );

endmodule


module adc_ram (
  //cpu
  input wire          clk,
  input wire    [9:0] address,
  input wire   [31:0] writedata,
  output wire  [31:0] readdata,
  input wire          write,
  input wire    [3:0] byteenable,
  //mu
  input wire          adc_ram_clk,
  input wire    [9:0] adc_ram_addr,
  output wire  [31:0] adc_ram_rd_data,
  input wire          adc_ram_we,
  input wire   [31:0] adc_ram_wr_data
);

ram8x1024 RAM_0 (
  .clock_a    (clk),
  .address_a  (address),
  .data_a     (writedata[7:0]),
  .q_a        (readdata[7:0]),
  .wren_a     (write && byteenable[0]),
  .clock_b    (adc_ram_clk),
  .address_b  (adc_ram_addr),
  .data_b     (adc_ram_wr_data[7:0]),
  .q_b        (adc_ram_rd_data[7:0]),
  .wren_b     (adc_ram_we)
);
ram8x1024 RAM_1 (
  .clock_a    (clk),
  .address_a  (address),
  .data_a     (writedata[15:8]),
  .q_a        (readdata[15:8]),
  .wren_a     (write && byteenable[1]),
  .clock_b    (adc_ram_clk),
  .address_b  (adc_ram_addr),
  .data_b     (adc_ram_wr_data[15:8]),
  .q_b        (adc_ram_rd_data[15:8]),
  .wren_b     (adc_ram_we)
);
ram8x1024 RAM_2 (
  .clock_a    (clk),
  .address_a  (address),
  .data_a     (writedata[23:16]),
  .q_a        (readdata[23:16]),
  .wren_a     (write && byteenable[2]),
  .clock_b    (adc_ram_clk),
  .address_b  (adc_ram_addr),
  .data_b     (adc_ram_wr_data[23:16]),
  .q_b        (adc_ram_rd_data[23:16]),
  .wren_b     (adc_ram_we)
);
ram8x1024 RAM_3 (
  .clock_a    (clk),
  .address_a  (address),
  .data_a     (writedata[31:24]),
  .q_a        (readdata[31:24]),
  .wren_a     (write && byteenable[3]),
  .clock_b    (adc_ram_clk),
  .address_b  (adc_ram_addr),
  .data_b     (adc_ram_wr_data[31:24]),
  .q_b        (adc_ram_rd_data[31:24]),
  .wren_b     (adc_ram_we)
);

endmodule
