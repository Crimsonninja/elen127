module Sub5BCD(S, R);
  output [4:0] R;

  input [4:0] S;

  wire [5:1] B;

  FullSub FS0(S[0], 0,    0, B[1], R[0]);
  FullSub FS1(S[1], 1, B[1], B[2], R[1]);
  FullSub FS2(S[2], 0, B[2], B[3], R[2]);
  FullSub FS3(S[3], 1, B[3], B[4], R[3]);
  FullSub FS4(S[4], 0, B[4], B[5], R[4]);
endmodule
