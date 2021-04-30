module osDecoder #(
parameter Width = 32,
parameter GEN1_PIPEWIDTH = 64 ,	
parameter GEN2_PIPEWIDTH = 8 ,	
parameter GEN3_PIPEWIDTH = 8 ,	
parameter GEN4_PIPEWIDTH = 8 ,	
parameter GEN5_PIPEWIDTH = 8 )
(
input clk,
input [2:0]gen,
input reset,
input [4:0]numberOfDetectedLanes,
input [511:0]data,
input validFromLMC,
input linkUp
output reg valid);

reg [9:0]width;
reg [2047:0]orderedSets,out;
reg [2:0]numberOfShifts;
reg found;
reg [11:0]capacity;
integer i;

parameter[7:0]
COM = 	8'b10111100, //BC
gen3TS1 = 8'h1E,
gen3TS2 = 8'h2D,
gen3SKIP =8'hAA, 
STP = 8'b11111011,
SDP = 8'b01011100,
SDS = 8'hE1;
always@(posedge clk or negedge reset)
begin
if(!reset)orderedSets =2048'b0;

end
always@(posedge clk)
begin
found = 1'b0;
valid = 1'b0;
if(validFromLMC)
begin
for(i=504;i>=0;i=i-8)
begin	
	if(data[i+:8]==COM &&!found/*||data[i+:8]==gen3TS1||data[i+:8]==gen3TS2||data[i+:8]==gen3SKIP*/)
	begin
	found = 1'b1;
	if(capacity+i-((numberOfDetectedLanes-1)<<3) >= 128<<numberOfShifts)
	begin
	valid = 1'b1;
	out = orderedSets|(data)<<capacity;
	end
	orderedSets = data>>i-((numberOfDetectedLanes-1)<<3);
	capacity = width-i+((numberOfDetectedLanes-1)<<3);
	end

	
end
	if(!found)
	begin
	orderedSets = orderedSets|((2048'b0|data) << capacity);
	capacity = capacity + width;
	if(capacity >= (128<<numberOfShifts))
	begin
	valid = 1'b1;
	out = orderedSets;
	end
	end
end
end

always@(*)
begin
case(numberOfDetectedLanes)
5'd1:numberOfShifts = 3'd0;
5'd2:numberOfShifts = 3'd1;
5'd4:numberOfShifts = 3'd2;
5'd8:numberOfShifts = 3'd3;
5'd16:numberOfShifts= 3'd4;
endcase
end


always@(*)
begin
case (gen)
3'b001 : width = GEN1_PIPEWIDTH<<(numberOfShifts);
3'b010 : width = GEN2_PIPEWIDTH<<(numberOfShifts);
3'b011 : width = GEN3_PIPEWIDTH<<(numberOfShifts);
3'b100 : width = GEN4_PIPEWIDTH<<(numberOfShifts);
3'b101 : width = GEN5_PIPEWIDTH<<(numberOfShifts);
endcase
end
endmodule








module osDecoderTB;
reg clk;
reg reset;
reg [4:0]numberOfDetectedLanes;
reg [511:0]data;
reg validFromLMC;
reg linkUp;
osDecoder os(
 clk,
 3'b001,
 reset,
 numberOfDetectedLanes,
 data,
 validFromLMC,
 linkUp);


initial
begin
clk = 0;
validFromLMC = 1'b1;
numberOfDetectedLanes = 5'd2;
#8
reset = 1;
#10
data = 128'hBBBCBCBBBBBBBBBBBBBBBBBBBCBCBCBC;
#10
data = 128'hAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA;
#10
data = 128'hBBBCBCBBBBBBBBBBBBBBBBBBBCBCBCBC;
#10
data = 512'd0;
#10
validFromLMC=1'b0;
end
always #5 clk = ~clk;
endmodule