module counter #(parameter width = 5)(input reset,input clk,input up,output reg [width-1 : 0] count);

always @(posedge clk or negedge reset)
begin
if(!reset) count = {width{1'b0}};
else if (up) count = count + 1'b1;
else count = count;
end

endmodule

