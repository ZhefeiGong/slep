`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/01/04 00:40:50
// Design Name: 
// Module Name: L3G4200D_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module L3G4200D_tb();
reg clk;
reg rst;
reg ACL_MISO;
wire [5:0]led;
wire ACL_CSN;
wire ACL_MOSI;
wire ACL_SCLK;


top t(
    //show more
    .clk(clk),
    .rst(rst),
    .led(led),
    // SPI port
    .ACL_CSN(ACL_CSN),
    .ACL_MOSI(ACL_MOSI),//主机输出
    .ACL_MISO(ACL_MISO),//主机输入
    .ACL_SCLK(ACL_SCLK)
);

initial
begin
    rst=1'b1;
    #50
    rst=1'b0;
    #50
    ACL_MISO=1'b1;
end
endmodule

