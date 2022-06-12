module Voltage (
input clk,
input [6:0] PhaseA,
input [6:0] PhaseB,
input [6:0] PhaseC,
input [6:0] Freq,

output [6:0] outPhaseA,
output [6:0] outPhaseB,
output [6:0] outPhaseC
);

reg [6:0]calcVlotagePhaseA = 0;
reg [6:0]calcVlotagePhaseB = 0;
reg [6:0]calcVlotagePhaseC = 0;

reg [6:0]tempA = 0;
reg [6:0]tempB = 0;
reg [6:0]tempC = 0;

reg [6:0]tempFreq = 0;

always @(posedge clk)
begin
	tempA <= PhaseA;
	tempB <= PhaseB;
	tempC <= PhaseC;
	tempFreq <= Freq;
	calcVlotagePhaseA <= (tempA*tempFreq)/50;
	calcVlotagePhaseB <= (tempB*tempFreq)/50;
	calcVlotagePhaseC <= (tempC*tempFreq)/50;
end
	assign outPhaseA = calcVlotagePhaseA;
	assign outPhaseB = calcVlotagePhaseB;
	assign outPhaseC = calcVlotagePhaseC;
	
endmodule 