module RanGen(
    input               clk,      /*clock signal*/
    output reg [9:0]    rand_num  /*random number output*/
);


initial
begin
	rand_num<=10'b1001100011;
end

always@(posedge clk)
begin
	rand_num[0] <= rand_num[9];
	rand_num[1] <= rand_num[0];
	rand_num[2] <= rand_num[1];
	rand_num[3] <= rand_num[2];
	rand_num[4] <= rand_num[3]^rand_num[9];
	rand_num[5] <= rand_num[4]^rand_num[9];
   rand_num[6] <= rand_num[5]^rand_num[9];
   rand_num[7] <= rand_num[6];
	rand_num[8] <= rand_num[7]^rand_num[9];
	rand_num[9] <= rand_num[8];
	
end

endmodule