s.boot;
s.quit;
o = Server.local.options;
o.device ="Saffire";
o.inDevice = "Saffire";

(
p = "/Users/Jildert/Music/Logic/WiemerMotionGraphicStraightV3/Audio Files/WiemerMotionGraphicStraightV3_1#01.wav";
b = Buffer.read(s, p);
// b = Buffer.alloc(s, s.sampleRate * 10.0, 1);
// {RecordBuf.ar(AudioIn.ar(1), b, loop: 0)}.play;
)
b.duration;
b.normalize;
b.play;
b.plot;

(
~val;
~values = List.new();
w = Window.new("GUI", Rect(0,0,1000,200));
w.view.keyDownAction = { arg view, char, modifiers, unicode, keycode;  [char, keycode].postln;
	if(keycode == 49){
		~values.add(~val);
		~values.postln;
	};
	if(keycode == 17){
		"Play".postln;
		x = Synth(\PlayShortSample, [buf: b, attack: 0.0001, release: 0.1, dur:0.25, rate: 1, pos: ~val]);
	};
	if(keycode == 16){
		g.value_(1.0.rand);
	};
};
g = EZSlider(label:" Song ", bounds: Rect(0,0,800,50), parent: w);
g.action_({ |ez| ~val = ez.value; ~val.postln;

});
w.front;

SynthDef(\PlayShortSample, {
	|amp=1, attack=0.1, release=0.1, buf, duration=0.1, pos=0.5, rate=1, pan=0|
	var sample, env;
	sample = PlayBuf.ar(buf.numChannels, buf, rate, startPos: pos*b.duration*s.sampleRate);
	env = EnvGen.kr(Env.linen(attack, duration, release), doneAction: 2);
	sample = Pan2.ar(sample, pan);
	Out.ar(0, sample*env*amp);
}).add;
)

x = Synth(\PlayShortSample, [buf: b, pos: ~values[3], dur: 0.5]);

~values.size;
(
t = Pbind(\instrument, \PlayShortSample, \pos, Pseq(~values.scramble, inf), \duration, 0.05, \buf, b, \rate, Pseq(Array.fill(~values.size, {[-1, 1].choose}),inf), \dur, 0.136*1, \attack, 0.01, \amp, Pseq(Array.fill(~values.size, {0.5+0.5.rand}), inf), \pan, Pseq(Array.fill(~values.size, {2.0.rand-1}), inf)).play;)
t.stop;

s.record;