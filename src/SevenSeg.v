module bcdConvertor( 
	input [6:0] temp,
	output reg [3:0] bcd_tens,
	output reg [3:0] bcd_ones
);
	reg [3:0] count;
	reg [6:0] tempCopy;
	
	always @(temp) begin 
		tempCopy = temp;
		bcd_tens = 0;
		bcd_ones = 0;
		
		for(count = 0; count < 10; count = count+1) begin 
			if (tempCopy >= 10) begin
				tempCopy = tempCopy - 10;
				bcd_tens = bcd_tens +1;
			end
		end
		bcd_ones = tempCopy;
	end
endmodule

module SevenSeg(Clk, Cn, Ti, seg_data, seg_sel);
    input Clk;
    input [6:0] Cn, Ti;
    output reg [4:0] seg_sel;
    output reg [7:0] seg_data;

    reg [1:0] digSel = 0;
    reg [3:0] digit;
    wire [3:0] digits[3:0];

	bcdConvertor
		bcd1(Ti,digits[1],digits[0]),
		bcd2(Cn,digits[3],digits[2]);

    always @(posedge Clk)
        digSel <= (digSel + 1)%4;

    always @(Cn or Ti or digSel or digit) begin
        case (digSel)
            2'd0: begin
                seg_sel = 5'b00001;
                digit = digits[0];
            end
            2'd1: begin
                seg_sel = 5'b00010;
                digit = digits[1];
            end
            2'd2: begin
                seg_sel = 5'b00100;
                digit = digits[2];
            end
            2'd3: begin
                seg_sel = 5'b01000;
                digit = digits[3];
            end
        endcase

        case (digit)
            4'd0: seg_data = 8'b00111111;
            4'd1: seg_data = 8'b00000110;
            4'd2: seg_data = 8'b01011011;
            4'd3: seg_data = 8'b01001111;
            4'd4: seg_data = 8'b01100110;
            4'd5: seg_data = 8'b01101101;
            4'd6: seg_data = 8'b01111101;
            4'd7: seg_data = 8'b00000111;
            4'd8: seg_data = 8'b01111111;
            4'd9: seg_data = 8'b01101111;
        endcase
    end

endmodule
