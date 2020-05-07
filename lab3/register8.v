module register8(clk, writeEn, writeAddr, writeData, rdAddrA, rdAddrB, dataA, dataB);

input clk, writeEn;
input [2:0] writeAddr, rdAddrA, rdAddrB;
input [7:0] writeData;
output [7:0] dataA, dataB;
reg [7:0] dataA, dataB;
reg[7:0] registers[0:7];

// bypass logic
//assign dataA = registers[rdAddrA];
//assign dataB = registers[rdAddrB];

// update data into the register at location writeAddr every cycle
always @(posedge clk) begin
	if (writeEn==1) begin
		registers[writeAddr]<=writeData;
	end
end

always @* begin
	if (rdAddrA == writeAddr)
		dataA = writeData;
        else
                dataA = registers[rdAddrA];
end

always @* begin
	if (rdAddrB == writeAddr)
		dataB = writeData;
	else
		dataB = registers[rdAddrB];
end

endmodule
