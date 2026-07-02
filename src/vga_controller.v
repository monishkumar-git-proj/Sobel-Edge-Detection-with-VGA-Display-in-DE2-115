module vga_controller (
    input wire clk_25,      
    output reg [9:0] x,    
    output reg [9:0] y,     
    output wire hsync,      
    output wire vsync,      
    output wire active   
);
initial begin
x = 0;
y = 0;
end
always @(posedge clk_25) begin
	if (x == 799) begin
            x <= 0;
            if (y == 524)
                y <= 0;
            else
                y <= y + 1;
        end 
	else begin
            x <= x + 1;
        end
    end
assign hsync = ~(x >= 656 && x < 752); // front porch = 16 , back porch = 96
assign vsync = ~(y >= 490 && y < 492); // front porch 2 ,  back porch =10
assign active = (x < 640 && y < 480);  // active region
endmodule
