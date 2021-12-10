module frog(
    input wire clk_in, reset_in, pseudo,
    input buttonup, buttondown, buttonleft, buttonright,
    output reg [9:0] frogL, frogR,
    output reg [8:0] frogT, frogB
);

wire[3:0] select;
wire[3:0] direction;

debouncer debounceup(.clk_i(clk_in), .reset_i(reset_in), .button_in(buttonup), .button_out(select[3]));
debouncer debouncedown(.clk_i(clk_in), .reset_i(reset_in), .button_in(buttondown), .button_out(select[2]));
debouncer debounceleft(.clk_i(clk_in), .reset_i(reset_in), .button_in(buttonleft), .button_out(select[1]));
debouncer debounceright(.clk_i(clk_in), .reset_i(reset_in), .button_in(buttonright), .button_out(select[0]));

mux4to1 buttonmux(.input1(select[3]), .input2(select[2]), .input3(select[1]), .input4(select[0]), .select_in(select), .output_o(direction));

always @ (posedge clk_in) begin
    if ((reset_in == 1'b0) || (pseudo == 0)) begin
        frogL <= 10'd310;
        frogR <= 10'd330;
        frogT <= 9'd415;
        frogB <= 9'd435;
    end else begin
        if (direction == 4'b1000) begin //up
            frogT <= frogT - 5'b10000;
            frogB <= frogB - 5'b10000;
            frogL <= frogL;
            frogR <= frogR;
        end else if (direction == 4'b0100) begin //down
            frogT <= frogT + 5'b10000;
            frogB <= frogB + 5'b10000;
            frogL <= frogL;
            frogR <= frogR;
        end else if (direction == 4'b0010) begin //left
            frogL <= frogL - 5'b10000;
            frogR <= frogR - 5'b10000;
            frogT <= frogT;
            frogB <= frogB;
        end else if (direction == 4'b0001) begin //right
            frogL <= frogL + 5'b10000;
            frogR <= frogR + 5'b10000;
            frogT <= frogT;
            frogB <= frogB;
        /*end else if (pseudo == 1'b0) begin
            frogL <= 10'd310;
            frogR <= 10'd330;
            frogT <= 9'd415;
            frogB <= 9'd435;  */
        end else begin
            frogL <= frogL;
            frogR <= frogR;
            frogT <= frogT;
            frogB <= frogB;
        end
    end 
 end
 
endmodule
