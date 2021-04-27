module RxLTSSM #(parameter DEVICETYPE=0) (
input clk,
input reset,
input [2047:0] orderedSets,
input [4:0]numberOfDetectedLanes,
input [3:0]substate,
input [7:0]linkNumber,
input forceDetect,
input rxElectricalIdle,
input validOrderedSets,
output [7:0] rateid,
output upConfigureCapability,
output finish,
output [3:0]exitTo,
output linkUp,
output witeUpconfigureCapability,
output writerateid,
output disableDescrambler
);

wire [15:0]resetOsCheckers;
wire [15:0]countUp,resetCounters;
wire [127:0]rateIds;
wire [15:0]upConfigurebits;
wire [79:0]countersValues;
wire [4:0] checkValues;
wire [15:0]comparisonValues;
wire [15:0]enableTimers,resetTimers,timeOuts;
wire [95:0]setTimers;


genvar i;
generate
   for (i=0; i <= 15; i=i+1) 
   begin
     osChecker #(.DEVICETYPE(DEVICETYPE))osChecker( 
     clk,
     linkNumber,
     i,
     orderedSets[(i*16)+15:i*16],
     validOrderedSets,
     substate,
     resetOsCheckers[i],
     countUp[i],
     resetCounters[i],
     rateid[(i*8)+7:i*8],
     upConfigurebits[i]);

     counter counter(
     resetCounters[i],
     clk,
     countUp[i],
     countersValues[(i*5)+4:i*5]);

     comparator comparator(
     countersValues[(i*5)+4:i*5],
     checkValues,
     comparisonValues[i]);

     timer timer(clk,setTimers[(i*6)+5:i*6],enableTimers[i],resetTimers[i],timeOuts[i]);
   end
endgenerate


masterRxLTSSM masterRxLTSSM(
    clk,
    numberOfDetectedLanes,
    substate,
    comparisonValues,
    forceDetect,
    rxElectricalIdle,
    timeOuts,
    reset,
    finish,
    exitTo,
    resetOsCheckers,
    disableDescrambler,
    setTimers,
    enableTimers,
    resetTimers,
    checkValues);


assign {witeUpconfigureCapability,writerateid} = (finish &&(exitTo == 3'd4|| exitTo == 3'd9))? 1'b1 : 1'b0;
endmodule