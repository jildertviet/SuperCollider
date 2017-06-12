~lowGrooveBuf = Buffer.alloc(s, 44100*10, 2);
{RecordBuf.ar([SoundIn.ar(0),SoundIn.ar(1)], ~lowGrooveBuf.bufnum, loop: 0, doneAction: 2)}.play;

~lowGrooveBuf.play;


~live1.free; ~live2.free;
~live1.set(\q, 0.4, \freq, 700, \mix, 1);
(
~live1 = SynthDef(\tonalGrooveProcessing, {
	|amp=1, q=1, freq=500, mix=0.5|
	var in, out, allP, bpf;
	in = In.ar(~tonalGrooveBus, 2);
	allP = AllpassL.ar(in, maxdelaytime: 0.2, delaytime: [0.2,0.3].choose, decaytime: 2);
	bpf = BPF.ar(allP, freq, q, mix) + (allP*(1-mix));
	out = bpf;
	Out.ar([0,1], out);
}).play(s, [amp:1]);

~live2 = SynthDef(\LiveEffect, {
	|amp=1, freq=2000, dec=10|
	var in, out, filter, delay, d2;
	var left, right;
	left = SoundIn.ar(0);
	right = SoundIn.ar(1);
	in = Mix.ar([left,right]);
	filter = LPF.ar(in, freq);

	filter = PitchShift.ar(filter, 0.2, 0.5) + filter;

	delay = CombN.ar(filter, 1, [0.1, 0.15]*4, dec, 0.3);
	delay = Lag.ar(
		LFPulse.ar([2,4].choose,),
		lagTime: 0.1,
		mul: 0.5,
		add: 0.25
	)* delay;
	d2 = CombN.ar(filter, 1, [0.1, 0.15]*2, dec, 0.3);
	d2 = Lag.ar(
		LFPulse.ar([2,4,8].choose),
		lagTime: 0.4,
		mul: 0.5,
		add: 0.25
	)* d2;

	out = filter + delay + d2;
	Out.ar([0,1], out);
}).add;


~buf = Buffer.alloc(s, 44100*2, 2);
~live3 = SynthDef(\LiveEffect, {
	|amp=1, freq=2000, dec=10, mix=0.2|
	var in, out, filter, delay, d2, a, b, c;
	var left, right;
	left = SoundIn.ar(0);
	right = SoundIn.ar(1);
	out = Mix.ar([left, right]);
	// a = RecordBuf.ar([left, right], ~buf);
	~rate = 4;
	a = BufWr.ar(out, ~buf.bufnum, Phasor.ar(1, ~rate, 0, BufFrames.kr(~buf.bufnum)));
	b = BufRd.ar(2, ~buf.bufnum, Phasor.ar(Impulse.kr(10), ~rate, 0.1 * BufFrames.kr(~buf.bufnum), 1.1 * BufFrames.kr(~buf.bufnum),
		Phasor.ar(1, ~rate, 0, 1).round(0.1) * BufFrames.kr(~buf.bufnum)
	));

	// b = PlayBuf.ar(2, ~buf.bufnum, 1, Impulse.ar(1), 500);
	b = b * EnvGen.kr(Env.perc(0.05, 0.05), Impulse.kr(5));
	out = LPF.ar(out, freq);
	b = (out*mix) + b *(1-mix);
	Out.ar([0,1], b);
}).play(s, [dec: 1]);

)


~buf.play;

