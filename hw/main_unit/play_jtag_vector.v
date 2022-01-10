module play_jtag_vector #(
  parameter MASTER_CLK = 600
)(
  input           clk,
  output  [11:0] vector_1_addr,
  input    [7:0] vector_1_rd_data,
  output         vector_1_we,
  output   [7:0] vector_1_wr_data,

  output reg [1:0] vector_data,
  input get_next_data,
  output reg data_ready,
  output wait_state,

  input [15:0] vector_start,
  input [15:0] vector_end,
  input [15:0] vector_number_repeat,
  input [31:0] adc_start_delay,
  output adc_start,
  output adc_sequence_one,

  input tdo
);

reg [15:0] vector_count;
reg [7:0] vector_1_rd_data_reg;
reg [1:0] get_next_data_reg;

always @(posedge clk) begin
  vector_1_rd_data_reg <= vector_1_rd_data;
  get_next_data_reg[1:0] <= {get_next_data_reg[0], get_next_data};
end

wire [1:0] tms_tdi_out[0:3];
assign tms_tdi_out[0] = vector_1_rd_data_reg[1:0];
assign tms_tdi_out[1] = vector_1_rd_data_reg[3:2];
assign tms_tdi_out[2] = vector_1_rd_data_reg[5:4];
assign tms_tdi_out[3] = vector_1_rd_data_reg[7:6];

assign vector_1_addr[11:0] = vector_count[13:2];
assign adc_start = vector_count[15:0] == adc_start_delay[15:0];

always @(posedge clk) begin
  if (get_next_data_reg[1] && !data_ready) begin
    vector_count <= vector_count +1;
    vector_data <= tms_tdi_out[vector_count[1:0]];
    data_ready <= 1'b1;
  end
  else if (!get_next_data_reg[1])
    data_ready <= 1'b0;
end


endmodule
