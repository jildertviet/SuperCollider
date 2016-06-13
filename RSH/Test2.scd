( // One block
~paths = [
"/Users/Jildert/Desktop/PlayfullArtsFestival/Sounds/Laser_samples_acoustic/1.aif",
"/Users/Jildert/Desktop/PlayfullArtsFestival/Sounds/Laser_samples_acoustic/2.aif",
"/Users/Jildert/Desktop/PlayfullArtsFestival/Sounds/Laser_samples_acoustic/3.aif",
"/Users/Jildert/Desktop/PlayfullArtsFestival/Sounds/Laser_samples_acoustic/4.aif",
"/Users/Jildert/Desktop/PlayfullArtsFestival/Sounds/Laser_samples_acoustic/5.aif",
"/Users/Jildert/Desktop/PlayfullArtsFestival/Sounds/Laser_samples_acoustic/6.aif",
"/Users/Jildert/Desktop/PlayfullArtsFestival/Sounds/Laser_samples_acoustic/7.aif",
"/Users/Jildert/Desktop/PlayfullArtsFestival/Sounds/Laser_samples_acoustic/8.aif"
];
// ~klarinet = Array.fill(~paths.size, { arg i; Buffer.readChannel(s, ~paths[i], channels: [0]) });
~klarinet = Array.fill(~paths.size, { arg i; Buffer.read(s, ~paths[i])});
~clarinetAmpBus = Bus.alloc(\control);
~clarinetRateBus = Bus.alloc(\control);
~controlVolumeClarinet.value(1);
~controlRateClarinet.value(1);

SynthDef(\PlayBufLinen, {
	|startPos=0, amp=1, rate=1, attack=1, release=1, lpf=10000, pan=0, buf=0, sustain=1, ampBus=1, rateBus=1|
	var out, env;
	env = EnvGen.kr(Env.linen(attack, sustain, release), doneAction: 2);
	out = PlayBuf.ar(1, buf, BufRateScale.kr(1)*(rate), startPos: startPos);
	out = LPF.ar(out, lpf);
	out = Pan2.ar(out, pan);
	out = out * env;
	Out.ar(0, out*amp*ampBus);
}).play(s, [amp: 1, startPos: 0, attack: 0.0001, sustain: 0.0001, release: 0.1, buf:~klarinet[1].bufnum]);

~clarinetTasks = [0,1];
~clarinetTasks.size.do({|i|
	~clarinetTasks[i] = Task({
	|offset=0, string="empty"|
	var sequence = Array.series(~klarinet.size, 0, 1).stutter(2).scramble;
	var amps = Array.fill(~klarinet.size, {exprand(0.001, 1)}+0.2);
	var startPos = Array.fill(~klarinet.size, {|i| ~klarinet[i].numFrames * [0.125, 0.25, 0.5, 0.75].choose});
	var rhythm = Array.fill(~klarinet.size, {|i| [0.1, 0.2, 0.05, 0.5].choose});
	var pans = Array.fill(~klarinet.size, {1.0.rand-0.5});
	var attack = [0.1, 0.01].choose; var release = [0.1, 0.01].choose;
	var rate = [0.5, 1].choose*1;
	var lpf = [500,20000].choose;
	inf.do({
		|i|
		var index = i.mod(~klarinet.size);
		1.do({
		x = Synth(\PlayBufLinen, [buf: ~klarinet[sequence[index]].bufnum,
		// x = Synth(\PlayBufLinen, [buf: ~klarinet[~klarinet.size.exprand(2.0).asInt].bufnum,
		amp: amps[index],
		ampBus: ~clarinetAmpBus.asMap,
		rateBus: ~clarinetRateBus.asMap,
		startPos: startPos[index],
		attack: attack,
		release: release,
		pan: pans[index],
		rate: rate,
		lpf: lpf,
		sustain: 0.1]);
		});
		rhythm[index].wait;
	});
});
});
~doClarinetGroove = {~clarinetTasks.size.do({|i|
	~clarinetTasks[i].stop;
	~clarinetTasks[i].reset;
	~clarinetTasks[i].play;

})};
~stopClarinetGroove = {~clarinetTasks.size.do({|i|
	~clarinetTasks[i].stop;
})};
~controlVolumeClarinet = {|value| ~clarinetAmpBus.set(value)};
~controlRateClarinet = {|value| ~clarinetRateBus.set(value)};
)

s.record;
s.stopRecording;