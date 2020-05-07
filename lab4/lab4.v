module lab4 (farmer, fox, chicken, seed, reset, clk, win, lose, inv, state);

    input farmer, fox, chicken, seed;
    wire [3:0] temp;
    input reset;
    input clk;
    output win, lose;
    output inv, state;
    reg inv, lose, win;
    reg [3:0] NS;
    reg [3:0] state;

    assign temp = {farmer, fox, chicken, seed};

    always @ (*) begin
    case(state)
        0: begin // 0000
            if (temp == 4'b1010)
            begin
                $display("State 0");
                NS = temp;
                win = 0;
                lose = 0;
                inv = 0;
            end
            else if (temp == 4'b1000 || temp == 4'b1100 || temp == 4'b1001) begin
                NS = temp; // LOSE
                win = 0;
                lose = 1;
                inv = 0;
            end
            else begin
                inv = 1;
                win = 0;
                lose = 0;
                NS = state;
            end
        end
        1: begin // 0001
            if (temp == 4'b1101) begin
                NS = 13;
                win = 0;
                lose = 0;
                inv = 0;
            end
            else if (temp == 4'b1011) begin
                NS = 11;
                win = 0;
                lose = 0;
                inv = 0;
            end
            else if (temp == 4'b1001) begin
                NS = 16; // LOSE
                win = 0;
                lose = 1;
                inv = 0;
            end
            else begin
                win = 0;
                lose = 0;
                inv = 1;
                NS = state;
            end
        end
        2: begin // 0010
        $display("State 2");
            if (temp == 4'b1010) begin
                NS = 10;
                win = 0;
                lose = 0;
                inv = 0;
            end
            else if (temp == 4'b1110) begin
                NS = 14;
                win = 0;
                lose = 0;
                inv = 0;
            end
            else if (temp == 4'b1011) begin
                NS = 11;
                win = 0;
                lose = 0;
                inv = 0;
            end
            else begin
            inv = 1;
          win = 0;
          lose = 0;
            NS = state;
            end
        end
        3: begin // 0011
            NS = 16;
            win = 0;
            lose = 1;
            inv = 0;
        end
        4: begin // 0100
            if (temp == 4'b1110) begin
                win = 0;
                lose = 0;
                inv = 0;
                NS = 14;
            end
            else if (temp == 4'b1101) begin
                NS = 13;
                win = 0;
                lose = 0;
                inv = 0;
            end
            else if (temp == 4'b1100) begin
                NS = 16; // LOSE
                win = 0;
                lose = 0;
                inv = 0;
            end
            else begin
            inv = 1;
          win = 0;
          lose = 0;
            NS = state;
            end
        end
        5: begin // 0101
            if (temp == 4'b1101) begin
                win = 0;
                lose = 0;
                inv = 0;
                NS = 13;
            end
            else if (temp == 4'b1111) begin
                win = 0;
                lose = 0;
                inv = 0;
                NS = 15;
            end
            else begin
                    inv = 1;
                win = 0;
                    lose = 0;
                    NS = state;
                end
           end
        6:  begin // 0110
                NS = 16;  // Lose
            win = 0;
            lose = 1;
            inv = 0;
        end
      7:  begin // 0111
            NS = 16;  // Lose
        win = 0;
        lose = 1;
        inv = 0;
        end
      8:  begin // 1000
            NS = 16;  // Lose
        win = 0;
        lose = 1;
        inv = 0;
        end
      9:  begin // 1001
            NS = 16;  // Lose
          win = 0;
            lose = 1;
        inv = 0;
        end
      10: begin // 1010
            $display("State 10");
            if (temp == 4'b0000) begin
            NS = 0;
          win = 0;
          lose = 0;
          inv = 0;
        end
            else if (temp == 4'b0010) begin
            NS = 2;
          win = 0;
          lose = 0;
          inv = 0;
        end
            else begin
            inv = 1;
          win = 0;
          lose = 0;
            NS = state;
            end
        end
      11: begin // 1011
            if (temp == 4'b0001)
            NS = 1;
            else if (temp == 4'b0010)
            NS = 2;
            else if (temp == 4'b0011)
            NS = 16;
            else begin
            inv = 1;
            NS = state;
            end
        end
      12: begin
            NS = 16;
        end
      13: begin
        $display("State 13");
        if (temp == 4'b0101)
            NS = 5;
        else if (temp == 4'b0001)
            NS = 1;
        else if (temp == 4'b0100)
            NS = 4;
        else begin
            inv = 1;
            NS = state;
        end
        end
      14: begin
        $display("State 14");
            if (temp == 4'b0110) begin
        win = 0;
        lose = 0;
        inv = 0;
            NS = 6;
        end
        else if (temp == 4'b0010) begin
        win = 0;
        lose = 0;
        inv = 0;
            NS = 2;
        end
        else if (temp == 4'b0100) begin
            NS = 4;
        win = 0;
        lose = 0;
        inv = 0;
        end
        else begin
            inv = 1;
        win = 0;
        lose = 0;
            NS = state;
        end
        end
      15: begin
            win = 1;
            NS = state;
        end
      16: begin
        lose = 1;
        NS = state;
        end
      default: NS = 0;
    endcase
    end

    always @ (posedge clk) begin // update state
    if (reset == 1)
        NS <= 0;
    else
        state <= NS;
    end

endmodule
