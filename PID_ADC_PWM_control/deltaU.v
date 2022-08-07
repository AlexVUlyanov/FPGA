module deltaU(error,errorPrev,deltaU);

    input signed [15:0] error;
    input signed [15:0] errorPrev;  
    output signed [15:0] deltaU; 
    
 parameter KpKi = 3; 
 parameter KiKp = 1; 
 
assign deltaU = (KpKi * error) + (KiKp * errorPrev); 
  
endmodule
