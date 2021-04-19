module #(parameter MAXLANES) masterRxLTSSM (
    input clk,
    input [4:0]numberOfDetectedLanes,
    input [3:0]substate,
    input [63:0]countersValues //4bit*16lanes = 64bits
    input forceDetect,
    input rxElectricalIdle,
    input timeOut,
    input reset,
    output finish,
    output [3:0]exitTo,
    output [15:0]resetOsCheckers,
    output disableDescrambler,
    //output [3:0]lpifStatus
    output [5:0]setTimer,
    output enableTimer,
    output resetTimer,
    output writeRateId,
    output writeUpconfig;
);
    
    reg[1:0] currentState,nextState;
    reg[3:0]count;
    reg[5:0]timeToWait;

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
    

//local states
    localparam [1:0]
    start = 2'b00,
    counting = 2'b01,
    success = 2'b10,
    failed = 2'b11;

    //CURRENT STATE FF
always @(posedge clk or negedge reset or posedge forceDetect)
begin
    if(!reset || !forceDetect)
    begin
        currentState <= start;
    end
    else
    begin
        currentState <= nextState;
    end    
end

always @(*)
 begin
     disableDescrambler = 1'b0;
     writeRateId = 1'b0;
     writeUpconfig = 1'b0;
     case(currentState):
        start:
        begin
            enableTimer = 1'b0;
            resetTimer = 1'b0;
            resetOsCheckers = 16'b0;
            if(substate==pollingActive||substate==configurationComplete)
                begin
                    count = 4'd8;
                    timeToWait = 6'd24;
                    nextState = counting;
                end
            else if (substate==configurationLinkWidthStart||substate==configurationLinkWidthAccept||substate==configurationLanenumAccept)
                begin
                    count = 4'd2;
                    timeToWait = 6'd24;
                    nextState = counting;                 
                end
            else if (substate==configurationLanenumWait)
                begin
                        count=4'd2;
                        timeToWait = 6'd2;
                        nextState = counting;
                end
            else if (substate==pollingConfiguration)
                begin
                        count=4'd8;
                        timeToWait = 6'd48;
                        nextState = counting;
                end
            else 
                begin
                    count=4'd0;
                    timeToWait = 6'd0;
                    nextState = start;
                end
        end
     
        counting:
        begin
            resetOsCheckers = 16'b1;
            if(!timeOut && countersValues >= {numberOfDetectedLanes{count}})
            begin
                enableTimer = 1'b1;
                resetTimer = 1'b1;
                nextState = success; 
            end
            else if(timeOut)
            begin
                nextState = failed;
            end
        end
        success:
        begin
            resetOsCheckers = 16'b0;
            enableTimer = 1'b0;
            resetTimer = 1'b0;
            finish = 1'b1;
            exitTo = substate + 1'b1;
            nextState = start;
        end
        failed:
        begin
            resetOsCheckers = 16'b0;
            enableTimer = 1'b0;
            resetTimer = 1'b0;
            finish = 1'b1;
            exitTo = detectQuiet;
            nextState = start;
        end
     default:
     begin
            nextState = start;
            enableTimer = 1'b0;
            resetTimer = 1'b0;
            resetOsCheckers = 16'b0;
     end
     end

   
     endcase
 end
    





endmodule
