module collision(
    input wire clk_in, reset_in,
    input wire pseudo,
    input wire [9:0] frogL, frogR, 
    input wire [9:0] car1L, car1R, car2L, car2R, car3L, car3R, car4L, car4R,
    input wire [8:0] frogT, frogB, 
    input wire [8:0] car1T, car1B, car2T, car2B, car3T, car3B, car4T, car4B,
    output reg collision_o
);
    always @ (posedge clk_in) begin
        if ((reset_in == 1'b0) || (pseudo == 0)) begin
            collision_o <= 1'b0;
        end else begin
            if ((frogR > car1L) && (frogL < car1R) && (frogB > car1T) && (frogT < car1B)) begin
                collision_o <= 1'b1;
            end else if ((frogR > car2L) && (frogL < car2R) && (frogB > car2T) && (frogT < car2B)) begin
                collision_o <= 1'b1;
            end else if ((frogR > car3L) && (frogL < car3R) && (frogB > car3T) && (frogT < car3B)) begin
                collision_o <= 1'b1;
            end else if ((frogR > car4L) && (frogL < car4R) && (frogB > car4T) && (frogT < car4B)) begin
                collision_o <= 1'b1;
            end else begin
                collision_o <= 1'b0;
                
            end
        end
     end
     //Jessica's logic
     //((((frogL > car4L) && (frogL < car4R)) || ((frogR > car4L) && (frogR < car4R))) && (((frogT > car4T) && (frogT < car4B)) || ((frogB > car4T) && (frogB < car4B))))
endmodule
