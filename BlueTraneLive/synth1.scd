/*~live1 = SynthDef(\tonalGrooveProcessing, {
	|amp=1, q=1, freq=500, mix=0.5|
	var in, out, allP, bpf;
	in = In.ar(~tonalGrooveBus, 2);
	allP = AllpassL.ar(in, maxdelaytime: 0.2, delaytime: [0.2,0.3].choose, decaytime: 2);
	bpf = BPF.ar(allP, freq, q, mix) + (allP*(1-mix));
	out = bpf;
	Out.ar([0,1], out);
}).add;*/