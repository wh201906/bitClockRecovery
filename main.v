module main (
    input clk_50M,
    input signal,
    input key_rev,
    input key_type,
    
    output reg clk_rec,
    output reg [15:0] clk_freq=16'd801,
    output test_led
);
    reg signal_reg;
    reg key_type_reg;
    reg type_reg=0;
    
    wire clk_200M;
    wire clk_200M_global;
    wire key_rev_out;
    wire key_type_out;
    
    reg [15:0] interval_counter;
    
    reg clk_reset_flag=1'b0;

    reg [15:0] clk_counter;

    reg [3:0] clk_stable_counter;
    
    reg key_rev_reg=1'b1;

    clkGen clkGen( // generate 200Mhz clock as the base clock
        .inclk0(clk_50M),
        .c0(clk_200M)
	);
    
    globalClock u0 (
        .inclk  (clk_200M),
        .outclk (clk_200M_global)
    );
    
    key keyRev(
        .clk(clk_50M),
        .key_in(key_rev),
        .key_out(key_rev_out)
    );
    
    key keyType(
        .clk(clk_50M),
        .key_in(key_type),
        .key_out(key_type_out)
    );
    
    always @(posedge clk_200M_global) begin
        if(signal_reg!=signal) begin //edge detected
            if(interval_counter<clk_freq) begin // get the smallest interval
                clk_freq=interval_counter; // put the smallest interval
                clk_stable_counter=4'd0; // duration set to 0 since the interval has been updated
                
            end
            else begin // edge, but the interval will not change
                clk_stable_counter=clk_stable_counter+4'd1; // add duration
            end
            interval_counter=16'd0;
            if(clk_stable_counter==4'b1111) begin // try to add threshold after 16 edges
                clk_freq=clk_freq+16'd1;
            end
            clk_reset_flag=1'b1;
        end
        else begin
            interval_counter=interval_counter+16'd1;
            clk_reset_flag=1'b0;
        end
        signal_reg=signal;
    end

    always @(posedge clk_200M_global) begin // clock out
        clk_counter=clk_counter+16'd1;
        if(((clk_counter>=(clk_freq/2)) && type_reg==0) || (clk_counter>=clk_freq && type_reg==1)) begin
            clk_counter=16'd0;
            clk_rec=!clk_rec;
        end
        else if(clk_reset_flag==1'b1 && clk_counter<(clk_freq/8)) begin
            clk_counter=16'd0;
        end
        if(key_rev_out==0 && key_rev_reg!=key_rev_out) begin
            clk_rec=!clk_rec;
        end
        key_rev_reg=key_rev_out;
    end
    
    always @(posedge clk_200M_global) begin
        if(key_type_out==0 && key_type_reg!=key_type_out) begin
            type_reg=!type_reg;
        end
        key_type_reg=key_type_out;
    end
        
    assign test_led=type_reg;
        
endmodule