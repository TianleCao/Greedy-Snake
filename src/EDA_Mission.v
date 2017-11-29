module EDA_Mission(
		CLK,
		RST,
		MISO,
		PAUSE,
		DIFFICULTY,
		LED0,
		LED1,
		LED2,
		LED3,
		CS1,
		MOSI,
		CS2,
		SDIN,
		SCLK1,
		SCLK2,
		DC,
		RES,
		VBAT,
//		TEST,
		VDD 
);

input CLK;
input RST;
input MISO;
input PAUSE;
input DIFFICULTY;
output wire [7:0]LED0;
output wire [7:0]LED1;
output wire [7:0]LED2;
output wire [7:0]LED3;
output CS1;
output CS2;
output MOSI;
output SCLK2;
output SDIN;
output SCLK1;
output DC;
output RES;
output VBAT;
output VDD;
//output wire TEST;

wire CS, SDIN, SCLK, DC;
wire VDD, VBAT, RES;

wire [3:0] direction;

reg [1:0] d_clk;

wire clk_new;

always@(posedge CLK)
begin
	d_clk<=d_clk+1'b1;
end

assign clk_new=d_clk[1];

direction_output Direction_out(
	.CLK(clk_new),
	.direction(direction),
	.CS(CS2),
	.MISO(MISO),
	.MOSI(MOSI),
	.SCLK(SCLK2)
);

PmodOLEDCtrl OLED(
	.CLK(clk_new),
	.RST(RST),
	.CS1(CS1),
	.PAUSE(PAUSE),
	.DIFFICULTY(DIFFICULTY),
	.SDIN(SDIN),
	.LED0(LED0),
	.LED1(LED1),
	.LED2(LED2),
	.LED3(LED3),
	.SCLK1(SCLK1),
	.DC(DC),
	.RES(RES),
	.VBAT(VBAT),
	.VDD(VDD),
//	.TEST(TEST),
	.DIRECTION(direction)
);

endmodule