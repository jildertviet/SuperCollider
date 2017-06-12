~buf = Buffer.alloc(s, 44100*2, 2);
~live3 = SynthDef(\LiveEffect, {
	|amp=0, freq=2000, dec=10, mix=1, ratio=1|
	var in, out, filter, delay, d2, a, b, c;
	var left, right;
	out = In.ar(~afterFX, 2);
	out = Compander.ar(out, out,
        thresh: 0.1,
        slopeBelow: 1,
        slopeAbove: 0.5,
        clampTime: 0.01,
        relaxTime: 1
    );
	// a = RecordBuf.ar([left, right], ~buf);
	~rate = 4;
	a = BufWr.ar(out, ~buf.bufnum, Phasor.ar(1, ~rate, 0, BufFrames.kr(~buf.bufnum)));
	b = BufRd.ar(2, ~buf.bufnum, Phasor.ar(Impulse.kr(10), ~rate, 0.1 * BufFrames.kr(~buf.bufnum), 1.1 * BufFrames.kr(~buf.bufnum),
		Phasor.ar(1, ~rate, 0, 1).round(0.1) * BufFrames.kr(~buf.bufnum)
	));

	// b = PlayBuf.ar(2, ~buf.bufnum, 1, Impulse.ar(1), 500);
	b = b * EnvGen.kr(Env.perc(0.05, 0.05), Impulse.kr(5));
	out = LPF.ar(out, freq);
	// b = (out*mix) + b *(1-mix);
	Out.ar([0,1], b * amp);
}).play(s, addAction: 'addToTail');
