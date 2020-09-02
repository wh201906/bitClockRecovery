module main (
    input clk_50M,
    input signal,
    output reg clk_rec,
    output reg [15:0] clk_freq
);
    
    wire clk_200M;
    
    reg interval_reg;
    reg [15:0] interval_counter;

    reg [15:0] curr_clk_counter;

    reg [11:0] curr_clk_duration_counter;

    clkGen clkGen( // generate 200Mhz clock as the base clock
        .inclk0(clk_50M),
        .c0(clk_200M)
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
            if(curr_clk_duration_counter==12'hfff) begin // try to add threshold after 4096 edges
                clk_freq=clk_freq+1;
//                curr_clk_duration_counter=0;
            end
        end
        else
            interval_counter=interval_counter+1;
        interval_reg=signal;
    end

    always @(posedge clk_200M) begin // clock out
        curr_clk_counter=curr_clk_counter+1;
        if(curr_clk_counter>=clk_freq) begin
            curr_clk_counter=0;
            clk_rec=!clk_rec;
        end
    end

endmodule