module car(
    input wire clk_in, reset_in, pseudo,
    input [2:0] level,
    output reg [9:0] carL, carR,
    output reg [8:0] carT, carB
);
    wire clk_1hz;
    reg [9:0] speed;
    
    
    
    clockdivide #(.div_val(28'd15000000)) clockC1(.clk_in(clk_in), .reset_in(reset_in), .clk_out(clk_1hz));
    
    always @ (posedge clk_1hz) begin
        if ((reset_in == 1'b0) || (pseudo == 0)) begin
            carL <= 10'd20;
            carR <= 10'd80;
            carT <= 9'd110;
            carB <= 9'd150;
        end else begin
            case (level)
                3'd0: speed <= 10'd20;
                default: speed <= 10'd40;
            endcase
          
            if (carL < 10'd561) begin
                carL = carL + speed;
                carR = carL + 10'd60;
                carT = carT;
                carB = carB;
            end else if (pseudo == 1'b0) begin
                carL <= 10'd20;
                carR <= 10'd80;
                carT <= 9'd110;
                carB <= 9'd150;  
            end else begin
                carL <= 10'd20;
                carR <= 10'd80;
                carT <= 9'd110;
                carB <= 9'd150;
            end
        end
    end      
endmodule
