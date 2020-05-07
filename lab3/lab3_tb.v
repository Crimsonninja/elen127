module tb();

reg [2:0] read_addr0, read_addr1, write_addr;
reg [7:0] write_data, read_data0, read_data1;
reg write_en, clk;

integer i;

register8 dut(.rdAddrA(read_addr0),
            .rdAddrB(read_addr1),
            .dataA(read_data0),
            .dataB(read_data1),
            .writeAddr(write_addr),
            .writeData(write_data),
            .writeEn(write_en),
            .clk(clk));

initial begin
  clk = 0;
  $display("Start of test");
  $monitor("# %t, WRITE/READ = %d : WR_ADDR = %d  WR_DATA = %d RD_ADDR0 = %d RD_DATA0 = %d",
  $time, write_en, write_addr, write_data, read_addr0, read_data0);
  read_addr0 = 4'd1;
  read_addr1 = 4'd1;
  write_addr = 4'd1;
  write_en = 1;
  write_data = 15;
  #20
  for(i=0; i<16; i=i+1) begin
    write_en = 1'b1;
    write_data = $urandom%256;
    //write_addr = $urandom%8;
    write_addr = i;
    $display("WRITE: Addr = %h, DATA = %h", write_addr, write_data);
    //#10;
    write_en = 1'b1;
    read_addr0 = i;
    read_addr1 = 15-i;
    #10;
  end
  
  $display("End of test");
  #10;
  $finish;
end

always #5 clk = !clk;

endmodule
