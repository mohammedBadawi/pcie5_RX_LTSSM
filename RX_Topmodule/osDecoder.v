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
input linkUp,
output reg valid,
output reg [2047:0]outOs);

reg [9:0]width;
reg [2047:0]orderedSets,out;
reg [2:0]numberOfShifts;
reg found;
reg [3:0] lane_iter;
reg [6:0] index_iter;
reg [11:0]capacity;
integer i,j;

parameter[7:0]
COM = 	8'b10111100, //BC
gen3TS1 = 8'h1E,
gen3TS2 = 8'h2D,
gen3SKIP =8'hAA, 
STP = 8'b11111011,
SDP = 8'b01011100,
SDS = 8'hE1;


parameter [175:0] lanesOffsets ={11'd1920,11'd1792,11'd1664,11'd1536,11'd1408,11'd1280,11'd1152
,11'd1024,11'd896,11'd768,11'd640,11'd512,11'd384,11'd256,11'd128,11'd0};
always@(posedge clk or negedge reset)
begin
if(!reset)
begin
orderedSets =2048'b0;
lane_iter = 4'd0;
index_iter = 7'd0;
end

end
always@(posedge clk)
begin
if(valid)
begin
valid = 1'b0;
capacity = 12'd0;
end
found = 1'b0;
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

//reg [11:0]test1 = lanesOffsets[((1<<3)+(1<<1)+1) +: 11];
//reg [11:0]test2 = lanesOffsets[1*11 +: 11];

always@(out)
begin
	
	for(j = 0;j<128<<numberOfShifts;j=j+8)
	begin
	outOs[(lanesOffsets[((lane_iter<<3)+(lane_iter<<1)+lane_iter) +: 11]+index_iter)+:8] = out[j+:8];
	if(lane_iter==numberOfDetectedLanes-1)
	begin
	lane_iter = 4'd0;
	index_iter = index_iter + 8; 
	end
	else lane_iter = lane_iter + 1'b1;
	end
end
endmodule








module osDecoderTB;
reg clk;
reg reset;
reg [4:0]numberOfDetectedLanes;
reg [511:0]data;
reg validFromLMC;
reg linkUp;
wire valid;
wire [2047:0]outOs;
osDecoder os(
clk,
3'b001,
reset,
numberOfDetectedLanes,
data,
validFromLMC,
linkUp,
valid,
outOs);

initial
begin
clk = 0;
reset = 0;
validFromLMC = 1'b1;
numberOfDetectedLanes = 5'd2;
#8
reset = 1;
#10
data = 512'hAABBAABBBCBC00000000000000000000;
#10
data = 512'hAABBAABBAABBAABBAABBAABBAABBAABB;
#10
data = 512'h000000000000AABBAABBAABBAABBAABB;
#10
data = 512'd0;
#10
validFromLMC=1'b0;
end
always #5 clk = ~clk;
endmodule