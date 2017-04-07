(
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
		Out.ar([0,1], out*0.33);
		// Out.ar(~mfBus, out*0.33);
	}).store;
)

(
3.do{
	|j|		~synths[i] = Synth(\Feedback, [freq: [200,200,200].at(j), cutoff: 1000, amp: 1, resonance: 1]);
};
)