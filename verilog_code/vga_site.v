`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 
// Design Name: 
// Module Name: vga_site
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

module vga_site (
    input          [4:0]     state,            //search-warning-run-inter-start
    input          [1485:0]  broad,            //60*44
    input    signed[15:0]    site_X,
    input    signed[15:0]    site_Y,
    input                    I_rst_n,          //low level effective
    input                    R_clk_25M,
    input                    W_active_flag,    
    input          [9:0]     R_h_cnt,
    input          [9:0]     R_v_cnt,     
    output   reg   [3:0]    O_red   , // VGA
    output   reg   [3:0]    O_green , // VGA
    output   reg   [3:0]    O_blue    // VGA
);
parameter linerow = 20  ;
parameter linevolumn = 20 ;

/**********************************************************************/
// 
//
//            *******
//            *     *
//            *     *
//            *******
//            *     *
//            *     *
//            *******
/**********************************************************************/
parameter car_red = 4'b0000 ;
parameter car_green = 4'b0111 ;
parameter car_blue =  4'b0000 ;
parameter radius =15 ;

parameter h_startsite = 144 ;        //96+48
parameter h_endsite = 784;           //96+48+640
parameter c_startsite = 35;          //2+33
parameter c_endsite = 515;           //2+33+480
reg signed [15:0] getx;
reg signed [15:0] gety;

always @(posedge R_clk_25M or negedge I_rst_n)
begin
    if(!I_rst_n)begin
            O_red   <=  4'b0000    ;
            O_green <=  4'b0000    ;
            O_blue  <=  4'b0000    ; 
    end
    else if(W_active_flag)begin
        /*homepage*/
        if(state[0])begin
             getx=R_h_cnt-h_startsite;
             gety=R_v_cnt-c_startsite;
             if(((getx-200)*(getx-200)+(gety-180)*(gety-180))<=25*25)begin
                 O_red   <=  4'b0000   ; 
                 O_green <=  4'b0000   ;
                 O_blue  <=  4'b0000   ;
             end
             else if(((getx-400)*(getx-400)+(gety-180)*(gety-180))<=25*25)begin
                 O_red   <=  4'b0000   ; 
                 O_green <=  4'b0000   ;
                 O_blue  <=  4'b0000   ;
             end
             else if(((getx-300)*(getx-300)+(gety-300)*(gety-300))<=25*25)begin
                 O_red   <=  4'b0000   ; 
                 O_green <=  4'b0000   ;
                 O_blue  <=  4'b0000   ;
             end
             else if(((getx-300)*(getx-300)+(gety-400)*(gety-400))<=25*25)begin
                 O_red   <=  4'b0000   ; 
                 O_green <=  4'b0000   ;
                 O_blue  <=  4'b0000   ;
             end
             else if(gety<=40)begin
                 O_red   <=  4'b0101   ; 
                 O_green <=  4'b0111   ;
                 O_blue  <=  4'b0000   ;
             end
             else if(gety<=80)begin
                 O_red   <=  4'b0101    ; 
                 O_green <=  4'b0010    ;
                 O_blue  <=  4'b0101    ;
             end
             else if(gety<=120)begin
                 O_red   <=  4'b0001    ; 
                 O_green <=  4'b0100    ;
                 O_blue  <=  4'b0111    ;
             end
             else if(gety<=160)begin
                 O_red   <=  4'b0001    ; 
                 O_green <=  4'b1000    ;
                 O_blue  <=  4'b0110    ;
             end
             else if(gety<=200)begin
                 O_red   <=  4'b0001    ; 
                 O_green <=  4'b0100    ;
                 O_blue  <=  4'b0100    ;
             end
             else if(gety<=240)begin
                 O_red   <=  4'b0011    ; 
                 O_green <=  4'b0110    ;
                 O_blue  <=  4'b0010    ;
             end
             else if(gety<=280)begin
                 O_red   <=  4'b0101    ; 
                 O_green <=  4'b1100    ;
                 O_blue  <=  4'b0110    ;
             end
             else if(gety<=320)begin
                 O_red   <=  4'b0101    ; 
                 O_green <=  4'b0000    ;
                 O_blue  <=  4'b0000    ;
             end
             else if(gety<=360)begin
                 O_red   <=  4'b1111    ; 
                 O_green <=  4'b0100    ;
                 O_blue  <=  4'b0011    ;
             end
             else if(gety<=400)begin
                 O_red   <=  4'b0000    ; 
                 O_green <=  4'b0110    ;
                 O_blue  <=  4'b1000    ;
             end
             else begin
                 O_red   <=  4'b0000    ; 
                 O_green <=  4'b1000    ;
                 O_blue  <=  4'b0010    ;
             end
        end
        /*mainpage*/
        else if(state[1]||state[2]||state[4])begin
            getx=R_h_cnt-h_startsite;
            gety=R_v_cnt-c_startsite;
            //frame
            if((getx <= linerow || getx >= (h_endsite - linerow - h_startsite )) ||
                (gety <= linevolumn || gety >= (c_endsite - linevolumn - c_startsite)))begin
                O_red   <=  4'b0101    ; 
                O_green <=  4'b0000    ;
                O_blue  <=  4'b0000    ;
            end
            //car
            else if(((getx-site_X)*(getx-site_X)+(gety-site_Y)*(gety-site_Y))<=radius*radius)begin
                O_red   <=  car_red     ; 
                O_green <=  car_green   ;
                O_blue  <=  car_blue    ;
            end
            //barrier
            else if(broad[getx/13+gety/13*45])begin
                O_red   <=  4'b1010    ; 
                O_green <=  4'b0000    ;
                O_blue  <=  4'b1111    ;
            end
            //none
            else begin
                O_red   <=  4'b0000   ;
                O_green <=  4'b0000   ;
                O_blue  <=  4'b0000   ; 
            end
        end
        /*warning page*/
        else if(state[3])begin
            getx=R_h_cnt-h_startsite;
            gety=R_v_cnt-c_startsite;
            //frame
            if((getx <= linerow|| getx >= (h_endsite - linerow-h_startsite)) ||
                (gety <= linevolumn || gety >= (c_endsite - linevolumn-c_startsite)))begin
                O_red   <=  4'b0101    ; 
                O_green <=  4'b1000    ;
                O_blue  <=  4'b0000    ;
             end
            //Waiting for the supplement...

            //car
            else if(((getx-site_X)*(getx-site_X)+(gety-site_Y)*(gety-site_Y))<=radius*radius)begin
                O_red   <=  car_red     ; 
                O_green <=  car_green   ;
                O_blue  <=  car_blue    ;
            end
            //barrier
            else if(broad[getx/13+gety/13*45])begin
                O_red   <=  4'b1010    ; 
                O_green <=  4'b0000    ;
                O_blue  <=  4'b1111    ;
            end
            //none
            else begin
                O_red   <=  4'b0000   ;
                O_green <=  4'b0000   ;
                O_blue  <=  4'b0000   ; 
            end

        end
    end
    else begin
        O_red   <=  4'b0000    ;
        O_green <=  4'b0000    ;
        O_blue  <=  4'b0000    ; 
    end           
end
    
endmodule