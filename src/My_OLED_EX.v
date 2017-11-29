module My_OLED_EX(
	 CLK,
    RST,
    EN,
	 DIFFICULTY,
	 RANDOM,
	 DIRECTION,
	 PAUSE,
    CS,
    SDO,
    SCLK,
    DC,
	 COUNT,
    FIN
   );
	
	
	// ===========================================================================
	// 										Port Declarations
	// ===========================================================================
	 input CLK;
    input RST;
    input EN;
	 input [9:0] RANDOM;
	 input [3:0] DIRECTION;
	 input DIFFICULTY;
	 input PAUSE;
    output CS;
    output SDO;
    output SCLK;
    output DC;
    output FIN;
	 output wire [12:0] COUNT; 
	 
	// ===========================================================================
	// 							  Parameters, Regsiters, and Wires
	// ===========================================================================
	wire CS, SDO, SCLK, DC, FIN;
	
	//Variable that contains what the screen will be after the next UpdateScreen state
   reg        current_screen[0:31][0:127];
	
	//Current overall state of the state machine
   reg [143:0] current_state;
	//State to go to after the SPI transmission is finished
   reg [143:0] after_state;
   //State to go to after the set page sequence
   reg [143:0] after_page_state;
   //State to go to after sending the character sequence
   reg [143:0] after_char_state;
	//State to go to after the UpdateScreen is finished
   reg [143:0] after_update_state;
	
	integer i = 0;
	integer j = 0;
		
	//Contains the value to be outputted to DC
   reg temp_dc;
	
		
	//-------------- Variables used in the Delay Controller Block --------------
   reg [11:0] temp_delay_ms;		//amount of ms to delay
   reg temp_delay_en;				//Enable signal for the delay block
   wire temp_delay_fin;				//Finish signal for the delay block
	
	
	reg temp_spi_en;					//Enable signal for the SPI block
   reg [7:0] temp_spi_data;		//Data to be sent out on SPI
   wire temp_spi_fin;				//Finish signal for the SPI block
	
	reg [4:0] temp_page;				//Current page
	reg [7:0] temp_index;			//Current position on page
	reg [7:0] temp_char;
	

	
	reg END;//game over signal
	
	//蛇计算部分,以2*2作为蛇的基本单元
	reg [6:0] snake_Length;//记录蛇的长度
	reg [11:0] Food;
	reg FoodAteFlag;
	reg [12:0] FoodAte_Count;
	 

	
	// ===========================================================================
	// 										Implementation
	// ===========================================================================
	 
	assign COUNT=FoodAte_Count*13'd5;
	
	 
	assign DC = temp_dc;
   //Example finish flag only high when in done state
   assign FIN = (current_state == "Done") ? 1'b1 : 1'b0;
	
	
	//Instantiate SPI Block
   SpiCtrl SPI_COMP(
			.CLK(CLK),
			.RST(RST),
			.SPI_EN(temp_spi_en),
			.SPI_DATA(temp_spi_data),
			.CS(CS),
			.SDO(SDO),
			.SCLK(SCLK),
			.SPI_FIN(temp_spi_fin)
	);

   //Instantiate Delay Block
   Delay DELAY_COMP(
			.CLK(CLK),
			.RST(RST),
			.DELAY_MS(temp_delay_ms),
			.DELAY_EN(temp_delay_en),
			.DELAY_FIN(temp_delay_fin)
	);
	
	reg [2:0] inicount;
	
	reg [1:0] flag; //clear screen 里下一个状态
	
	reg [6:0] GetScreen_count;//getscreen 用以展开循环
	
	reg [6:0] Update_Snake_count;//Update_Snake展开蛇的循环
	
	
	//  State Machine
	always @(posedge CLK) begin
		if(!RST)
		begin
			current_state<="Idle";
		end
		case(current_state)
			
			// Idle until EN pulled high than initialize Page to 0 and go to state Alphabet afterwards
			"Idle" : begin
				if(EN == 1'b1) begin	
		//		TEST<=1'b0;
				current_state <= "ClearDC";
				after_page_state <= "INI";
				temp_page <= 2'b00;
				end
			end
			
			"INI": begin
				//开始3，2，1 
				flag<=2'b01;
				inicount<=2'b0;
				current_state <= "ClearScreen";
			end
			
			"Display" : begin
				flag<=2'b10;
				current_state <= "ClearScreen";
			end
			
			//显示结束
			"Over" : begin
				flag<=2'b11;
				current_state <= "ClearScreen";
			end
			
			"ReScreen1": begin
					inicount<=inicount+1'b1;
					current_state <= "UpdateScreen";
					after_update_state <= "Wait1";
			end
					
			"ReScreen2": begin
				if(PAUSE)
					current_state<="ReScreen4";
				else
				begin
					current_state <= "UpdateFood";
					GetScreen_count<=7'b0;
					Update_Snake_count<=7'b0;
				end
			end
			
			"ReScreen3": begin
					current_state <= "UpdateScreen";
					after_update_state <= "Wait3";
			end
			
			//Pause screen
			"ReScreen4":begin
				current_state<="UpdateScreen";
				if(PAUSE)
				begin
					after_update_state<="Wait4";
				end
				else
					after_update_state<="Wait2";
				begin
				end
			end

			"UpdateFood":begin
				current_state<="UpdateSnake";
			end
			
			"UpdateSnake":
			begin
				if(END==1'b1)
					current_state<="Over";
				else
				begin
					if(Update_Snake_count<snake_Length)
					begin
						current_state<="UpdateSnake";
						Update_Snake_count<=Update_Snake_count+1'b1;
					end
					else
					begin
						current_state<="GetScreen";
						Update_Snake_count<=7'b0;
					end
				end
			end
			
			"GetScreen":begin
				if(GetScreen_count<snake_Length)
				begin
					current_state<="GetScreen";
					GetScreen_count<=GetScreen_count+1'b1;
				end
				else
				begin
					current_state<="UpdateScreen";
					after_update_state<="Wait2";
					GetScreen_count<=7'b0;
				end
			end
			
			"Wait1" : begin
					temp_delay_ms <= 12'b0111110100; //500*2
					if(inicount<=2'b10)//倒计时3，2，1
						after_state<="ReScreen1";
					else
					begin
						after_state<="Display";
						inicount<=2'b00;
					end
					current_state <= "Transition3"; // Transition3 = The delay transition states
			end
			
			"Wait2" : begin
					if(!DIFFICULTY)
						temp_delay_ms <= 12'b011111010; //250*2
					else
						temp_delay_ms<=12'b001111101;//125*2
					after_state<= "Display";
					current_state <= "Transition3"; // Transition3 = The delay transition states
			end
			
			"Wait3" : begin
					flag<=2'b00;
					temp_delay_ms <= 12'b1111101000; //1000*2
						after_state<= "ClearScreen";
					current_state <= "Transition3"; // Transition3 = The delay transition states
			end
			
			"Wait4":begin
					temp_delay_ms <= 12'b0111010; //58
					after_state<= "ReScreen4";
					current_state <= "Transition3"; // Transition3 = The delay transition states
			end
			
			// set current_screen to constant clear_screen and update the screen. Go to state Wait2 afterwards
			"ClearScreen" : begin
				case(flag)
					2'b00:after_update_state <= "Done";
					2'b01:after_update_state<="ReScreen1";
					2'b10:after_update_state<="ReScreen2"; 
					2'b11:after_update_state<="ReScreen3";
				endcase
					current_state <= "UpdateScreen";
			end
			
			"Done" : begin
			//		TEST<=1'b1;
					if(EN == 1'b0) begin
						current_state <= "Idle";
					end
			end
			
			
			
			//UpdateScreen State
			//1. Gets ASCII value from current_screen at the current page and the current spot of the page
			//2. If on the last character of the page transition update the page number, if on the last page(3)
			//			then the updateScreen go to "after_update_state" after
			"UpdateScreen" : begin
					
					temp_char <= {current_screen[(temp_page<<3)+5'b00111][temp_index],current_screen[(temp_page<<3)+5'b00110][temp_index],//6'b0};
					current_screen[(temp_page<<3)+5'b00101][temp_index],current_screen[(temp_page<<3)+5'b00100][temp_index],
					current_screen[(temp_page<<3)+5'b00011][temp_index],current_screen[(temp_page<<3)+5'b00010][temp_index],
					current_screen[(temp_page<<3)+5'b00001][temp_index],current_screen[temp_page<<3][temp_index]};
		//			if(temp_page<<3==62)
		//				TEST<=1'b1;
						
					
//					temp_char<=8'b0;
					if(temp_index == 'd127) begin

						temp_index <= 'd0;
						temp_page <= temp_page + 1'b1;
						after_char_state <= "ClearDC";
						if(temp_page == 2'b11) begin
							after_page_state <= after_update_state;
							temp_page<=2'b0;
						end
						else	begin
							after_page_state <= "UpdateScreen";
						end
					end
					else begin
//						temp_char<="00000000";
						temp_index <= temp_index + 1'b1;
						after_char_state <= "UpdateScreen";

					end
					
					current_state <= "SendChar";

			end
			
			
			//Update Page states
			//1. Sets DC to command mode
			//2. Sends the SetPage Command
			//3. Sends the Page to be set to
			//4. Sets the start pixel to the left column
			//5. Sets DC to data mode
			"ClearDC" : begin
					temp_dc <= 1'b0;
					current_state <= "SetPage";
			end
			
			"SetPage" : begin
					temp_spi_data <= 8'b00100010;
					after_state <= "PageNum";
					current_state <= "Transition1";
			end
			
			"PageNum" : begin
					temp_spi_data <= {6'b000000,temp_page[1:0]};
					after_state <= "LeftColumn1";
					current_state <= "Transition1";
			end
			
			"LeftColumn1" : begin
					temp_spi_data <= 8'b00000000;
					after_state <= "LeftColumn2";
					current_state <= "Transition1";
			end
			
			"LeftColumn2" : begin
					temp_spi_data <= 8'b00010000;
					after_state <= "SetDC";
					current_state <= "Transition1";
			end
			
			"SetDC" : begin
					temp_dc <= 1'b1;
					current_state <= after_page_state;
			end
	
			//Send Character States
			//1. Sets the Address to ASCII value of char with the counter appended to the end
			//2. Waits a clock for the data to get ready by going to ReadMem and ReadMem2 states
			//3. Send the byte of data given by the block Ram
			"SendChar" : begin
					temp_spi_data <=temp_char;
					after_state <= after_char_state;
					current_state <= "Transition1";
			end
			
			
			// SPI transitions
			// 1. Set SPI_EN to 1
			// 2. Waits for SpiCtrl to finish
			// 3. Goes to clear state (Transition5)
			"Transition1" : begin
					temp_spi_en <= 1'b1;
					current_state <= "Transition2";
			end
			
			"Transition2" : begin
					if(temp_spi_fin == 1'b1) begin
						current_state <= "Transition5";
					end
			end

			// Delay Transitions
			// 1. Set DELAY_EN to 1
			// 2. Waits for Delay to finish
			// 3. Goes to Clear state (Transition5)
			"Transition3" : begin
					temp_delay_en <= 1'b1;
					current_state <= "Transition4";
			end

			"Transition4" : begin
					if(temp_delay_fin == 1'b1) begin
						current_state <= "Transition5";
					end
			end

			// Clear transition
			// 1. Sets both DELAY_EN and SPI_EN to 0
			// 2. Go to after state
			"Transition5" : begin
					temp_spi_en <= 1'b0;
					temp_delay_en <= 1'b0;
					current_state <= after_state;
			end
			//END SPI transitions
			//END Delay Transitions
			//END Clear transition

			default : current_state <= "Idle";
		
		endcase
	end
	
	
	 //蛇计算部分,以2*2作为蛇的基本单元
	reg [11:0] point_temp;
	
	reg [3:0] current_Direction;//0000无 1000 上 0100 下 0010 左 0001 右
	reg [3:0] next_Direction;
	
	reg [11:0] snake[0:127] ;//记录蛇的坐标的数组 {[9:6][5:0]}{i,j}
	
	
	
	integer index;
	reg [4:0] page_index;
	reg [6:0] column_index;
	 

function reg OutofRange;
	input [11:0] position;
	begin
		if(position[11:7]<=15&&position[6:0]<=63)
			OutofRange=1'b0;
		else
			OutofRange=1'b1;
	end
endfunction


always@(posedge CLK)
	case(current_state)
	"Idle":
	begin
		snake_Length<=8;
		snake[0]<={5'b00100,7'b0001111};
		snake[1]<={5'b00100,7'b0001110};
		snake[2]<={5'b00100,7'b0001101};
		snake[3]<={5'b00100,7'b0001100};
		snake[4]<={5'b00100,7'b0001011};
		snake[5]<={5'b00100,7'b0001010};
		snake[6]<={5'b00100,7'b0001001};
		snake[7]<={5'b00100,7'b0001000};
		END<=1'b0;
		FoodAte_Count<=1'b0;
		current_Direction<=4'b0001;	
		Food<={1'b0,RANDOM[9:6],1'b0,RANDOM[5:0]};
	end
	
	"ClearScreen":
	begin
	for(i = 0; i <= 31 ; i=i+1) begin
		for(j = 0; j <= 127 ; j=j+1) begin
		if(i==0||j==0||i==31||j==127)
			current_screen[i][j]<=1'b1;
		else
			current_screen[i][j] <= 1'b0;
		end
	end
	end
	
	"ReScreen1":
	begin
		case(inicount)
		2'b00:
		begin
			for(i = 0; i <= 31 ; i=i+1) begin
				for(j = 0; j <= 127 ; j=j+1) begin
					if(i==0||j==0||i==31||j==127||(i<=9&&5<=i&&j<=67&&j>=59)||
					(i<=13&&i>=9&&j<=67&&j>=65)||(j<=67&&j>=59&&i<=17&&i>=13)||
					(i<=21&&i>=17&&j<=67&&j>=65)||(j<=67&&j>=59&&i<=25&&i>=21))
						current_screen[i][j]<=1'b1;
					else 
						current_screen[i][j]<=1'b0;
				end
			end
		end
		2'b01:
		begin
			for(i = 0; i <= 31 ; i=i+1) begin
				for(j = 0; j <= 127 ; j=j+1) begin
					if(i==0||j==0||i==31||j==127||(i<=9&&5<=i&&j<=67&&j>=59)||
					(i<=13&&i>=9&&j<=67&&j>=65)||(j<=67&&j>=59&&i<=17&&i>=13)||
					(i<=21&&i>=17&&j<=61&&j>=59)||(j<=67&&j>=59&&i<=25&&i>=21))
						current_screen[i][j]<=1'b1;
					else 
						current_screen[i][j]<=1'b0;
				end
			end
		end
		2'b10:
		begin
			for(i = 0; i <= 31 ; i=i+1) begin
				for(j = 0; j <= 127 ; j=j+1) begin
					if(i==0||j==0||i==31||j==127||(i<=25&&i>=5&&j<=65&&j>=61))
						current_screen[i][j]<=1'b1;
					else 
						current_screen[i][j]<=1'b0;
				end
			end
		end
		endcase
	end
	
	"ReScreen2":
	begin	
		//设置下一步的位置
		case(DIRECTION)
			4'b0000:
			begin
				next_Direction=current_Direction;
			end
			4'b1000:
			begin
				if(current_Direction!=4'b0100)
					next_Direction=4'b1000;
				else
					next_Direction=current_Direction;
			end
			4'b0100:
			begin
				if(current_Direction!=4'b1000)
					next_Direction=4'b0100;
				else
					next_Direction=current_Direction;
			end
			4'b0010:
			begin
				if(current_Direction!=4'b0001)
					next_Direction=4'b0010;
				else
					next_Direction=current_Direction;
			end
			4'b0001:
			begin
				if(current_Direction!=4'b0010)
					next_Direction=4'b0001;
				else
					next_Direction=current_Direction;
			end
		endcase
		current_Direction<=next_Direction;
		
		case(next_Direction)
			4'b0010:
			begin
				point_temp={snake[0][11:7],snake[0][6:0]-1'b1};
			end
			4'b1000:
			begin
				point_temp={snake[0][11:7]-1'b1,snake[0][6:0]};
			end
			4'b0001:
			begin
				point_temp={snake[0][11:7],snake[0][6:0]+1'b1};
			end
			4'b0100:
			begin
				point_temp={snake[0][11:7]+1'b1,snake[0][6:0]};
			end
		endcase
		
		if(OutofRange(point_temp))
			begin
				END=1'b1;
			end
		else
			begin
				for(index=1;index<snake_Length;index=index+1)
				begin
					if(point_temp==snake[index])
					begin
						END=1'b1;
					end
				end
			end
		if(END==1'b0)
		begin
			if(point_temp==Food)
			begin
				FoodAteFlag=1'b1;
				FoodAte_Count<=FoodAte_Count+1'b1;
				if(snake_Length<=127)
					snake_Length<=snake_Length+1'b1;
			end
			else
			begin
				FoodAteFlag=1'b0;
			end
		end
		if(FoodAteFlag)
			begin
				Food<={1'b0,RANDOM[9:6],1'b0,RANDOM[5:0]};
			end
	end
	
	
	"UpdateFood":
	begin
		//food 放进显示
		page_index=(Food[11:7]<<1'b1);
		column_index=(Food[6:0]<<1'b1);
		current_screen[page_index][column_index]<=1'b1;
		current_screen[page_index][column_index+1'b1]<=1'b1;
		current_screen[page_index+1'b1][column_index]<=1'b1;
		current_screen[page_index+1'b1][column_index+1'b1]<=1'b1;
	end
	
	
	
	"UpdateSnake":
	begin
		snake[Update_Snake_count]<=point_temp;
		point_temp<=snake[Update_Snake_count];
	end
	//page_index四位，column_index六位
	"GetScreen":
	begin
		page_index=(snake[GetScreen_count][11:7]<<1);
		column_index=(snake[GetScreen_count][6:0]<<1);
		current_screen[page_index][column_index]<=1'b1;
		current_screen[page_index][column_index+1'b1]<=1'b1;
		current_screen[page_index+1'b1][column_index]<=1'b1;
		current_screen[page_index+1'b1][column_index+1'b1]<=1'b1;
	end
	
	
	"ReScreen4":
	begin
	for(i = 0; i <= 31 ; i=i+1) begin
		for(j = 0; j <= 127 ; j=j+1) begin
		if(i==0||j==0||i==31||j==127||(i<17&&i>=15&&
		(j==31||j==32||j==63||j==64||j==95||j==96)))
			current_screen[i][j]<=1'b1;
		else
			current_screen[i][j] <= 1'b0;
		end
	end
	end
	
	"ReScreen3":
	begin
	//char G
	for(i=0;i<32;i=i+1) begin
		for(j=0;j<16;j=j+1) begin
			if(i==0||j==0||i==31||(i<11&&i>=9&&j<11&&j>=4)||(i<13&&i>=11&&j>=2&&j<14)||
				(i<15&&i>=13&&j<6&&j>=2)||(i<17&&i>=15&&((j<6&&j>=2)||(j<14&&j>=10)))||
				(i<19&&i>=17&&((j<6&&j>=2)||(j<14&&j>=10)))||(i<21&&i>=19&&j<11&&j>=4))
					current_screen[i][j]<=1'b1;
			else
					current_screen[i][j]<=1'b0;
		end
	end
	
	//char A
	for(i=0;i<32;i=i+1) begin
		for(j=16;j<32;j=j+1) begin
			if(i==0||i==31||(i<11&&i>=9&&j<26&&j>=22)||(i<13&&i>=11&&j<28&&j>=20)||
			(i<15&&i>=13&&((j<22&&j>=18)||(j<30&&j>=26)))||(i<17&&i>=15&&j<30&&j>=18)||
			(i<21&&i>=17&&((j<22&&j>=18)||(j<30&&j>=26))))
				current_screen[i][j]<=1'b1;
			else
				current_screen[i][j]<=1'b0;
		end
	end
	
	//char M
	for(i=0;i<32;i=i+1) begin
		for(j=32;j<48;j=j+1) begin
			if(i==0||i==31||(j<36&&j>=34&&i<21&&i>=9)||(j<38&&j>=36&&i<11&&i>=9)||
			(j<42&&j>=38&&i<15&&i>=11)||(j<44&&j>=42&&i<11&&i>=9)||
			(j<46&&j>44&&i<21&&i>=9))
					current_screen[i][j]<=1'b1;
			else
					current_screen[i][j]<=1'b0;
		end
	end
	
	//char E
	for(i=0;i<32;i=i+1) begin
		for(j=48;j<64;j=j+1) begin
			if(i==0||i==31||(i<11&&i>=9&&j<60&&j>=50)||(i<13&&i>=11&&j>=50&&j<52)||
				(i<15&&i>=13&&j<58&&j>=50)||(i<19&&i>=15&&j<52&&j>=50)||
				(i<21&&i>=19&&j<60&&j>=50))
					current_screen[i][j]<=1'b1;
			else
					current_screen[i][j]<=1'b0;
		end
	end
	
	//char O
	for(i=0;i<32;i=i+1) begin
		for(j=64;j<80;j=j+1) begin
			if(i==0||i==31||(i<11&&i>=9&&j<74&&j>=68)||
			(i>=11&&i<19&&(j<68&&j>=66||j<76&&j>=74))||(i<21&&i>=19&&j<74&&j>=68))
					current_screen[i][j]<=1'b1;
			else
					current_screen[i][j]<=1'b0;
		end
	end
	
	//char V
	for(i=0;i<32;i=i+1) begin
		for(j=80;j<96;j=j+1) begin
			if(i==0||i==31||(j<84&&j>=82&&i<13&&i>=9)||(j<86&&j>=84&&i<15&&i>=11)||
				(j<90&&j>=86&&i<21&&i>=17)||(j>=90&&j<92&&i<15&&i>=11)||
				(j<94&&j>=90&&i<13&&i>=9))
					current_screen[i][j]<=1'b1;
			else
					current_screen[i][j]<=1'b0;
		end
	end
	
	//char E
	for(i=0;i<32;i=i+1) begin
		for(j=96;j<112;j=j+1) begin
			if(i==0||i==31||(i<11&&i>=9&&j<108&&j>=98)||(i<13&&i>=11&&j>=98&&j<100)||
				(i<15&&i>=13&&j<106&&j>=98)||(i<19&&i>=15&&j<100&&j>=98)||
				(i<21&&i>=19&&j<108&&j>=98))
					current_screen[i][j]<=1'b1;
			else
					current_screen[i][j]<=1'b0;
		end
	end
	
	//char R
	for(i=0;i<32;i=i+1) begin
		for(j=112;j<128;j=j+1) begin
			if(i==0||i==31||j==127||(j<116&&j>=114&&i<21&&i>=9)||
			(j<120&&j>=116&&(i<11&&i>=9||i<17&&i>=15))||(j<122&&j>=120&&(i<11&&i>=9||i<19&&i>=15))||
			(j<124&&j>=122&&(i<15&&i>=11||i<21&&i>=19)))
					current_screen[i][j]<=1'b1;
			else
					current_screen[i][j]<=1'b0;
		end
	end
	
	end
	
	endcase
		
	
endmodule