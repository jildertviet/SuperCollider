(
"Exec synthDefs.sc".postln;
~synthNames = ["\Kay", "\FM", "\AM", "\BPad", "\sine2", "\sine3", "\sine4"];

~synthBus = Bus.alloc('audio', s, 2);
~master = Bus.alloc('audio', s, 2);


~masterBusHandler = {
	|amp = 1, freq=1000, lfoFreq = 1, lfoDepth = 0.5|
	var lfo;
	var lpf = LPF.ar(In.ar(~master, 2), freq);
	lpf = Limiter.ar(lpf, 0.9, 0.01);
	lfo = 1 - (SinOsc.ar(lfoFreq, 0, lfoDepth, 0).abs);
	lpf = lpf * lfo;
	Out.ar([0,1], lpf * amp);
}.play;


~synthBusHandler = {
	|amp = 1|
	var in;
	in = In.ar(~synthBus, 2);
	in = Limiter.ar(in, 0.9, 0.01);
	Out.ar(~master, in * amp);
}.play;




SynthDef(\Kay, {
	|amp = 1, freq = 100, gate=1, release=0.5, attack=0.1, decay=1.8, sustain=0.4, tremoloDepth=0.2, tremoloRate=5|

	var saw, filter, envelope, sawsub, tremolo;
	saw = Saw.ar(
		freq + LFDNoise1.kr(freq/2000, freq/150);
	);
	saw = saw + Saw.ar(
		freq + LFDNoise1.kr(freq/2000, freq/150
		);
	);

	saw = saw + Saw.ar(
		freq/2 + LFDNoise1.kr(freq/2000, freq/150
		);
	);

	saw = saw + Saw.ar(
		freq/2 + LFDNoise1.kr(freq/2000, freq/150
		);
	);

	saw = saw * 0.5;







	sawsub = Saw.ar(
		freq/2 + LFDNoise1.kr(1, freq/2000), 0.2);
	// sawsub = BPF.ar(sawsub, freq/1.9, 0.01, 50);
	sawsub = HPF.ar(sawsub, freq);
	saw = saw * 0.4;
	saw = saw + sawsub;

	tremolo = 1 - SinOsc.ar(tremoloRate, 0, tremoloDepth).abs;
	saw = saw * tremolo;
	// saw = sawsub;
	filter = LPF.ar(saw, freq*5);
	envelope = Env.adsr(attack, decay, sustain, release);
	envelope = EnvGen.kr(envelope, gate, doneAction: 2);
	Out.ar(~synthBus, filter * amp * envelope);
}).add;

SynthDef(\FM, {
	|
	amp=0.1, gate=1, freq=100,
	attack = 0.01, release = 1, sustain = 0.1, decay=1,
	rq=0.01
	|
	var osc1, env, envGen;
	var osc2;
	var mix;
	osc1 = BPF.ar(
		WhiteNoise.ar(1),
		EnvGen.kr(Env.adsr(attack/2, decay, 1, release*8, curve: [4,4,10]), gate: gate, levelBias: freq/2, levelScale: freq)
		+ LFDNoise1.kr(0.1, freq/100)
		,
		rq,
		6
	);

	osc2 = LPF.ar(
		Saw.ar(freq, 0.1),
		freq*2,
		EnvGen.kr(Env.perc(attack, 3))
	);
	env = Env.adsr(attack, decay, sustain, release, curve: [
		4, -4, 4
	]
	);
	envGen = EnvGen.kr(env, gate, doneAction: 2);
	mix = osc1 + osc2;
	mix = mix * amp * envGen;
	Out.ar(~synthBus, mix);
}).add;

SynthDef(\AM, {
	|amp=1, freq=100, attack=0.01, decay=1, sustain=0.7, release=1, gate=1|
	var osc, env, osc2, env2;
	osc = SinOsc.ar(freq);
	osc2 = Saw.ar(freq*0.5+LFDNoise1.kr(0.1, 0.005));
	osc2 = osc2*0.5 + Saw.ar(freq*0.5+LFDNoise1.kr(0.1, 0.005)) * 0.5;
	env = Env.adsr(attack, decay, sustain, release);
	env = EnvGen.kr(env, gate, doneAction: 2);

	env2 = Env.adsr(attack*amp.linlin(0, 1, 300, 50), 1, 1, release);
	env2 = EnvGen.kr(env2, gate, freq*10, freq);

	osc = osc * osc2;
	osc = LPF.ar(osc, env2);
	osc = osc * env;
	Out.ar(~synthBus, osc * amp);
}).add;

SynthDef(\BPad, {
	|freq = 100, amp = 1, pulseFreq=0.1, out = #[0,1], pulseModOffset = 0, gate=1|
	var width = LFSaw.kr(pulseFreq, pulseModOffset);
	var pulse = Pulse.ar(freq, width);
	var env = EnvGen.kr(Env.adsr(0.1, 2, 0.7, 2), gate, doneAction: 2);
	// pulse = Lag.ar(pulse, 0.01);
	pulse = Resonz.ar(pulse, 1000);
	pulse = pulse * SinOsc.ar(freq);
	pulse = HPF.ar(pulse, 400);
	pulse = pulse + Saw.ar(freq, 0.2);
	pulse = LPF.ar(pulse, freq*2);
	Out.ar(~synthBus, pulse*amp*env*1.1);
}).add;

SynthDef(\sine2, {arg freq = 100, amp = 0.2, gate = 1;
	var freqMod, snd, env, arp;
	freqMod = {freq * LFNoise2.kr(1,0.02,1)}!24;
	env = EnvGen.kr(Env.asr(0.5, 1, 2.5), gate, doneAction: 2);
	snd = SinOsc.ar(freq: Lag.kr(freqMod), mul: amp) * 0.1;
	arp = Blip.ar(freq: freqMod, numharm: Line.kr(1, 50, Rand(20, 40)), mul: 0.04);
	snd = (snd + arp) * env;
	Out.ar(~synthBus, snd);
}).add;

SynthDef(\sine3, {arg freq = 60, amp = 0.2, gate = 1;
	var freqMod, snd, env, arp, harms;
	freqMod = {freq * LFNoise2.kr(1,0.02,1)}!24;
	env = EnvGen.kr(Env.asr(0.5, 1, 1), gate, doneAction: 2);
	snd = SinOsc.ar(freq: Lag.kr(freqMod), mul: amp) * 0.1;

	harms = 10;
	arp = Blip.ar(freq: freqMod, numharm: harms, mul: 0.06);
	snd = (snd + arp) * env;
	Out.ar(~synthBus, snd);
}).add;

SynthDef(\sine4, {arg freq = 60, amp = 0.2, gate = 1;
	var freqM, snd, env, ffreq;
	freqM = {freq * LFNoise2.kr(1,0.02,1)}!24;
	env = EnvGen.kr(Env.asr(0.01, 1, 2), gate, doneAction: 2);
	snd = Saw.ar(freq: Lag.kr(freqM), mul: amp) * 0.5;
	ffreq = Lag.kr((2000 * 2 + (freq * 1.5)), 1);
	snd = LPF.ar(in: snd, freq: freqM);
	snd = snd * env;
	snd = Limiter.ar(snd, 0.96, 0.01);
	Out.ar(~synthBus, snd * 0.8);
}).add;
)