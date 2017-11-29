module keyboard_drive(
	input key_clk,
	input rst,
	input 	 [3:0]row,
	output reg[3:0]col,
	output reg[3:0]keyboard_val,
	output reg key_pressed_flag
);

wire clk;
reg [1:0] cnt;

always@ (posedge key_clk)
	cnt<=cnt+1'b1;

assign clk=cnt[1];


//状态机部分
parameter NO_KEY_PRESSED = 6'b000_001;  // 没有按键按下  
parameter SCAN_COL0      = 6'b000_010;  // 扫描第0列 
parameter SCAN_COL1      = 6'b000_100;  // 扫描第1列 
parameter SCAN_COL2      = 6'b001_000;  // 扫描第2列 
parameter SCAN_COL3      = 6'b010_000;  // 扫描第3列 
parameter KEY_PRESSED    = 6'b100_000;  // 有按键按下

reg [5:0] current_state,next_state;

always @ (posedge clk, negedge rst)
  if (!rst)
    current_state <= NO_KEY_PRESSED;
  else
    current_state <= next_state;

always @ *
  case (current_state)
    NO_KEY_PRESSED :                    // 没有按键按下
        if (row != 4'h0)
          next_state = SCAN_COL0;
        else
          next_state = NO_KEY_PRESSED;
    SCAN_COL0 :                         // 扫描第0列 
        if (row != 4'h0)
          next_state = KEY_PRESSED;
        else
          next_state = SCAN_COL1;
    SCAN_COL1 :                         // 扫描第1列 
        if (row != 4'h0)
          next_state = KEY_PRESSED;
        else
          next_state = SCAN_COL2;    
    SCAN_COL2 :                         // 扫描第2列
        if (row != 4'h0)
          next_state = KEY_PRESSED;
        else
          next_state = SCAN_COL3;
    SCAN_COL3 :                         // 扫描第3列
        if (row != 4'h0)
          next_state = KEY_PRESSED;
        else
          next_state = NO_KEY_PRESSED;
    KEY_PRESSED :                       // 有按键按下
        if (row != 4'h0)
          next_state = KEY_PRESSED;
        else
          next_state = NO_KEY_PRESSED;                      
  endcase
  
  reg [3:0] col_val,row_val;
  
  always@(posedge clk or negedge rst)
  begin
		if(!rst)
		begin
			col<=4'hF;
			key_pressed_flag<= 1;
		end
		else 
			case(next_state)
				NO_KEY_PRESSED:
				begin
					col<=4'hF;
					key_pressed_flag<=1;
				end
				SCAN_COL0 :                       // 扫描第0列
					col <= 4'b0001;
				SCAN_COL1 :                       // 扫描第1列
					col <= 4'b0010;
				SCAN_COL2 :                       // 扫描第2列
					col <= 4'b0100;
				SCAN_COL3 :                       // 扫描第3列
					col <= 4'b1000;
				KEY_PRESSED :                     // 有按键按下
				begin
					col_val          = col;        // 锁存列值
					row_val          = row;        // 锁存行值
					key_pressed_flag = 0;          // 置键盘按下标志  
					case ({col_val, row_val})
						8'b0001_0001 : keyboard_val <= 4'h1;
						8'b0001_0010 : keyboard_val <= 4'h5;
						8'b0001_0100 : keyboard_val <= 4'h9;
						8'b0001_1000 : keyboard_val <= 4'hC;
         
						8'b0010_0001 : keyboard_val <= 4'h2;
						8'b0010_0010 : keyboard_val <= 4'h6;
						8'b0010_0100 : keyboard_val <= 4'h0;
						8'b0010_1000 : keyboard_val <= 4'hD;
         
						8'b0100_0001 : keyboard_val <= 4'h3;
						8'b0100_0010 : keyboard_val <= 4'h7;
						8'b0100_0100 : keyboard_val <= 4'hA;
						8'b0100_1000 : keyboard_val <= 4'hE;
         
						8'b1000_0001 : keyboard_val <= 4'h4; 
						8'b1000_0010 : keyboard_val <= 4'h8;
						8'b1000_0100 : keyboard_val <= 4'hB;
						8'b1000_1000 : keyboard_val <= 4'hF;        
					endcase
				end
			endcase
	end		
  endmodule