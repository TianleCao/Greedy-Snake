module PmodOLEDCtrl(
		CLK,
		RST,
		CS1,
		DIRECTION,
		SDIN,
		SCLK1,
		DIFFICULTY,
//		TEST,
		LED0,
		LED1,
		LED2,
		LED3,
		DC,
		RES,
		VBAT,
		PAUSE,
		VDD
    );

	// ===========================================================================
	// 										Port Declarations
	// ===========================================================================
	input CLK;
	input RST;
	input PAUSE;
	input DIFFICULTY;
	input [3:0] DIRECTION;
	output CS1;
	output SDIN;
	output SCLK1;
//	output reg TEST;
	output wire [7:0] LED0;
	output wire [7:0] LED1;
	output wire [7:0] LED2;
	output wire [7:0] LED3;
	output DC;
	output RES;
	output VBAT;
	output VDD;
//	output wire TEST;

	// ===========================================================================
	// 							  Parameters, Regsiters, and Wires
	// ===========================================================================
	wire CS, SDIN, SCLK, DC;
	wire VDD, VBAT, RES;

	reg [110:0] current_state = "Idle";

	wire init_en;
	wire init_done;
	wire init_cs;
	wire init_sdo;
	wire init_sclk;
	wire init_dc;
	
	wire example_en;
	wire example_cs;
	wire example_sdo;
	wire example_sclk;
	wire example_dc;
	wire example_done;
	
	wire [9:0] RANDOM;
	
	wire [12:0] ATE_COUNT;
	
	
	// ===========================================================================
	// 										Implementation
	// ===========================================================================
	OledInit Init(
			.CLK(CLK),
			.RST(RST),
			.EN(init_en),
			.CS(init_cs),
			.SDO(init_sdo),
			.SCLK(init_sclk),
			.DC(init_dc),
			.RES(RES),
			.VBAT(VBAT),
			.VDD(VDD),
			.FIN(init_done)
	);
	
	My_OLED_EX Example(
			.CLK(CLK),
			.RST(RST),
			.EN(example_en),
			.RANDOM(RANDOM),
			.DIRECTION(DIRECTION),
			.DIFFICULTY(DIFFICULTY),
			.CS(example_cs),
			.SDO(example_sdo),
			.SCLK(example_sclk),
			.DC(example_dc),
			.PAUSE(PAUSE),
			.COUNT(ATE_COUNT),
			.FIN(example_done)
	);
	
	RanGen Random(
			.clk(CLK),
			.rand_num(RANDOM)
	);

	
	CountDisplay LED_DISPLAY(
		.clk(CLK),
		.Count(ATE_COUNT),
		.out0(LED0),
		.out1(LED1),
		.out2(LED2),
		.out3(LED3)
	);

	//MUXes to indicate which outputs are routed out depending on which block is enabled
	assign CS1 = (current_state == "OledInitialize") ? init_cs : example_cs;
	assign SDIN = (current_state == "OledInitialize") ? init_sdo : example_sdo;
	assign SCLK1 = (current_state == "OledInitialize") ? init_sclk : example_sclk;
	assign DC = (current_state == "OledInitialize") ? init_dc : example_dc;
	//END output MUXes

	
	//MUXes that enable blocks when in the proper states
	assign init_en = (current_state == "OledInitialize") ? 1'b1 : 1'b0;
	assign example_en = (current_state == "OledExample") ? 1'b1 : 1'b0;
	//END enable MUXes
	
	
	//  State Machine
	always @(posedge CLK) begin
			if(!RST) begin
					current_state <= "Idle";
			end
			else begin
					case(current_state)
						"Idle" : begin
							current_state <= "OledInitialize";
						end
  					   // Go through the initialization sequence
						"OledInitialize" : begin
								if(init_done == 1'b1) begin
										current_state <= "OledExample";
								end
						end
						// Do example and Do nothing when finished
						"OledExample" : begin
								if(example_done == 1'b1) begin
										current_state <= "Done";
								end
						end
						// Do Nothing
						"Done" : begin
							current_state <= "Done";
						end
						
						default : current_state <= "Idle";
					endcase
			end
	end

endmodule
