module toptb;    
    reg clk;
    reg [3:0]substate;
    reg [127:0]orderedset1;
    reg [127:0]orderedset2;
    reg valid;
    reg forceDetec;
    reg rxElectricalIdle;
    reg timeOut;
    reg reset;
    wire finish;
    wire [3:0]exitTo;
    wire [15:0]resetOsCheckers;
    wire disableDescrambler;
    //output [3:0]lpifStatus
    wire [5:0]setTimer;
    wire enableTimer;
    wire resetTimer;
    wire writeRateId;
    wire writeUpconfig;
    wire countup1;
    wire countup2;
    wire resetcounter1;
    wire resetcounter2;
    wire [7:0] rateid1;
    wire [7:0] rateid2;
    wire upconfigure_capability1;
    wire[4:0]currentState1,nextState1;
    wire [7:0]link1,lane1,id1;
    wire[4:0]currentcount1;
    wire upconfigure_capability2;
    wire[4:0]currentState2,nextState2;
    wire [7:0]link2,lane2,id2;
    wire[4:0]currentcount2;

 localparam [7:0]
    PAD = 8'b11110111, //F7
    TS1 = 8'b00101010,	//2A
    TS2 = 8'b00100101;  //25

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



masterRxLTSSM  #(16)mymaster(
     clk,
     5'd2,
     substate,
     {{70{1'b0}},currentcount2,currentcount1}, //4bit*16lanes = 64bits
     forceDetect,
     rxElectricalIdle,
     timeOut,
     reset,
     finish,
     exitTo,
    resetOsCheckers,
    disableDescrambler,
    //output [3:0]lpifStatus
    setTimer,
    enableTimer,
    resetTimer,
    writeRateId,
    writeUpconfig);

os_checker #(0) os1(clk,
    linkNumber,
    1'b0,
    orderedset1,
    valid,
    substate,
    resetOsCheckers[0],
    countup1,
    resetcounter1,
    rateid1,
    upconfigure_capability1,currentState1,nextState1,link1,lane1,id1);
os_checker #(0) os2(clk,
    linkNumber,
    1'b1,
    orderedset2,
    valid,
    substate,
    resetOsCheckers[1],
    countup2,
    resetcounter2,
    rateid2,
    upconfigure_capability2,currentState2,nextState2,link2,lane2,id2);
counter #(8)Counter1(resetcounter1,clk,countup1,currentcount1);
counter #(8)Counter2(resetcounter2,clk,countup2,currentcount2);

initial
begin
clk = 0;
reset = 0;
timeOut = 1'b0;
#12
reset = 1;
substate = pollingActive;
#10
valid = 1'b1;
orderedset1 = 128'h25252525252525AAAAF7F7F7; //counter = 1
orderedset2 = 128'h25252525252525AAAAF7F7F7; //counter = 1
#10
valid = 1'b1;
orderedset1 = 128'h25252525252525AAAAF7F7F7; //counter = 1
orderedset2 = 128'h25252525252525AAAAF7F7F7; //counter = 
#10
valid = 1'b1;
orderedset1 = 128'h25252525252525AAAAF7F7F7; //counter = 1
orderedset2 = 128'h25252525252525AAAAF7F7F7; //counter = #10
#10
valid = 1'b1;
orderedset1 = 128'h25252525252525AAAAF7F7F7; //counter = 1
orderedset2 = 128'h25252525252525AAAAF7F7F7; //counter = #10
#10
valid = 1'b1;
orderedset1 = 128'h25252525252525AAAAAAAAAA; //counter = 1
orderedset2 = 128'h25252525252525AAAAF7F7F7; //counter = #10
#10
valid = 1'b1;
orderedset1 = 128'h25252525252525AAAAF7F7F7; //counter = 1
orderedset2 = 128'h25252525252525AAAAF7F7F7; //counter = #10
#10
valid = 1'b1;
orderedset1 = 128'h25252525252525AAAAF7F7F7; //counter = 1
orderedset2 = 128'h25252525252525AAAAF7F7F7; //counter = #10
#10
valid = 1'b1;
orderedset1 = 128'h25252525252525AAAAF7F7F7; //counter = 1
orderedset2 = 128'h25252525252525AAAAF7F7F7; //counter = #10
#10
valid = 1'b1;
orderedset1 = 128'h25252525252525AAAAF7F7F7; //counter = 1
orderedset2 = 128'h25252525252525AAAAF7F7F7; //counter = #10

/*
#10
valid = 0;
reset = 1;
substate = pollingConfiguration;
#10
valid = 1'b1;
orderedset = 128'h25252525252525AAAAF7F7F7; //counter = 1
#10
orderedset = 128'h25252525252525AAAAF7F7F7; //counter = 2
#10
orderedset = 128'h25252525252525AAAAF7F7F7; //counter = 3
#10
orderedset = 128'h25252525252525AAAAAAAAAA; //counter = 0
#10
orderedset = 128'h25252525252525AAAAF7F7F7; //counter = 1
#10
orderedset = 128'h25252525252525AAAAF7F7F7; //counter = 2
#10
reset = 0;

#10
valid = 0;
reset = 1;
substate = configurationLinkWidthStart;
linkNumber = 1;
#10
valid = 1'b1;
orderedset = 128'h2A2A2A2A2A2A2AAAAAF701F7; //counter = 1
#10
orderedset = 128'h2A2A2A2A2A2A2AAAAAF701F7; //counter = 2
#10
orderedset = 128'h2A2A2A2A2A2A2AAAAAF701F7; //counter = 3
#10
orderedset = 128'h25252525252525AAAAAAAAAA; //counter = 0
#10
orderedset = 128'h2A2A2A2A2A2A2AAAAAF701F7; //counter = 1
#10
orderedset = 128'h2A2A2A2A2A2A2AAAAAF701F7; //counter = 2
#10
reset = 0;

end


always #5 clk = ~clk;




*/
end
always #5 clk = ~clk;
endmodule