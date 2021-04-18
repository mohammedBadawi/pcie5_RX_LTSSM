module counter #(parameter width = 8)(input reset,input clk,input enable,input up,output [width-1 : 0] count);

reg[width-1 : 0] next_count,current_count;

always @(posedge clk or negedge reset)
begin
if(!reset)current_count <= {width{1'b0}};
else current_count <= next_count;
end

always @(*)
begin
if(enable & up)next_count = current_count+1'b1;
else if (enable & !up)next_count = current_count-1'b1;
else next_count = current_count;
end

assign count = current_count;

endmodule

