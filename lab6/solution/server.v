module server(clk,
   	      reset,
              req0,
              req1,
              wr0,
              wr1,
              wr_data0,
              wr_data1,
              rd_data0,
              rd_data1,
              resp0,
              resp1,
              addr0,
              addr1,
              cs,
              we,
              mem_addr,
              mem_bus             
              );

input clk, reset, req0, req1, wr0, wr1;
input [31:0] addr0, addr1;
input [7:0] wr_data0, wr_data1;
output reg [7:0] rd_data0, rd_data1;
output reg resp0, resp1, cs, we;
output reg [31:0] mem_addr;
inout [31:0] mem_bus;

reg last_served;
reg [2:0] curr_state, next_state, cnt;
reg done0, done1;
reg [31:0] mem_data_rd;
reg [31:0] mem_data_wr;


//last served
always@(posedge clk) begin
  if(reset == 1)
    last_served <= 0;
  else begin
    if(done0 == 1)
      last_served <= 0;
    else if(done1 == 1)
      last_served <= 1;
  end
end

always@(posedge clk) begin
  if(reset ==  1)
    curr_state <= 0;
  else
    curr_state <= next_state;
end

always@(*) begin
  case(curr_state)
    0: begin
      //req0 read
      if(req0 == 1 && req1 == 0 && wr0 == 0)
        next_state = 1;
      //req0 write
      else if(req0 == 1 && req1 == 0 && wr0 == 1)
        next_state = 2;
      //req1 read
      else if(req0 == 0 && req1 == 1 && wr1 == 0)
        next_state =  3;
      //req1 write
      else if(req0 == 0 && req1 == 1 && wr1 == 1)
        next_state =  4;
      else if(req0 == 1 && req1 == 1 && last_served == 1) begin
        if(wr0 == 0) //req0 read
	  next_state = 1;
        else // req0 write
	  next_state = 2;
      end
      else if(req0 == 1 && req1 == 1 && last_served == 0) begin
        if(wr1 == 0) //req0 read
	  next_state = 3;
        else
	  next_state = 4;
      end
      else
        next_state = curr_state;
    end
    //REQ0 READ
    1: begin
      if(cnt == 0) begin
        next_state = 0;
      end
      else begin
        next_state = curr_state;
      end
    end
    //REQ0 WRITE
    2: begin
      if(cnt == 0) begin
        next_state = 0;
      end
      else begin
        next_state = curr_state;
      end
    end
    //REQ1 READ
    3: begin
      if(cnt == 0) begin
        next_state = 0;
      end
      else begin
        next_state = curr_state;
      end
    end
    //REQ0 WRITE
    4: begin
      if(cnt == 0) begin
        next_state = 0;
      end
      else begin
        next_state = curr_state;
      end
    end
  endcase
end

//read/wr counter
always@(posedge clk) begin
  if(reset == 1)
    cnt <= 0;
  else if(curr_state == 0 && (req0 == 1 || req1 == 1))
    //cnt <= size_in-1;
    cnt <= 4;
  else if((curr_state == 1 || curr_state == 2 || curr_state == 3 || curr_state == 4))
    cnt <= cnt - 1;
  else
    cnt <= 0;
end

//mem write0
always@(posedge clk) begin
  if(reset == 1) begin 
    mem_data_wr <= 0;
  end
  else if(curr_state == 2 && cnt == 4) begin
    mem_data_wr[31:24] <= wr_data0;
  end
  else if(curr_state == 2 && cnt == 3) begin
    mem_data_wr[23:16] <= wr_data0;
  end
  else if(curr_state == 2 && cnt == 2) begin
    mem_data_wr[15:8] <= wr_data0;
  end
  else if(curr_state == 2 && cnt == 1) begin
    mem_data_wr[7:0] <= wr_data0;
  end
end

//mem write1
always@(posedge clk) begin
  if(reset == 1) begin
    mem_data_wr <= 0;
  end
  else if(curr_state == 4 && cnt == 4) begin
    mem_data_wr[31:24] <= wr_data1;
  end
  else if(curr_state == 4 && cnt == 3) begin
    mem_data_wr[23:16] <= wr_data1;
  end
  else if(curr_state == 4 && cnt == 2) begin
    mem_data_wr[15:8] <= wr_data1;
  end
  else if(curr_state == 4 && cnt == 1) begin
    mem_data_wr[7:0] <= wr_data1;
  end
end



//mem read 0
always@(*) begin
  if(curr_state == 1 && cnt == 3)
    rd_data0 = mem_data_rd[31:24];
  else if(curr_state == 1 && cnt == 2)
    rd_data0 =mem_data_rd[23:16];
  else if(curr_state == 1 && cnt == 1)
    rd_data0 =mem_data_rd[15:8];
  else if(curr_state == 1 && cnt == 0)
    rd_data0 =mem_data_rd[7:0];
end

//mem read 1
always@(*) begin
  if(curr_state == 3) begin
    case(cnt)
      3: rd_data1 = mem_data_rd[31:24];
      2: rd_data1 = mem_data_rd[23:16];
      1: rd_data1 = mem_data_rd[15:8];
      0: rd_data1 = mem_data_rd[7:0];
    endcase
  end
  else
    rd_data1 = 0;
end

//CS && WE
always@(*) begin
  //Read
  if(curr_state == 1 && cnt == 4) begin
    cs = 1;
  end
  //Write
  else if(curr_state == 2 && cnt == 0) begin
    cs = 1;
  end
  else if(curr_state == 3 && cnt == 4) begin
    cs = 1;
  end
  else if(curr_state == 4 && cnt == 0) begin
    cs = 1;
  end
  else
    cs = 0;
end

always@(*) begin
  //Write
  if((curr_state == 2 || curr_state == 4) && cnt == 0) begin
    we = 1;
  end
  else
    we = 0;
end


// MEMORY ADDRESS
always@(*) begin
  if(curr_state == 1 || curr_state == 2)
    mem_addr = addr0;
  else if(curr_state == 3 || curr_state == 4)
    mem_addr = addr1;
end

//MEM BUS
assign mem_bus = ((cs == 1'b1) && (we == 1'b1))?mem_data_wr:32'bz;

always @(posedge clk) begin
  if ((cs == 1'b1) && (we == 1'b0))
    mem_data_rd <= mem_bus;
end

//RESP 0
always@(*) begin
  if((curr_state == 1) && cnt < 4) begin
    resp0 = 1;
  end
  else if((curr_state == 2) && cnt > 0) begin
    resp0 = 1;
  end
  else begin
    resp0 = 0;
  end
end

//RESP 1
always@(*) begin
  if((curr_state == 3) && cnt < 4) begin
    resp1 = 1;
  end
  else if((curr_state == 4) && cnt > 0) begin
    resp1 = 1;
  end
  else begin
    resp1 = 0;
  end
end

//DONE0
always@(*) begin
  if((curr_state == 1 || curr_state == 2) && cnt== 0)
    done0 = 1;
  else
    done0 = 0;
end

//DONE0
always@(*) begin
  if((curr_state == 1 || curr_state == 2) && cnt== 0)
    done1 = 1;
  else
    done1 = 0;
end
endmodule
