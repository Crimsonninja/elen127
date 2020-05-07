module server(req0, size0, resp0, req1, size1, resp1, rst, clk);

  input [2:0] size0, size1;
  input req0, req1, rst, clk;
  output resp0, resp1;
  reg resp0, resp1, last_served;

  reg [2:0] temp0, temp1;

  reg [1:0] curr_state, next_state;

  always@(posedge clk) begin
    if (rst == 1'b1)
      curr_state <= 4'd0;
    else
      curr_state <= next_state;
  end

  always@(*) begin
  resp0 = 0;
  resp1 = 0;
    case (curr_state)
      0: begin
        if (req0==1'b1 && req1 == 1'b0) begin
          next_state = 1;
        end
        else if (req0==1'b0 && req1 == 1'b1) begin
          next_state = 2;
        end
        else if (req0==1'b1 && req1 == 1'b1 && last_served == 0)
            next_state = 2;
        else if (req0==1'b1 && req1 == 1'b1 && last_served == 1)
            next_state = 1;
        else begin
          next_state = curr_state;
        end // end else
      end // end first case
      1: begin
        if (temp0 > 0)
          next_state = 1;
        else begin
          next_state = 0;
  	resp0 = 1;
        end
      end
      2: begin
        if (temp1 > 0)
          next_state = 2;
        else begin
          next_state = 0;
  	resp1 = 1;
        end
      end
      endcase
  end

  always@(posedge clk) begin
    if (rst == 1)
      last_served <= 0;
    if (curr_state == 1 && next_state == 0)
      last_served <= 0;
    if (curr_state == 2 && next_state == 0)
      last_served <= 1;
  end

  always@(posedge clk) begin
    if (curr_state ==0 && (req0==1'b1 && req1 == 1'b0))
      temp0 <= size0;
    if (curr_state ==0 && (req0==1'b0 && req1 == 1'b1))
      temp1 <= size1;
    if (curr_state == 1 && temp0 > 0)
      temp0 <= temp0 - 1;
    if (curr_state == 2 && temp1 > 0)
      temp1 <= temp1 - 1;
  end
endmodule
