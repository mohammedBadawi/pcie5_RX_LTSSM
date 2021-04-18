module os_checker #(parameter LANESNUMBER,parameter DEVICETYPE)(
    input clk,
input linkNumber,
    input [127:0]orderedset,
    input valid,
    input [3:0]substate,
    input reset,
    output countup,
    output resetcounter,
    output [7:0] rateid,
    output upconfigure_capability);

    //LOCLA VARIABLES
    reg[4:0] currentState,nextState;
    reg[127:0] localorderedset;

    localparam [7:0]
    PAD = 8'b11110111,
    TS1 = 8'b0101010,
    TS2 = 8'b0100101;
//input substates from main ltssm
    localparam [3:0]
	detectQuiet =  3'd0,
	detectActive = 3'd1,
	pollingActive= 3'd2,
	pollingConfiguration= 3'd3,
    	configurationLinkWidthStart = 3'd4,
    	configurationLinkWidthAccept = 3'd5,
    	configurationLanenumWait = 3'd6,
    	configurationLanenumAccept = 3'd7,
    	configurationComplete = 3'd8,
    	configurationIdle = 3'd9;


//internal states
    localparam [4:0]
    	start = 4'd0,
	pollingActive1= 4'd1,
    	pollingActive2= 4'd2,
	pollingConfiguration1= 4'd3,
    	pollingConfiguration2= 4'd4,
	configLinkWidthStartDown1 = 4'd5,
	configLinkWidthStartDown2 = 4'd6,
	configLinkWidthStartUp1 = 4'd7,
	configLinkWidthStartUp2 = 4'd8;


//CURRENT STATE FF
always @(posedge clk or negedge reset)
begin
    if(!reset)
    begin
        currentState <= start;
    end
    else
    begin
        currentState <= nextState;
        if(valid)localorderedset<=orderedset;
    end    
end

//next state logic block
always @(*)
begin
    case(currentState)
    start:
    if(substate == pollingActive) nextState = pollingActive1;
    else if (substate == configurationLinkWidthStart && DEVICETYPE == 1'b0)nextState = configLinkWidthStartDown1;
else if (substate == configurationLinkWidthStart && DEVICETYPE == 1'b1)nextState = configLinkWidthStartUp1;
    else nextState = start;

    pollingActive1:
    if((valid && orderedset[15:8]==PAD && orderedset[23:16]==PAD && orderedset[43] == 1'b0 && orderedset[87:80] == TS1)||
    (valid && orderedset[15:8]==PAD && orderedset[23:16]==PAD && orderedset[87:80] == TS2)||
    (valid && orderedset[15:8]==PAD && orderedset[23:16]==PAD && orderedset[42] == 1'b1 && orderedset[87:80] == TS1)) nextState = pollingActive2;
    else nextState = pollingActive1;

pollingActive2:
    if(valid)
    begin
       if((orderedset[15:8]==PAD && orderedset[23:16]==PAD && orderedset[43] == 1'b0 && orderedset[87:80] == TS1)||
        (orderedset[15:8]==PAD && orderedset[23:16]==PAD && orderedset[87:80] == TS2)||
        (orderedset[15:8]==PAD && orderedset[23:16]==PAD && orderedset[42] == 1'b1 && orderedset[87:80] == TS1)) nextState = pollingActive2;
       else nextState = pollingActive1; 
    end
    else nextState = pollingActive2;

pollingConfiguration1:
    if(valid && orderedset[15:8]==PAD && orderedset[23:16]==PAD && orderedset[87:80] == TS2)nextState = pollingConfiguration2;
    else nextState = pollingConfiguration1;

pollingConfiguration2:
    if(valid)
    begin
        if(orderedset[15:8]==PAD && orderedset[23:16]==PAD && orderedset[87:80] == TS2)nextState = pollingConfiguration2;
        else nextState = pollingConfiguration1;        
    end
    else nextState = pollingConfiguration2;
/***************************************************************************************************/
configLinkWidthStartDown1:
 	if(valid && orderedset[15:8]==linkNumber && orderedset[23:16]==PAD && orderedset[43] == 1'b0 && orderedset[87:80] == TS1)nextState =  configLinkWidthStartDown2;
	else nextState = configLinkWidthStartDown1;
configLinkWidthStartDown2:
	if(valid)
	begin
		if(orderedset[15:8]==linkNumber && orderedset[23:16]==PAD && orderedset[43] == 1'b0 && orderedset[87:80] == TS1)nextState =  configLinkWidthStartDown2;
		else nextState =  configLinkWidthStartDown1;
	end

configLinkWidthStartUp1:
 	if(valid && orderedset[15:8]!=PAD && orderedset[23:16]==PAD && orderedset[43] == 1'b0 && orderedset[87:80] == TS1)nextState =  configLinkWidthStartUp2;
	else nextState = configLinkWidthStartUp1;
configLinkWidthStartUp2:
	if(valid)
	begin
		if(orderedset[15:8]!=PAD && orderedset[23:16]==PAD && orderedset[43] == 1'b0 && orderedset[87:80] == TS1)nextState =  configLinkWidthStartUp2;
		else nextState =  configLinkWidthStartUp1;
	end
endcase

end

    
endmodule
