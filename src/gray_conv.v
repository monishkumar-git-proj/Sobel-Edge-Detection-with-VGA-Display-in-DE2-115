module gray_conv(
input clk,
input [7:0] px,
output reg[7:0] gray_out
);
wire[7:0] R,G,B;
// RGB332 format to Grayscale
assign R = {px[7:5],px[7:5],px[7:6]};
assign G = {px[4:2],px[4:2],px[4:3]};
assign B = {px[1:0],px[1:0],px[1:0],px[1:0]};

//gray ≈ 0.25R + 0.5G + 0.125B

always@(posedge clk)
	gray_out <=(R>>2)+(G>>1)+(B>>3);
endmodule
