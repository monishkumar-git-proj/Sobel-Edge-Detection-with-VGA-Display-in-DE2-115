module image_rom (
    input wire clk,
    input wire [15:0] address,
    output reg [7:0] data_out);

    reg [7:0] memory_array [0:65535];
    initial begin
        $readmemh("colour_new.txt", memory_array);
    end
    always @(posedge clk) begin
        data_out <= memory_array[address];
    end
endmodule