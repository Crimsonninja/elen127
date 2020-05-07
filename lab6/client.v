module client(clk, rst, req_in, rd_data, addr_in, data_in, wr_in, size_in, addr_out, data_out, done, req_out, size_out, wr_out, wr_data, resp);

  input clk, rst, req_in, resp;
  input [31:0] addr_in;
  input [31:0] data_in;
  input [7:0] rd_data;
  input [2:0] size_in;
  input wr_in;

  output wr_out;
  output [2:0] size_out;
  output [7:0] wr_data;
  output [31:0] addr_out;
  output [31:0] data_out;
  output req_out;
  output done;

  reg [7:0] wr_data;
  reg [31:0] addr_out;
  reg [31:0] data_out;
  reg [3:0] curr_state, next_state; //change later
  reg [2:0] cnt;
  reg done;

  wire [2:0] size_out;

  assign size_in = 4;
  assign size_out = size_in;
  assign req_out = req_in;
  assign addr_out = addr_in;
  assign wr_out = wr_in;

  always@(posedge clk) begin
    if(rst ==  1'b1)
      curr_state <= 0;
    else
      curr_state <= next_state;
  end

  always@(*) begin
    case(curr_state)
      // WAIT REQ
      0 : begin //$display("Client 0");
        done = 0;
        if(req_in==1'b1 && wr_in== 1'b0)
          next_state = 1; // read state
        else if (req_in == 1'b1 && wr_in == 1'b1)
          next_state = 2;
        else
          next_state = curr_state;
        end

      //WAIT RESP to finish. Read State.
      1 : begin //$display("Client 1"); $display("cnt: %d", cnt);
        if(resp == 1 && cnt != 0) begin
          next_state = curr_state;
          done = 0;
        end
        else if(cnt == 0) begin
          next_state = 0;
          done = 1;       end
        else begin
          next_state = curr_state; // curr_state;
          done = 0;
        end
       end
      //WAIT RESP to finish. Write State.
      2: begin //$display("Client 2");
        if (resp == 1 && cnt != 0) begin
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

  //Counter to keep track of the number of responses recieved
  always@(posedge clk) begin
    if(rst == 1)
      cnt <= 0;
    //Set expected response count
    else if(curr_state == 0 && req_in == 1'b1)
      cnt <= size_in;
    //Decrement on resp == 1
    else if(resp == 1 && cnt != 0)
      cnt <=  cnt - 1;
  end

  always @(posedge clk) begin
    if (curr_state == 1) begin //$display("trying to read data"); // read data
      //$display("data_out: %h", data_out);
    case (cnt)
        1: data_out[7:0] <= rd_data;
        2: data_out[15:8] <= rd_data;
        3: data_out[23:16] <= rd_data;
      4: data_out[31:24] <= rd_data;
      default: data_out <= data_out;
      endcase
    end
    else if (curr_state == 2) begin //$display("trying to write data"); // write data
        case (cnt)
        0: wr_data <= data_in[7:0];
        1: wr_data <= data_in[15:8];
        2: wr_data <= data_in[23:16];
      3: wr_data <= data_in[31:24];
      endcase
      end
   end

endmodule
