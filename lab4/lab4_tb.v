`timescale 1ns/1ns;
module tb();

  reg clk, rst, farmer, fox, chicken, seeds, move;
  wire win, lose, invalid_move;
  wire[3:0] curr_state;
  wire [3:0] temp;

  lab4 dut(.clk(clk),
     .reset(rst),
     .farmer(farmer),
     .fox(fox),
    .chicken(chicken),
     .seed(seeds),
     //.move(move),
     .win(win),
       .lose(lose),
     .state(curr_state),
     .inv(invalid_move)
  );
 // temp = {farmer, fox, chicken, seeds);

  initial begin
  clk = 0;
  rst = 0;
  farmer = 0;
  fox = 0;
  chicken = 0;
  seeds = 0;
   // move = 0;
  //Reset the state machine
  #10 rst = 1'b1;
  #20 rst = 1'b0;
  //#10 reset(rst);
  $monitor("# %t, Current state = %d, inv = %d",$time, curr_state, invalid_move);
  // TEST1 Win Scenario1
  // Move Farmer & Chicken right
  #10 farmer = 1; fox = 0; chicken = 1; seeds = 0; //move = 1; // 10
  // Move Farmer left
  #10 farmer = 0; fox = 0; chicken = 1; seeds = 0; //move = 1; // 2
  // Move Farmer & Fox right
  #10 farmer = 1; fox = 1; chicken = 1; seeds = 0; //move = 1; // 14
  // Move Farmer & Chicken left
  #10 farmer = 0; fox = 1; chicken = 0; seeds = 0; //move = 1; // 8
  // Move Farmer & Seeds right
  #10 farmer = 1; fox = 1; chicken = 0; seeds = 1; //move = 1; // 13
  // Move Farmer left
  #10 farmer = 0; fox = 1; chicken = 0; seeds = 1; //move = 1; // 5
  // Move Farmer & Chicken right
  #10 farmer = 1; fox = 1; chicken = 1; seeds = 1; //move = 1; // 15
  #50;
  rst = 1'b1;
  #20 rst = 1'b0;
  #10 farmer = 1; fox = 0; chicken = 1; seeds = 0;
  #10 farmer = 1; fox = 1; chicken = 1; seeds = 1;  // invalid
  #50 rst = 1'b1;
  #10 rst = 1'b0;
  #10 farmer = 1; fox = 0; chicken = 0; seeds = 0;  // Lose
  #50

  farmer = 0;

  $finish;
  end

  always #5 clk = !clk;

  task reset;
  output rst;
    @(posedge clk) rst = 1;
    #10 rst = 0;
  endtask
endmodule
