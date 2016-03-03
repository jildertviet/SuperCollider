( // One block
~paths = [
"/Users/Jildert/Music/Logic/Fred2/Bounces/Klarinet/1.aif",
"/Users/Jildert/Music/Logic/Fred2/Bounces/Klarinet/2.aif",
"/Users/Jildert/Music/Logic/Fred2/Bounces/Klarinet/3.aif",
"/Users/Jildert/Music/Logic/Fred2/Bounces/Klarinet/4.aif",
"/Users/Jildert/Music/Logic/Fred2/Bounces/Klarinet/5.aif",
"/Users/Jildert/Music/Logic/Fred2/Bounces/Klarinet/6.aif",
"/Users/Jildert/Music/Logic/Fred2/Bounces/Klarinet/7.aif",
"/Users/Jildert/Music/Logic/Fred2/Bounces/Klarinet/8.aif"
];
// ~klarinet = Array.fill(~paths.size, { arg i; Buffer.readChannel(s, ~paths[i], channels: [0]) });
~klarinet = Array.fill(~paths.size, { arg i; Buffer.read(s, ~paths[i])});
)

~klarinet[0].numChannels;

(
SynthDef(\PlayBufLinen, {
	|startPos=0, amp=1, rate=1, attack=1, release=1, lpf=10000, pan=0, buf=0, sustain=1|
	var out, env;
	env = EnvGen.kr(Env.linen(attack, sustain, release), doneAction: 2);
	out = PlayBuf.ar(1, buf, BufRateScale.kr(1)*rate, startPos: startPos);
	out = LPF.ar(out, lpf);
	out = Pan2.ar(out, pan);
	out = out * env;
	Out.ar(0, out*amp);
}).play(s, [amp: 1, startPos: 0, release: 10, buf:~klarinet[1].bufnum]);
)


(
2.do({
t = Task({
	|offset=0, string="empty"|
	var sequence = Array.series(~klarinet.size, 0, 1).stutter(2).scramble;
	var amps = Array.fill(~klarinet.size, {exprand(0.001, 1)});
	var startPos = Array.fill(~klarinet.size, {|i| ~klarinet[i].numFrames * [0.125, 0.25, 0.5, 0.75].choose});
	var rhythm = Array.fill(~klarinet.size, {|i| [0.1, 0.2, 0.05, 0.5].choose});
	var pans = Array.fill(~klarinet.size, {1.0.rand-0.5});
	var attack = [0.1, 0.01].choose; var release = [0.1, 0.01].choose;
	var rate = [0.5, 1].choose;
	inf.do({
		|i|
		var index = i.mod(~klarinet.size);
		1.do({
		x = Synth(\PlayBufLinen, [buf: ~klarinet[sequence[index]].bufnum,
		// x = Synth(\PlayBufLinen, [buf: ~klarinet[~klarinet.size.exprand(2.0).asInt].bufnum,
		amp: amps[index],
		startPos: startPos[index],
		attack: attack,
		release: release,
		pan: pans[index],
		rate: rate,
		sustain: 0.1]);
		});
		rhythm[index].wait;
	});
}).play;
});
)

s.record;


exprand(0.01, 1);
Random