module main(
    input clk_50M,
    input signal,
    input key_rev,
    input key_type,
    
    output reg clk_rec,
    output reg [CLK_LEN-1:0] clk_freq=801,
    output test_led
);
    localparam CLK_LEN=32;
    localparam STABLE_LEN=8;
    
    reg signal_reg;
    reg key_type_reg;
    reg type_reg=1'b0;
    
    wire clk_300M;
    wire clk_300M_global;
    wire key_rev_out;
    wire key_type_out;
    
    reg [CLK_LEN-1:0] interval_counter;

    reg [CLK_LEN-1:0] clk_counter;

    reg [STABLE_LEN-1:0] clk_stable_counter;
    
    reg key_rev_reg=1'b1;

    clkGen clkGen( // generate 300Mhz clock as the base clock
        .inclk0(clk_50M),
        .c0(clk_300M)
	);
    
    globalClock u0 (
        .inclk  (clk_300M),
        .outclk (clk_300M_global)
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
    
    always @(posedge clk_300M_global) begin
        if(signal_reg!=signal) begin //edge detected
            if(interval_counter<clk_freq) begin // get the smallest interval
                clk_freq=interval_counter; // put the smallest interval
                clk_stable_counter=4'd0; // duration set to 0 since the interval has been updated
            end
            else begin // edge, but the interval will not change
                clk_stable_counter++; // add duration
            end
            interval_counter=0;
            if(clk_stable_counter=={STABLE_LEN{1'b1}}) begin // try to add threshold after 16 edges
                clk_freq++;
            end
            clk_counter=0;
        end
        else begin
            if(interval_counter<{CLK_LEN{1'b1}})
                interval_counter++;
        end
        signal_reg=signal;
        
        clk_counter++;
        if(((clk_counter>=(clk_freq>>1)) && type_reg==1'b0) || (clk_counter>=clk_freq && type_reg==1'b1)) begin
            clk_counter=0;
            clk_rec=~clk_rec;
        end
        else if(clk_counter<(clk_freq>>3)) begin
            clk_counter=0;
        end
        
        if(key_rev_out==1'b0 && key_rev_reg!=key_rev_out) begin
            clk_rec=~clk_rec;
        end
        key_rev_reg=key_rev_out;
    end
    
    always @(posedge clk_300M_global) begin
        if(key_type_out==1'b0 && key_type_reg!=key_type_out) begin
            type_reg=~type_reg;
        end
        key_type_reg=key_type_out;
    end
        
    assign test_led=type_reg;
        
endmodule