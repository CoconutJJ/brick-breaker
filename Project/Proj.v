module Proj(
		CLOCK_50,						//	On Board 50 MHz
		// Your inputs and outputs here
        KEY,
		  LEDR, HEX0, HEX1, HEX4, HEX5, HEX6, HEX7,
		// The ports below are for the VGA output.  Do not change.
		VGA_CLK,   						//	VGA Clock
		VGA_HS,							//	VGA H_SYNC
		VGA_VS,							//	VGA V_SYNC
		VGA_BLANK_N,						//	VGA BLANK
		VGA_SYNC_N,						//	VGA SYNC
		VGA_R,   						//	VGA Red[9:0]
		VGA_G,	 						//	VGA Green[9:0]
		VGA_B   						//	VGA Blue[9:0]
	);

	input			CLOCK_50;				//	50 MHz
	input   [3:0]   KEY;
	output [17:0] LEDR;

	// Declare your inputs and outputs here
	// Do not change the following outputs
	output			VGA_CLK;   				//	VGA Clock
	output			VGA_HS;					//	VGA H_SYNC
	output			VGA_VS;					//	VGA V_SYNC
	output			VGA_BLANK_N;				//	VGA BLANK
	output			VGA_SYNC_N;				//	VGA SYNC
	output	[9:0]	VGA_R;   				//	VGA Red[9:0]
	output	[9:0]	VGA_G;	 				//	VGA Green[9:0]
	output	[9:0]	VGA_B;   				//	VGA Blue[9:0]
	output [6:0] HEX0;
	output [6:0] HEX1;
	output [6:0] HEX4;
	output [6:0] HEX5;
	output [6:0] HEX6;
	output [6:0] HEX7;
    

	// Create an Instance of a VGA controller - there can be only one!
	// Define the number of colours as well as the initial background
	// image file (.MIF) for the controller.
	vga_adapter VGA(
			.resetn(1'b1),
			.clock(CLOCK_50),
			.colour(colour),
			.x(x),
			.y(y),
			.plot(1'b1),
			/* Signals for the DAC to drive the monitor. */
			.VGA_R(VGA_R),
			.VGA_G(VGA_G),
			.VGA_B(VGA_B),
			.VGA_HS(VGA_HS),
			.VGA_VS(VGA_VS),
			.VGA_BLANK(VGA_BLANK_N),
			.VGA_SYNC(VGA_SYNC_N),
			.VGA_CLK(VGA_CLK));
		defparam VGA.RESOLUTION = "160x120";
		defparam VGA.MONOCHROME = "FALSE";
		defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
		defparam VGA.BACKGROUND_IMAGE = "black.mif";
	 
	 reg [5:0] state;
	 reg border_initing, paddle_initing, ball_initing, block_initing;
	 reg [7:0] x, y;
	 reg [7:0] p_x, p_y, b_x, b_y, bl_1_x, bl_1_y, bl_2_x, bl_2_y, bl_3_x, bl_3_y, bl_4_x, bl_4_y, bl_5_x, bl_5_y, bl_6_x, bl_6_y, bl_7_x, bl_7_y, bl_8_x, bl_8_y, bl_9_x, bl_9_y, bl_10_x, bl_10_y, bl_11_x, bl_11_y, bl_12_x, bl_12_y, bl_13_x, bl_13_y, bl_14_x, bl_14_y, bl_15_x, bl_15_y, bl_16_x, bl_16_y, bl_17_x, bl_17_y, bl_18_x, bl_18_y, bl_19_x, bl_19_y, bl_20_x, bl_20_y, bl_21_x, bl_21_y, mbl_1_x, mbl_1_y, mbl_2_x, mbl_2_y;
    reg [7:0] ceil_y = 8'd0;
	 reg [7:0] score = 8'd0;
	 reg [7:0] hi_score = 8'd0;
	 reg mbl_1_xdir, mbl_2_xdir;
	 reg [2:0] colour;
	 reg b_x_direction, b_y_direction;
	 reg [17:0] draw_counter;
	 reg [2:0] block_1_colour, block_2_colour, block_3_colour, block_4_colour, block_5_colour, block_6_colour, block_7_colour, block_8_colour, block_9_colour, block_10_colour, block_11_colour, block_12_colour, block_13_colour, block_14_colour, block_15_colour, block_16_colour, block_17_colour, block_18_colour, block_19_colour, block_20_colour, block_21_colour;
	 reg [2:0] mblock_1_colour = 3'b101;
	 reg [2:0] mblock_2_colour = 3'b101;
	 wire frame;
	 reg wall_count = 1'b0;
	 /* 
	 power 1 is raise ceiling,
	 2 is shorten paddle,
	 3 is normal paddle,
	 4 is lengthen paddle
	 */
	 reg power_1, power_2, power_3, power_4;
	 reg [6:0] p_length;
	 assign LEDR[5:0] = state;
	 
	 localparam  RESET_BLACK       = 7'b0000000,
                INIT_PADDLE       = 7'b0000001,
                INIT_BALL         = 7'b0000010,
                INIT_BLOCK_1      = 7'b0000011,

				INIT_BLOCK_2      = 7'b0000100,
				INIT_BLOCK_3      = 7'b0000101,
				INIT_BLOCK_4      = 7'b0000110,
				INIT_BLOCK_5      = 7'b0000111,
				INIT_BLOCK_6 = 7'b0001000,
				INIT_BLOCK_7 = 7'b0001001,
				INIT_BLOCK_8 = 7'b0001010,
				INIT_BLOCK_9 = 7'b0001011,
				INIT_BLOCK_10 = 7'b0001100,
				INIT_MOVBLK_1 = 7'b0001101,  //Remember to change all these numbers

				 IDLE              = 7'b0001110,
				 ERASE_PADDLE	    = 7'b0001111,
				 UPDATE_PADDLE     = 7'b0010000,
				 DRAW_PADDLE	    = 7'b0010001,
				 ERASE_BALL        = 7'b0010010,

				UPDATE_BALL       = 7'b0010011,
				DRAW_BALL         = 7'b0010100,
				UPDATE_BLOCK_1    = 7'b0010101,
				DRAW_BLOCK_1      = 7'b0010110,
				UPDATE_BLOCK_2    = 7'b0010111,
		    	DRAW_BLOCK_2      = 7'b0011000,
				UPDATE_BLOCK_3    = 7'b0011001,
				DRAW_BLOCK_3      = 7'b0011010,
				UPDATE_BLOCK_4    = 7'b0011011,
				DRAW_BLOCK_4      = 7'b0011100,
				UPDATE_BLOCK_5    = 7'b0011101,
				DRAW_BLOCK_5      = 7'b0011110,
            			UPDATE_BLOCK_6  = 7'b0011111,
			   DRAW_BLOCK_6    = 7'b0100000,
            UPDATE_BLOCK_7  = 7'b0100001,
			   DRAW_BLOCK_7    = 7'b0100010,
            UPDATE_BLOCK_8  = 7'b0100011,
			   DRAW_BLOCK_8    = 7'b0100100,
            UPDATE_BLOCK_9  = 7'b0100101,
            DRAW_BLOCK_9    = 7'b0100110,
            UPDATE_BLOCK_10 = 7'b0100111,
			   DRAW_BLOCK_10   = 7'b0101000,
				ERASE_MOVBLK_1   = 7'b0101001,
				UPDATE_MOVBLK_1  = 7'b0101010,
				DRAW_MOVBLK_1    = 7'b0101011,
				DEAD = 7'b0101100, 

            INIT_CEIL = 7'b0101101,
            UPDATE_CEIL = 7'b0101110,

            CHECK_IFWON = 7'b0101111,  //state for checking if player has cleared all the blocks
            WON_GAME = 7'b0110000,
            
            INIT_BLOCK_11 = 7'b0110001,
            INIT_BLOCK_12 = 7'b0110010,
            INIT_BLOCK_13 = 7'b0110011,
            INIT_BLOCK_14 = 7'b0110100,
            INIT_BLOCK_15 = 7'b0110101,
            INIT_BLOCK_16 = 7'b0110110,
            INIT_BLOCK_17 = 7'b0110111,
            INIT_BLOCK_18 = 7'b0111000,
            INIT_BLOCK_19 = 7'b0111001,
            INIT_BLOCK_20 = 7'b0111010,
            INIT_BLOCK_21 = 7'b0111011,
            INIT_MOVBLK_2 = 7'b0111100,
            ERASE_MOVBLK_2   = 7'b0111101,
			UPDATE_MOVBLK_2  = 7'b0111110,
			DRAW_MOVBLK_2    = 7'b0111111,
			
			UPDATE_BLOCK_11    = 7'b1000000,
			DRAW_BLOCK_11      = 7'b1000001,
			UPDATE_BLOCK_12    = 7'b1000010,
			DRAW_BLOCK_12      = 7'b1000011,
			UPDATE_BLOCK_13    = 7'b1000100,
			DRAW_BLOCK_13      = 7'b1000101,
			UPDATE_BLOCK_14    = 7'b1000110,
			DRAW_BLOCK_14      = 7'b1000111,
			UPDATE_BLOCK_15    = 7'b1001000,
			DRAW_BLOCK_15      = 7'b1001001,
			UPDATE_BLOCK_16    = 7'b1001010,
			DRAW_BLOCK_16      = 7'b1001011,
			UPDATE_BLOCK_17    = 7'b1001100,
			DRAW_BLOCK_17      = 7'b1001101,
			UPDATE_BLOCK_18    = 7'b1001110,
			DRAW_BLOCK_18      = 7'b1001111,
			UPDATE_BLOCK_19    = 7'b1010000,
			DRAW_BLOCK_19      = 7'b1010001,
			UPDATE_BLOCK_20    = 7'b1010010,
			DRAW_BLOCK_20      = 7'b1010011,
			UPDATE_BLOCK_21    = 7'b1010100,
			DRAW_BLOCK_21      = 7'b1010101;
			

	 clock(.clock(CLOCK_50), .clk(frame));
	 
     assign LEDR[7] = ((b_y_direction) && (b_y > p_y - 8'd1) && (b_y < p_y + 8'd2) && (b_x >= p_x) && (b_x <= p_x + 8'd8));
	  
	  //current scores
	  hex_decoder H0(
        .hex_digit(score[3:0]), 
        .segments(HEX0)
        );
        
     hex_decoder H1(
        .hex_digit(score[7:4]), 
        .segments(HEX1)
        );
		  
		
		//hi score
		//show hi
		assign HEX7[6:0] = 7'b0001001;
		assign HEX6[6:0] = 7'b1001111;
		//show hi score
		hex_decoder H4(
        .hex_digit(hi_score[3:0]), 
        .segments(HEX4)
        );
        
     hex_decoder H5(
        .hex_digit(hi_score[7:4]), 
        .segments(HEX5)
        );

	 
	 
     // GAME FSM
     always@(posedge CLOCK_50)
        begin
			border_initing = 1'b0;  //unused?
			paddle_initing = 1'b0;
			ball_initing = 1'b0;
			block_initing = 1'b0;
			colour = 3'b000;
			x = 8'b00000000;
			y = 8'b00000000;
			
			if (~KEY[0]) begin
				ceil_y = 8'd0;
				score = 8'd0;
				power_1 = 0;
				power_2 = 0;
				power_3 = 0;
				power_4 = 0;
				mblock_1_colour = 3'b101;
				mblock_2_colour = 3'b101;
				state = RESET_BLACK;
			end
			
        case (state)
		  RESET_BLACK: begin
			if (draw_counter < 17'b10000000000000000) begin
						x = draw_counter[7:0];
						y = draw_counter[16:8];
						draw_counter = draw_counter + 1'b1;
						end
			else begin
						draw_counter= 8'b00000000;
						state = INIT_PADDLE;
			end
		  end
    			 INIT_PADDLE: begin
    			 	 p_length = 7'b0010000; //reset paddle length to 16
					 if (draw_counter < 6'b10000) begin
					 p_x = 8'd76;
					 p_y = 8'd110;
						x = p_x + draw_counter[3:0];
						y = p_y + draw_counter[4];
						draw_counter = draw_counter + 1'b1;
						colour = 3'b111;
						end
					else begin
						draw_counter= 8'b00000000;
						state = INIT_BALL;
					end
				 end
				 INIT_BALL: begin
					 b_x = 8'd80;
					 b_y = 8'd108;
						x = b_x;
						y = b_y;
						colour = 3'b111;
						if ((ceil_y > 0) || (power_1 == 1'b1)) state = IDLE;  //if not first round then skip initialization of blocks
						else state = INIT_BLOCK_1;
				 end
				
				 INIT_BLOCK_1: begin //red
					 bl_1_x = 8'd34; 
					 bl_1_y = 8'd30;
					 block_1_colour = 3'b100;
						state = INIT_BLOCK_2;
				 end

				 INIT_BLOCK_2: begin
					 bl_2_x = 8'd76;
					 bl_2_y = 8'd30;
					 block_2_colour = 3'b100;
						state = INIT_BLOCK_3;
				 end
				 INIT_BLOCK_3: begin
					 bl_3_x = 8'd118;
					 bl_3_y = 8'd30;
					 block_3_colour = 3'b100;
						state = INIT_BLOCK_4;
				 end
				 INIT_BLOCK_4: begin //green-blue
					 bl_4_x = 8'd25;
					 bl_4_y = 8'd38;
					 block_4_colour = 3'b011;
						state = INIT_BLOCK_5;
				 end
				
				 INIT_BLOCK_5: begin
					 bl_5_x = 8'd58;
					 bl_5_y = 8'd38;
					 block_5_colour = 3'b011;
						state = INIT_BLOCK_6;
				 end

                		INIT_BLOCK_6: begin
					 bl_6_x = 8'd91;
					 bl_6_y = 8'd38;
					 block_6_colour = 3'b011;
						state = INIT_BLOCK_7;
				 end

                 		INIT_BLOCK_7: begin
					 bl_7_x = 8'd124;
					 bl_7_y = 8'd38;
					 block_7_colour = 3'b011;
						state = INIT_BLOCK_8;
				 end
                		INIT_BLOCK_8: begin //blue
					 bl_8_x = 8'd34;
					 bl_8_y = 8'd45;
					 block_8_colour = 3'b001;
						state = INIT_BLOCK_9;
				 end

                		INIT_BLOCK_9: begin
					 bl_9_x = 8'd76;
					 bl_9_y = 8'd45;
					 block_9_colour = 3'b001;
						state = INIT_BLOCK_10;
				 end
                 		INIT_BLOCK_10: begin

					 bl_10_x = 8'd51;
					 bl_10_y = 8'd45;
					 block_10_colour = 3'b001;
						state = INIT_MOVBLK_1; //INIT_BLOCK_11;
				 end



				INIT_MOVBLK_1: begin
					 if (draw_counter < 6'b100000) begin
					 mbl_1_x = 8'd76;
					 mbl_1_y = 8'd20;
						x = mbl_1_x + draw_counter[2:0];
						y = mbl_1_y + draw_counter[4:3];
						draw_counter = draw_counter + 1'b1;
						mblock_1_colour = 3'b101;
						colour = mblock_1_colour;
						mbl_1_xdir = 1'b1;  //this means move right first
						end
					else begin
						draw_counter= 8'b00000000;
						state = INIT_MOVBLK_2;
					end
				 end
				 
				 INIT_MOVBLK_2: begin
					 if (draw_counter < 6'b100000) begin
					 mbl_2_x = 8'd76;

					 mbl_2_y = 8'd55;

						x = mbl_2_x + draw_counter[2:0];
						y = mbl_2_y + draw_counter[4:3];
						draw_counter = draw_counter + 1'b1;
						mblock_2_colour = 3'b101;
						colour = mblock_2_colour;
						mbl_2_xdir = 1'b0;  //this means move right first
						end
					else begin
						draw_counter= 8'b00000000;
						state = IDLE;
					end
				 end
				


				 IDLE: begin
				 if (frame)
					state = UPDATE_BLOCK_1;
				 end
				 
				 UPDATE_BLOCK_1: begin
					if ((block_1_colour != 3'b000) && (b_y > bl_1_y + ceil_y - 8'd1) && (b_y < bl_1_y + ceil_y + 8'd4) && (b_x >= bl_1_x) && (b_x <= bl_1_x + 8'd7)) begin
						b_y_direction = ~b_y_direction;
						block_1_colour = 3'b000;
						score = score + 8'd1;
						power_2 = 1'b1;
						power_3 = 1'b0;
						power_4 = 1'b0;
					end
					state = DRAW_BLOCK_1;
				 end
				 DRAW_BLOCK_1: begin
					if (draw_counter < 5'b10000) begin
						x = bl_1_x + draw_counter[2:0];
						y = bl_1_y + ceil_y + draw_counter[3];
						draw_counter = draw_counter + 1'b1;
						colour = block_1_colour;
						end
					else begin
						draw_counter= 8'b00000000;
						state = UPDATE_BLOCK_2;
					end
				 end
				 UPDATE_BLOCK_2: begin
					if ((block_2_colour != 3'b000) && (b_y > bl_2_y + ceil_y - 8'd1) && (b_y < bl_2_y + ceil_y + 8'd4) && (b_x >= bl_2_x) && (b_x <= bl_2_x + 8'd7)) begin
						b_y_direction = ~b_y_direction;
						block_2_colour = 3'b000;
						score = score + 8'd1;
						power_2 = 1'b1;
						power_3 = 1'b0;
						power_4 = 1'b0;
					end
					state = DRAW_BLOCK_2;
				 end
				 DRAW_BLOCK_2: begin
					if (draw_counter < 5'b10000) begin
						x = bl_2_x + draw_counter[2:0];
						y = bl_2_y + ceil_y + draw_counter[3];
						draw_counter = draw_counter + 1'b1;
						colour = block_2_colour;
						end
					else begin
						draw_counter= 8'b00000000;
						state = UPDATE_BLOCK_3;
					end
				 end
				 UPDATE_BLOCK_3: begin
					if ((block_3_colour != 3'b000) && (b_y > bl_3_y + ceil_y - 8'd1) && (b_y < bl_3_y + ceil_y + 8'd4) && (b_x >= bl_3_x) && (b_x <= bl_3_x + 8'd7)) begin
						b_y_direction = ~b_y_direction;
						block_3_colour = 3'b000;
						score = score + 8'd1;
						power_2 = 1'b1;
						power_3 = 1'b0;
						power_4 = 1'b0;
					end
					state = DRAW_BLOCK_3;
				 end
				 DRAW_BLOCK_3: begin
					if (draw_counter < 5'b10000) begin
						x = bl_3_x + draw_counter[2:0];
						y = bl_3_y + ceil_y + draw_counter[3];
						draw_counter = draw_counter + 1'b1;
						colour = block_3_colour;
						end
					else begin
						draw_counter= 8'b00000000;
						state = UPDATE_BLOCK_4;
					end
				 end
				 UPDATE_BLOCK_4: begin
					if ((block_4_colour != 3'b000) && (b_y > bl_4_y + ceil_y - 8'd1) && (b_y < bl_4_y + ceil_y + 8'd4) && (b_x >= bl_4_x) && (b_x <= bl_4_x + 8'd7)) begin
						b_y_direction = ~b_y_direction;
						block_4_colour = 3'b000;
						score = score + 8'd1;
						power_2 = 1'b0;
						power_3 = 1'b1;
						power_4 = 1'b0;
					end
					state = DRAW_BLOCK_4;
				 end
				 DRAW_BLOCK_4: begin
					if (draw_counter < 5'b10000) begin
						x = bl_4_x + draw_counter[2:0];
						y = bl_4_y + ceil_y + draw_counter[3];
						draw_counter = draw_counter + 1'b1;
						colour = block_4_colour;
						end
					else begin
						draw_counter= 8'b00000000;
						state = UPDATE_BLOCK_5;
					end
				 end
				 UPDATE_BLOCK_5: begin
					if ((block_5_colour != 3'b000) && (b_y > bl_5_y + ceil_y - 8'd1) && (b_y < bl_5_y + ceil_y + 8'd4) && (b_x >= bl_5_x) && (b_x <= bl_5_x + 8'd7)) begin
						b_y_direction = ~b_y_direction;
						block_5_colour = 3'b000;
						score = score + 8'd1;
						power_2 = 1'b0;
						power_3 = 1'b1;
						power_4 = 1'b0;
					end
					state = DRAW_BLOCK_5;
				 end
				 DRAW_BLOCK_5: begin
					if (draw_counter < 5'b10000) begin
						x = bl_5_x + draw_counter[2:0];
						y = bl_5_y + ceil_y + draw_counter[3];
						draw_counter = draw_counter + 1'b1;
						colour = block_5_colour;
						end
					else begin
						draw_counter= 8'b00000000;
						state = UPDATE_BLOCK_6;
					end
				 end
                
				 UPDATE_BLOCK_6: begin
					if ((block_6_colour != 3'b000) && (b_y > bl_6_y + ceil_y - 8'd1) && (b_y < bl_6_y + ceil_y + 8'd4) && (b_x >= bl_6_x) && (b_x <= bl_6_x + 8'd7)) begin
						b_y_direction = ~b_y_direction;
						block_6_colour = 3'b000;
						score = score + 8'd1;
						power_2 = 1'b0;
						power_3 = 1'b1;
						power_4 = 1'b0;
					end
					state = DRAW_BLOCK_6;
				 end
				 DRAW_BLOCK_6: begin
					if (draw_counter < 5'b10000) begin
						x = bl_6_x + draw_counter[2:0];
						y = bl_6_y + ceil_y + draw_counter[3];
						draw_counter = draw_counter + 1'b1;
						colour = block_6_colour;
						end
					else begin
						draw_counter= 8'b00000000;
						state = UPDATE_BLOCK_7;
					end
				 end
                
				 UPDATE_BLOCK_7: begin
					if ((block_7_colour != 3'b000) && (b_y > bl_7_y + ceil_y - 8'd1) && (b_y < bl_7_y + ceil_y + 8'd4) && (b_x >= bl_7_x) && (b_x <= bl_7_x + 8'd7)) begin
						b_y_direction = ~b_y_direction;
						block_7_colour = 3'b000;
						score = score + 8'd1;
						power_2 = 1'b0;
						power_3 = 1'b1;
						power_4 = 1'b0;
					end
					state = DRAW_BLOCK_7;
				 end
				 DRAW_BLOCK_7: begin
					if (draw_counter < 5'b10000) begin
						x = bl_7_x + draw_counter[2:0];
						y = bl_7_y + ceil_y + draw_counter[3];
						draw_counter = draw_counter + 1'b1;
						colour = block_7_colour;
						end
					else begin
						draw_counter= 8'b00000000;
						state = UPDATE_BLOCK_8;
					end
				 end
                
				 UPDATE_BLOCK_8: begin
					if ((block_8_colour != 3'b000) && (b_y > bl_8_y + ceil_y - 8'd1) && (b_y < bl_8_y + ceil_y + 8'd4) && (b_x >= bl_8_x) && (b_x <= bl_8_x + 8'd7)) begin
						b_y_direction = ~b_y_direction;
						block_8_colour = 3'b000;
						score = score + 8'd1;
						power_2 = 1'b0;
						power_3 = 1'b0;
						power_4 = 1'b1;
					end
					state = DRAW_BLOCK_8;
				 end
				 DRAW_BLOCK_8: begin
					if (draw_counter < 5'b10000) begin
						x = bl_8_x + draw_counter[2:0];
						y = bl_8_y + ceil_y + draw_counter[3];
						draw_counter = draw_counter + 1'b1;
						colour = block_8_colour;
						end
					else begin
						draw_counter= 8'b00000000;
						state = UPDATE_BLOCK_9;
					end
				 end

				 UPDATE_BLOCK_9: begin
					if ((block_9_colour != 3'b000) && (b_y > bl_9_y + ceil_y - 8'd1) && (b_y < bl_9_y + ceil_y + 8'd4) && (b_x >= bl_9_x) && (b_x <= bl_9_x + 8'd7)) begin
						b_y_direction = ~b_y_direction;
						block_9_colour = 3'b000;
						score = score + 8'd1;
						power_2 = 1'b0;
						power_3 = 1'b0;
						power_4 = 1'b1;
					end
					state = DRAW_BLOCK_9;
				 end
				 DRAW_BLOCK_9: begin
					if (draw_counter < 5'b10000) begin
						x = bl_9_x + draw_counter[2:0];
						y = bl_9_y + ceil_y + draw_counter[3];
						draw_counter = draw_counter + 1'b1;
						colour = block_9_colour;
						end
					else begin
						draw_counter= 8'b00000000;
						state = UPDATE_BLOCK_10;
					end
				 end
				 
                 UPDATE_BLOCK_10: begin
					if ((block_10_colour != 3'b000) && (b_y > bl_10_y + ceil_y - 8'd1) && (b_y < bl_10_y + ceil_y + 8'd4) && (b_x >= bl_10_x) && (b_x <= bl_10_x + 8'd7)) begin
						b_y_direction = ~b_y_direction;
						block_10_colour = 3'b000;
						score = score + 8'd1;
						power_2 = 1'b0;
						power_3 = 1'b0;
						power_4 = 1'b1;
					end
					state = DRAW_BLOCK_10;
				 end
				 DRAW_BLOCK_10: begin
					if (draw_counter < 5'b10000) begin
						x = bl_10_x + draw_counter[2:0];
						y = bl_10_y + ceil_y + draw_counter[3];
						draw_counter = draw_counter + 1'b1;
						colour = block_10_colour;
						end
					else begin
						draw_counter= 8'b00000000;
						state = ERASE_MOVBLK_1; 
					end
				 end
	
				 

				
				ERASE_MOVBLK_1: begin
						if (draw_counter < 5'b10000) begin
						x = mbl_1_x + draw_counter[2:0];
						y = mbl_1_y + ceil_y + draw_counter[3];
						draw_counter = draw_counter + 1'b1;
						end
					else begin
						draw_counter= 8'b00000000;
						state = UPDATE_MOVBLK_1;
					end
				 end
				 UPDATE_MOVBLK_1: begin
						//change directions
						if (mbl_1_x == 8'd152) mbl_1_xdir = ~mbl_1_xdir;
						if (mbl_1_x == 8'd0) mbl_1_xdir = ~mbl_1_xdir;

						if (mbl_1_xdir) mbl_1_x = mbl_1_x + 1'b1; //move right
						else mbl_1_x = mbl_1_x - 1'b1;  //move left

						//if block gets hit
						if ((mblock_1_colour != 3'b000) && (b_y > mbl_1_y + ceil_y - 8'd1) && (b_y < mbl_1_y + ceil_y + 8'd4) && (b_x >= mbl_1_x) && (b_x <= mbl_1_x + 8'd7)) begin
						b_y_direction = ~b_y_direction;  
						mblock_1_colour = 3'b000;
						score = score + 8'd5;
						//powerup 1
						if (ceil_y >= 8'd7) begin 
							ceil_y = ceil_y - 8'd7;
							power_1 = 1'b1;
							state = UPDATE_CEIL;
							end
						end

						state = DRAW_MOVBLK_1;
						
				 end
				 DRAW_MOVBLK_1: begin
					if (draw_counter < 5'b10000) begin
						x = mbl_1_x + draw_counter[2:0];
						y = mbl_1_y + ceil_y + draw_counter[3];
						draw_counter = draw_counter + 1'b1;
						colour = mblock_1_colour;
						end
					else begin
						draw_counter= 8'b00000000;
						state = ERASE_MOVBLK_2;
					end
				 end
				 
				 ERASE_MOVBLK_2: begin
						if (draw_counter < 5'b10000) begin
						x = mbl_2_x + draw_counter[2:0];
						y = mbl_2_y + ceil_y + draw_counter[3];
						draw_counter = draw_counter + 1'b1;
						end
					else begin
						draw_counter= 8'b00000000;
						state = UPDATE_MOVBLK_2;
					end
				 end
				 UPDATE_MOVBLK_2: begin
						//change directions
						if (mbl_2_x == 8'd152) mbl_2_xdir = ~mbl_2_xdir;
						if (mbl_2_x == 8'd0) mbl_2_xdir = ~mbl_2_xdir;

						if (mbl_2_xdir) mbl_2_x = mbl_2_x + 1'b1; //move right
						else mbl_2_x = mbl_2_x - 1'b1;  //move left

						//if block gets hit
						if ((mblock_2_colour != 3'b000) && (b_y > mbl_2_y + ceil_y - 8'd1) && (b_y < mbl_2_y + ceil_y + 8'd2) && (b_x >= mbl_2_x) && (b_x <= mbl_2_x + 8'd7)) begin
						b_y_direction = ~b_y_direction;  
						mblock_2_colour = 3'b000;
						score = score + 8'd5;
						//powerup 1
						if (ceil_y >= 8'd7) begin 
							ceil_y = ceil_y - 8'd7;
							power_1 = 1'b1;
							state = UPDATE_CEIL;
							end
						end

						state = DRAW_MOVBLK_2;
						
				 end
				 DRAW_MOVBLK_2: begin
					if (draw_counter < 5'b10000) begin
						x = mbl_2_x + draw_counter[2:0];
						y = mbl_2_y + ceil_y + draw_counter[3];
						draw_counter = draw_counter + 1'b1;
						colour = mblock_2_colour;
						end
					else begin
						draw_counter= 8'b00000000;
						state = ERASE_PADDLE;
					end
				 end
				
				ERASE_PADDLE: begin
						if (draw_counter < 7'b1000000) begin 
						x = p_x + draw_counter[4:0];
						y = p_y + draw_counter[5];
						draw_counter = draw_counter + 1'b1;
						end
					else begin
						draw_counter= 8'b00000000;
						state = UPDATE_PADDLE;
					end
				 end
				 UPDATE_PADDLE: begin
				 		if (power_2) p_length = 7'b0001000; //8
				 		else if (power_3) p_length = 7'b0010000; //16
				 		else if (power_4) p_length = 7'b0100000; //32
				 
						if (~KEY[1] && p_x < 8'd160 - p_length) p_x = p_x + 1'b1; //right
						if (~KEY[2] && p_x > 8'd0) p_x = p_x - 1'b1;  //left
						state = DRAW_PADDLE;
						
				 end
				 DRAW_PADDLE: begin
					if (draw_counter < (p_length + p_length)) begin
						//if length is 8
						if (p_length == 7'b0001000) begin
						x = p_x + draw_counter[2:0];
						y = p_y + draw_counter[3];
						end
						//if length is 16
						else if (p_length == 7'b0010000) begin
						x = p_x + draw_counter[3:0];
						y = p_y + draw_counter[4];
						end
						//if length is 32
						else if (p_length == 7'b0100000) begin
						x = p_x + draw_counter[4:0];
						y = p_y + draw_counter[5];
						end
						
						draw_counter = draw_counter + 1'b1;
						colour = 3'b111;
						end
					else begin
						draw_counter= 8'b00000000;
						state = ERASE_BALL;
					end
				 end
				 
				 ERASE_BALL: begin
					x = b_x;
						y = b_y;
						state = UPDATE_BALL;
				 end
				UPDATE_BALL: begin
									
										 
					if (~b_x_direction) begin
						//if (wall_count == 0 && b_y % 2 == 0) //attempt to vary ball speed/angle
							b_x = b_x + 1'b1;  
						end
					 else begin
						//if (wall_count == 0 && b_y % 2 == 0) 
							b_x = b_x - 1'b1;
						end

					
					 if (b_y_direction) b_y = b_y + 1'b1;
					 else b_y = b_y - 1'b1;
					 
					if ((b_x <= 8'd0) || (b_x >= 8'd160)) begin
					b_x_direction = ~b_x_direction;
					//wall_count = wall_count + 1'b1;
					end
				
				//check if ball hits paddle or the top of screen
				if ((b_y == 8'd0) || ((b_y_direction) && (b_y > p_y - 8'd1) && (b_y < p_y + 8'd2) && (b_x >= p_x) && (b_x <= p_x + p_length - 8'd1))) begin
					b_y_direction = ~b_y_direction;

					//vary direction of the ball
					if ((p_y % 1'd2) == 1'd0) b_x_direction = ~b_x_direction;

				end
					
					if (b_y >= 8'd120) begin 
					ceil_y = ceil_y + 8'd7;
	               state = UPDATE_CEIL;
	            end
               else state = DRAW_BALL;
				 end
				 DRAW_BALL: begin
					x = b_x;
						y = b_y;
						colour = 3'b111;
						state = CHECK_IFWON;
				 end

                                CHECK_IFWON: begin
                                	if ((block_1_colour == 3'b000) &&
                                		(block_2_colour == 3'b000) &&
		                                (block_3_colour == 3'b000) &&
                                		(block_4_colour == 3'b000) &&
                                		(block_5_colour == 3'b000) &&
                                		(block_6_colour == 3'b000) &&
                                		(block_7_colour == 3'b000) &&
                                		(block_8_colour == 3'b000) &&
                                		(block_9_colour == 3'b000) &&
                                		(block_10_colour == 3'b000) &&
                                        (block_11_colour == 3'b000) &&
                                        (block_12_colour == 3'b000) &&
                                        (block_13_colour == 3'b000) &&
                                        (block_14_colour == 3'b000) &&
                                        (block_15_colour == 3'b000) &&
                                        (block_16_colour == 3'b000) &&
                                        (block_17_colour == 3'b000) &&
                                        (block_19_colour == 3'b000) &&
                                        (block_20_colour == 3'b000) &&
                                        (block_21_colour == 3'b000) &&
                                		(mblock_1_colour == 3'b000) &&
                                		(mblock_2_colour == 3'b000)
                                		) state = WON_GAME;
                                	else state = IDLE;
                                end

                                WON_GAME: begin
                                	if (draw_counter < 17'b10000000000000000) begin
                                		x = draw_counter[7:0];
		                                y = draw_counter[16:8];
                                		draw_counter = draw_counter + 1'b1;
                                		colour = 3'b010;
                                	end
						ceil_y = 8'd0;
						if (hi_score < score) hi_score = score;
						score = 8'd0;
                                end
				


				 DEAD: begin

					if (draw_counter < 17'b10000000000000000) begin
						x = draw_counter[7:0];
						y = draw_counter[16:8];
						draw_counter = draw_counter + 1'b1;
						colour = 3'b100;
						ceil_y = 8'd0;
						if (hi_score < score) hi_score = score;
						score = 8'd0;
						end
				end



                                
										  UPDATE_CEIL: begin

                                	//check if blocks have reached bottom, if yes then go to dead state
                                	// take into account anticipated ceiling position for blocks
                                	if (((block_1_colour != 3'b000) && (bl_1_y + ceil_y + 8'd2 > 8'd108)) ||
                                		((block_2_colour != 3'b000) && (bl_2_y + ceil_y + 8'd2 > 8'd108)) ||
                                		((block_3_colour != 3'b000) && (bl_3_y + ceil_y + 8'd2 > 8'd108)) ||
                                		((block_4_colour != 3'b000) && (bl_4_y + ceil_y + 8'd2 > 8'd108)) ||
                                		((block_5_colour != 3'b000) && (bl_5_y + ceil_y + 8'd2 > 8'd108)) ||
                                		((block_6_colour != 3'b000) && (bl_6_y + ceil_y + 8'd2 > 8'd108)) ||
                                		((block_7_colour != 3'b000) && (bl_7_y + ceil_y + 8'd2 > 8'd108)) ||
                                		((block_8_colour != 3'b000) && (bl_8_y + ceil_y + 8'd2 > 8'd108)) ||
                                		((block_9_colour != 3'b000) && (bl_9_y + ceil_y + 8'd2 > 8'd108)) ||
                                		((block_10_colour != 3'b000) && (bl_10_y + ceil_y + 8'd2 > 8'd108)) ||
                                		((block_11_colour != 3'b000) && (bl_11_y + ceil_y + 8'd2 > 8'd108)) ||
                                		((block_12_colour != 3'b000) && (bl_12_y + ceil_y + 8'd2 > 8'd108)) ||
                                		((block_13_colour != 3'b000) && (bl_13_y + ceil_y + 8'd2 > 8'd108)) ||
                                		((block_14_colour != 3'b000) && (bl_14_y + ceil_y + 8'd2 > 8'd108)) ||
                                		((block_15_colour != 3'b000) && (bl_15_y + ceil_y + 8'd2 > 8'd108)) ||
                                		((block_16_colour != 3'b000) && (bl_16_y + ceil_y + 8'd2 > 8'd108)) ||
                                		((block_17_colour != 3'b000) && (bl_17_y + ceil_y + 8'd2 > 8'd108)) ||
                                		((block_18_colour != 3'b000) && (bl_18_y + ceil_y + 8'd2 > 8'd108)) ||
                                		((block_19_colour != 3'b000) && (bl_19_y + ceil_y + 8'd2 > 8'd108)) ||
                                		((block_20_colour != 3'b000) && (bl_20_y + ceil_y + 8'd2 > 8'd108)) ||
                                		((block_21_colour != 3'b000) && (bl_21_y + ceil_y + 8'd2 > 8'd108)) ||
                                		((mblock_1_colour != 3'b000) && (mbl_1_y + ceil_y + 8'd2 > 8'd108)) ||
                                		((mblock_2_colour != 3'b000) && (mbl_2_y + ceil_y + 8'd2 > 8'd108))
                                		) state = DEAD;

                                	else state = RESET_BLACK; //init ball and paddle again
	
                                	end
								
         endcase
    end
endmodule

module clock(input clock, output clk);
reg [19:0] frame_counter;
reg frame;
	always@(posedge clock)
    begin
        if (frame_counter == 20'b00000000000000000000) begin
		  frame_counter = 20'b11001011011100110100;
		  frame = 1'b1;
		  end
        else begin
			frame_counter = frame_counter - 1'b1;
			frame = 1'b0;
		  end
    end
	 assign clk = frame;
endmodule



module hex_decoder(hex_digit, segments);
    input [3:0] hex_digit;
    output reg [6:0] segments;
   
    always @(*)
        case (hex_digit)
            4'h0: segments = 7'b100_0000;
            4'h1: segments = 7'b111_1001;
            4'h2: segments = 7'b010_0100;
            4'h3: segments = 7'b011_0000;
            4'h4: segments = 7'b001_1001;
            4'h5: segments = 7'b001_0010;
            4'h6: segments = 7'b000_0010;
            4'h7: segments = 7'b111_1000;
            4'h8: segments = 7'b000_0000;
            4'h9: segments = 7'b001_1000;
            4'hA: segments = 7'b000_1000;
            4'hB: segments = 7'b000_0011;
            4'hC: segments = 7'b100_0110;
            4'hD: segments = 7'b010_0001;
            4'hE: segments = 7'b000_0110;
            4'hF: segments = 7'b000_1110;   
            default: segments = 7'h7f;
        endcase
endmodule

