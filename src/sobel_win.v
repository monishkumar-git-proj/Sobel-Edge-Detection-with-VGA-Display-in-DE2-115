module sobel_win(
input clk,
input [7:0] pixel,
output[7:0] edge_pixel
);
parameter WIDTH=256;
parameter HEIGHT=256;

reg [7:0] r1 [0:255];
reg [7:0] r2 [0:255];
reg [7:0] r3 [0:255];

reg [7:0] p0,p1,p2,p3,p4,p5,p6,p7,p8;

reg [8:0] i=0,row=0;

initial begin
    p0 = 8'h00; p1 = 8'h00; p2 = 8'h00;
    p3 = 8'h00; p4 = 8'h00; p5 = 8'h00;
    p6 = 8'h00; p7 = 8'h00; p8 = 8'h00;
end

always @(posedge clk)begin
    r3[i]<= r2[i];
    r2[i]<= r1[i];
    r1[i]<= pixel;
		
if (row > 1 && i > 1)begin
	p0<= r3[i-2];
	p1<= r3[i-1];
	p2 <= r3[i];
	
	p3<= r2[i-2];
	p4<= r2[i-1];
	p5<= r2[i];
	
	p6<= r1[i-2];
	p7<= r1[i-1];
	p8<= pixel;

end
if (i < WIDTH - 1)begin
	i <= i + 1;
end
else begin
        i   <= 0;
        row <= row + 1;
end
end

Sobel_core dut(.p0(p0),.p1(p1),.p2(p2),.p3(p3),.p4(p4),.p5(p5),.p6(p6),.p7(p7),.p8(p8),.edge_out(edge_pixel),.clk(clk));

endmodule