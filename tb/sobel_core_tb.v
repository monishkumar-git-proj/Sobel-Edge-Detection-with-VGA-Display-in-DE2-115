module soble_core_tb;
reg [7:0] p0,p1,p2,p3,p4,p5,p6,p7,p8;
wire [7:0] edge_out;
Sobel_core dut(p0,p1,p2,p3,p4,p5,p6,p7,p8,edge_out);

initial begin
p0 = 8'h12;
p1 = 8'ha0;
p2 = 8'h2e;
p3 = 8'h09;
p4 = 8'h43;
p5 = 8'hF1;
p6 = 8'h00;
p7 = 8'h01;
p8 = 8'h11;
#10;
p4 = 8'h43;
p5 = 8'hEE;
p6 = 8'h04;
p7 = 8'h11;
p8 = 8'h35;
#40 $finish;
end
endmodule
