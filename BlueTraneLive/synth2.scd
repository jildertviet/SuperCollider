~delay = SynthDef(\LiveEffect1, {
	|amp=0, freq=2000, dec=10, ratio = 1|
	var in, out, filter, delay, d2;
	var left, right;
	in = In.ar(~afterFX, 2);
	filter = LPF.ar(in, freq);

	filter = PitchShift.ar(filter, 0.2, 0.5) + filter;

	delay = CombN.ar(filter, 1, [0.1, 0.15]*4, dec, 0.3);
	delay = Lag.ar(
		LFPulse.ar([2,4].choose * ratio),
		lagTime: 0.1,
		mul: 0.5,
		add: 0.25
	)* delay;
	d2 = CombN.ar(filter, 1, [0.1, 0.15]*2, dec, 0.3);
	d2 = Lag.ar(
		LFPulse.ar([2,4,8].choose * ratio),
		lagTime: 0.4,
		mul: 0.5,
		add: 0.25
	)* d2;

	out = (filter*0) + delay + d2;
	Out.ar([0,1], out * amp);
}).play(s, addAction: 'addToTail');