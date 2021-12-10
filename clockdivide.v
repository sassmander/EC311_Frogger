module clockdivide
    # (parameter div_val = 28'd100000000)
    (clk_in, reset_in, clk_out);
    input clk_in;
    input reset_in;
    output clk_out;
    
    reg clk_int;
    
    reg [27:0] count = 0;
    
    always @ (posedge clk_in or negedge reset_in) begin
       if (reset_in == 1'b0) begin
           count <= 0;
       end else begin
       if (count != (div_val-1'b1)) begin
           count <= count + 1'b1;
       end else if (count == (div_val-1'b1)) begin
           clk_int <= ~clk_int;
           count <= 0;
       end
       end
    end //always
    
    assign clk_out = clk_int;
    
    endmodule
