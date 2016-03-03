b = Buffer.read(s, "/Users/Jildert/Music/Logic/Fred/Audio Files/Fred_5#01.wav");

b.bufnum;


(
SynthDef(\PlayBuf, {
	|startPos=0, amp=1, rate=1, attack=0.1, release=0.1, lpf=10000, pan=0, buf=0|
	var out, env;
	env = EnvGen.kr(Env.perc(attack, release), doneAction: 2);
	out = PlayBuf.ar(1, buf, BufRateScale.kr(1)*rate, startPos: startPos);
	out = LPF.ar(out, lpf);
	out = Pan2.ar(out, pan);
	out = out * env;
	Out.ar(0, out*amp);
}).play(s, [amp: 1, startPos: 0, release: 10, buf:b.bufnum]);
)






(
SynthDef(\PlayPosMod, {
	|startPos=0, amp=1, rate=1, attack=0.1, release=0.1, lpf=10000, pan=0, buf=0, length=1|
	var out, env;
	// env = EnvGen.kr(Env.perc(attack, release), doneAction: 2);
	out = PlayBuf.ar(1, buf, BufRateScale.kr(1)*(Lag.ar(LFPulse.ar(1/length, mul:2*rate, add: -1*rate), 0.001)), startPos: startPos);
	out = LPF.ar(out, lpf);
	out = Pan2.ar(out, pan);
	out = out;
	Out.ar(0, out*amp);
}).play(s, [amp: 1, startPos: b.numFrames.rand, buf:b.bufnum, rate: 1, length: 1]);
)

(
SynthDef(\Gran, {
	|amp=1, dur=0.01, rate=1, freq1=50, freq2=0.01, add=1, freq3=0.1, pan=0, buf=3, mul=1, attack=5, release=5, sustainT=3, reverb=0, lowcut=2000, delay2=0, gate=1 |
	var grain, env, lpf;
	env = EnvGen.kr(Env.adsr(attack, 1, 1, release), gate, doneAction: 2);
	grain = TGrains.ar(2, Impulse.ar(freq1), buf, rate: rate, centerPos: SinOsc.kr(freq2+LFDNoise3.kr(0.1), add:add, mul:mul), dur: dur, pan: pan, amp: amp, interp: 4);
	lpf = LPF.ar(grain*env, lowcut);
	Out.ar(0,lpf*amp);
}).play(s, [buf: b.bufnum, amp: 0.5, add:~startPosistions, mul: 0.001, lowcut: 1000, freq1: 20, dur: 0.2, rate: Scale.minorPentatonic.ratios.choose, freq2: 0.001]);
)

(
{
~startPosistions = [50.9, 17.16, 7.56, 7.3, 8.6].choose;
	4.do({
		Synth(\Gran, [buf: b.bufnum, amp: 0.5, add:~startPosistions, mul: 0.001, lowcut: 1000, freq1: 20, dur: 0.2, rate: Scale.minorPentatonic.ratios.choose*[0.5,1].choose, freq2: 0.001, pan: 1.0.rand-0.5]);
	});
}.play;
)

(// Laag met rate 0.25, en een met 0.5 werkt
t = Task({
	|offset=0, string="empty"|
	inf.do({
		|i|
		[5,10].choose.do({x = Synth(\PlayBuf, [
			buf: b.bufnum,
			pan: 2.0.rand-1,
			amp: [0.4, 0.2, 0.5, 1.0].at(i.mod(3)*2),
			startPos: offset+b.numFrames.exprand(10.0),
			// rate: [0.5, 1, 2, 1.5].choose * [-1,1].choose,
			rate: [0.5,0.5,-1].at(i.mod(3))*1,
			attack: [0.01, 0.02].choose,
			// release: [0.05,0.1,0.5].choose,
			release: [0.1,0.4,0.1, 0.05].at(i.mod(4)),
			lpf: [100,500,2000,100,200,5000].choose])});
		// ([0.1, 0.2].choose/1).wait;
		([0.1, 0.2, 0.05, 0.2].at(i.mod(4))).wait;
		if(i.mod(50)==0){
			"New Offset".postln;
			// offset=b.numFrames.rand;
			offset = [249595, 393946, 499190, 748785].choose / [1].choose;
			offset.postln;
		};
	});
}).play;
)
