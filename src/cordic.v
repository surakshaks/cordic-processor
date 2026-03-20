
module cordic #(
    parameter WIDTH = 32,
    parameter FRAC  = 30,
    parameter ITER  = 16
)(
    input  wire                    clk,
    input  wire                    rst,       
    input  wire                    start,     
    input  wire signed [WIDTH-1:0] angle_in,  
    output reg signed [WIDTH-1:0]  cos_out,   
    output reg signed [WIDTH-1:0]  sin_out,   
    output reg                     done
);
 localparam signed [WIDTH-1:0] K_CONST = 32'h26DD3B6A; // ~0.607252935 (Q2.30)
 function signed [WIDTH-1:0] atan_const;
        input [4:0] idx;
        begin
            case (idx)
                5'd0:  atan_const = 32'h3243F6A9; // atan(2^0)
                5'd1:  atan_const = 32'h1DAC6705; // atan(2^-1)
                5'd2:  atan_const = 32'h0FADBAFD; // atan(2^-2)
                5'd3:  atan_const = 32'h07F56EA6; // atan(2^-3)
                5'd4:  atan_const = 32'h03FEAB77; // atan(2^-4)
                5'd5:  atan_const = 32'h01FFD55C; // atan(2^-5)
                5'd6:  atan_const = 32'h00FFFAAB; // atan(2^-6)
                5'd7:  atan_const = 32'h007FFF55; // atan(2^-7)
                5'd8:  atan_const = 32'h003FFFEB; // atan(2^-8)
                5'd9:  atan_const = 32'h001FFFFD; // atan(2^-9)
                5'd10: atan_const = 32'h000FFFFF; // atan(2^-10)
                5'd11: atan_const = 32'h0007FFFF; // atan(2^-11)
                5'd12: atan_const = 32'h0003FFFF; // atan(2^-12)
                5'd13: atan_const = 32'h0001FFFF; // atan(2^-13)
                5'd14: atan_const = 32'h0000FFFF; // atan(2^-14)
                5'd15: atan_const = 32'h00007FFF; // atan(2^-15)
                default: atan_const = 32'h0;
            endcase
        end
    endfunction
 reg signed [WIDTH-1:0] x_reg, y_reg, z_reg;
 reg [7:0] iter_cnt;
 reg  running;
 always @(posedge clk) begin
        if (rst) begin
            x_reg    <= 0;
            y_reg    <= 0;
            z_reg    <= 0;
            iter_cnt <= 0;
            done     <= 0;
            running  <= 0;
            cos_out  <= 0;
            sin_out  <= 0;
        end else begin
            done <= 0; 
if (start && !running) begin

                x_reg    <= K_CONST;     
                y_reg    <= 0;
                z_reg    <= angle_in;    
                iter_cnt <= 0;
                running  <= 1;
            end else if (running) begin
                if (iter_cnt < ITER) begin
                   
                    if (z_reg >= 0) begin
                        x_reg <= x_reg - (y_reg >>> iter_cnt);
                        y_reg <= y_reg + (x_reg >>> iter_cnt);
                        z_reg <= z_reg - atan_const(iter_cnt);
                    end else begin
                        x_reg <= x_reg + (y_reg >>> iter_cnt);
                        y_reg <= y_reg - (x_reg >>> iter_cnt);
                        z_reg <= z_reg + atan_const(iter_cnt);
                    end
                    iter_cnt <= iter_cnt + 1;
                end else begin
      
                    cos_out <= x_reg;
                    sin_out <= y_reg;
                    done    <= 1;
                    running <= 0;
                end
            end
        end
    end

endmodule
