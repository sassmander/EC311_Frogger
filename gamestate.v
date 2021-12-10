module gamestate(

    input wire clk_in, reset_in,
    input wire collision_i,
    input wire [8:0] frogB,
    output reg pseudo, 
    output reg gameover,
    output reg gamewin,
    output reg [2:0] level,
    output reg [2:0] lives
    );
    wire countdown;
    wire clk_1hz;
    reg [5:0] count;
    
    clockdivide #(.div_val(28'd100000000)) clockgamestate(.clk_in(clk_in), .reset_in(reset_in), .clk_out(clk_1hz));
    always @(posedge clk_1hz) begin
        count <= count + 5'b00001;
    end  //always
    //counter_30sec gameend(.clk_in(clk_in), .reset_in(reset_in), .count_is30(countdown));
    
    always @ (posedge clk_in) begin
        if (reset_in == 1'b0) begin
            pseudo <= 1'b1;
            level <= 3'd0;
            lives <= 3'd4;
            gameover <= 1'b0;
            gamewin <= 1'b0;
            count <= 5'b00000;
        end else begin
            if ((level <= 3'd4) && (lives > 2'd0)) begin
                if (collision_i == 1'b0) begin
                    pseudo <= 1'b1;
                    gameover <= 1'b0;
                end else if ((collision_i == 1'b1)||(count == 5'd30)) begin
                    pseudo <= 1'b0;
                    lives <= lives - 1'd1;
                    gameover <= 1'b0;
                    count <= 5'd0;
                end
                
                if (frogB <= 9'd90) begin
                    if (level < 3'd4) begin
                        level <= level + 1'd1;
                        lives <= 3'd4;
                        pseudo <= 1'b0;
                    end else if (level == 3'd4) begin
                        gamewin <= 1'b1;
                        pseudo <= 1'b0;
                    end
                end
                
//                if ((frogB <= 9'd90)&&(level <= 2'b10)) begin
//                    level <= level + 1'b1;
//                    lives <= 2'b11;
//                    pseudo <= 1'b0;
//                end else if ((frogB <= 9'd90)&&(level == 2'b11)) begin
//                    gamewin <= 1'b1;
//                    pseudo <= 1'b0;
//                end

            end
            
            if (lives == 3'd0) begin
                gameover <= 1'b1;
                pseudo <= 1'b0;
            end
            
            
        end
     end
 
    
endmodule
