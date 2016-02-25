/*
by Jildert Viet 2015
*/

//>>1<<
s.boot;

( //>>2<<
{
	~freqs = [200, 671, 1153, 1723];
	// ~freqs = Array.fill(4, {|i| 200+(i*200)+10.rand});
	// ~freqs = Array.fill(4, {|i| 200+(i*i*200)});
	~amps = [1, 1, 1, 1];
	~ringTimes = [1, 1, 1, 1];
	// ~ringTimes = Array.fill(4, {|i| 0.1+(0.9.rand)});
	Klank.ar(`[~freqs, ~amps, ~ringTimes], PinkNoise.ar([0.007, 0.007]))
}.play;
)

//>>3<<
s.record; // Will write a file @ Music/SuperColliderRecordings/