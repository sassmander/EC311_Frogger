module colormodule(
    input wire clk_in, boxC1, boxC2, boxC3, boxC4, boxFrog, boxWater, boxGrass, boxLane, boxLine1, boxLine2, boxLine3, boxDead, boxWin, boxArea,
    output reg [3:0] red_o, green_o, blue_o
    );
    
    //CHANGE COLORS
    //box1 = car1, box2 = car2, etc etc
    always @ (posedge clk_in) begin
        if (boxFrog) begin
            red_o <=4'd15;
            green_o <=4'd15;
            blue_o <=4'd15;
        end 
        else if (boxC1) begin
            red_o <=4'd15;
            green_o <=4'd0;
            blue_o <=4'd15;
        end
        else if (boxC2) begin
            red_o <=4'd0;
            green_o <=4'd0;
            blue_o <=4'd15;
        end
        else if (boxC3) begin
            red_o <=4'd15;
            green_o <=4'd0;
            blue_o <=4'd0;
        end
        else if (boxC4) begin
            red_o <=4'd15;
            green_o <=4'd15;
            blue_o <=4'd0;
        end
        else if (boxWater) begin
            red_o <=4'd0;
            green_o <=4'd15;
            blue_o <=4'd15;
        end
        else if (boxGrass) begin
            red_o <=4'd0;
            green_o <=4'd15;
            blue_o <=4'd0;
        end
        else if (boxLane) begin
            red_o <=4'd0;
            green_o <=4'd0;
            blue_o <=4'd0;
        end
        else if (boxLine1) begin
            red_o <=4'd8;
            green_o <=4'd8;
            blue_o <=4'd0;
       end
        else if (boxLine2) begin
            red_o <=4'd8;
            green_o <=4'd8;
            blue_o <=4'd0;
       end
        else if (boxLine3) begin
            red_o <=4'd8;
            green_o <=4'd8;
            blue_o <=4'd0;
       end
       else if (boxDead) begin
            red_o <=4'd15;
            green_o <=4'd0;
            blue_o <=4'd0;
       end
       else if (boxWin) begin
            red_o <=4'd0;
            green_o <=4'd15;
            blue_o <=4'd0;
       end
       else if (boxArea) begin
            red_o <=4'd0;
            green_o <=4'd0;
            blue_o <=4'd0;
        end 
        /*else begin
            red_o <=4'd0;
            green_o <=4'd0;
            blue_o <=4'd0;
        end*/
        
    end
            
endmodule
