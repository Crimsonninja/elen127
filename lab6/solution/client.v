module client(clk, 
	      reset, 
	      wr_in,
  	      wr_out, 
              //size_in, 
              //size_out,
              resp, 
              addr_in, 
              addr_out, 
              data_in, 
              data_out,
              rd_data,
              wr_data,
              done,
              req_in, 
              req_out);

input clk, reset, wr_in, req_in, resp;
input [31:0] addr_in, data_in;
input [7:0] rd_data;
//input [2:0] size_in;

output reg done;
output reg [7:0] wr_data;
output reg [31:0] data_out;
output req_out;
output [31:0] addr_out;
output wr_out;


reg [2:0] cnt; 
reg [1:0] curr_state, next_state;

/*   write operation => wr=1
 *   read operation =>wr=0
 *   address 8 bit or 256 locations => addr
 *   done => the required byte of read data is available
 *   8 bit write data => data_in
 *   8 bit read data => data_out
 *   request from testbench => req_in
 *   request size from testbench => size_in
 *   request size to server => size_out
 *   request to the server  => req_out
 *   clk => clk
 *   reset */

assign req_out =  req_in;
assign addr_out = addr_in;
assign wr_out = wr_in;

always@(posedge clk) begin
  if(reset == 1)
    curr_state <= 0;
  else
    curr_state <= next_state;
end

always@(*) begin
  case(curr_state)
    //Wait req
    0: begin
      if(req_in == 1 && wr_in == 0)
        next_state = 1;
      else if (req_in == 1 && wr_in ==1)
        next_state = 2;
      else
        next_state =  curr_state;
      done = 0;
    end
    //read
    1: begin
      if(resp == 1) begin
        next_state = curr_state;
        done = 0;
      end
      else if(cnt == 0) begin
        next_state = 0;
        done = 1;
      end
      else begin
        next_state = curr_state;
        done = 0;
      end
    end
    //write
    2: begin
      if(resp == 1) begin
        next_state = curr_state;
        done = 0;
      end
      else if(cnt == 0) begin
        next_state = 0;
        done = 1;
      end
      else begin
        next_state = curr_state;
        done = 0;
      end
    end
    default: begin
      next_state = 0;
      done = 0;
    end
  endcase
end

//read/wr counter
always@(posedge clk) begin
  if(reset == 1)
    cnt <= 0;
  else if(curr_state == 0 && req_in == 1)
    //cnt <= size_in-1;
    cnt <= 4;
  else if((curr_state == 1 || curr_state == 2) && resp == 1)
    cnt <= cnt - 1;
end

//READ
always@(posedge clk) begin
  if(reset)
    data_out <= 0;
  else if(curr_state == 1 && resp == 1 && cnt == 4)
    data_out[31:24] <= rd_data;
  else if(curr_state == 1 && resp == 1 && cnt == 3)
    data_out[23:16] <= rd_data;
  else if(curr_state == 1 && resp == 1 && cnt == 2)
    data_out[15:8] <= rd_data;
  else if(curr_state == 1 && resp == 1 && cnt == 1)
    data_out[7:0] <= rd_data;
end

//WRITE
always@(*) begin
  if(reset == 1)
    wr_data<= 0;
  else if(curr_state == 2 && resp == 1 && cnt == 4)
    wr_data = data_in[31:24];
  else if(curr_state == 2 && resp == 1 && cnt == 3)
    wr_data = data_in[23:16];
  else if(curr_state == 2 && resp == 1 && cnt == 2)
    wr_data = data_in[15:8];
  else if(curr_state == 2 && resp == 1 && cnt == 1)
    wr_data = data_in[7:0];
end
endmodule
