module tb();

reg clk, reset, wr_in0, wr_in1;
reg [31:0] addr_in0;
reg [31:0] addr_in1;
reg req_in0, req_in1;
reg [31:0] data_in0, data_in1;
reg [31:0] ram_model[0:127];

wire[31:0] addr_out0;
wire [31:0] mem_addr;
wire [31:0] mem_bus;
wire [31:0] addr_out1;
wire req_out0, req_out1;
wire [31:0] data_out0, data_out1;
wire [7:0] rd_data0, wr_data0;
wire [7:0] rd_data1, wr_data1;
wire done0, done1, wr_out0, wr_out1, resp0, resp1;
integer i, err_cnt = 0;

client client0(.clk(clk), 
	      .reset(reset), 
	      .wr_in(wr_in0),
  	      .wr_out(wr_out0), 
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
 
  task init_ram_model;
    for (i=0; i<128; i=i+1) ram_model[i] = 32'd0;
    $readmemh("MIPS_Instructions.txt", ram_model);
  endtask
 
  task send_req0;
    input [31:0] addr;
    input [31:0] data_in;
    input wr;
     
    if(wr == 0) begin
      @(posedge clk)
      req_in0 = 1; addr_in0 = addr; wr_in0 = 0;
      $display("READ 0 @ %h started!!", addr_in0);
      @(posedge done0);
      req_in0 = 0;
      $display("READ 0 DONE! DATA = %h", data_out0);
      if(data_out0 == ram_model[addr_in0])
        $display("SUCCESS - CLIENT 0");
      else begin
        err_cnt = err_cnt+1;
        $display("ERROR - CLIENT 0 EXPECTED DATA = %h ACTUAL DATA = %h", ram_model[addr_in0], data_out0);
      end
    end  
    else begin
      @(posedge clk)
      req_in0 = 1; addr_in0 = addr; wr_in0 = 1; data_in0 = data_in;
      $display("WRITE 0 started! ADDR = %h DATA = %h", addr_in0, data_in0);
      @(posedge done0);
      req_in0 = 0; 
      ram_model[addr] = data_in;
      $display("WRITE 0 DONE!!");
    end  
  endtask

  task send_req1; 
    input [31:0] addr; 
    input [31:0] data_in;
    input wr;
    if(wr == 0) begin
      @(posedge clk)
      req_in1 = 1; addr_in1 = addr; wr_in1 = 0;
      $display("READ 1 @ %h started!!", addr_in1);
      @(posedge done1);
      req_in1 = 0; 
      $display("READ 1 DONE! DATA = %h", data_out1);
      if(data_out1 == ram_model[addr_in1])
        $display("SUCCESS - CLIENT 1");
      else begin
        $display("ERROR - CLIENT 1 EXPECTED DATA = %h ACTUAL DATA = %h", ram_model[addr_in1], data_out1);
        err_cnt = err_cnt+1;
      end
    end  
    else begin
      @(posedge clk)
      req_in1 = 1; addr_in1 = addr; wr_in1 = 1; data_in1 = data_in;
      $display("WRITE 1 started! ADDR = %h DATA = %h", addr_in1, data_in1);
      @(posedge done1);
      req_in1 = 0; 
      ram_model[addr] = data_in;
      $display("WRITE 1 DONE!!");
    end  
  endtask


  initial begin
    //$monitor("REQ0 = %h, RESP0 = %h, DONE0 = %h, ADDR_IN0 = %h, DATA_IN0 = %h, DATA_OUT0 = %h REQ1 = %h, RESP1 = %h, DONE1 = %h, ADDR_IN1 = %h, DATA_IN1 = %h, DATA_OUT1 = %h", req_in0, resp0, done0, addr_in0, data_in0, data_out0, req_in1, resp1, done1, addr_in1, data_in1, data_out1);
    clk = 0;
    req_in0 = 0; addr_in0 = 32'h0; wr_in0 = 0; data_in0 = 0;
    req_in1 = 0; addr_in1 = 32'h0; wr_in1 = 0; data_in1 = 0;
    //RESET
    reset_task();
    //INITIALIZE THE REFERENCE RAM MODEL
    init_ram_model();
    
    //Change the for loop to increase/decrease the number of requests
    for(i=0; i<256; i=i+1) begin
      fork
        //send req(ADDR,      	DATA_IN,   RD/WR)
        send_req0($urandom%128, $urandom, $urandom);
        send_req1($urandom%128, $urandom, $urandom);
      join
    end
    for(i=0; i<127; i=i+1) begin
      send_req0(i, 0, 0);
      $display("ERROR COUNT = %d", err_cnt);
    end
    #50
    $finish;
  end


always #5 clk = !clk;

endmodule
