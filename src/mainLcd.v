module bcdConv2(
    input [9:0] temp,
    output reg [3:0] bcd_hundreds, bcd_tens, bcd_ones  
);
    reg [6:0] count;
    reg [9:0] tempCopy;


    always @(temp) begin
        tempCopy = temp;
        bcd_hundreds = 0;
        bcd_tens = 0;
        bcd_ones = 0;

        for(count = 0; count < 10; count = count + 1) begin
            if (tempCopy >= 100) begin
                tempCopy = tempCopy - 100;
                bcd_hundreds = bcd_hundreds + 1;
            end
        end

        for(count = 0; count < 10; count = count + 1) begin
            if (tempCopy >= 10) begin
                tempCopy = tempCopy - 10;
                bcd_tens = bcd_tens + 1;
            end
        end

        bcd_ones = tempCopy;

    end
endmodule

//// ///// //// ////

module mainLcd (WCn, Cn, Ti, clk, reset, Rs, Rw, E, Data);
	input clk, reset;
	input [9:0] Cn,Ti;
	input [3:0] WCn;
	
	output reg Rs,Rw,E;
	output reg [7:0] Data;
	
	localparam FUNC_SET = 8'h38;
	localparam DISPLAY_ON = 8'h0C;
	localparam CLEAR = 8'h01;
	localparam ENTRY_MODE = 8'h06;
	localparam SET_ROW1 = 8'h80;
	localparam SET_ROW2 = 8'h80 + 8'h40;
	localparam SET_FIRST_LETTER = 8'h80;
		
	reg [7:0] firstLine [15:0];
	reg [7:0] secondLine [15:0];
	reg [7:0] sports_names [0:10][0:15];

	initial begin
        // Cn: xxx / Ti: yy
        firstLine[0] = "C"; 
        firstLine[1] = "n";
        firstLine[2] = ":";
        firstLine[3] = " ";
        firstLine[4] = "x"; 
        firstLine[5] = "x";
        firstLine[6] = "x";
        firstLine[7] = " ";
        firstLine[8] = "/";
        firstLine[9] = " ";
        firstLine[10] = "T";
        firstLine[11] = "i";
        firstLine[12] = ":";
        firstLine[13] = " ";
        firstLine[14] = "y";
        firstLine[15] = "y";

        // 0 - "Lunges,right leg"
        sports_names[0][0]  = "L";
        sports_names[0][1]  = "u";
        sports_names[0][2]  = "n";
        sports_names[0][3]  = "g";
        sports_names[0][4]  = "e";
        sports_names[0][5]  = "s";
        sports_names[0][6]  = ",";
        sports_names[0][7]  = "r";
        sports_names[0][8]  = "i";
        sports_names[0][9]  = "g";
        sports_names[0][10] = "h";
        sports_names[0][11] = "t";
        sports_names[0][12] = " ";
        sports_names[0][13] = "l";
        sports_names[0][14] = "e";
        sports_names[0][15] = "g";

        // 1 - "Lunges,left  leg"
        sports_names[1][0]  = "L";
        sports_names[1][1]  = "u";
        sports_names[1][2]  = "n";
        sports_names[1][3]  = "g";
        sports_names[1][4]  = "e";
        sports_names[1][5]  = "s";
        sports_names[1][6]  = ",";
        sports_names[1][7]  = "l";
        sports_names[1][8]  = "e";
        sports_names[1][9]  = "f";
        sports_names[1][10] = "t";
        sports_names[1][11] = " ";
        sports_names[1][12] = " ";
        sports_names[1][13] = "l";
        sports_names[1][14] = "e";
        sports_names[1][15] = "g";

        // 2 - "    Push-Ups    "
        sports_names[2][0]  = " ";
        sports_names[2][1]  = " ";
        sports_names[2][2]  = " ";
        sports_names[2][3]  = " ";
        sports_names[2][4]  = "P";
        sports_names[2][5]  = "u";
        sports_names[2][6]  = "s";
        sports_names[2][7]  = "h";
        sports_names[2][8]  = "-";
        sports_names[2][9]  = "U";
        sports_names[2][10] = "p";
        sports_names[2][11] = "s";
        sports_names[2][12] = " ";
        sports_names[2][13] = " ";
        sports_names[2][14] = " ";
        sports_names[2][15] = " ";

        // 3 - "Squat      Jumps"
        sports_names[3][0]  = "S";
        sports_names[3][1]  = "q";
        sports_names[3][2]  = "u";
        sports_names[3][3]  = "a";
        sports_names[3][4]  = "t";
        sports_names[3][5]  = " ";
        sports_names[3][6]  = " ";
        sports_names[3][7]  = " ";
        sports_names[3][8]  = " ";
        sports_names[3][9]  = " ";
        sports_names[3][10] = " ";
        sports_names[3][11] = "J";
        sports_names[3][12] = "u";
        sports_names[3][13] = "m";
        sports_names[3][14] = "p";
        sports_names[3][15] = "s";

        // 4 - "Tricep      Dips"
        sports_names[4][0]  = "T";
        sports_names[4][1]  = "r";
        sports_names[4][2]  = "i";
        sports_names[4][3]  = "c";
        sports_names[4][4]  = "e";
        sports_names[4][5]  = "p";
        sports_names[4][6]  = " ";
        sports_names[4][7]  = " ";
        sports_names[4][8]  = " ";
        sports_names[4][9]  = " ";
        sports_names[4][10] = " ";
        sports_names[4][11] = " ";
        sports_names[4][12] = "D";
        sports_names[4][13] = "i";
        sports_names[4][14] = "p";
        sports_names[4][15] = "s";

        // 5 - "MountainClimbers"
        sports_names[5][0]  = "M";
        sports_names[5][1]  = "o";
        sports_names[5][2]  = "u";
        sports_names[5][3]  = "n";
        sports_names[5][4]  = "t";
        sports_names[5][5]  = "a";
        sports_names[5][6]  = "i";
        sports_names[5][7]  = "n";
        sports_names[5][8]  = "C";
        sports_names[5][9]  = "l";
        sports_names[5][10] = "i";
        sports_names[5][11] = "m";
        sports_names[5][12] = "b";
        sports_names[5][13] = "e";
        sports_names[5][14] = "r";
        sports_names[5][15] = "s";

        // 6 - "Plank     Ladder"
        sports_names[6][0]  = "P";
        sports_names[6][1]  = "l";
        sports_names[6][2]  = "a";
        sports_names[6][3]  = "n";
        sports_names[6][4]  = "k";
        sports_names[6][5]  = " ";
        sports_names[6][6]  = " ";
        sports_names[6][7]  = " ";
        sports_names[6][8]  = " ";
        sports_names[6][9]  = " ";
        sports_names[6][10] = "L";
        sports_names[6][11] = "a";
        sports_names[6][12] = "d";
        sports_names[6][13] = "d";
        sports_names[6][14] = "e";
        sports_names[6][15] = "r";

        // 7 - "Wall   Sit  Hold"
        sports_names[7][0]  = "W";
        sports_names[7][1]  = "a";
        sports_names[7][2]  = "l";
        sports_names[7][3]  = "l";
        sports_names[7][4]  = " ";
        sports_names[7][5]  = " ";
        sports_names[7][6]  = " ";
        sports_names[7][7]  = "S";
        sports_names[7][8]  = "i";
        sports_names[7][9]  = "t";
        sports_names[7][10] = " ";
        sports_names[7][11] = " ";
        sports_names[7][12] = "H";
        sports_names[7][13] = "o";
        sports_names[7][14] = "l";
        sports_names[7][15] = "d";

        // 8 - "Plank       Hold"
        sports_names[8][0]  = "P";
        sports_names[8][1]  = "l";
        sports_names[8][2]  = "a";
        sports_names[8][3]  = "n";
        sports_names[8][4]  = "k";
        sports_names[8][5]  = " ";
        sports_names[8][6]  = " ";
        sports_names[8][7]  = " ";
        sports_names[8][8]  = " ";
        sports_names[8][9]  = " ";
        sports_names[8][10] = " ";
        sports_names[8][11] = " ";
        sports_names[8][12] = "H";
        sports_names[8][13] = "o";
        sports_names[8][14] = "l";
        sports_names[8][15] = "d";

        // 9 - "    Burpees     "
        sports_names[9][0]  = " ";
        sports_names[9][1]  = " ";
        sports_names[9][2]  = " ";
        sports_names[9][3]  = " ";
        sports_names[9][4]  = "B";
        sports_names[9][5]  = "u";
        sports_names[9][6]  = "r";
        sports_names[9][7]  = "p";
        sports_names[9][8]  = "e";
        sports_names[9][9]  = "e";
        sports_names[9][10] = "s";
        sports_names[9][11] = " ";
        sports_names[9][12] = " ";
        sports_names[9][13] = " ";
        sports_names[9][14] = " ";
        sports_names[9][15] = " ";

        // 10 - "----------------"
        sports_names[10][0]  = "-";
        sports_names[10][1]  = "-";
        sports_names[10][2]  = "-";
        sports_names[10][3]  = "-";
        sports_names[10][4]  = "-";
        sports_names[10][5]  = "-";
        sports_names[10][6]  = "-";
        sports_names[10][7]  = "-";
        sports_names[10][8]  = "-";
        sports_names[10][9]  = "-";
        sports_names[10][10] = "-";
        sports_names[10][11] = "-";
        sports_names[10][12] = "-";
        sports_names[10][13] = "-";
        sports_names[10][14] = "-";
        sports_names[10][15] = "-";

	end
	
	wire [3:0] Tihundreds, Titens, Tiones;
	wire [3:0] Cnhundreds, Cntens, Cnones;
	
	bcdConv2 bcd1(Cn, Cnhundreds, Cntens, Cnones);
	bcdConv2 bcd2(Ti, Tihundreds, Titens, Tiones);
	
	integer i;
	
	always @(clk) 
		begin 
			for (i = 0; i < 16; i = i+1)
				secondLine[i] = sports_names[WCn][i];

			firstLine[4] = 8'h30 + Cnhundreds;
			firstLine[5] = 8'h30 + Cntens;
			firstLine[6] = 8'h30 + Cnones;
			firstLine[14] = 8'h30 + Titens;
			firstLine[15] = 8'h30 + Tiones;
		end
		
		
	reg [5:0] state = 0;
	reg [5:0] helperState = 0;
	reg [5:0] id = 0;
	
	reg [15:0] delay_cnt = 0;
	reg wait_flag = 0;
	
	always @(posedge clk)
		begin 
			case (state)
				0: begin Data <= FUNC_SET; E <=1; Rs<=0; state<=20; helperState <= 0; end
				1: begin Data <= DISPLAY_ON; E <=1; Rs<=0; state<=20; helperState <= 1; end
				2: begin Data <= CLEAR; Rs<=0; E <=1; state<=20; helperState <= 2; end
				3: begin Data <= ENTRY_MODE; E <=1; Rs<=0; state<=20; helperState <= 3; end
				4: begin Data <= SET_ROW1; E <=1; Rs<=0 ; state<=20; helperState <= 4; end
				5: begin Data <= firstLine[id]; E <=1; Rs<=1; delay_cnt<=0; wait_flag<=1; state<=30; end
				6:
				begin 
					if (id < 15) begin
						id = id + 1;
						state <= 5;
						helperState <= 4;
					end else begin
						id = 0;
						state <= 7;
						helperState <= 6;
					end
				end
				7: begin Data <= SET_ROW2; E <=1; Rs<=0; state<=20; helperState <= 7; end
				8: begin Data <= secondLine[id]; E <=1; Rs<=1; delay_cnt<=0; wait_flag<=1; state<=31; end
				9:
				begin
					if (id < 15) begin 
						id = id + 1;
						state <= 8;
						helperState <= 7;
					end else begin
						id = 0;
						state <=10;
						helperState <= 9;
					end
				end

				10:
				begin 
					Data <= SET_FIRST_LETTER; 
					Rs<=0; 
					E<=1; 
					state<=20; 
					helperState<=4;
				end
				
				20:
				begin
					case (helperState)
						0: begin state<=1; E<=0; end
						1: begin state<=2; E<=0; end
						2: begin state<=3; E<=0; end
						3: begin state<=4; E<=0; end
						4: begin state<=5; E<=0; end
						5: begin state<=6; E<=0; end
						6: begin state<=7; E<=0; end
						7: begin state<=8; E<=0; end
						8: begin state<=9; E<=0; end
						9: begin state<=10; E<=0; end
					endcase
				end
				
				30:
				begin
					E<=0;
					delay_cnt <= delay_cnt + 1;
					if (delay_cnt > 20) begin
						delay_cnt <= 0;
						wait_flag <= 0;
						state <= 6;
					end
				
				end
				31:
				begin
					E<=0;
					delay_cnt <= delay_cnt + 1;
					if (delay_cnt > 20) begin
						delay_cnt <= 0;
						wait_flag <= 0;
						state <= 9;
					end
				end
			endcase
		end
endmodule
