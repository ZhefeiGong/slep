`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 
// Design Name: 
// Module Name: triaxial
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
module triaxial (
    input clk,
    input I_rst_n,             //low level effective
    input [4:0] set,           //will change that...
    input running,             //high level effective
    output reg [4:0] runstate  //F10000 L01000 S00100 R00010 B00001 
);

always @(posedge clk) begin
    if(!I_rst_n)begin
        runstate<=5'b00000;
    end
    else if(!running)begin
        runstate<=5'b00000;
    end
    else begin
        if(set[0])begin
            runstate<=5'b00001;
        end
        else if(set[1])begin
            runstate<=5'b00010;
        end
        else if(set[2])begin
            runstate<=5'b00100;
        end
        else if(set[3])begin
            runstate<=5'b01000;
        end
        else if(set[4])begin
            runstate<=5'b10000;
        end
        else begin
            runstate<=5'b00000;
        end
    end
end
//wait for change...
endmodule
