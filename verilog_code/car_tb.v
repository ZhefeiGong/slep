`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/01/06 22:49:19
// Design Name: 
// Module Name: car_tb
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

module car_tb();
reg clk;
reg I_rst_n;
reg rxd;
reg go;
reg excute;
reg [4:0]setdir;
wire txd;
wire [3:0] O_red;
wire [3:0] O_green;
wire [3:0] O_blue;
wire O_hs;
wire O_vs;
wire [4:0]showstate;

car_top car(
    .clk(clk)      ,
    .I_rst_n(I_rst_n)  ,   // low level effective
    .rxd(rxd)      ,
    .go(go)       ,   // high level effective
    .excute(excute)   ,   // high level effective
    .setdir(setdir)   ,   // for test traxial...
    .txd(txd)      ,
    .O_red(O_red)    ,   // VGA's red   channel
    .O_green(O_green)  ,   // VGA's green channel
    .O_blue(O_blue)   ,   // VGA's blue  channel
    .O_hs(O_hs)     ,   // VGA
    .O_vs(O_vs)     ,   // VGA
    .showstate(showstate)    // show for test
    );
reg [7:0] invect;
initial
    begin
        I_rst_n<=1'b0;
        clk<=1'b0;
        rxd<=1'b1;
        go<=1'b1;
        excute<=1'b1;
        setdir<=5'b00000;
        #10
        for (invect = 0; invect < 9999999; invect = invect + 1)
                 begin  
                 I_rst_n<=1'b1;
                 #10
                 clk=~clk;//time keeper
                 end
    end  
endmodule
