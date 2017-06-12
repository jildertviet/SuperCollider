(
~afterFX = Bus.alloc('audio', s, 2);
{
SynthDef(\globalFX, {
	|freq=20000, amp=1|
	var in, filt, out;
	in = SoundIn.ar([0,1]);
		// filt = LPF.ar(in, freq);
	out = in;
	out = Limiter.ar(out, 0.9, 0.01);
	Out.ar(~afterFX, out);
	Out.ar([0,1], out*amp*0.9);
}).add;

1.wait;

~synths = s.makeBundle(false, {
	    ~globalFX = Synth(\globalFX);
	    NodeWatcher.register(~globalFX); // register before creating on the server
});

s.listSendBundle(nil, ~synths);    //start the node on the server
}.fork;
)