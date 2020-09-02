module main (
    input clk_50M,
    input signal,
    input key_reverse,
    
    output reg clk_rec,
    output reg [15:0] clk_freq=16'd801
);
    
    wire clk_200M;
    wire key_rev_out;
    
    reg curr_clk_reset_flag=0;
    reg interval_reg;
    reg [15:0] interval_counter;

    reg [15:0] curr_clk_counter;

    reg [3:0] curr_clk_duration_counter;
    
    reg key_rev_reg=1;

    clkGen clkGen( // generate 200Mhz clock as the base clock
        .inclk0(clk_50M),
        .c0(clk_200M)
	);
    
    key key_rev(
        .clk(clk_50M),
        .key_in(key_reverse),
        .key_out(key_rev_out)
    );
    
    always @(posedge clk_200M) begin
        if(interval_reg!=signal) begin //edge detected
            if(interval_counter<clk_freq) begin // get the smallest interval
                clk_freq=interval_counter; // put the smallest interval
                curr_clk_duration_counter=0; // duration set to 0 since the interval has been updated
            end
            else // edge, but the interval will not change
                curr_clk_duration_counter=curr_clk_duration_counter+1; // add duratino
            interval_counter=0;
            if(curr_clk_duration_counter==4'b1111) begin // try to add threshold after 4096 edges
                clk_freq=clk_freq+1;
            end
            curr_clk_reset_flag=1;
        end
        else begin
            interval_counter=interval_counter+1;
            curr_clk_reset_flag=0;
        end
        interval_reg=signal;
    end

    always @(posedge clk_200M) begin // clock out
        curr_clk_counter=curr_clk_counter+1;
        if(curr_clk_counter>=(clk_freq/2)) begin
            curr_clk_counter=0;
            clk_rec=!clk_rec;
        end
        else if(curr_clk_reset_flag==1 && curr_clk_counter<(clk_freq/8)) begin
            curr_clk_counter=0;
        end
        if(key_rev_out==0 &&key_rev_reg!=key_rev_out) begin
            clk_rec=!clk_rec;
        end
        key_rev_reg=key_rev_out;
    end
endmodule