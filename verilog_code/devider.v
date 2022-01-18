`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 
// Design Name: 
// Module Name: divider
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


module divider(I_CLK,rst,O_CLK);
    input I_CLK;             //输入时钟限号 上升沿有效
    input rst;               //同步复位信号 高电平有效
    output reg O_CLK;        //输出时钟
    integer count;
    integer first=1'b0;
parameter NUM_DIV=20;
//初始化输出
initial
begin
   if(first==0)
     begin
     O_CLK=1'b0;
     first=first+1;
     count=1'b0;
     end
end
//进行改变
always @ (posedge I_CLK)
begin
    count=count+1;//使用阻塞赋值
    if(rst)//同步复位信号--高电平有效
        begin
        O_CLK=1'b0;
        count=0;
        end
    else if(count==NUM_DIV/2)
        begin
        O_CLK=~O_CLK;
        count=0;
        end
    else
        O_CLK=O_CLK;
end
endmodule
