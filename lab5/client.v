module client(req_in, size_in, resp, req_out, size_out, done, rst, clk);

input req_in, size_in, resp, rst, clk;
output req_out, size_out, done;

reg done, req_out;
reg [2:0] size_in, size_out, temp;

reg [1:0] curr_state, next_state;

always@(posedge clk) begin
if (rst == 1'b1)
  curr_state <= 4'd0;
else curr_state <= next_state;
end

always @(*) begin
  done = 0;
  case(curr_state)
    0: begin   // reset/beginning state
      if (req_in == 1'b1) begin
        next_state = 1;
      end
      else begin
      next_state = 0;
      end
    end
    1: begin // request received
      if (resp == 1'b1)
        next_state = 2;
      else
        next_state = 1;
    end
    2: begin // process request
      if (temp == 0) begin
        next_state = 0;
	done = 1;
      end
      else begin
        next_state = 2;
      end
    end
    endcase     
end

always@(posedge clk) begin
  req_out<=req_in;
  size_out<=size_in;
end

always@ (posedge clk) begin
  if (curr_state == 0 & req_in == 1'b1)
    temp <= size_in;
  if (curr_state == 2)
    temp <= temp - 1;
end

endmodule
