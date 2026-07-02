module SOBEL(
    input clk,
    output  [7:0] R,  
    output [7:0] G,   
    output [7:0] B,   
    output hsync,    
    output vsync,      
    output vga_clk,     
    output blank_n,
    output sync_n
);
reg clk_25 = 1'b0;

always @(posedge clk) begin
	clk_25 <= ~clk_25;
end

assign vga_clk = clk_25;

reg [9:0] x_d0,x_d1,x_d2,x_d3;
reg [9:0] y_d0,y_d1,y_d2,y_d3;
wire [9:0] x,y;
wire active_video;
wire raw_hsync, raw_vsync;
// Base VGA Controller
vga_controller vga(.clk_25(clk_25),.x(x),.y(y),.hsync(raw_hsync),.vsync(raw_vsync),.active(active_video));
wire [15:0] rom_address = (x<256)&&(y<256) ? (y * 256) + x : 16'h0 ;
wire [7:0] data_out, pixel_data, out;

image_rom rom(.clk(clk_25), .address(rom_address), .data_out(data_out));

gray_conv converter(.clk(clk_25), .px(data_out), .gray_out(pixel_data));

sobel_win sobel(.clk(clk_25), .pixel(pixel_data), .edge_pixel(out));    
  
reg [3:0] hsync_delay  = 4'b1111;
reg [3:0] vsync_delay  = 4'b1111;
reg [3:0] active_delay = 4'b0;
    

always @(posedge clk_25) begin
	  hsync_delay  <= {hsync_delay[2:0],raw_hsync};
	  vsync_delay  <= {vsync_delay[2:0],raw_vsync};
	  active_delay <= {active_delay[2:0],active_video};
	  
	  x_d0 <= x;
     x_d1 <= x_d0;
     x_d2 <= x_d1;
     x_d3 <= x_d2;

     y_d0 <= y;ssss
     y_d1 <= y_d0;
     y_d2 <= y_d1;
     y_d3 <= y_d2;
end

assign hsync = hsync_delay[3];
assign vsync = vsync_delay[3];
assign blank_n = active_delay[3];
assign sync_n  = 1'b0;

// Image region condition in 640X480 output
wire draw_image = (x_d3 < 256) && (y_d3 < 256) && active_delay[3];

assign R = draw_image ? out : 8'h00;    
assign G = draw_image ? out : 8'h00;
assign B = draw_image ? out : 8'h00;

endmodule