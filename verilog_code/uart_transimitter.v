`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:
// Design Name: 
// Module Name: uart_transmitter
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

module uart_transmitter (
    input clk,                  //9600hz*16
    input clrn,                 //Low level effective
    input wrn,                  //Low level effective
    input [7:0] d_in,           //put data in the txd
    input [3:0] cnt,            //count 16
    output reg txd,             //txd line
    output reg t_empty          //judge whether we can put data in(1:can/0:can't)
);

parameter bits=4'b1010;
//internal singnals
reg [3:0] no_bits;
reg [7:0] t_buffer;         //data_buffer
reg sending;                //transport_buffer
reg [7:0] d_buffer;
reg load_t_buffer;

/************************************************************/
//load d_in ,sending enalbe , t_empty ,sending_place
/************************************************************/
always @(posedge clk or negedge clrn or negedge wrn) begin
    if(clrn == 0)begin
        sending <= 1'b0;
        t_empty <= 1'b1;
        load_t_buffer <= 1'b0;
    end
    else begin
        if(!wrn)begin
            d_buffer <= d_in;
            t_empty <= 1'b0;
            load_t_buffer <= 1'b1;
        end
        else begin
            if(!sending)begin
                if(load_t_buffer)begin
                    sending <= 1'b1;
                    t_buffer <= d_buffer;
                    t_empty <= 1'b1;
                    load_t_buffer <= 1'b0;
                end
            end
            else begin
                if(no_bits == bits)
                sending <= 1'b0;
            end
        end
    end
end
assign clkw = cnt[3];

/************************************************************/
//number of bits sent
/************************************************************/
always @(posedge clkw or negedge sending) begin
    if(!sending)begin
        no_bits<=4'b0000;
        txd <= 1'b1;
    end
    else begin
        case (no_bits)
             0:txd <= 1'b0;//start
             1:txd <= t_buffer[0];
             2:txd <= t_buffer[1];
             3:txd <= t_buffer[2];
             4:txd <= t_buffer[3];
             5:txd <= t_buffer[4];
             6:txd <= t_buffer[5];
             7:txd <= t_buffer[6];
             8:txd <= t_buffer[7];
             //9:txd <= ^t_buffer;//parity site-->don't need parity
             default: txd <= 1'b0;//end
        endcase
        no_bits <= no_bits+4'b0001;
    end
end

endmodule