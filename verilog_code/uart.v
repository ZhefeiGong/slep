`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:
// Design Name: 
// Module Name: uart
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

module uart(
    input clk,               //100Mhz
    input I_rst_n,           //low level effective
    input rdn,               //low level effective
    input wrn,               //low level effectives
    input rxd,
    input [7:0]d_in,
    output[7:0]d_out,
    output r_ready,
    output t_empty,
    output txd
    );

/************************************************************/
// inter signals
/************************************************************/
parameter count=651;
reg [15:0] num;
reg [3:0] cnt;
reg clkin;
wire parity_error;     //ignore
wire frame_error;      //ignore

/************************************************************/
// produce clock--clkin
/************************************************************/
always@(posedge clk or negedge I_rst_n)
begin
    if(!I_rst_n)begin
        num<=16'b0000000000000000;
        clkin<=1'b0;
    end
    else begin
        num=num+16'b0000000000000001;
        if(num>=count/2) begin
            clkin=~clkin;     
            num<=16'b0000000000000000;
        end 
    end
end

/************************************************************/
// produce cnt
/************************************************************/
always @(posedge clkin or negedge I_rst_n) begin
    if(!I_rst_n)begin
        cnt<=4'b0000;
    end
    else begin
        cnt <= cnt + 4'b0001;
    end
end

/************************************************************/
//module part
/************************************************************/
//reciever
uart_receiver rx(
    .clk(clkin),.clrn(I_rst_n),.cnt(cnt),.rdn(rdn),.rxd(rxd),
    .d_out(d_out),.r_ready(r_ready),.parity_error(parity_error),.frame_error(frame_error)
);
//transmitter
uart_transmitter tx(
    .clk(clkin),.clrn(I_rst_n),.wrn(wrn),.d_in(d_in),.cnt(cnt),
    .t_empty(t_empty),.txd(txd)
);

endmodule
