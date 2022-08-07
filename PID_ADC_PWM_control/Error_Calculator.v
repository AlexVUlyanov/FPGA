module Error_Calculator(clk,reset_b,adc_in_0,adc_in_1,error);
    input clk; 
    input reset_b; 
    input [15:0] adc_in_0; 
    input [15:0] adc_in_1;
    output reg signed [15:0] error;
    
    
    always @ (posedge clk) 
        begin 
            if (!reset_b)
                error <= 0;  
            else 
                begin 
                error <= adc_in_0 - adc_in_1; 
                end
        end 
              
endmodule
