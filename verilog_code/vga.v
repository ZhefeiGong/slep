`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 
// Design Name: 
// Module Name: vga
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

module vga(
    input    signed [15:0]   site_X  ,
    input    signed [15:0]   site_Y  ,
    input           [4 :0]   state   ,   // search-warning-run-inter-start   high level effective
    input           [1485:0] broad   ,   // 60*44
    input                    I_clk   ,   // 100Mhz-clock
    input                    I_rst_n ,   // low level effective
    output   wire   [3:0]    O_red   ,   // VGA's red   channel
    output   wire   [3:0]    O_green ,   // VGA's green channel
    output   wire   [3:0]    O_blue  ,   // VGA's blue  channel
    output                   O_hs    ,  
    output                   O_vs       
);

// 640*480
parameter      C_H_SYNC_PULSE      =   96  ;
parameter      C_H_BACK_PORCH      =   48  ;
parameter      C_H_ACTIVE_TIME     =   640 ;
parameter      C_H_FRONT_PORCH     =   16  ;
parameter      C_H_LINE_PERIOD     =   800 ;

// 640*480               
parameter      C_V_SYNC_PULSE      =   2   ; 
parameter      C_V_BACK_PORCH      =   33  ;
parameter      C_V_ACTIVE_TIME     =   480 ;
parameter      C_V_FRONT_PORCH     =   10  ;
parameter      C_V_FRAME_PERIOD    =   525 ;
  
reg [9:0]       R_h_cnt         ; // 
reg [9:0]       R_v_cnt         ; // 
wire            R_clk_25M       ; // 
wire            W_active_flag   ; // 

/**********************************************************************/
//produce a 25Mhz-clock       
/**********************************************************************/
divider #(.NUM_DIV(4)) div(.I_CLK(I_clk),.rst(!I_rst_n),.O_CLK(R_clk_25M));

/**********************************************************************/
//produce O_hs              
/**********************************************************************/
always @(posedge R_clk_25M or negedge I_rst_n)
begin
    if(!I_rst_n)
        R_h_cnt <=  9'd0   ;
    else if(R_h_cnt == C_H_LINE_PERIOD - 1'b1)
        R_h_cnt <=  9'd0   ;
    else
        R_h_cnt <=  R_h_cnt + 1'b1  ;                
end                
assign O_hs =   (R_h_cnt < C_H_SYNC_PULSE||!I_rst_n) ? 1'b0 : 1'b1    ; 

/**********************************************************************/
//produce O_vs
/**********************************************************************/
always @(posedge R_clk_25M or negedge I_rst_n)
begin
    if(!I_rst_n)
        R_v_cnt <=  9'd0   ;
    else if(R_v_cnt == C_V_FRAME_PERIOD - 1'b1)
        R_v_cnt <=  9'd0   ;
    else if(R_h_cnt == C_H_LINE_PERIOD - 1'b1)//琛屾椂搴忔弧浜?--銆嬪満鏃跺簭鍔?1
        R_v_cnt <=  R_v_cnt + 1'b1  ;
    else
        R_v_cnt <=  R_v_cnt ;                        
end                
assign O_vs =   (R_v_cnt < C_V_SYNC_PULSE||!I_rst_n) ? 1'b0 : 1'b1    ; 

/**********************************************************************/
//produce W_active_flag
/**********************************************************************/
assign W_active_flag =  (R_h_cnt >= (C_H_SYNC_PULSE + C_H_BACK_PORCH                  ))  &&
                        (R_h_cnt <= (C_H_SYNC_PULSE + C_H_BACK_PORCH + C_H_ACTIVE_TIME))  && 
                        (R_v_cnt >= (C_V_SYNC_PULSE + C_V_BACK_PORCH                  ))  &&
                        (R_v_cnt <= (C_V_SYNC_PULSE + C_V_BACK_PORCH + C_V_ACTIVE_TIME))  ;                     

/**********************************************************************/
//module for show
/**********************************************************************/
vga_site site(
    .state(state),
    .broad(broad),
    .site_X(site_X),
    .site_Y(site_Y),
    .I_rst_n(I_rst_n),
    .R_clk_25M(R_clk_25M),
    .W_active_flag(W_active_flag),    
    .R_h_cnt(R_h_cnt),
    .R_v_cnt(R_v_cnt),     
    .O_red(O_red)   ,    // VGA
    .O_green(O_green) ,  // VGA
    .O_blue(O_blue)      // VGA
);

endmodule
