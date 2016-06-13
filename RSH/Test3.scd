(

~lowGrooveBuf = Buffer.read(s, "/Users/Jildert/Music/Jildert/Samples/Regular/Nature Samples/21888__anton__drip-kraan-els.wav");
~lowGrooveAmpBus = Bus.alloc(\control);
~lowGrooveRateBus = Bus.alloc(\control);
~loop2AmpBus = Bus.alloc(\control);
~loopAmpBus = Bus.alloc(\control);

~controlVolumeLoop.value(1);
~controlVolumeLoop2.value(1);

~controlVolumeLowGroove.value(1);
~controlRateLowGroove.value(1);

4.do({
SynthDef(\Jildert, {
	|amp=1, pulseFreq=1, pulsePhase=0, pulseWidth=0.5, bufnum=0, rate=1, startPos=0, lagTime=0.0000001, delayTime=0.1, ampBus=0|
	var pulse, pulse2, pulse3, sample, echo, echo2, echo3, output;
	pulse = LFPulse.kr(pulseFreq, pulsePhase, pulseWidth);
	pulse = Lag.kr(pulse, lagTime);
	pulse2 = pulse = LFPulse.kr(pulseFreq*1.5, pulsePhase, pulseWidth*1.125);
	pulse2 = Lag.kr(pulse2, lagTime);
	pulse3 = LFPulse.kr(pulseFreq, pulsePhase+0.25, pulseWidth);
	pulse3 = Lag.kr(pulse3, lagTime);
	sample = PlayBuf.ar(1, bufnum, rate, startPos: startPos, loop: 1);
	echo = DelayL.ar(sample*pulse, 1, delayTime);
	echo2 = DelayL.ar(sample*pulse2, 1, delayTime*1.25);
	echo3 = echo2 * Lag.kr(LFPulse.kr(1, 0, 0.01), 0.1);
	echo3 = CombL.ar(echo3, 1, 0.1, 5.0);
	echo3 = Pan2.ar(echo3, LFTri.kr(0.5));
	sample = sample*pulse3;
	output = ([echo, echo2]+[sample, sample]+echo3);
	output = Decay.ar(output, 0.0005);
	Out.ar(0, output*amp*ampBus);
}).add;/*play(s, [bufnum: ~lowGrooveBuf.bufnum, pulseFreq: [3, 2, 4].choose, lagTime: 0.05, rate:[1].choose, pulseWidth: [0.01, 0.0075].choose*10, pulsePhase: [0.25, 0.5, 0.75].choose]);*/
});

SynthDef(\Jildert2, {
	|amp=1, pulseFreq=1, pulsePhase=0, pulseWidth=0.5, bufnum=0, rate=1, startPos=0, lagTime=0.0000001, delayTime=0.1, attack=0.0001, release=1, gate=1, ampBus=1, rateBus=1|
	var pulse, pulse2, pulse3, sample, echo, echo2, echo3, output, rateMod, env;
	rateMod = 1 + Lag.kr(LFPulse.kr(1, width: 0.5, mul: LFPulse.kr(2, width:0.25, mul:0.25), add: 0.25), 0.0001) * Lag.kr(LFPulse.kr(1, 0.5, 0.25, [1.5,2].choose, 1), 0.001);
	pulse = LFPulse.kr(pulseFreq, pulsePhase, pulseWidth);
	pulse = Lag.kr(pulse, lagTime);
	pulse2 = pulse = LFPulse.kr(pulseFreq*1.5, pulsePhase, pulseWidth*1.125);
	pulse2 = Lag.kr(pulse2, lagTime);
	pulse3 = LFPulse.kr(pulseFreq, pulsePhase+0.25, pulseWidth);
	pulse3 = Lag.kr(pulse3, lagTime);
	// sample = BufRd.ar(1, bufnum, Phasor.ar(0, 1, 0, BufDur.ir(bufnum))); // Dit klinkt best cool
	// sample = BufRd.ar(1, bufnum, Phasor.ar(0, (0.5+LFPulse.ar(10, 0, 0.25, 0.5)*rateBus), 0, BufDur.ir(bufnum)*(s.sampleRate)/1000));
	sample = BufRd.ar(1, bufnum, Phasor.ar(0, (0.5+
		LFPulse.ar([2,5,10].choose, 0,
			LFPulse.ar([1,2,3].choose, 0, [0.25, 0.125, 0.5].choose, 0.25, 0.25)
			, 0.5))
		, 0, 100000));
	echo = DelayL.ar(sample*pulse, 1, delayTime);
	echo2 = DelayL.ar(sample*pulse2, 1, delayTime*1.25);
	echo3 = echo2 * Lag.kr(LFPulse.kr(1, 0, 0.01), 0.1);
	echo3 = CombL.ar(echo3, 1, 0.1, 5.0);
	echo3 = Pan2.ar(echo3, LFTri.kr(0.5));
	sample = sample*pulse3;
	output = ([echo, echo2]+[sample, sample]+echo3);
	output = Decay.ar(output, 0.0005);
	env = EnvGen.kr(Env.adsr(attack, 0.01, 1.0, release), gate, doneAction: 2);
	Out.ar(0, output*env*amp*ampBus);
}).add;

~doLowGroove = {|bufnum=0|
	~stopLowGroove.value(0.1);
	~lowGroove = Synth(\Jildert2, [bufnum: bufnum, pulseFreq: [3, 2, 4].choose, lagTime: 0.05, rate:[1].choose, pulseWidth: [0.01, 0.0075].choose*10, pulsePhase: [0.25, 0.5, 0.75].choose, release: 3, ampBus: ~lowGrooveAmpBus.asMap, rateBus: ~lowGrooveRateBus.asMap])};

~stopLowGroove = {|release=3| if(~lowGroove!=nil){~lowGroove.set(\release, release); ~lowGroove.set(\gate, 0)}};
~controlVolumeLowGroove = {|value| ~lowGrooveAmpBus.set(value)};
~controlRateLowGroove = {|value| ~lowGrooveRateBus.set(value)};

// RECORD LOOPS

~loop = {
	|duration=10, delayT=5, inChan=1, bus=1|
	var time = Date.getDate.bootSeconds;
	~loopSynth = SynthDef(\loopSynth, {
	|delayT = 0.2, dur=10, chan=1, recordDur = 1, gate=1, time=1, amp=1|
	var echo, env, input;
		input = HPF.ar(AudioIn.ar(chan), 200) * EnvGen.kr(Env.adsr(0.3, 0.0001, 1.0, 0.3), gate);
	env = EnvGen.kr(Env.linen(0.00001, 0.5*dur, 0.5*dur), doneAction: 2);
	echo = CombL.ar(input, 5, delayT, 100) * env;
	Out.ar([0,1], echo*amp);
	}).play(s, [delayT: delayT, time: time, dur: duration, chan: inChan, amp: bus.asMap]);
};

~setLoopDuration = {
	(
	~loopSynth.set(\gate, 0);
	~loopSynth.get(\time, { |val| ~loopSynth.set(\delayT, (Date.getDate.bootSeconds)-val);});
	)
};

~controlVolumeLoop = { |value| ~loopAmpBus.set(value)};
~controlVolumeLoop2 = { |value| ~loop2AmpBus.set(value)};

)

s.record;
s.stopRecording;