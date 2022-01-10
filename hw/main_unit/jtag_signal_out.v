module jtag_signal_out #(
  parameter FC_WIDTH = 9
)(
  input wire clk_max,
  input wire [1:0] vector_data,
  output reg get_next_data,
  input wire data_ready,
  input wire wait_state,
  input wire [31:0] tck_width,
  input wire [31:0] tck_delay,
  input wire [31:0] tms_delay,
  input wire [31:0] tdi_delay,
  output wire tck,
  output wire tms,
  output wire tdi,
  input wire tdo_in,
  output reg tdo
);

  reg [(FC_WIDTH-1):0] fast_counter;
  reg [(FC_WIDTH-1):0] fast_counter_reg;
  reg [1:0] vector_data_reg;
  reg tck_out, tms_out, tdi_out;
  wire tck_neg, tck_pos, tms_next, tdi_next;
  wire fast_counter_zero, fast_counter_half, fast_counter_max;


/*  always @(posedge clk_max) begin
    tck_neg = fast_counter_reg[(FC_WIDTH-1):0] == tck_delay[(FC_WIDTH-1):0];
    tck_pos = fast_counter_reg[(FC_WIDTH-1):0] == tck_delay[(FC_WIDTH-1):0] + {1'b0, tck_width[(FC_WIDTH-1):1]};
    tms_next = fast_counter_reg[(FC_WIDTH-1):0] == tms_delay[(FC_WIDTH-1):0];
    tdi_next = fast_counter_reg[(FC_WIDTH-1):0] == tdi_delay[(FC_WIDTH-1):0];
    fast_counter_zero = |fast_counter_reg[(FC_WIDTH-1):0] == 0;
    fast_counter_half = fast_counter_reg[(FC_WIDTH-1):0] == {1'b0, tck_width[(FC_WIDTH-1):1]};
    fast_counter_max = fast_counter_reg[(FC_WIDTH-1):0] == tck_width[(FC_WIDTH-1):0];
  end*/
  equal3clk res_tck_neg( .clk(clk_max), .a(fast_counter_reg[(FC_WIDTH-1):0]), .b(tck_delay[(FC_WIDTH-1):0]), .res(tck_neg) );
  equal3clk res_tck_pos( .clk(clk_max), .a(fast_counter_reg[(FC_WIDTH-1):0]), .b(tck_delay[(FC_WIDTH-1):0] + {1'b0, tck_width[(FC_WIDTH-1):1]}), .res(tck_pos) );
  equal3clk res_tms_next( .clk(clk_max), .a(fast_counter_reg[(FC_WIDTH-1):0]), .b(tms_delay[(FC_WIDTH-1):0]), .res(tms_next) );
  equal3clk res_tdi_next( .clk(clk_max), .a(fast_counter_reg[(FC_WIDTH-1):0]), .b(tdi_delay[(FC_WIDTH-1):0]), .res(tdi_next) );
  equal3clk res_fast_counter_zero( .clk(clk_max), .a(fast_counter_reg[(FC_WIDTH-1):0]), .b({FC_WIDTH{1'b0}}), .res(fast_counter_zero) );
  equal3clk res_fast_counter_half( .clk(clk_max), .a(fast_counter_reg[(FC_WIDTH-1):0]), .b({1'b0, tck_width[(FC_WIDTH-1):1]}), .res(fast_counter_half) );
  equal3clk res_fast_counter_max( .clk(clk_max), .a(fast_counter_reg[(FC_WIDTH-1):0]), .b(tck_width[(FC_WIDTH-1):0]), .res(fast_counter_max) );

  always @(posedge clk_max) begin
    if (tck_neg)
      tck_out <= 1'b0;
    else if (tck_pos)
      tck_out <= 1'b1;
  end
/*  SRFF srff_tck_out (
    .s(tck_pos),
    .r(tck_neg),
    .clk(clk_max),
    .clrn(1'b1),
    .prn(1'b1),
    .q(tck)
  );*/

  always @(posedge clk_max) begin
    if (fast_counter_zero)
      get_next_data <= 1'b1;
    else if (fast_counter_half)
      get_next_data <= 1'b0;
  end
/*  SRFF srff_get_next_data (
    .s(fast_counter_zero),
    .r(fast_counter_half),
    .clk(clk_max),
    .clrn(1'b1),
    .prn(1'b1),
    .q(get_next_data)
  );*/

  always @(posedge clk_max) begin
    if (tms_next)
      tms_out <= vector_data_reg[1];
  end

  always @(posedge clk_max) begin
    if (tdi_next)
      tdi_out <= vector_data_reg[0];
  end

  always @(posedge clk_max) begin
    if (fast_counter_max)
      vector_data_reg[1:0] <= vector_data[1:0];
  end

  //always @(posedge fast_counter_max or posedge clk_max) begin
  always @(posedge clk_max) begin
      if (fast_counter_max)
      fast_counter <= {FC_WIDTH{1'b0}};
    else
      fast_counter <= fast_counter + 1'b1;
  end

  always @(posedge clk_max) begin
    fast_counter_reg <= fast_counter;
  end

  assign tck = tck_out;
  assign tms = tms_out;
  assign tdi = tdi_out;
  //delay_in_clk tck_dl( .clk(clk_max), .delay(tck_delay), .d(tck_out), .q(tck) );
  //delay_in_clk tms_dl( .clk(clk_max), .delay(tms_delay), .d(tms_out), .q(tms) );
  //delay_in_clk tdi_dl( .clk(clk_max), .delay(tdi_delay), .d(tdi_out), .q(tdi) );
  //delay_in_clk tdo_dl( .clk(clk_max), .delay(tdo_delay), .d(tdo_in), .q(tdo) );
  always @(posedge clk_max) begin
    if (tck_pos)
      tdo = tdo_in;
  end


endmodule

module equal3clk (
  input wire clk,
  input wire [8:0] a,
  input wire [8:0] b,
  output reg res
);

  reg [8:0] equal_stage_1;
  reg [2:0] equal_stage_2;

  always @(posedge clk) begin
    equal_stage_1 <= a ~^ b;
  end

  always @(posedge clk) begin
    equal_stage_2[0] <= &equal_stage_1[(3*0+2):(3*0)];
    equal_stage_2[1] <= &equal_stage_1[(3*1+2):(3*1)];
    equal_stage_2[2] <= &equal_stage_1[(3*2+2):(3*2)];
  end

  always @(posedge clk) begin
    res <= &equal_stage_2;
  end

endmodule


module delay_in_clk #(
  parameter DELAY_WIDTH = 8
) (
  input wire clk,
  input wire  [(DELAY_WIDTH-1):0] delay,
  input wire  d,
  output wire q
);

  reg [(2**DELAY_WIDTH-1):0] dreg;

  always @ (posedge clk) begin
    dreg[(2**DELAY_WIDTH-1):0] <= {dreg[(2**DELAY_WIDTH-2):0],d};
  end

  assign q = dreg[delay];

endmodule
