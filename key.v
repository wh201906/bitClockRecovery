module key ( // delay for 50ms
    input clk, //clk at 50Mhz.

    input key_in,
    output reg key_out=1
);
    reg [32:0] counter=0;
    reg last_st=0;

    always @(posedge clk) begin
        if(counter>=32'd15_000_000) begin
//        else if(counter==22'd2_5) begin
            key_out<=last_st;
            counter<=0;
        end
        else if(key_in==last_st)
            counter<=counter+1;
        else
            counter<=0;
		last_st<=key_in;
    end
    
endmodule