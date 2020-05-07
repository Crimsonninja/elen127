module topLayer(dig1, dig2, hex0, h3x1, hex2, hex3);

  output [6:0] hex0, hex1, hex2, hex3;

  input [3:0] dig1, dig2;

  wire [4:0] sum0, sum1;

  reg [6:0] hex3;
  reg [3:0] sumF;

  BCDDecoder BCD0(dig1, hex0);
  BCDDecoder BCD1(dig2, hex1);
  BCDDecoder BCD2(sumF, hex2);

  Adder4 AD0(dig1, dig2, sum0[3:0], sum0[4]);
  Sub5BCD SB0(sum0, sum1);

  always @(*) begin
    if (sum0 >= 5'b01010) begin
      hex3 <= 7'b1111001;
      sumF <= sum1[3:0];
    end
    else begin
      hex3 <= 7'b1000000;
      sumF <= sum0[3:0];
    end
  end

endmodule
