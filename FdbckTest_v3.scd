// Chapter, runtime, fft-freq naar OF

// 1.)
ServerOptions.outDevices;

// 2.)
s.options.device = "Saffire";

// 3.)
s.boot;

// 5.)
~composition.play;

( // 4.)
thisProcess.openUDPPort(6060);// OF
n = NetAddr("127.0.0.1", 6060); // local machine

~ampMax = Bus.control(s, 1);
~ampMax.set(1.0);
~amp = Bus.control(s, 1);  // To store the receiver speaker-amp
~amp.set(0);

b = OSCdef(\Jildert, {|msg| // Receive from Lemur (GUI-app)
	msg.postln;
}, '/toSC', recvPort: 8080);
c = OSCdef(\Jildert, {|msg| // Receive from OF
	// msg.postln;

	var flux = msg[1];
	var brightness = msg[2];
	var amp = msg[3];
	var state = msg[4];

	~ampMax.get({|val| amp = amp.linlin(0.0, 1.0, 0.0, val)}); // Scale
	amp.postln;

	~amp.set(amp);

	// b.sendMsg(""); Send
}, '/fromOF', recvPort: 6060);

// ---------------------------------------------------------------------- SOUND ---------------------------------------------------------------------------
// Bus to store the added (3x) multiepliedfeedback synths
~mfBus = Bus.audio(s);
// Synth to analyze the MF and drive the base sine oscillator
SynthDef(\FFTAnalyse, {
	|out, amp=1, attack=1, gate=1, ampMax=1|
	var in, fft, buf, sin, env;
	buf = LocalBuf(1024);
	in = In.ar(~mfBus);
	fft = FFT(buf, in);
	// fft = FFTPeak.kr(buf, 20, 50000)[0];
	fft = FFTCentroid.kr(buf);
	// fft = Lag.kr(fft, 20).poll;
	fft = (RunningSum.kr(fft, 690)/690);
	fft = LinLin.kr(fft, 20, 3000, 20, 100);
	env = EnvGen.kr(Env.adsr(attack, 0.1, 1, 1), gate);
	sin = SinOsc.ar(fft);
	sin = sin * env; // Fade in
	amp = LinLin.kr(amp, 0, 1, 0, ampMax);
	Out.ar(0, sin * amp);
}).store;

// MultipliedFeedback !!! :)
~synths = Array.newClear(3);
SynthDef(\Feedback,
	{|freq=500, amp=1, cutoff=1000, reverbMix=1, resonance=1|
		var src, out, in, delay, env;
		// Sources
		src = SinOsc.ar(freq + SinOsc.kr(0.02, 1.rand));
		src = FreeVerb.ar(src, reverbMix, 0.9);

		in = LocalIn.ar(1);
		in = in;
		in = BPF.ar(in, cutoff, resonance);

		// Mix source + input
		out = (in*src);

		// Filter
		out = HPF.ar(out, 10);
		out = FreeVerb.ar(out, 1, 0.9);
		out = Normalizer.ar(out, 1);
		out = Limiter.ar(out, 0.9);
		out = LeakDC.ar(out);

		// Delay & delay out
		delay = CombN.ar(out, 1, 0.05+LFDNoise3.kr(0.005, 0.001));
		LocalOut.ar(delay+src);

		// Output
		out = out * amp;
		// Out.ar([0,1], out*0.33);
		Out.ar(~mfBus, out*0.33);
	}).store;

// COMPOSITION :)
~composition = Task({
	1.do{
		|i|
		// Ch0
		// Tikjes
		// x = Synth(\ja, [freq: 1]);
		// 30.wait;
		// Ch1
		// x.set(\gate, 0); // Stop tikjes
		~fft = Synth(\FFTAnalyse, [attack: 30]);
		~fft.map(4, ~ampMax);
		3.do{
			|j|
			~synths[i] = Synth(\Feedback, [freq: [200,200,200].at(i), cutoff: 1000, amp: 1, resonance: 1]);
		};

		30.wait;
		"Chapter 2".postln;
		~fft.map(1, ~amp);
		~fft.map(4, ~ampMax);

	}
});
)