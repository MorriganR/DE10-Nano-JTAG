module adc_capture (
  output reg adc_convst,
  output reg adc_sck,
  output reg adc_sdi,
  input   adc_sdo,

  input          clk, // 160MHz, 6.25 ns
  output reg [11:0] adc_ram_addr,
  input   [31:0] adc_ram_rd_data,
  output         adc_ram_we,
  output reg [31:0] adc_ram_wr_data,

  input   [31:0] adc_config_odd,
  input   [31:0] adc_config_even,
  input adc_start,
  input adc_sequence_one
);

//wire [5:0] adc_config [0:1];
//assign adc_config[0][5:0] = adc_config_even[5:0];
//assign adc_config[1][5:0] = adc_config_odd[5:0];
wire [5:0] adc_config;
assign adc_config = ( adc_ram_addr[0] == 1'b1 ) ? adc_config_odd[5:0] : adc_config_even[5:0];
wire start_t_cyc;
assign start_t_cyc = adc_start;
                // tCYC    | Total Cycle Time | 2 μs       (320) /0001 0100 0000/
wire t_wh_conv; // tWHCONV | CONVST High Time | min 20 ns    (4) /0000 0000 0100/
wire t_conv;    // tCONV   | Conversion Time  | max 1.6 μs (256) /0001 0000 0000/

reg [8:0] t_cyc_counter;
always @(posedge clk) begin
  if (start_t_cyc || (t_cyc_counter == 9'd319))
    t_cyc_counter <= 9'b0;
  else
    t_cyc_counter <= t_cyc_counter + 1'b1;
end

always @(posedge clk) begin
  if (start_t_cyc)
    adc_ram_addr <= 9'b0;
  else if (t_cyc_counter == 8'd1)
    adc_ram_addr <= adc_ram_addr + 1'b1;
end

// adc_convst
/* A rising edge at CONVST begins a conversion. For best performance,
ensure that CONVST returns low within 40ns after the conversion starts
or after the conversion ends.*/
always @(posedge clk) begin
  if (t_cyc_counter == 8'd1)
    adc_convst <= 1'b1;
  else if (t_cyc_counter == 8'd7)
    adc_convst <= 1'b0;
end

// adc_sck
always @(posedge clk) begin
  if ((t_cyc_counter[8] == 1'b1) && (t_cyc_counter[7:2] < 6'd12))
    adc_sck <= t_cyc_counter[1];
  else
    adc_sck <= 1'b0;
end

// adc_sdi
always @(posedge clk) begin
  if ((t_cyc_counter[8] == 1'b1) && (t_cyc_counter[7:2] < 6'd6))
    //adc_sdi = adc_config[adc_ram_addr[0]][t_cyc_counter[4:2]];
    adc_sdi <= adc_config[t_cyc_counter[4:2]];
  else
    adc_sdi <= 1'b0;
end

// adc_sdo
reg [11:0] adc_data;
always @(posedge clk) begin
  if ((t_cyc_counter[8] == 1'b1) && (t_cyc_counter[7:2] < 6'd12) && (t_cyc_counter[1:0] == 2'b0))
    adc_data <= {adc_data[10:0],adc_sdo};
end

// wr mem
reg [31:0] adc_ram_rd_data_reg;
always @(posedge clk) begin
  if (t_cyc_counter == 9'd315)
    adc_ram_rd_data_reg <= adc_ram_rd_data;
end
always @(posedge clk) begin
  if (t_cyc_counter == 9'd316)
    adc_ram_wr_data <= adc_ram_rd_data_reg + adc_data;
end
assign adc_ram_we = t_cyc_counter == 9'd317;

endmodule
