module sobel_win_output_tb;
reg clk;
wire [7:0]edge_pixel;
wire [7:0] pixel_data,gray_data;
reg [8:0] x,y;
wire [15:0] rom_add = y*256+x;
always @(posedge clk) begin
	if (x == 255) begin
            x <= 0;
            if (y == 255)
                y <= 0;
            else
                y <= y + 1;
        end 
	else begin
            x <= x + 1;
        end
end
image_rom rom(.clk(clk),.address(rom_add),.data_out(pixel_data));
gray_conv conv(.clk(clk),.px(pixel_data),.gray_out(gray_data));
sobel_win dut(.clk(clk),.edge_pixel(edge_pixel),.pixel(gray_data));
initial begin
x=0;
y=0;
clk = 0;
end
always #2 clk=~clk;
endmodule

