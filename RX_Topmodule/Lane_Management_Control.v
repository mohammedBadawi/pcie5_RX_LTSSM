module LMC #(parameter GEN1_PIPEWIDTH = 8, parameter GEN2_PIPEWIDTH = 16, parameter GEN3_PIPEWIDTH = 32, parameter GEN4_PIPEWIDTH = 8,
			parameter GEN5_PIPEWIDTH = 8)(input wire clk, input wire reset, input wire [2:0]GEN, 
				input wire [1:0]descramblerSyncHeader, input wire [15:0]descramblerDataValid, input wire [4:0]LANESNUMBER,
				input wire [511: 0]LMCIn , input wire [63:0]descramblerDataK, output wire LMCValid,
				output wire [63:0]LMCDataK, output wire [511:0]LMCData);

	wire [511:0]unstripedData, stripedData;
	wire [63:0]unstripedDataK, stripedDataK;
	wire [5:0]PIPEWIDTH;
	reg valid , valid_next;
	
	DataHandling #(.GEN1_PIPEWIDTH(GEN1_PIPEWIDTH), .GEN2_PIPEWIDTH(GEN2_PIPEWIDTH), .GEN3_PIPEWIDTH(GEN3_PIPEWIDTH), .GEN4_PIPEWIDTH(GEN4_PIPEWIDTH), .GEN5_PIPEWIDTH(GEN5_PIPEWIDTH)) 
					dataHandling(.LMCIn(LMCIn), .GEN(GEN), .LANESNUMBER(LANESNUMBER), .descramblerDataK(descramblerDataK), .stripedDataK(stripedDataK), .stripedData(stripedData), .PIPEWIDTH(PIPEWIDTH));
	
	UnStriping ustriping(.clk(clk), .reset(reset), .LANESNUMBER(LANESNUMBER), .PIPEWIDTH(PIPEWIDTH), .strippedDataK(stripedDataK), .strippedData(stripedData), .unstripedData(unstripedData), .unstripedDataK(unstripedDataK));
	
	always@(posedge clk or negedge reset)
		if(!reset)
			valid <= 0;
		else 
			valid <= valid_next;

	always@*
		if(descramblerDataValid != 0)
			valid_next = 1;
		else 
			valid_next = 0;
		
	assign LMCData = unstripedData;
	assign LMCDataK = unstripedDataK;
	assign LMCValid = valid;

endmodule
