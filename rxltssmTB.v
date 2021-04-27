module rxltssmTB;
reg clk;
reg reset;
reg [2047:0] orderedSets;
reg [4:0]numberOfDetectedLanes;
reg [3:0]substate;
reg [7:0]linkNumber;
reg forceDetect;
reg rxElectricalIdle;
reg validOrderedSets;
wire [7:0] rateid;
wire upConfigureCapability;
wire finish;
wire [3:0]exitTo;
wire linkUp;
wire witeUpconfigureCapability;
wire writerateid;
wire disableDescrambler;




RxLTSSM #(0) rxltssm(
 clk,
 reset,
 orderedSets,
 numberOfDetectedLanes,
 substate,
 linkNumber,
 forceDetect,
 rxElectricalIdle,
 validOrderedSets,
 rateid,
 upConfigureCapability,
 finish,
 exitTo,
 linkUp,
 witeUpconfigureCapability,
 writerateid,
 disableDescrambler
);

initial
begin
clk = 0;
reset = 0;
#8
reset = 1;
substate = detectQuiet;
#10
rxElectricalIdle = 1'b1;
end


always #5 clk = ~clk;

endmodule