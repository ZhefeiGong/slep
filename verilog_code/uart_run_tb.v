`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/01/01 21:17:15
// Design Name: 
// Module Name: uart_run_tb
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


module uart_run_tb();

reg clrn;
reg clk;
reg [7:0] d_in;
reg write;
reg rxd;

wire[7:0] d_out;
wire txd;
wire get;
uart_run #(0)uart(.clrn(clrn),.clk(clk),.d_in(d_in),.d_out(d_out),.write(write),.rxd(rxd),.txd(txd),.get(get));

reg [7:0] invect;
reg [7:0]cou1;
reg [7:0]cou2;
initial
begin
    cou1<=0;
    cou2<=0;
    write<=1'b1;
    clk<=1'b0;
    d_in<=8'b01101110;
    clrn=1'b0;
    #10
    rxd=1'b1;
    for (invect = 0; invect < 9999999; invect = invect + 1)
             begin  
             cou1=cou1+8'b00000001;
             write=~write;
             clrn=1'b1;
             #10
             clk=~clk;//time keeper
             if(cou1>=16)
             begin
                  rxd<=1'b1;
                  cou2<=cou2+8'b00000001;
                  if(cou2>=14)begin
                      rxd<=1'b0;
                      cou2<=8'b00000000;
                  end
                  cou1<=1'b0;
             end
             end
end

endmodule
