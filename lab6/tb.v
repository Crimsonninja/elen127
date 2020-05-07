module tb();

reg clk, reset, wr_in0, wr_in1;
reg [31:0] addr_in0;
wire[31:0] addr_out0;
reg [31:0] addr_in1;
wire [31:0] mem_addr;
wire [31:0] mem_bus;
wire [31:0] addr_out1;
reg req_in0, req_in1;
wire req_out0, req_out1;
reg [31:0] data_in0, data_in1;
wire [31:0] data_out0, data_out1;
wire [7:0] rd_data0, wr_data0;
wire [7:0] rd_data1, wr_data1;
wire done0, done1, wr_out0, wr_out1, resp0, resp1;

client client0(.clk(clk), 
	      .reset(reset), 
	      .wr_in(wr_in0),
  	      .wr_out(wr_out0), 
              .size_in(), 
              .size_out(),
              .resp(resp0), 
              .addr_in(addr_in0), 
              .addr_out(addr_out0), 
              .data_in(data_in0), 
              .data_out(data_out0),
              .rd_data(rd_data0),
              .wr_data(wr_data0),
              .done(done0),
              .req_in(req_in0), 
              .req_out(req_out0));

client client1(.clk(clk), 
	      .reset(reset), 
	      .wr_in(wr_in1),
  	      .wr_out(wr_out1), 
              .size_in(), 
              .size_out(),
              .resp(resp1), 
              .addr_in(addr_in1), 
              .addr_out(addr_out1), 
              .data_in(data_in1), 
              .data_out(data_out1),
              .rd_data(rd_data1),
              .wr_data(wr_data1),
              .done(done1),
              .req_in(req_in1), 
              .req_out(req_out1));

server server0(.clk(clk),
   	      .reset(reset),
              .req0(req_out0),
              .req1(req_out1),
              .wr0(wr_out0),
              .wr1(wr_out1),
              .wr_data0(wr_data0),
              .wr_data1(wr_data1),
              .rd_data0(rd_data0),
              .rd_data1(rd_data1),
              .resp0(resp0),
              .resp1(resp1),
              .addr0(addr_out0),
              .addr1(addr_out1),
              .cs(cs),
              .we(we),
              .mem_addr(mem_addr),
              .mem_bus(mem_bus)             
              );

  Memory mem(.CS(cs),
	     .WE(we),
	     .CLK(clk),
             .ADDR(mem_addr),
             .Mem_Bus(mem_bus)); 
 
  task reset_task; begin
    reset = 1;
    req_in0 = 0; req_in1 = 0;
    #20 reset = 0;
  end
  endtask
  
  task send_rd_req0; 
    begin
      @(posedge clk)
      req_in0 = 1; addr_in0 = 32'h0; wr_in0 = 0;
      $display("REQUEST 0 started!!");
      @(posedge done0);
      req_in0 = 0; 
      $display("REQUEST 0 DONE!!");
    end  
  endtask

  initial begin
    $monitor("REQ0 = %h, DONE0 = %h, ADDR_IN0 = %h, DATA_IN0 = %h, DATA_OUT0 = %h", req_in0, done0, addr_in0, data_in0, data_out0);
    clk = 0;
    reset_task();
    send_rd_req0();
    #50
    $finish;
  end


always #5 clk = !clk;

endmodule
