module FRHealth(Clk, w, cal, g, met, inSt, inRe, inSk, seg_data, seg_sel, BuFreq, lcd_Data, lcd_Rs, lcd_Rw, lcd_E, lcd_reset);
    input Clk, g, inSt, inRe, inSk;
    input [2:0] w;
    input [1:0] cal, met;
    output [7:0] seg_data , lcd_Data;
    output [4:0] seg_sel;
    output BuFreq, lcd_E, lcd_Rw, lcd_Rs, lcd_reset;
  
	wire St, Re, Sk;
	assign St = ~inSt , Re = ~inRe , Sk = ~inSk;

    wire [1:0] Bu;
    wire [8:0] Cn;
    wire [5:0] Ti;
    wire [3:0] WCn;
    wire StDeb, ReDeb, SkDeb;
    wire ClkFsm, Clk7seg, ClkDeb, ClkLcd, beep500, beep1k, beep2k;

    Debouncer deb1(ClkDeb, St, StDeb),
              deb2(ClkDeb, Re, ReDeb),
              deb3(ClkDeb, Sk, SkDeb);
	

    FreqDiv freqDiv(Clk, ClkFsm, Clk7seg, ClkDeb, ClkLcd, beep500, beep1k, beep2k);
    FSM fsm(ClkFsm, ClkDeb, w, cal, g, met, StDeb, ReDeb, SkDeb, Bu, Cn, Ti, WCn);
    SevenSeg sevenSeg(Clk7seg, Cn[6:0], {1'b0,Ti}, seg_data, seg_sel);
	mainLcd lcd(WCn, Cn, Ti, ClkLcd, lcd_reset, lcd_Rs, lcd_Rw, lcd_E, lcd_Data);

    assign BuFreq = (Bu == 2'b00) ? 0 :
                    (Bu == 2'b01) ? beep1k :
                    (Bu == 2'b10) ? beep500 :
                    beep2k;

endmodule
