(
ServerOptions.outDevices;
// Set this to the right output
s.options.device = "Scarlett 2i4 USB";
s.options.sampleRate = 48000;
o = Server.local.options;
o.memSize = 8192*10;
b = Buffer.read(s, "/Users/Jildert/Music/Jildert/Samples/Regular/Nature Samples/170657__omar-alvarado__atthetree.wav");

~tonalGrooveAmpBus = Bus.alloc(\control);
~granAmpBus = Bus.alloc(\control);
~tonalGrooveRateBus = Bus.alloc(\control);
~controlRateTonalGroove.value(1);
~controlVolumeTonalGroove.value(1);
~controlVolumeGran.value(1);

SynthDef(\PlayBuf, {
	|startPos=0, amp=1, rate=1, attack=0.1, release=0.1, lpf=10000, pan=0, buf=0, ampBus=1, rateBus=1|
	var out, env;
	env = EnvGen.kr(Env.perc(attack, release), doneAction: 2);
	out = PlayBuf.ar(1, buf, BufRateScale.kr(1)*rate*rateBus, startPos: startPos);
	out = LPF.ar(out, lpf);
	out = Pan2.ar(out, pan);
	out = out * env;
	Out.ar(0, out*amp*ampBus);
}).play(s, [amp: 1, startPos: 0, release: 0.1, buf:b.bufnum]);

~startPosistions = [50.9, 17.16, 7.56, 7.3, 8.6].choose;
SynthDef(\Gran, {
	|amp=1, dur=0.01, rate=1, freq1=50, freq2=0.01, add=1, freq3=0.1, pan=0, buf=3, mul=1, attack=5, release=5, sustainT=3, reverb=0, lowcut=2000, delay2=0, gate=1, amp2 = 1 |
	var grain, gr2, gr3, env, lpf;
	env = EnvGen.kr(Env.adsr(attack, 1, 1, release), gate, doneAction: 2);
	grain = TGrains.ar(2, Impulse.ar(freq1), buf, rate: rate*Scale.minorPentatonic.ratios.choose, centerPos: SinOsc.kr(freq2+LFDNoise3.kr(0.1), add:add, mul:mul), dur: dur, pan: 2.0.rand-1, amp: amp, interp: 4);
	gr2 = TGrains.ar(2, Impulse.ar(freq1), buf, rate: rate*Scale.minorPentatonic.ratios.choose, centerPos: SinOsc.kr(freq2+LFDNoise3.kr(0.1), add:add, mul:mul), dur: dur, pan: 2.0.rand-1, amp: amp, interp: 4);
	gr3 = TGrains.ar(2, Impulse.ar(freq1), buf, rate: rate*Scale.minorPentatonic.ratios.choose, centerPos: SinOsc.kr(freq2+LFDNoise3.kr(0.1), add:add, mul:mul), dur: dur, pan: 2.0.rand-1, amp: amp, interp: 4);
	grain = grain + gr2 + gr3;
	lpf = LPF.ar(grain*env, lowcut);
	Out.ar(0,lpf*amp2);
	}).add;
// }).play(s, [buf: b.bufnum, amp: 1, add:~startPosistions, mul: 0.001, lowcut: 1000, freq1: 20, dur: 0.2, rate: 1, freq2: 0.001]);

~doGranScape = {|note="c", bufnum=0|
	var index = ["c", "db", "d", "eb", "e", "f", "gb", "g", "ab", "a", "bb", "b"].detectIndex({ arg item, i; item == note });
	"Start Gran Scape".postln;
	~stopGranScape.value();
	~randomIndex = ~addTemp.size.rand;
	~addTemp = [50.9, 17.16, 7.56, 7.3, 8.6];
	~ratesTemp = 0.5*[ 0.92971907371625, 1.0435743758353, 0.92971907371625, 0.87753795169115, 0.87753795169115 ]*Scale.chromatic.ratios.at(index%12); // Vanaf C
	~scape = Synth(\Gran, [buf: bufnum, amp2: ~granAmpBus.asMap, add:~addTemp[~randomIndex], mul: 0.001, lowcut: 1000, freq1: 20, dur: 0.2, rate: ~ratesTemp[~randomIndex], freq2: 0.001]);
};

~stopGranScape = {"Stop Gran Scape".postln; if(~scape!=nil){~scape.set(\gate, 0);}};

// Laag met rate 0.25, en een met 0.5 werkt
~tonalGrooveAmp = 0.1;
~doTonalGroove = {|bufnum=0|
	"Start Tonal Groove".postln;
	~tonalGroove.stop;
	~tonalGroove.reset;
	~tonalGroove = Task({
	var offset = 0;
	inf.do({
		|i|
		[5,10].choose.do({x = Synth(\PlayBuf, [
			buf: bufnum,
			pan: 2.0.rand-1,
			amp: ([0.4, 0.2, 0.5, 1.0].at(i.mod(3))*2),
			ampBus: ~tonalGrooveAmpBus.asMap,
			rateBus: ~tonalGrooveRateBus.asMap,
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
};
~stopTonalGroove = {"Stop Tonal Groove".postln; ~tonalGroove.stop;};
~controlVolumeTonalGroove = {|value| ~tonalGrooveAmpBus.set(value)};
~controlVolumeGran = {|value| ~granAmpBus.set(value)};
~controlRateTonalGroove = {|value| ~tonalGrooveRateBus.set(value)};

~recBuf = Array.fill(2, {Buffer.alloc(s, (s.sampleRate)*4, 1)};);

~recordToBuf = {|bufIndex=0, inChan=1|
	"Recording".postln;
	~recBuf[bufIndex].bufnum.postln;
	{
	RecordBuf.ar(AudioIn.ar(inChan), ~recBuf[bufIndex].bufnum, loop: 0);
	0.0; // silent
	}.play;
}
)

~recordToBuf.value(0, 1);
~recBuf[0].play;
