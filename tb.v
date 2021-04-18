module tb;
    reg clk;
    reg linkNumber;
    reg laneNumber;
    reg [127:0]orderedset;
    reg valid;
    reg [3:0]substate;
    reg reset;
    wire countup;
    wire resetcounter;
    wire [7:0] rateid;
    wire upconfigure_capability;
wire[4:0]currentState,nextState;
wire [7:0]link,lane,id;
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

os_checker #(0) test(clk,
    linkNumber,
    laneNumber,
    orderedset,
    valid,
    substate,
    reset,
    countup,
    resetcounter,
    rateid,
    upconfigure_capability,currentState,nextState,link,lane,id);
initial
begin
clk = 0;
reset = 0;
#12
reset = 1;
substate = pollingActive;
valid = 1'b1;
orderedset = 128'h25252525252525AAAAF7F7F7;
#10
orderedset = 128'h25252525252525AAAAF7F7F7;
#10
orderedset = 128'h25252525252525AAAAF7F7F7;
#10
orderedset = 128'h25252525252525AAAAAAAAAA;
#10
orderedset = 128'h25252525252525AAAAF7F7F7;
#10
orderedset = 128'h25252525252525AAAAF7F7F7;
end


always #5 clk = ~clk;
endmodule
