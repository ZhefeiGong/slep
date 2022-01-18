`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 
// Design Name: 
// Module Name: car_top
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

module car_top(
    input                  clk      ,
    input                  I_rst_n  ,   // low level effective
    input                  rxd      ,
    input                  go       ,   // high level effective
    input                  excute   ,   // high level effective
    input           [4:0]  setdir   ,   // for test traxial...
    output   wire          txd      ,
    output   wire   [3:0]  O_red    ,   // VGA's red   channel
    output   wire   [3:0]  O_green  ,   // VGA's green channel
    output   wire   [3:0]  O_blue   ,   // VGA's blue  channel
    output                 O_hs     ,   // VGA
    output                 O_vs     ,   // VGA
    output   reg    [4:0]  showstate,   // show for test
    output   wire   [6:0]  out
    );
/************************************************************/
// inter signals
/************************************************************/
//uart
reg rdn;                   //low level effective
reg wrn;                   //low level effective
reg [7:0] d_in;
wire [7:0] d_out;
wire r_ready;
wire t_empty;
//vga
reg signed [15:0] site_X; //0-600
reg signed [15:0] site_Y; //0-440
reg [1485:0] broad;        
reg [4:0] vga_state;
reg [9:0] angle;          //don't define in vga.v
//triaxial
reg running;
//display7
reg [3:0]playseven;

//state defination
parameter NONE     =  5'b00000 ;
parameter START    =  5'b00001 ;
parameter INTER    =  5'b00010 ;
parameter RUN      =  5'b00100 ;
parameter WARNING  =  5'b01000 ;
parameter SEARCH   =  5'b10000 ;
reg [4:0]state;

//others
reg barrier;
reg goback;
reg stop;
reg direction;
reg done;
wire [4:0]runstate;//F10000 L01000 S00100 R00010 B00001 
parameter Forward = 5'b10000 ;
parameter Left    = 5'b01000 ;
parameter Stop    = 5'b00100 ;
parameter Right   = 5'b00010 ;
parameter Back    = 5'b00001 ;

//parameter Watch   = 5'b11111 ;

reg [7:0]rxdstate;//D10000000 i01000000 e00100000 s00010000
                  //f00001000 l00000100 r00000010 b00000001
parameter Dann = 8'b10000000 ;
parameter Inii = 8'b01000000 ;
parameter Endd = 8'b00100000 ;
parameter Stoo = 8'b00010000 ;
parameter Forr = 8'b00001000 ;
parameter Leff = 8'b00000100 ;
parameter Rigg = 8'b00000010 ;
parameter Bacc = 8'b00000001 ;

/************************************************************/
// set module
/************************************************************/
uart ua(
    .clk(clk)          ,   //100Mhz
    .I_rst_n(I_rst_n)  ,   //low level effective
    .rdn(rdn)          ,   //low level effective
    .wrn(wrn)          ,   //low level effectives
    .rxd(rxd)          ,
    .d_in(d_in)        ,
    .d_out(d_out)      ,
    .r_ready(r_ready)  ,
    .t_empty(t_empty)  ,
    .txd(txd)
);
vga vg(
    .site_X(site_X)    ,
    .site_Y(site_Y)    ,
    .state(vga_state)  ,   // start-inter-run-search-warning--high level effective
    .broad(broad)      ,   // 60*44
    .I_clk(clk)        ,   // 100Mhz-clock
    .I_rst_n(I_rst_n)  ,   // low level effective
    .O_red(O_red)      ,   // VGA's red   channel
    .O_green(O_green)  ,   // VGA's green channel
    .O_blue(O_blue)    ,   // VGA's blue  channel
    .O_hs(O_hs)        ,  
    .O_vs(O_vs)       
);
triaxial tr(
    .clk(clk)          ,
    .I_rst_n(I_rst_n)  ,   // low level effective
    .set(setdir)       ,   // will change that...
    .running(running)  ,   // high level effective
    .runstate(runstate)
);
//display7
display7 dis(
    .iData(playseven),.oData(out)
);
/************************************************************/
//state machine
/************************************************************/
always @ (posedge clk)
begin
    if(!I_rst_n)begin
        state<=5'b00000;
        //...something need input...
    end
    else begin
        case(state)
            NONE:begin
                state<=START;
            end
            START:begin
                if(go==1'b1)
                    state<=INTER;
                else
                    state<=START;
            end
            INTER:begin
                if(barrier==1'b1)
                    state<=WARNING;
                else if(direction==1'b1)
                    state<=RUN;
                else
                    state<=INTER;
            end
            WARNING:begin
                if(goback==1'b1)
                    state<=INTER;
                else
                    state<=WARNING;
            end
            RUN:begin
                if(barrier==1'b1)
                    state<=WARNING;
                else if(stop==1'b1&&excute==1'b1)
                    state<=SEARCH;
                else
                    state<=RUN;
            end
            SEARCH:begin
                if(done==1'b1)
                    state<=INTER;
                else
                    state<=SEARCH;
            end
            default:begin
                state<=START;
            end
        endcase
    end
end

/************************************************************/
//data in state machine
/************************************************************/

//barrier
always @(posedge clk) begin
    if(!I_rst_n)
        barrier<=1'b0;
    else if(rxdstate[7])//D?
        barrier<=1'b1;
    else
        barrier<=1'b0;
end

//goback
always @(posedge clk) begin
    if(!I_rst_n)
        goback<=1'b0;
    else if(rxdstate[0])//b
        goback<=1'b1;
    else
        goback<=1'b0;
end
//direction
always @(posedge clk) begin
    if(!I_rst_n)
        direction<=1'b0;
    else if(rxdstate[0]||rxdstate[1]||rxdstate[2]||rxdstate[3])//f l r b
        direction<=1'b1;
    else
        direction<=1'b0;
end
//stop
always @(posedge clk) begin
    if(!I_rst_n)
        stop<=1'b0;
    else if(rxdstate[4])//s
        stop<=1'b1;
    else
        stop<=1'b0;
end
//done
always @(posedge clk) begin
    if(!I_rst_n)
        done<=1'b0;
    else if(rxdstate[5])//e
        done<=1'b1;
    else
        done<=1'b0;
end

/************************************************************/
//set uart's data
/************************************************************/
//rdn
always @(posedge clk) begin
    if(!I_rst_n)begin
        rdn<=1'b1;     
    end
    else begin 
        if(r_ready)
            rdn<=1'b0;
        else
            rdn<=1'b1;
    end
end
//wrn
reg searchrecord;
reg Forwardrecord;
reg Backrecord;
reg Stoprecord;
reg Leftrecord;
reg Rightrecord;
always @(posedge clk) begin
    if(!I_rst_n)begin
        wrn<=1'b1;
        searchrecord<=1'b1;
        Forwardrecord<=1'b1;
        Backrecord<=1'b1;
        Stoprecord<=1'b1;
        Leftrecord<=1'b1;
        Rightrecord<=1'b1;
    end
    else if(state==SEARCH)begin            //SEARCH
        if(t_empty)
            if(rxdstate!=Inii&&searchrecord)begin        //only transmite when not get i
                wrn<=1'b0;
                searchrecord<=1'b0;
                Forwardrecord<=1'b1;
                Backrecord<=1'b1;
                Stoprecord<=1'b1;
                Leftrecord<=1'b1;
                Rightrecord<=1'b1;
            end
            else
                wrn<=1'b1;
        else 
            wrn<=1'b1;
    end
    else if(state==RUN||state==INTER)begin //RUN&INTER
        if(t_empty)begin
            if(runstate==Forward)begin
                if(rxdstate!=Forr&&Forwardrecord)begin         //transmite once
                    wrn<=1'b0;
                    searchrecord<=1'b1;
                    Forwardrecord<=1'b0;
                    Backrecord<=1'b1;
                    Stoprecord<=1'b1;
                    Leftrecord<=1'b1;
                    Rightrecord<=1'b1;
                end
                else
                    wrn<=1'b1;
            end
            else if(runstate==Back)begin
                if(rxdstate!=Bacc&&Backrecord)begin         //transmite once
                    wrn<=1'b0;
                    searchrecord<=1'b1;
                    Forwardrecord<=1'b1;
                    Backrecord<=1'b0;
                    Stoprecord<=1'b1;
                    Leftrecord<=1'b1;
                    Rightrecord<=1'b1;
                end
                else
                    wrn<=1'b1;
            end
            else if(runstate==Left)begin
                if(rxdstate!=Leff&&Leftrecord)begin        //transmite once
                    wrn<=1'b0;
                    searchrecord<=1'b1;
                    Forwardrecord<=1'b1;
                    Backrecord<=1'b1;
                    Stoprecord<=1'b1;
                    Leftrecord<=1'b0;
                    Rightrecord<=1'b1;
                end
                else
                    wrn<=1'b1;
            end
            else if(runstate==Right)begin
                if(rxdstate!=Rigg&&Rightrecord)begin         //transmite once
                    wrn<=1'b0;
                    searchrecord<=1'b1;
                    Forwardrecord<=1'b1;
                    Backrecord<=1'b1;
                    Stoprecord<=1'b1;
                    Leftrecord<=1'b1;
                    Rightrecord<=1'b0;
                end
                else
                    wrn<=1'b1;
                
            end
            else if(runstate==Stop)begin
                if(rxdstate!=Stoo&&Stoprecord)begin         //transmite once
                    wrn<=1'b0;
                    searchrecord<=1'b1;
                    Forwardrecord<=1'b1;
                    Backrecord<=1'b1;
                    Stoprecord<=1'b0;
                    Leftrecord<=1'b1;
                    Rightrecord<=1'b1; 
                end
                else
                    wrn<=1'b1;
            end
            else 
                wrn<=1'b1;
        end
        else
            wrn<=1'b1;
    end
    else if(state==WARNING)begin         //WARNING
        if(t_empty)begin
            if(runstate==Back)begin
                if(rxdstate!=Bacc&&Backrecord)begin       //transmite once
                    wrn<=1'b0;
                    searchrecord<=1'b1;
                    Forwardrecord<=1'b1;
                    Backrecord<=1'b0;
                    Stoprecord<=1'b1;
                    Leftrecord<=1'b1;
                    Rightrecord<=1'b1;     
                end
                else
                    wrn<=1'b1;
            end 
            else
                wrn<=1'b1;
        end
        else 
            wrn<=1'b1;
    end
    else
        wrn<=1'b1;
end
//rxdstate
always @(posedge clk) begin
    if(!I_rst_n)begin
        rxdstate<=8'b00000000;
    end
    else begin
        case(d_out)
            8'b01000100:rxdstate<=Dann;//D
            8'b01101001:rxdstate<=Inii;//i
            8'b01100101:rxdstate<=Endd;//e
            8'b01110011:rxdstate<=Stoo;//s
            8'b01100110:rxdstate<=Forr;//f
            8'b01101100:rxdstate<=Leff;//l
            8'b01110010:rxdstate<=Rigg;//r
            8'b01100010:rxdstate<=Bacc;//b
            default:rxdstate<=rxdstate;
        endcase
    end
end
//d_in
always @(posedge clk) begin
    if(!I_rst_n)
        d_in<=8'b00000000;
    else if(state==SEARCH)
        d_in<=8'b01010111;              //W
    else begin
        case(runstate)
            Forward:
                d_in<=8'b01000110;      //F
            Left:
                d_in<=8'b01001100;      //L
            Right:
                d_in<=8'b01010010;      //R
            Stop:
                d_in<=8'b01010011;      //S
            Back:
                d_in<=8'b01000010;      //B
            default:d_in<=8'b00000000;  //none
        endcase
    end
end
/************************************************************/
//other data set
/************************************************************/
always @(posedge clk) begin
    if(!I_rst_n)
        playseven<=4'b0000;
    else begin
        case(rxdstate)
            Dann:playseven<=4'b0001;//D
            Inii:playseven<=4'b0010;//i
            Endd:playseven<=4'b0011;//e
            Stoo:playseven<=4'b0100;//s
            Forr:playseven<=4'b0101;//f
            Leff:playseven<=4'b0110;//l
            Rigg:playseven<=4'b0111;//r
            Bacc:playseven<=4'b1000;//b
            default:playseven<=4'b0000;
        endcase
    end
end
/************************************************************/
//set traxial's data
/************************************************************/
//running
always @(posedge clk) begin
    if(!I_rst_n)
        running<=1'b0;
    else if(state==RUN || state==WARNING || state==INTER)//get data
        running<=1'b1;
    else
        running<=1'b0;
end

/************************************************************/
//set vga's data
/************************************************************/
reg signed [15:0] sin ;
reg signed [15:0] cos ;
reg signed [15:0] temp_sin ;
reg signed [15:0] temp_cos ;
reg [9:0] angle_temp;
reg [3:0] quadrant;
reg [15:0] length;
reg [7:0] lastdirec;
reg signed [15:0] originalX;
reg signed [15:0] originalY;
reg [3:0] countsearch;
reg [7:0] distance;
reg [9:0] temp_angle;
reg [3:0] temp_quadrant;
parameter waringdis = 15 ;

//vga_state
always @(posedge clk) begin
    if(!I_rst_n)
        vga_state<=5'b00000;
    else 
        vga_state<=state;
end

//clk may need to change
wire clkg;
divider #(.NUM_DIV(1353382)) divid1(.I_CLK(clk),.rst(!I_rst_n),.O_CLK(clkg));
//angle(1-361)
always @(posedge clkg) begin
    if(!I_rst_n)begin
        angle=10'b0000000000;//45
    end
    else begin
        if(angle==10'b0000000000)
            angle=10'b0101101000+1;//361
        else if(angle==10'b0101101000+2)
            angle=10'b0000000001;//1
        else if(rxdstate==Leff)
            angle=angle-1;
        else if(rxdstate==Rigg)
            angle=angle+1;
        else
            angle=angle;
    end
end
//clk may need to change
wire clkv;
divider #(.NUM_DIV(3000000)) divid2(.I_CLK(clk),.rst(!I_rst_n),.O_CLK(clkv));
//originalX/originalY/lastdirec/length
always @(posedge clkv) begin
    if(!I_rst_n)begin
        lastdirec=8'b00000000;
        length=16'b0000000000000000;
        originalX=300;
        originalY=400;
    end
    else begin
        if(rxdstate==Forr||rxdstate==Bacc)begin
            if(rxdstate!=lastdirec)begin
                length=16'b0000000000000000;
                lastdirec=rxdstate;
                originalX=site_X;
                originalY=site_Y;
            end
            else begin
                length=length+1;
            end
        end
        else begin
            lastdirec=rxdstate;
            originalX=site_X;
            originalY=site_Y;
            length=16'b0000000000000000;
        end
    end
end
//site_X/site_Y
always @(posedge clkv) begin
    if(!I_rst_n)begin
        site_X<=16'b0000000100101100;
        site_Y<=16'b0000000110010000;
    end
    else begin
        if(rxdstate==Forr||rxdstate==Bacc)begin//Forward & Back
            angle_temp=angle;
            if(rxdstate==Bacc)begin
                if(angle_temp>=180)begin
                    angle_temp=angle_temp-180;
                end
                else begin
                    angle_temp=angle_temp+180;
                end
            end
            /*preparation*/
            if(angle_temp>=1&&angle_temp<=90)begin
                quadrant=4'b0001;
                angle_temp=angle_temp-1;
            end
            else if(angle_temp>90&&angle_temp<=180)begin
                quadrant=4'b0010;
                angle_temp=angle_temp-90-1;
            end
            else if(angle_temp>180&&angle_temp<=270)begin
                quadrant=4'b0100;
                angle_temp=angle_temp-180-1;
            end
            else if(angle_temp>270&&angle_temp<=361)begin
                quadrant=4'b1000;
                angle_temp=angle_temp-270-1;
            end
            else begin
                quadrant=4'b0001;
                angle_temp=10'b0000000000;
            end
            /*taylor expansion*/
            sin=(angle_temp*3141/180)/1-
                (angle_temp*3141/180)*(angle_temp*3141/180)*(angle_temp*3141/180)/1000/1000/2/3+
                (angle_temp*3141/180)*(angle_temp*3141/180)*(angle_temp*3141/180)*(angle_temp*3141/180)*(angle_temp*3141/180)/1000/1000/1000/1000/2/3/4/5-
                (angle_temp*3141/180)*(angle_temp*3141/180)*(angle_temp*3141/180)*(angle_temp*3141/180)*(angle_temp*3141/180)*(angle_temp*3141/180)*(angle_temp*3141/180)/1000/1000/1000/1000/1000/1000/2/3/4/5/6/7+
                (angle_temp*3141/180)*(angle_temp*3141/180)*(angle_temp*3141/180)*(angle_temp*3141/180)*(angle_temp*3141/180)*(angle_temp*3141/180)*(angle_temp*3141/180)*(angle_temp*3141/180)*(angle_temp*3141/180)/1000/1000/1000/1000/1000/1000/1000/1000/2/3/4/5/6/7/8/9-
                (angle_temp*3141/180)*(angle_temp*3141/180)*(angle_temp*3141/180)*(angle_temp*3141/180)*(angle_temp*3141/180)*(angle_temp*3141/180)*(angle_temp*3141/180)*(angle_temp*3141/180)*(angle_temp*3141/180)*(angle_temp*3141/180)*(angle_temp*3141/180)/1000/1000/1000/1000/1000/1000/1000/1000/1000/1000/2/3/4/5/6/7/8/9/10/11;   
            cos=1000-
                (angle_temp*3141/180)*(angle_temp*3141/180)/1000/2+
                (angle_temp*3141/180)*(angle_temp*3141/180)*(angle_temp*3141/180)*(angle_temp*3141/180)/1000/1000/1000/2/3/4-
                (angle_temp*3141/180)*(angle_temp*3141/180)*(angle_temp*3141/180)*(angle_temp*3141/180)*(angle_temp*3141/180)*(angle_temp*3141/180)/1000/1000/1000/1000/1000/2/3/4/5/6+
                (angle_temp*3141/180)*(angle_temp*3141/180)*(angle_temp*3141/180)*(angle_temp*3141/180)*(angle_temp*3141/180)*(angle_temp*3141/180)*(angle_temp*3141/180)*(angle_temp*3141/180)/1000/1000/1000/1000/1000/1000/1000/2/3/4/5/6/7/8-
                (angle_temp*3141/180)*(angle_temp*3141/180)*(angle_temp*3141/180)*(angle_temp*3141/180)*(angle_temp*3141/180)*(angle_temp*3141/180)*(angle_temp*3141/180)*(angle_temp*3141/180)*(angle_temp*3141/180)*(angle_temp*3141/180)/1000/1000/1000/1000/1000/1000/1000/1000/1000/2/3/4/5/6/7/8/9/10;
            /*change*/
            case(quadrant)
                4'b0001:begin
                    site_X=originalX+length*sin/1000;
                    site_Y=originalY-length*cos/1000;
                end
                4'b0010:begin
                    site_X=originalX+length*cos/1000;
                    site_Y=originalY+length*sin/1000;   
                end
                4'b0100:begin
                    site_X=originalX-length*sin/1000;
                    site_Y=originalY+length*cos/1000;
                end
                4'b1000:begin
                    site_X=originalX-length*cos/1000;
                    site_Y=originalY-length*sin/1000;
                end
                default: begin
                    site_X=originalX;
                    site_Y=originalY;
                end
            endcase
            /*boundary*/
            if(site_X>=600)
                 site_X=600;
            else if (site_X<=8)
                 site_X=2;
            if(site_Y>=440)
                 site_Y=440;
            else if (site_Y<=8)
                 site_Y=2;
        end
    end
end
//broad
always @(posedge clk) begin
    if(!I_rst_n)begin
        broad=1486'b0;
        countsearch=4'b0000;
        temp_angle=16'b0;
        temp_quadrant=4'b0000;
    end
    else begin
        if(state==SEARCH)begin
                distance=8'b00111010;
                temp_angle=45;
                        /*temp_angle(There are som bugs that haven't been solved)*/
                        /*if(countsearch==0)begin
                            temp_angle=temp_angle-90;
                            if(temp_angle<1)
                            temp_angle=temp_angle+360;
                        end
                        else if(countsearch==1)begin
                            temp_angle=temp_angle-60;
                            if(temp_angle<1)
                                temp_angle=temp_angle+360;
                        end
                        else if(countsearch==2)begin
                            temp_angle=temp_angle-30;
                            if(temp_angle<1)
                                temp_angle=temp_angle+360;
                        end
                        else if(countsearch==3)begin
                            temp_angle=temp_angle;
                        end
                        else if(countsearch==4)begin
                            temp_angle=temp_angle+30;
                            if(temp_angle>361)
                                temp_angle=temp_angle-360;
                        end
                        else if(countsearch==5)begin
                            temp_angle=temp_angle+60;
                            if(temp_angle>361)
                                temp_angle=temp_angle-360;
                        end
                        else if(countsearch==6)begin
                            temp_angle=temp_angle+90;
                            if(temp_angle>361)
                                temp_angle=temp_angle-360;
                        end*/
                        /*preparation*/
                        if(angle>=1&&angle<=90)begin
                            temp_quadrant=4'b0001;
                        end
                        else if(angle>90&&angle<=180)begin
                            temp_quadrant=4'b0010;
                        end
                        else if(angle>180&&angle<=270)begin
                            temp_quadrant=4'b0100;
                        end
                        else if(angle>270&&angle<=361)begin
                            temp_quadrant=4'b1000;
                        end
                        else begin
                            temp_quadrant=4'b0001;
                        end

                        /*taylor expansion*/
                        temp_sin=(temp_angle*3141/180)/1-
                            (temp_angle*3141/180)*(temp_angle*3141/180)*(temp_angle*3141/180)/1000/1000/2/3+
                            (temp_angle*3141/180)*(temp_angle*3141/180)*(temp_angle*3141/180)*(temp_angle*3141/180)*(temp_angle*3141/180)/1000/1000/1000/1000/2/3/4/5-
                            (temp_angle*3141/180)*(temp_angle*3141/180)*(temp_angle*3141/180)*(temp_angle*3141/180)*(temp_angle*3141/180)*(temp_angle*3141/180)*(temp_angle*3141/180)/1000/1000/1000/1000/1000/1000/2/3/4/5/6/7+
                            (temp_angle*3141/180)*(temp_angle*3141/180)*(temp_angle*3141/180)*(temp_angle*3141/180)*(temp_angle*3141/180)*(temp_angle*3141/180)*(temp_angle*3141/180)*(temp_angle*3141/180)*(temp_angle*3141/180)/1000/1000/1000/1000/1000/1000/1000/1000/2/3/4/5/6/7/8/9-
                            (temp_angle*3141/180)*(temp_angle*3141/180)*(temp_angle*3141/180)*(temp_angle*3141/180)*(temp_angle*3141/180)*(temp_angle*3141/180)*(temp_angle*3141/180)*(temp_angle*3141/180)*(temp_angle*3141/180)*(temp_angle*3141/180)*(temp_angle*3141/180)/1000/1000/1000/1000/1000/1000/1000/1000/1000/1000/2/3/4/5/6/7/8/9/10/11;   
                        temp_cos=1000-
                            (temp_angle*3141/180)*(temp_angle*3141/180)/1000/2+
                            (temp_angle*3141/180)*(temp_angle*3141/180)*(temp_angle*3141/180)*(temp_angle*3141/180)/1000/1000/1000/2/3/4-
                            (temp_angle*3141/180)*(temp_angle*3141/180)*(temp_angle*3141/180)*(temp_angle*3141/180)*(temp_angle*3141/180)*(temp_angle*3141/180)/1000/1000/1000/1000/1000/2/3/4/5/6+
                            (temp_angle*3141/180)*(temp_angle*3141/180)*(temp_angle*3141/180)*(temp_angle*3141/180)*(temp_angle*3141/180)*(temp_angle*3141/180)*(temp_angle*3141/180)*(temp_angle*3141/180)/1000/1000/1000/1000/1000/1000/1000/2/3/4/5/6/7/8-
                            (temp_angle*3141/180)*(temp_angle*3141/180)*(temp_angle*3141/180)*(temp_angle*3141/180)*(temp_angle*3141/180)*(temp_angle*3141/180)*(temp_angle*3141/180)*(temp_angle*3141/180)*(temp_angle*3141/180)*(temp_angle*3141/180)/1000/1000/1000/1000/1000/1000/1000/1000/1000/2/3/4/5/6/7/8/9/10;
        
                        /*calculate*/
                        case(temp_quadrant)
                            4'b0001:broad[(site_X+distance*temp_sin/1000)/13+(site_Y-distance*temp_cos/1000)/13*45]=1'b1;
                            4'b0010:broad[(site_X+distance*temp_cos/1000)/13+(site_Y+distance*temp_sin/1000)/13*45]=1'b1;
                            4'b0100:broad[(site_X-distance*temp_sin/1000)/13+(site_Y+distance*temp_cos/1000)/13*45]=1'b1;
                            4'b1000:broad[(site_X-distance*temp_cos/1000)/13+(site_Y-distance*temp_sin/1000)/13*45]=1'b1;
                            default: ;
                        endcase
        end
        else if(state==WARNING)begin
            if(countsearch==0)begin
                temp_angle=angle;
                /*preparation*/
                if(temp_angle>=1&&temp_angle<=90)begin
                    temp_quadrant=4'b0001;
                    temp_angle=temp_angle-1;
                end
                else if(temp_angle>90&&temp_angle<=180)begin
                    temp_quadrant=4'b0010;
                    temp_angle=temp_angle-90-1;
                end
                else if(temp_angle>180&&temp_angle<=270)begin
                    temp_quadrant=4'b0100;
                    temp_angle=temp_angle-180-1;
                end
                else if(temp_angle>270&&temp_angle<=361)begin
                    temp_quadrant=4'b1000;
                    temp_angle=temp_angle-270-1;
                end
                else begin
                    temp_quadrant=4'b0001;
                    temp_angle=10'b0000000000;
                end

                /*taylor expansion*/
                temp_sin=(temp_angle*3141/180)/1-
                    (temp_angle*3141/180)*(temp_angle*3141/180)*(temp_angle*3141/180)/1000/1000/2/3+
                    (temp_angle*3141/180)*(temp_angle*3141/180)*(temp_angle*3141/180)*(temp_angle*3141/180)*(temp_angle*3141/180)/1000/1000/1000/1000/2/3/4/5-
                    (temp_angle*3141/180)*(temp_angle*3141/180)*(temp_angle*3141/180)*(temp_angle*3141/180)*(temp_angle*3141/180)*(temp_angle*3141/180)*(temp_angle*3141/180)/1000/1000/1000/1000/1000/1000/2/3/4/5/6/7+
                    (temp_angle*3141/180)*(temp_angle*3141/180)*(temp_angle*3141/180)*(temp_angle*3141/180)*(temp_angle*3141/180)*(temp_angle*3141/180)*(temp_angle*3141/180)*(temp_angle*3141/180)*(temp_angle*3141/180)/1000/1000/1000/1000/1000/1000/1000/1000/2/3/4/5/6/7/8/9-
                    (temp_angle*3141/180)*(temp_angle*3141/180)*(temp_angle*3141/180)*(temp_angle*3141/180)*(temp_angle*3141/180)*(temp_angle*3141/180)*(temp_angle*3141/180)*(temp_angle*3141/180)*(temp_angle*3141/180)*(temp_angle*3141/180)*(temp_angle*3141/180)/1000/1000/1000/1000/1000/1000/1000/1000/1000/1000/2/3/4/5/6/7/8/9/10/11;   
                temp_cos=1000-
                    (temp_angle*3141/180)*(temp_angle*3141/180)/1000/2+
                    (temp_angle*3141/180)*(temp_angle*3141/180)*(temp_angle*3141/180)*(temp_angle*3141/180)/1000/1000/1000/2/3/4-
                    (temp_angle*3141/180)*(temp_angle*3141/180)*(temp_angle*3141/180)*(temp_angle*3141/180)*(temp_angle*3141/180)*(temp_angle*3141/180)/1000/1000/1000/1000/1000/2/3/4/5/6+
                    (temp_angle*3141/180)*(temp_angle*3141/180)*(temp_angle*3141/180)*(temp_angle*3141/180)*(temp_angle*3141/180)*(temp_angle*3141/180)*(temp_angle*3141/180)*(temp_angle*3141/180)/1000/1000/1000/1000/1000/1000/1000/2/3/4/5/6/7/8-
                    (temp_angle*3141/180)*(temp_angle*3141/180)*(temp_angle*3141/180)*(temp_angle*3141/180)*(temp_angle*3141/180)*(temp_angle*3141/180)*(temp_angle*3141/180)*(temp_angle*3141/180)*(temp_angle*3141/180)*(temp_angle*3141/180)/1000/1000/1000/1000/1000/1000/1000/1000/1000/2/3/4/5/6/7/8/9/10;
                        
                /*calculate*/
                case(temp_quadrant)
                    4'b0001:broad[(site_X+waringdis*temp_sin/1000)/13+(site_Y-waringdis*temp_cos/1000)/13*45]=1'b1;
                    4'b0010:broad[(site_X+waringdis*temp_cos/1000)/13+(site_Y+waringdis*temp_sin/1000)/13*45]=1'b1;
                    4'b0100:broad[(site_X-waringdis*temp_sin/1000)/13+(site_Y+waringdis*temp_cos/1000)/13*45]=1'b1;
                    4'b1000:broad[(site_X-waringdis*temp_cos/1000)/13+(site_Y-waringdis*temp_sin/1000)/13*45]=1'b1;
                    default: ;
                endcase

                countsearch=countsearch+1;
            end
        end
        else begin
        countsearch=4'b0000;
        end
    end
end

/************************************************************/
//set for test
/************************************************************/
always @(posedge clk) begin
    if(!I_rst_n)begin
        showstate<=5'b00000;
    end
    else begin
        showstate<= state;
    end
end

endmodule

