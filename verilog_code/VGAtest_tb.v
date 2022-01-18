`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/12/17 00:26:27
// Design Name: 
// Module Name: VGAtest_tb
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

module VGAtest_tb;
    reg I_clk;
    reg I_rst_n;
    wire [3:0] O_red;
    wire [3:0] O_green;
    wire [3:0] O_blue;      
    wire O_hs;
    wire O_vs;
    reg [7:0] invect;
vga_driver vga(.I_clk(I_clk),.I_rst_n(I_rst_n),.O_red(O_red),.O_green(O_green),.O_blue(O_blue),.O_hs(O_hs),.O_vs(O_vs));
initial
begin
       I_clk<=1'b1;
       I_rst_n=1'b0;   //ÏÈÖÃÎ»£¡£¡£¡
       #10
       for (invect = 0; invect < 9999999; invect = invect + 1)
           begin  
           I_rst_n=1'b1;
           #10
           I_clk<=~I_clk;
           end
end   
endmodule
