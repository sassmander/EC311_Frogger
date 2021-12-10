module top_frogger(
    input wire clk_in, reset_in,
    input wire buttonup, buttondown, buttonleft, buttonright, 
    output wire VGA_HS_O,       // horizontal sync output
    output wire VGA_VS_O,       // vertical sync output
    output wire [3:0] VGA_R,    // 4-bit VGA red output
    output wire [3:0] VGA_G,    // 4-bit VGA green output
    output wire [3:0] VGA_B,     // 4-bit VGA blue output
    output wire [6:0] sevenseg_o,
    output wire [3:0] digit_o
    );

    wire rst = ~reset_in;    // reset is active low on Arty & Nexys Video
   
    // generate a 25 MHz pixel strobe
    reg [15:0] cnt;
    reg pix_stb;
    always @(posedge clk_in)
        {pix_stb, cnt} <= cnt + 16'h4000;  // divide by 4: (2^16)/4 = 0x4000

    wire [9:0] X;  // current pixel x position: 10-bit value: 0-1023
    wire [8:0] Y;  // current pixel y position:  9-bit value: 0-511
    vga640x480 display(.i_clk(clk_in), .i_pix_stb(pix_stb), .i_rst(rst), .o_hs(VGA_HS_O), .o_vs(VGA_VS_O), .o_x(X), .o_y(Y));
    
    //Game state control registers
    wire[2:0] lives;
    wire[2:0] level;
    //localparam div_val = 28'd100000000;
    wire gamewin, gameover, pseudo;
    wire collision_w;
    wire[2:0] count_start;
    wire[2:0] sevensegout;


    //Instiations of game objects
    wire [9:0] frogL, frogR, car1L, car1R, car2L, car2R, car3L, car3R, car4L, car4R;
    wire [8:0] frogT, frogB, car1T, car1B, car2T, car2B, car3T, car3B, car4T, car4B;
    
    //gamestate to output lives, gameover, gamewin
    gamestate state(.clk_in(clk_in), .reset_in(reset_in), .collision_i(collision_w), .frogB(frogB), .pseudo(pseudo), .gameover(gameover), .gamewin(gamewin), .level(level), .lives(lives));
    
    //Moving objects instantiation
    frog onlyfrog(.clk_in(clk_in), .reset_in(reset_in), .pseudo(pseudo), .buttonup(buttonup), .buttondown(buttondown), .buttonleft(buttonleft), .buttonright(buttonright), .frogL(frogL), .frogR(frogR), .frogT(frogT), .frogB(frogB));
    //Cars should have another input for changing clock state
    car car1_1(.clk_in(clk_in), .reset_in(reset_in), .pseudo(pseudo), .carL(car1L), .carR(car1R), .carT(car1T), .carB(car1B));
    car2 car1_2(.clk_in(clk_in), .reset_in(reset_in), .pseudo(pseudo),.carL(car2L), .carR(car2R), .carT(car2T), .carB(car2B));
    car3 car1_3(.clk_in(clk_in), .reset_in(reset_in), .pseudo(pseudo),.carL(car3L), .carR(car3R), .carT(car3T), .carB(car3B));
    car4 car1_4(.clk_in(clk_in), .reset_in(reset_in), .pseudo(pseudo),.carL(car4L), .carR(car4R), .carT(car4T), .carB(car4B));
    //Collision check for each car
    collision colli1(.clk_in(clk_in), .reset_in(reset_in), .pseudo(pseudo), .frogL(frogL), .frogR(frogR), .frogT(frogT), .frogB(frogB), .car1L(car1L), .car1R(car1R), .car1T(car1T), .car1B(car1B), .car2L(car2L), .car2R(car2R), .car2T(car2T), .car2B(car2B), .car3L(car3L), .car3R(car3R), .car3T(car3T), .car3B(car3B),  .car4L(car4L), .car4R(car4R), .car4T(car4T), .car4B(car4B), .collision_o(collision_w));
    
    //5 sec countdown and seven segment display with countdown and number of lives
    counter_5sec startcount(.clk_in(clk_in), .reset_in(reset_in), .count_o(count_start));

    display_cont displaysevenseg(.clk_in(clk_in), .reset_in(reset_in), .startcount(count_start), .lives(lives), .digit_o(digit_o), .digit_seven_seg(sevensegout));
    seven_seg_start seven_seg(.binary_in(sevensegout), .sevenseg_o(sevenseg_o));
    assign disp_on = 1'b0;
    assign disp_off = 1'b1;
    
    //Set locations for lanes, locations, etc
    wire wholeArea = ((X >= 10'd20)&&(X <= 10'd620)&&(Y >= 9'd20)&&(Y <= 9'd460)); //Sets the entire area, cuts off 20 pixels from each border
    wire Frog = ((X >= frogL)&&(X <= frogR)&&(Y >= frogT)&&(Y <= frogB));
    wire Car1 = ((X >= car1L)&&(X <= car1R)&&(Y >= car1T)&&(Y <= car1B));
    wire Car2 = ((X >= car2L)&&(X <= car2R)&&(Y >= car2T)&&(Y <= car2B));
    wire Car3 = ((X >= car3L)&&(X <= car3R)&&(Y >= car3T)&&(Y <= car3B));
    wire Car4 = ((X >= car4L)&&(X <= car4R)&&(Y >= car4T)&&(Y <= car4B));
    
    wire Water = ((X >= 10'd20)&&(X <= 10'd620)&&(Y >= 9'd20)&&(Y <= 9'd90));
    wire Grass = ((X >= 10'd20)&&(X <= 10'd620)&&(Y >= 9'd390)&&(Y <= 9'd460));
    wire Lane = ((X >= 10'd0)&&(X <= 10'd0)&&(Y >= 9'd0)&&(Y <= 9'd0)); //((X >= 10'd20)&&(X <= 10'd620)&&(Y >= 9'd90)&&(Y <= 9'd390));
    wire Line1 = ((X >= 10'd20)&&(X <= 10'd620)&&(Y >= 9'd163)&&(Y <= 9'd167));
    wire Line2 = ((X >= 10'd20)&&(X <= 10'd620)&&(Y >= 9'd238)&&(Y <= 9'd242));
    wire Line3 = ((X >= 10'd20)&&(X <= 10'd620)&&(Y >= 9'd313)&&(Y <= 9'd317));
    
    //Win areas
    wire w11 = ((X >= 10'd120)&&(X <= 10'd160)&&(Y >= 9'd130)&&(Y <= 9'd350));
    wire w12 = ((X >= 10'd240)&&(X <= 10'd280)&&(Y >= 9'd130)&&(Y <= 9'd350));
    wire w13 = ((X >= 10'd290)&&(X <= 10'd330)&&(Y >= 9'd130)&&(Y <= 9'd350));
    wire w14 = ((X >= 10'd340)&&(X <= 10'd380)&&(Y >= 9'd130)&&(Y <= 9'd350));
    wire w15 = ((X >= 10'd460)&&(X <= 10'd500)&&(Y >= 9'd130)&&(Y <= 9'd350));
    
    wire w21 = ((X >= 10'd160)&&(X <= 10'd180)&&(Y >= 9'd306)&&(Y <= 9'd350));
    wire w22 = ((X >= 10'd220)&&(X <= 10'd240)&&(Y >= 9'd306)&&(Y <= 9'd350));
    wire w3 = ((X >= 10'd180)&&(X <= 10'd220)&&(Y >= 9'd262)&&(Y <= 9'd306));
    
    wire w41 = ((X >= 10'd380)&&(X <= 10'd420)&&(Y >= 9'd130)&&(Y <= 9'd196));
    wire w42 = ((X >= 10'd420)&&(X <= 10'd460)&&(Y >= 9'd284)&&(Y <= 9'd350));
    wire w5 = ((X >= 10'd400)&&(X <= 10'd440)&&(Y >= 9'd196)&&(Y <= 9'd284));
    
    //Dead areas
    wire d11 = ((X >= 10'd60)&&(X <= 10'd100)&&(Y >= 9'd130)&&(Y <= 9'd350));
    wire d12 = ((X >= 10'd480)&&(X <= 10'd520)&&(Y >= 9'd130)&&(Y <= 9'd350));
    
    wire d21 = ((X >= 10'd100)&&(X <= 10'd160)&&(Y >= 9'd306)&&(Y <= 9'd350));
    wire d22 = ((X >= 10'd520)&&(X <= 10'd580)&&(Y >= 9'd130)&&(Y <= 9'd174));
    wire d23 = ((X >= 10'd520)&&(X <= 10'd580)&&(Y >= 9'd218)&&(Y <= 9'd262));
    wire d24 = ((X >= 10'd520)&&(X <= 10'd580)&&(Y >= 9'd306)&&(Y <= 9'd350));
    
    wire d3 = ((X >= 10'd200)&&(X <= 10'd300)&&(Y >= 9'd130)&&(Y <= 9'd350));
    wire d4 = ((X >= 10'd240)&&(X <= 10'd260)&&(Y >= 9'd174)&&(Y <= 9'd306));
    
    wire d51 = ((X >= 10'd340)&&(X <= 10'd440)&&(Y >= 9'd130)&&(Y <= 9'd174));
    wire d52 = ((X >= 10'd340)&&(X <= 10'd440)&&(Y >= 9'd218)&&(Y <= 9'd262));
    wire d53 = ((X >= 10'd340)&&(X <= 10'd440)&&(Y >= 9'd306)&&(Y <= 9'd350));
    
    wire d61 = ((X >= 10'd340)&&(X <= 10'd380)&&(Y >= 9'd174)&&(Y <= 9'd218));
    wire d62 = ((X >= 10'd400)&&(X <= 10'd440)&&(Y >= 9'd262)&&(Y <= 9'd306));
    
    wire Win = wholeArea - w11-w12-w13-w14-w15-w21-w22-w3-w41-w42-w5;
    wire Dead = wholeArea - d11-d12-d21-d22-d23-d24-d3+d4-d51-d52-d53-d61-d62; 
    
    //Setting locations with objects to pass on to color module
    reg boxFrog, boxC1, boxC2, boxC3, boxC4, boxWater, boxGrass, boxLane, boxLine1, boxLine2, boxLine3, boxWin, boxDead, boxArea;
    always @ (posedge clk_in) begin //previously (*)
	if(Frog&&wholeArea) //frog -> boxFrog
	   begin
	   boxFrog = 1'b1; boxC1 = 1'b0; boxC2 = 1'b0; boxC3 = 1'b0; boxC4 = 1'b0; boxWater = 1'b0; boxGrass = 1'b0; boxLane = 1'b0; boxLine1 = 1'b0; boxLine2 = 1'b0; boxLine3 = 1'b0; boxWin = 1'b0; boxDead = 1'b0; boxArea = 1'b0;
	   end
	else if(Car1&&wholeArea) //Car1 -> boxC1
	   begin
	   boxFrog = 1'b0; boxC1 = 1'b1; boxC2 = 1'b0; boxC3 = 1'b0; boxC4 = 1'b0; boxWater = 1'b0; boxGrass = 1'b0; boxLane = 1'b0; boxLine1 = 1'b0; boxLine2 = 1'b0; boxLine3 = 1'b0; boxWin = 1'b0; boxDead = 1'b0; boxArea = 1'b0;
	   end
	else if(Car2&&wholeArea) //Car2 -> boxC2
	   begin
	   boxFrog = 1'b0; boxC1 = 1'b0; boxC2 = 1'b1; boxC3 = 1'b0; boxC4 = 1'b0; boxWater = 1'b0; boxGrass = 1'b0; boxLane = 1'b0; boxLine1 = 1'b0; boxLine2 = 1'b0; boxLine3 = 1'b0; boxWin = 1'b0; boxDead = 1'b0; boxArea = 1'b0;
	   end
	else if(Car3&&wholeArea) //Car3 -> boxC3
	   begin
	   boxFrog = 1'b0; boxC1 = 1'b0; boxC2 = 1'b0; boxC3 = 1'b1; boxC4 = 1'b0; boxWater = 1'b0; boxGrass = 1'b0; boxLane = 1'b0; boxLine1 = 1'b0; boxLine2 = 1'b0; boxLine3 = 1'b0; boxWin = 1'b0; boxDead = 1'b0; boxArea = 1'b0;
	   end
	else if(Car4&&wholeArea) //Car4 -> boxC4
	   begin
	   boxFrog = 1'b0; boxC1 = 1'b0; boxC2 = 1'b0; boxC3 = 1'b0; boxC4 = 1'b1; boxWater = 1'b0; boxGrass = 1'b0; boxLane = 1'b0; boxLine1 = 1'b0; boxLine2 = 1'b0; boxLine3 = 1'b0; boxWin = 1'b0; boxDead = 1'b0; boxArea = 1'b0;
       end 
    else if(Grass) //Grass -> boxGrass
	   begin
	   boxFrog = 1'b0; boxC1 = 1'b0; boxC2 = 1'b0; boxC3 = 1'b0; boxC4 = 1'b0; boxWater = 1'b0; boxGrass = 1'b1; boxLane = 1'b0; boxLine1 = 1'b0; boxLine2 = 1'b0; boxLine3 = 1'b0; boxWin = 1'b0; boxDead = 1'b0; boxArea = 1'b0;
       end 
    else if(Water&&wholeArea) //Water -> boxWater
	   begin
	   boxFrog = 1'b0; boxC1 = 1'b0; boxC2 = 1'b0; boxC3 = 1'b0; boxC4 = 1'b0; boxWater = 1'b1; boxGrass = 1'b0; boxLane = 1'b0; boxLine1 = 1'b0; boxLine2 = 1'b0; boxLine3 = 1'b0; boxWin = 1'b0; boxDead = 1'b0; boxArea = 1'b0;
       end 
    else if(Lane) //Lane -> boxLane
	   begin
	   boxFrog = 1'b0; boxC1 = 1'b0; boxC2 = 1'b0; boxC3 = 1'b0; boxC4 = 1'b0; boxWater = 1'b0; boxGrass = 1'b0; boxLane = 1'b1; boxLine1 = 1'b0; boxLine2 = 1'b0; boxLine3 = 1'b0; boxWin = 1'b0; boxDead = 1'b0; boxArea = 1'b0;
       end 
   	else if(Line1&&wholeArea) //Line1 -> boxLine1
	   begin
	   boxFrog = 1'b0; boxC1 = 1'b0; boxC2 = 1'b0; boxC3 = 1'b0; boxC4 = 1'b0; boxWater = 1'b0; boxGrass = 1'b0; boxLane = 1'b0; boxLine1 = 1'b1; boxLine2 = 1'b0; boxLine3 = 1'b0; boxWin = 1'b0; boxDead = 1'b0; boxArea = 1'b0;
       end 
   	else if(Line2&&wholeArea) //Line2 -> boxLine2
	   begin
	   boxFrog = 1'b0; boxC1 = 1'b0; boxC2 = 1'b0; boxC3 = 1'b0; boxC4 = 1'b0; boxWater = 1'b0; boxGrass = 1'b0; boxLane = 1'b0; boxLine1 = 1'b0; boxLine2 = 1'b1; boxLine3 = 1'b0; boxWin = 1'b0; boxDead = 1'b0; boxArea = 1'b0;
       end 
   	else if(Line3&&wholeArea) //Line3 -> boxLine3
	   begin
	   boxFrog = 1'b0; boxC1 = 1'b0; boxC2 = 1'b0; boxC3 = 1'b0; boxC4 = 1'b0; boxWater = 1'b0; boxGrass = 1'b0; boxLane = 1'b0; boxLine1 = 1'b0; boxLine2 = 1'b0; boxLine3 = 1'b1; boxWin = 1'b0; boxDead = 1'b0; boxArea = 1'b0;
       end 
    else if(gamewin&&Win) //Win -> boxWin
	   begin
	   boxFrog = 1'b0; boxC1 = 1'b0; boxC2 = 1'b0; boxC3 = 1'b0; boxC4 = 1'b0; boxWater = 1'b0; boxGrass = 1'b0; boxLane = 1'b0; boxLine1 = 1'b0; boxLine2 = 1'b0; boxLine3 = 1'b0; boxWin = 1'b1; boxDead = 1'b0; boxArea = 1'b0;
       end 
    else if(gameover&&Dead) //Dead -> boxLine
	   begin
	   boxFrog = 1'b0; boxC1 = 1'b0; boxC2 = 1'b0; boxC3 = 1'b0; boxC4 = 1'b0; boxWater = 1'b0; boxGrass = 1'b0; boxLane = 1'b0; boxLine1 = 1'b0; boxLine2 = 1'b0; boxLine3 = 1'b0; boxWin = 1'b0; boxDead = 1'b1; boxArea = 1'b0;
       end 
    else if(wholeArea) //wholeArea -> boxArea
	   begin
	   boxFrog = 1'b0; boxC1 = 1'b0; boxC2 = 1'b0; boxC3 = 1'b0; boxC4 = 1'b0; boxWater = 1'b0; boxGrass = 1'b0; boxLane = 1'b0; boxLine1 = 1'b0; boxLine2 = 1'b0; boxLine3 = 1'b0; boxWin = 1'b0; boxDead = 1'b0; boxArea = 1'b1;
       end 
	/*else //background everything is 0
	   begin
	   boxFrog = 1'b0; boxC1 = 1'b0; boxC2 = 1'b0; boxC3 = 1'b0; boxC4 = 1'b0; boxWater = 1'b0; boxGrass = 1'b0; boxLane = 1'b0; boxLine = 1'b0; boxWin = 1'b0; boxDead = 1'b0; boxArea = 1'b1;
	   end*/
	end
    
    //Set color to each location object
    colormodule color(.clk_in(clk_in), .boxC1(boxC1), .boxC2(boxC2), .boxC3(boxC3), .boxC4(boxC4), .boxFrog(boxFrog), .boxWater(boxWater), .boxGrass(boxGrass), .boxLane(boxLane), .boxLine1(boxLine1), .boxLine2(boxLine2), .boxLine3(boxLine3), .boxWin(boxWin), .boxDead(boxDead), .boxArea(boxArea), .red_o(VGA_R), .green_o(VGA_G), .blue_o(VGA_B)); 

endmodule
