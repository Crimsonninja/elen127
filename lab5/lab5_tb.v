module tb();

  reg clk, rst;
  //Client0 signals
  reg req0_in;
  reg [2:0] size0_in;
  wire done;
  //Client1 signals
  reg req1_in;
  wire done0, done1;
  reg [2:0] size0_in, size0_out, size1_in, size1_out;


  client client0(.clk(clk),
		.rst(rst),
		.req_in(req0_in),
		.size_in(size0_in),
 		.done(done0),
		.req_out(req0_out),
		.size_out(size0_out),
		.resp(resp0));

  client client1(.clk(clk),
		.rst(rst),
		.req_in(req1_in),
		.size_in(size1_in),
 		.done(done1),
		.req_out(req1_out),
		.size_out(size1_out),
		.resp(resp1));

  server server(.clk(clk),
		.rst(rst),
		.req0(req0_out),
		.req1(req1_out),
		.size0(size0_out),
		.size1(size1_out),
		.resp0(resp0),
		.resp1(resp1));

  initial begin
    $monitor("REQ0 = %d, SIZE0 = %d, DONE0 = %d, REQ1 = %d, SIZE1 = %d DONE1 = %d", req0_in, size0_in, done0, req1_in, size1_in, done1);
    clk = 0;
    rst = 1;
    #20 rst = 0;
    req0_in = 1; size0_in = 4; req1_in = 0; size1_in = 0;
    #100
    $finish;
  end

  always #5 clk =  !clk;

endmodule
