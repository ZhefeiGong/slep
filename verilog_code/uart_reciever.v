`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:
// Design Name: 
// Module Name: uart_receiver
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

module uart_receiver(
    input clk,                      //9600hz*16
    input clrn,                     //Low level effective
    input [3:0] cnt,                //count for 16
    input rdn,                      //Low level effective
    input rxd,                      //receibe data line
    output reg r_ready,             //judge whether we can read(1:can/0:can't)
    output [7:0] d_out,             //get data from rxd
    output reg parity_error=1'b1,   //1:parity_site error
    output reg frame_error          //1:end_site error
);


parameter bits=4'b1010;
//internl singnal
reg [3:0] sampling_place;
reg [3:0] no_bits;
reg [9:0] r_buffer;            //stop,data[7:0],start
reg clkr;
reg rxd_old,rxd_new;
reg sampling;
reg [7:0] frame;

/************************************************************/
//latch 2 sampling bits
/************************************************************/
always @ (posedge clk or negedge clrn)
begin
    if(clrn == 0) begin
        rxd_old <= 1'b1;
        rxd_new <= 1'b1;
    end
    else begin
        rxd_old <= rxd_new;
        rxd_new <= rxd;
    end
end

/************************************************************/
//detect start bit
/************************************************************/
always @(posedge clk or negedge clrn)
begin
    if(clrn==0)begin
        sampling <= 1'b0;
    end
    else begin
        if(rxd_old && !rxd_new) begin
            if(!sampling)
                sampling_place<= cnt+4'b1000;//half
            sampling <= 1'b1;
        end
        else begin
            if(no_bits == bits)
                sampling <= 1'b0; 
        end
    end
end

/************************************************************/
//sampling clock:clkr
/************************************************************/
always @ (posedge clk or negedge clrn)
begin
    if(clrn == 0) begin
        clkr<=1'b0;
    end else
    begin
        if(sampling) begin
            if(cnt == sampling_place)
                clkr<=1'b1;
            if(cnt == sampling_place+4'b0001)
                clkr<=1'b0;
        end else
            clkr<= 1'b0;
    end  
end

/************************************************************/
//number of bits received
/************************************************************/
always@(posedge clkr or negedge sampling)
begin
    if(!sampling) begin
        no_bits<=4'b0000;
    end
    else begin
        no_bits<=no_bits + 4'b0001;
        r_buffer[no_bits]<= rxd;
    end
end

/************************************************************/
//data processing
/************************************************************/
always @(posedge clk or negedge clrn or negedge rdn)
begin
    if(clrn==0) begin
        r_ready <= 1'b0;
        frame_error <=1'b0;
    end
    else begin
        if(!rdn) begin
            r_ready <= 1'b0;
            frame_error <= 1'b0;
        end
        else begin
            if(no_bits == bits) begin
            frame <= r_buffer[8:1];
            r_ready <= 1'b1;
            if(!r_buffer[9]) begin
                frame_error<=1'b1;
            end
            end
        end   
    end
end

assign d_out =!rdn ? frame :8'bz;

endmodule
