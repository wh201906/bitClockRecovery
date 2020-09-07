module main(
    input clk_50M,
    input signal,
    input key_rev,
    input key_clk_type,
    input key_edge_type,
    
    output reg clk_rec,
    output reg [CLK_LEN-1:0] clk_freq,
    output clk_type_led,
    output edge_type_led
);

    localparam CLK_LEN=32;
    localparam STABLE_LEN=4;
    
    reg signal_reg;
    reg key_clk_type_reg;
    reg clk_type_reg=1'b0;
    reg [1:0] clk_delta=1'b1;
    reg key_edge_type_reg;
    reg edge_type_reg=1'b0;
    
    wire clk_300M;
    wire clk_300M_global;
    wire key_rev_out;
    wire key_clk_type_out;
    wire key_edge_type_out;
    
    reg [CLK_LEN-1:0] interval_counter;
    
    reg clk_reset_flag=1'b0;

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
    
    key keyClkType(
        .clk(clk_50M),
        .key_in(key_clk_type),
        .key_out(key_clk_type_out)
    );
    
    key keyEdgeType(
        .clk(clk_50M),
        .key_in(key_edge_type),
        .key_out(key_edge_type_out)
    );
    
    reg counter_state=4'b0001;
    
    always @(posedge clk_300M_global) begin
        if(signal_reg!=signal && signal==edge_type_reg) begin //edge detected
            if(interval_counter<clk_freq) begin // get the smallest interval
                clk_freq<=interval_counter; // put the smallest interval
                clk_stable_counter<=0; // duration set to 0 since the interval has been updated
                
            end
            else begin // edge, but the interval will not change
                clk_stable_counter<=clk_stable_counter+1; // add duration
            end
            interval_counter<=0;
            if(clk_stable_counter=={STABLE_LEN{1'b1}}) begin // try to add threshold after 16 edges
                clk_freq<=clk_freq+1;
            end
            clk_reset_flag<=1'b1;
        end
        else begin
            if(interval_counter<{CLK_LEN{1'b1}})
                interval_counter<=interval_counter+1;
            clk_reset_flag<=1'b0;
        end
        signal_reg<=signal;
    end

    always @(posedge clk_300M_global) begin // clock out
        clk_counter<=clk_counter+clk_delta;
        if(clk_reset_flag==1'b1) begin
            if(clk_counter<(clk_freq>>3)) begin
                clk_counter<=0;
            end
            else if(clk_counter>=(clk_freq>>3)) begin
                clk_counter<=0;
                clk_rec<=~clk_rec;
            end
        end
        if(clk_counter>=(clk_freq>>1)) begin
            clk_counter<=0;
            clk_rec<=~clk_rec;
        end
        if(key_rev_out==1'b0 && key_rev_reg!=key_rev_out) begin
            clk_rec<=~clk_rec;
        end
        key_rev_reg<=key_rev_out;
    end
    
    always @(posedge clk_300M_global) begin
        if(key_clk_type_out==1'b0 && key_clk_type_reg!=key_clk_type_out) begin
            clk_type_reg<=~clk_type_reg;
        end
        if(clk_type_reg==1'b1)
            clk_delta=2'b1;
        else
            clk_delta=2'd2;
        key_clk_type_reg<=key_clk_type_out;
    end
    
    always @(posedge clk_300M_global) begin
        if(key_edge_type_out==1'b0 && key_edge_type_reg!=key_edge_type_out) begin
            edge_type_reg<=~edge_type_reg;
        end
        key_edge_type_reg<=key_edge_type_out;
    end
        
    assign clk_type_led=clk_type_reg;
    assign edge_type_led=edge_type_reg;
        
endmodule