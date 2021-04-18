module os_checker #(parameter DEVICETYPE)(
    input clk,
    input linkNumber,
    input laneNumber,
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
    reg notEqual;
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
    configLinkWidthAcceptUp1 = 4'd9,
    configLinkWidthAcceptUp2 = 4'd10,
    configLanenumWaitDown1 = 4'd11,
    configLanenumWaitDown1 = 4'd12,
    configLanenumWaitUp1 = 4'd13,
    configLanenumWaitUp1 = 4'd14,
    configLanenumAcceptDown1 = 4'd15,
    configLanenumAcceptDown2 = 4'd16,
    configLanenumAcceptUp1 = 4'd17,
    configLanenumAcceptUp2 = 4'd18,
    configCompleteDown1 = 4'd 19,
    configCompleteDown2 = 4'd 20,
    configCompleteUp1 = 4'd 21,
    configCompleteUp2 = 4'd 22;
//CURRENT STATE FF
always @(posedge clk or negedge reset)
begin
    notEqual <= 1'b0;
    if(!reset)
    begin
        currentState <= start;
    end
    else
    begin
        currentState <= nextState;
        if(valid)
        begin
            localorderedset<=orderedset;
            if((currentState == configCompleteDown2||currentState == configCompleteUp2)&&(localorderedset[42] != orderedset[42] || localorderedset[32:39] != orderedset[32:39]))
            notEqual <= 1'b1;
        end
    end    
end

