// Variabele afspeelsnelheid

s.boot;
Server.local.options.device ="Saffire";



(
~buffer = Buffer.read(s, "/Users/Jildert/Music/Logic/WiemerMotionGraphic/Audio Files/WiemerMotionGraphic_17#06.wav");
~rec_buffer = Buffer.alloc(s, 44100*60, 2);

SynthDef(\sampletje, { | startpos = 2, trigger = 0.5, rate = 1, level=1, panning=0.5, attack=0.5, release=0.5 |
	var sample, env;
	env = EnvGen.kr(Env.perc(attack, release, level), doneAction: 2);
	sample = PlayBuf.ar(1, ~buffer.bufnum, rate, 1, startpos*SampleRate.ir, 1)*level;
	Out.ar(0,Pan2.ar(sample*env, (2*panning-1)));
}).add;

SynthDef(\Recorder, {
	RecordBuf.ar(In.ar(0,2), ~rec_buffer.bufnum, doneAction: 2, loop: 0);
}).add;
)

x = Synth(\Recorder);
// Deze Task meerdere keren afspelen;

(
t = Task({
    loop {
		var attack, release, wachttijd, begintijd, rates, rate_index, rate;
		"duur ".post; ~buffer.duration.postln;
		attack = 1+(2.0.rand);
		"attack ".post; attack.postln;
		release = 2+(3.0.rand);
		"release ".post; release.postln;
		wachttijd = attack+release+(2.0.rand);
		"wachttijd ".post; wachttijd.postln;
		rate_index = 4.rand;
		rates = [0.5, 0.75, 1, 1.5, 2];
		rate = rates[rate_index];
		begintijd = (~buffer.duration)-attack-release;
		"begintijd ".post; begintijd.postln;
		Synth(\sampletje, [rate: rate, startpos: begintijd.rand, attack: attack, release: release, panning: 1.0.rand, level:0.2+0.8.rand]);
		wachttijd.wait;
	    }
}).play;
)

~rec_buffer.plot;
~rec_buffer.write("/Users/Jildert/Desktop/Pianos.aiff", "aiff",  ~rec_buffer.numFrames);