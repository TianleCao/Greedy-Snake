module CountDisplay(
	input clk,
	input [12:0] Count,
	output reg[7:0] out0,
	output reg[7:0] out1,
	output reg[7:0] out2,
	output reg[7:0] out3
);


reg [15:0] cnt;

always@(posedge clk)
begin
	cnt<=cnt+1'b1;
end

wire clk_new;

assign clk_new=cnt[15];

reg [1:0] state;

//最高位干掉小数点
function reg [7:0] Translate;
	input [3:0] num;
	begin
		case(num)
		4'h0:Translate=8'b11000000;
		4'h1:Translate=8'b11111001;
		4'h2:Translate=8'b10100100;
		4'h3:Translate=8'b10110000;
		4'h4:Translate=8'b10011001;
		4'h5:Translate=8'b10010010;
		4'h6:Translate=8'b10000010;
		4'h7:Translate=8'b11111000;
		4'h8:Translate=8'b10000000;
		4'h9:Translate=8'b10010000;
		4'hA:Translate=8'b10001000;
		4'hB:Translate=8'b10000011;
		4'hC:Translate=8'b11000110;
		4'hD:Translate=8'b10100001;
		4'hE:Translate=8'b10000110;
		4'hF:Translate=8'b11111111;
		endcase
	end
endfunction

always@(posedge clk_new)
begin
		out0<=Translate(Count%10);
		out1<=Translate((Count/10)%10);
		out2<=Translate((Count/100)%10);
		out3<=Translate(Count/1000);
end
	
endmodule