//next state logic block
always @(*)
begin
    case(currentState)
    start:
        resetcounter = 1'b0; countup = 1'b0;
        if(substate == pollingActive) nextState = pollingActive1;
        else if (substate == configurationLinkWidthStart && DEVICETYPE == 1'b0)nextState = configLinkWidthStartDown1;
        else if (substate == configurationLinkWidthStart && DEVICETYPE == 1'b1)nextState = configLinkWidthStartUp1;
        else if (substate == configurationLinkWidthAccept && DEVICETYPE == 1'b1)nextState = configLinkWidthAcceptUp1;
        else if (substate == configurationLanenumWait && DEVICETYPE == 1'b0) nextState = configLanenumWaitDown1;
        else if (substate == configurationLanenumWait && DEVICETYPE == 1'b1) nextState = configLanenumWaitUp1;
        else if (substate == configurationLanenumAccept && DEVICETYPE == 1'b0) nextState = configLanenumAcceptDown1;
        else if (substate == configurationLanenumAccept && DEVICETYPE == 1'b1) nextState = configLanenumAcceptUp1;
        else if (substate == configurationComplete && DEVICETYPE == 1'b0) nextState = configCompleteDown1;
        else if (substate == configurationComplete && DEVICETYPE == 1'b1) nextState = configCompleteUp1;

        else nextState = start;

    pollingActive1:
        resetcounter = 1'b0; countup = 1'b0;
        if((valid && orderedset[15:8]==PAD && orderedset[23:16]==PAD && orderedset[43] == 1'b0 && orderedset[87:80] == TS1)||
        (valid && orderedset[15:8]==PAD && orderedset[23:16]==PAD && orderedset[87:80] == TS2)||
        (valid && orderedset[15:8]==PAD && orderedset[23:16]==PAD && orderedset[42] == 1'b1 && orderedset[87:80] == TS1)) nextState = pollingActive2;
        else nextState = pollingActive1;

    pollingActive2:
        resetcounter = 1'b1; countup = 1'b0; 
        if(valid)
        begin
        if((orderedset[15:8]==PAD && orderedset[23:16]==PAD && orderedset[43] == 1'b0 && orderedset[87:80] == TS1)||
            (orderedset[15:8]==PAD && orderedset[23:16]==PAD && orderedset[87:80] == TS2)||
            (orderedset[15:8]==PAD && orderedset[23:16]==PAD && orderedset[42] == 1'b1 && orderedset[87:80] == TS1)) 
            begin
                countup = 1'b1; 
                nextState = pollingActive2;
            end
        else nextState = pollingActive1; 
        end
        else nextState = pollingActive2;

    pollingConfiguration1:
        resetcounter = 1'b0; countup = 1'b0;
        if(valid && orderedset[15:8]==PAD && orderedset[23:16]==PAD && orderedset[87:80] == TS2)nextState = pollingConfiguration2;
        else nextState = pollingConfiguration1;

    pollingConfiguration2:
        resetcounter = 1'b1; countup = 1'b0;
        if(valid)
        begin
            if(orderedset[15:8]==PAD && orderedset[23:16]==PAD && orderedset[87:80] == TS2)
            begin
                countup = 1'b1; 
                nextState = pollingConfiguration2;
            end
            else nextState = pollingConfiguration1;        
        end
        else nextState = pollingConfiguration2;
/***************************************************************************************************/
    configLinkWidthStartDown1:
        resetcounter = 1'b0; countup = 1'b0;
        if(valid && orderedset[15:8]==linkNumber && orderedset[23:16]==PAD && orderedset[87:80] == TS1)nextState =  configLinkWidthStartDown2;
        else nextState = configLinkWidthStartDown1;

    configLinkWidthStartDown2:
        resetcounter = 1'b1; countup = 1'b0;
        if(valid)
            begin
                if(orderedset[15:8]==linkNumber && orderedset[23:16]==PAD && orderedset[87:80] == TS1)
                begin
                    countup = 1'b1;
                    nextState =  configLinkWidthStartDown2;
                end
                else nextState =  configLinkWidthStartDown1;
            end
        else nextState =  configLinkWidthStartDown2;

    configLinkWidthStartUp1:
        resetcounter = 1'b0; countup = 1'b0;
        if(valid && orderedset[15:8]!=PAD && orderedset[23:16]==PAD && orderedset[87:80] == TS1)nextState =  configLinkWidthStartUp2;
        else nextState = configLinkWidthStartUp1;

    configLinkWidthStartUp2:
        resetcounter = 1'b1; countup = 1'b0;
        if(valid)
            begin
                if(orderedset[15:8]!=PAD && orderedset[23:16]==PAD && orderedset[87:80] == TS1)
                begin
                    countup =1'b1;
                    nextState =  configLinkWidthStartUp2;
                end
                else nextState =  configLinkWidthStartUp1;
            end
        else nextState =  configLinkWidthStartUp2;
/*******************************************************************************************************/
    configLinkWidthAcceptUp1:
        resetcounter = 1'b0; countup = 1'b0;
        if(valid && orderedset[15:8]==linkNumber && orderedset[23:16]!=PAD  && orderedset[87:80] == TS1)nextState = configLinkWidthAcceptUp2;
        else nextState = configLinkWidthAcceptUp1;
    
    configLinkWidthAcceptUp2:
        resetcounter = 1'b1; countup = 1'b0;
        if(valid)
            begin
                if(orderedset[15:8]==linkNumber && orderedset[23:16]!=PAD && orderedset[87:80] == TS1)
                begin
                    countup = 1'b1;
                    nextState =  configLinkWidthAcceptUp2;
                end
                else nextState =  configLinkWidthAcceptUp1;
            end
        else nextState =  configLinkWidthAcceptUp2;
/*******************************************************************************************************/
    configLanenumWaitDown1:
       resetcounter = 1'b0; countup = 1'b0;
        if(valid && orderedset[15:8]==linkNumber && orderedset[23:16]==laneNumber && orderedset[87:80] == TS1)nextState = configLanenumWaitDown2;
        else nextState = configLanenumWaitDown1;

    configLanenumWaitDown2:
    resetcounter = 1'b1; countup = 1'b0;
    if(valid)
        begin
            if(orderedset[15:8]==linkNumber && orderedset[23:16]==laneNumber && orderedset[87:80] == TS1)
            begin
                countup = 1'b1;
                nextState =  configLanenumWaitDown2;
            end
            else nextState =  configLanenumWaitDown1;
        end
    else nextState =  configLanenumWaitDown2;

    configLanenumWaitUp1:
        resetcounter = 1'b0; countup = 1'b0;
        if(valid && orderedset[15:8]==linkNumber && orderedset[23:16]==laneNumber && orderedset[87:80] == TS2)nextState = configLanenumWaitUp2;
        else nextState = configLanenumWaitUp1;

    configLanenumWaitUp2:
        resetcounter = 1'b1; countup = 1'b0;
        if(valid)
            begin
                if(orderedset[15:8]==linkNumber && orderedset[23:16]==laneNumber && orderedset[87:80] == TS2)
                begin
                    countup = 1'b1;
                    nextState =  configLanenumWaitUp2;
                end
                else nextState =  configLanenumWaitUp1;
            end
        else nextState =  configLanenumWaitUp2;
/*******************************************************************************************************/
    configLanenumAcceptDown1:
        resetcounter = 1'b0; countup = 1'b0;
        if(valid && orderedset[15:8]==linkNumber && orderedset[23:16]==laneNumber && orderedset[87:80] == TS1)nextState = configLanenumAcceptDown2;
        else nextState = configLanenumAcceptDown1;

    configLanenumAcceptDown2:
        resetcounter = 1'b1; countup = 1'b0;
        if(valid)
            begin
                if(orderedset[15:8]==linkNumber && orderedset[23:16]==laneNumber && orderedset[87:80] == TS1)
                begin
                    countup = 1'b1;
                    nextState =  configLanenumAcceptDown2;
                end
                else nextState =  configLanenumAcceptDown1;
            end
        else nextState =  configLanenumAcceptDown2;

    configLanenumAcceptUp1:
        resetcounter = 1'b0; countup = 1'b0;
        if(valid && orderedset[15:8]==linkNumber && orderedset[23:16]==laneNumber && orderedset[87:80] == TS2)nextState = configLanenumAcceptUp2;
        else nextState = configLanenumAcceptUp1;

    configLanenumAcceptUp2:
        resetcounter = 1'b1; countup = 1'b0;
        if(valid)
            begin
                if(orderedset[15:8]==linkNumber && orderedset[23:16]==laneNumber && orderedset[87:80] == TS2)
                begin
                    countup = 1'b1;
                    nextState =  configLanenumAcceptUp2;
                end
                else nextState =  configLanenumAcceptUp1;
            end
        else nextState =  configLanenumAcceptUp2;

/*******************************************************************************************************/
    configCompleteDown1:
        resetcounter = 1'b0; countup = 1'b0;
        if(valid && orderedset[15:8]==linkNumber && orderedset[23:16]==laneNumber && orderedset[87:80] == TS2)nextState = configCompleteDown2;
            else nextState = configCompleteDown1;

    configCompleteDown2:
        resetcounter = 1'b1; countup = 1'b0;
        if(notEqual)nextState = configCompleteDown1;
        else if(valid)
            begin
                if(orderedset[15:8]==linkNumber && orderedset[23:16]==laneNumber && orderedset[87:80] == TS2)
                begin
                    countup = 1'b1;
                    nextState =  configCompleteDown2;
                end
                else nextState =  configCompleteDown1;
            end
        else nextState =  configCompleteDown2;

    configCompleteUp1:
        resetcounter = 1'b0; countup = 1'b0;
        if(valid && orderedset[15:8]==linkNumber && orderedset[23:16]==laneNumber && orderedset[87:80] == TS2)nextState = configCompleteUp2;
            else nextState = configCompleteUp1;

    configCompleteUp2:
        resetcounter = 1'b1; countup = 1'b0;
        if(notEqual)nextState = configCompleteUp1;
        else if(valid)
            begin
                if(orderedset[15:8]==linkNumber && orderedset[23:16]==laneNumber && orderedset[87:80] == TS2)
                begin
                    countup = 1'b1;
                    nextState =  configCompleteUp2;
                end
                else nextState =  configCompleteUp1;
            end
        else nextState =  configCompleteUp2;
/*******************************************************************************************************/
endcase
end
    assign rateid = localorderedset[32:39];
    assign upconfigure_capability = localorderedset[42];    
endmodule
