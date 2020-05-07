module FullSub(X, Y, Bin, Bout, Re);
  output Bout, Re;

  input X, Y, Bin;

  assign Re = X ^ Y ^ Bin;
  assign Bout = (~X & Y) | (~(X ^ Y) & Bin);
endmodule
