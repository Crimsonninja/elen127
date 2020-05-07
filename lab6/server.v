module server(clk, rst, req0, req1, wr_out0, wr_out1, size0, size1, addr0, addr1, wr_data0, wr_data1, rd_data0, rd_data1, resp0, resp1, addr_out, Mem_Bus, CS, WE);

  input clk, rst, req0, req1;
  input wr_out0, wr_out1;
  input [31:0] addr0, addr1;
  input [7:0] wr_data0, wr_data1;
  input [2:0] size0, size1;

  output [7:0] rd_data0, rd_data1;
  output resp0, resp1;
  output [31:0] addr_out;
  output WE, CS;

  reg [2:0] size_0, size_1;
  reg [7:0] rd_data0, rd_data1;
  reg resp0, resp1;
  reg last_served;
  reg [2:0] curr_state, next_state;
  reg done0, done1;
  reg [31:0] read_reg;
  reg [31:0] write_reg;
  reg [31:0] addr_out;
  reg WE, CS;
  inout [31:0] Mem_Bus;

  //when write to ram, drive data from write reg onto bus
  //when read from ram, put server mem bus to hiZ
  assign Mem_Bus = ((CS == 1'b1 && WE == 1'b1))? (write_reg):32'bZ;

  // Record the last served client
  always@(posedge clk) begin
    if(rst == 1'b1) begin
      last_served <= 0;
    end
    else if(done0 == 1) begin
      last_served <= 0;
    end
    else if(done1 == 1) begin
      last_served <= 1;
    end
  end

  //Size 0 decrement
  always@(posedge clk) begin
    if(rst == 1)
      size_0 <= 0;
    else if(curr_state == 0 && req0 == 1'b1)
      size_0 <= 3;
    else if( (curr_state == 1 || curr_state == 3) && size_0 != 0)
      size_0 <= size_0-1;
  end

  //Size 1 decrement
  always@(posedge clk) begin
    if(rst == 1)
      size_1 <= 0;
    else if(curr_state == 0 && req1 == 1'b1)
      size_1 <= 4;
    else if( (curr_state == 2 || curr_state == 4 ) && size_1 != 0)
      size_1 <= size_1-1;
  end

  always@(posedge clk) begin
    if(rst ==  1'b1) begin
      curr_state <= 0;
    end
    else begin
      curr_state <= next_state;
    end
  end

  always@(*) begin
    case(curr_state)
      0 : begin //$display("Server 0");
        if( (req0 == 1 && req1 == 0) || (req0 == 1 && req1 == 1 && last_served == 1) ) begin
          if (wr_out0 == 0)
            next_state = 1; // READ 0
           else if (wr_out0 == 1)
            next_state = 3; // WRITE 0
         end
        else if( (req0 == 0 && req1 == 1) || (req0 == 1 && req1 == 1 && last_served == 0) ) begin
          if (wr_out1 == 0)
            next_state =  2; //READ 1
          else if (wr_out1 == 1)
            next_state = 4; // WRITE 1
         end
        else
          next_state = curr_state;
        done0 = 0;
        done1 = 0;
        resp0 = 0;
        resp1 = 0;
      end
      //READ 0
      1 : begin //$display("Server 1");
        if(size_0 == 0) begin
          next_state = 0;
          done0 = 1;
          done1 = 0;
          resp0 = 1;
          resp1 = 0;
        end
        else begin
          next_state = curr_state;
          done0 = 0;
          done1 = 0;
          resp0 = 1;
          resp1 = 0;
        end
      end
      // READ_1
      2: begin //$display("Server 2");
        if(size_1 == 0) begin
          next_state = 0;
          done0 = 0;
          done1 = 1;
        end
        else begin
          next_state = curr_state;
          done0 = 0;
          done1 = 0;
        end
        resp0 = 0;
        resp1 = 1;
      end
      // WRITE 0
      3: begin //$display("Server 3");
        if(size_0 == 0) begin
          next_state = 0;
          done0 = 1;
          done1 = 0;
        end
        else begin
          next_state = curr_state;
          done0 = 0;
          done1 = 0;
        end
        resp0 = 1;
        resp1 = 0;
      end
      // WRITE 1
      4 : begin //$display("Server 4");
        if(size_1 == 0) begin
          next_state = 0;
          done0 = 0;
          done1 = 1;
        end
        else begin
          next_state = curr_state;
          done0 = 0;
          done1 = 0;
        end
        resp0 = 0;
        resp1 = 1;
      end
      default : begin
        next_state = 0;
        done0 = 0;
        done1 = 0;
        resp0 = 0;
        resp1 = 1;
      end
    endcase
  end

  always @ (*) begin
    if (curr_state == 1 || curr_state == 2) begin
      CS = 1;
      WE = 0;
    end
    else if (curr_state == 3|| curr_state == 4) begin
      CS = 1;
      WE = 1;
    end
  end

  always @ (posedge clk) begin
   if (CS == 1 && WE == 0) //(curr_state == 1 || curr_state == 2)
       read_reg <= Mem_Bus; //$display("read_reg: %h", read_reg);
  end

  always @ (posedge clk) begin
    if (curr_state == 1) begin // READ 0
      addr_out <= addr0;
      //$display("read_reg: %h", read_reg);
    case (size_0)
        0: rd_data0 <= read_reg[7:0];
        1: rd_data0 <= read_reg[15:8];
        2: rd_data0 <= read_reg[23:16];
        3: rd_data0 <= read_reg[31:24];
       endcase
    end
    else if (curr_state == 2) begin// READ 1
      addr_out <= addr1;
      case (size_1)
        1: rd_data1 <= read_reg[7:0];
        2: rd_data1 <= read_reg[15:8];
        3: rd_data1 <= read_reg[23:16];
        4: rd_data1 <= read_reg[31:24];
      endcase
    end
    else if (curr_state == 3) begin // WRITE 0
      addr_out <= addr0;
      case (size_0)
        0: write_reg[7:0] <= wr_data0;
        1: write_reg[15:8] <= wr_data0;
        2: write_reg[23:16] <= wr_data0;
        3: write_reg[31:24] <= wr_data0;
      endcase
    end
    else if (curr_state == 4) begin // WRITE 1
      addr_out <= addr1;
      case (size_1)
        0: write_reg[7:0] <= wr_data1;
        1: write_reg[15:8] <= wr_data1;
        2: write_reg[23:16] <= wr_data1;
        3: write_reg[31:24] <= wr_data1;
      endcase
    end
  end

endmodule
