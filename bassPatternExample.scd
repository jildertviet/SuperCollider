(
SynthDef(\sinPluck, {
	|amp=1, freq=100, a=0.1, r=0.1, ratio=2|
	var env, osc, mod;
	mod = SinOsc.ar(freq*ratio, mul: freq * Line.kr(0.9, 0.1, a*3), add: freq);
	osc = SinOsc.ar(mod);
	env = EnvGen.kr(Env.perc(a, r, curve: -8), doneAction: 2);
	osc = osc + PinkNoise.ar(EnvGen.kr(Env.perc(0.001, 0.01)) * 0.2);
	osc = osc * env;
	Out.ar([0,1], osc * amp);
}).add;

{
	50.do{
		|i|
		x = Synth(\sinPluck, [
			a: [0.1, 0.05, 0.075].wrapAt(i) * (1-(i*0.015)),
			ratio: [0.5, 0.25, 0.5].wrapAt(i) * 1.005,
			r: [0.5, 0.3].wrapAt(i) * 1,
			freq: ([0, -2].wrapAt(i) + 60).midicps, // Don't go too high, I think :/
			amp: [0.4, 0.3, 0.3, 0.4].scramble.wrapAt(i)
		]);
		[0.25, 0.25, 0.5, 0.25, 0.25, 0.25, 0.25].wrapAt(i).wait;
	}
}.fork;
)