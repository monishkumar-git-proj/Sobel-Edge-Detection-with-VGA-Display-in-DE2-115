module Sobel_core(
input clk,
input  [7:0] p0,p1,p2,p3,p4,p5,p6,p7,p8,
output reg [7:0] edge_out
);

wire signed [10:0] g_x;
wire signed [10:0] g_y;
wire [10:0] abs_gx;
wire [10:0] abs_gy;
wire [11:0] magnitude;

//                pixel matrix = p0 p1 p2
//                               p3 p4 p5
//                               p6 p7 p8

// Sx = -1  0  1             Sy = -1 -2 -1
//      -2  0  2                   0  0  0
//      -1  0  1                  -1 -2 -1 

assign g_x= (-$signed({1'b0,p0}) + $signed({1'b0,p2}))+ (-( $signed({1'b0,p3}) <<< 1 ) + ( $signed({1'b0,p5}) <<< 1 ))+ (-$signed({1'b0,p6}) + $signed({1'b0,p8}));

assign g_y = (-$signed({1'b0,p0}) - ( $signed({1'b0,p1}) <<< 1 ) - $signed({1'b0,p2}))+ ( $signed({1'b0,p6}) + ( $signed({1'b0,p7}) <<< 1 ) + $signed({1'b0,p8}));

// modulus is used for approximation of square root.
assign abs_gx = (g_x < 0) ? -g_x : g_x;
assign abs_gy = (g_y < 0) ? -g_y : g_y;
assign magnitude = abs_gx + abs_gy;

always @(posedge clk) begin
    if(magnitude > 255)
        edge_out <= 8'hFF;
    else
        edge_out <= magnitude[7:0];
end
endmodule
