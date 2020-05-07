module FullAdder(X, Y, Cin, Cout, Sum);
  output Cout, Sum;

  input X, Y, Cin;

  assign Sum = X ^ Y ^ Cin;
  assign Cout = (X & Y) | (X & Cin) | (Y & Cin);
endmodule
