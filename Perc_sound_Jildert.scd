/*
by Jildert Viet - 2015

- @ step >>2<<, set the filepath to the desired path
- Execute @ 1, 2, 3, 4 (repeat 3 & 4 until you've got a nice result) & 5

If you want to use another sound, you can edit the SynthDef @ the bottom of this document
*/

//>>1<< // Wait till booted
s.boot;

( // >>3<<
// Start the sequence and record it in 8 different buffers

~hi_seq_panned_random.start;
// ~hi_seq_panned.start; // Choose on of the two functions to generate sound

~record.value;
)

// >>4<<
~playback.value;

// >>5<<
// If you like the result, save it:
~write.value;

( // >>2<<
~savepath = "/Users/Jildert/Desktop/";

~hi_seq_panned = Task({ // Play a sequence, panned on different speakers
	inf.do({
		|i|
		~hi_seq_panned_time = 0.1; // The speed of the sequence
		~index = i % 5;
		~speaker_index = i % 8;
		~speakers = [0,5,2,7,4,1,6,3]; // The order of speakers
		// ~speakers = [0,5,2,7,4,1,6,3].scramble; // Scrambles the order of speakers
		~ring_times = [0.5, 1, 2, 0.5, 2]/4; // The decay of the sound
		~freqs = [10000, 8000, 10000, 10000, 12000]; // The frequencies
		~hat_levels = [0.4, 0.4, 0.3, 0.4, 0.2]*3; // Amps
		x = Synth(\Perc_panned, [freq: ~freqs[~index], ring_time: ~ring_times[~index], out: ~speakers[~speaker_index], level: 3]);
		~hi_seq_panned_time.wait;
	});
});

~hi_seq_panned_random = Task({ // Play a sequence, panned on different speakers
	~hi_seq_panned_time = 0.1; // The speed of the sequence
	~speakers = [0,5,2,7,4,1,6,3].scramble; // Scrambles the order of speakers
	~ring_times = [0.5, 1, 2, 0.5, 2]/[2,3,4,5,6,8].choose; // The decay of the sound
	~freqs = [10000, 8000, 10000, 10000, 12000]*[0.5, 1.25, 1.75].choose; // The frequencies
	~hat_levels = [0.4, 0.4, 0.3, 0.4, 0.2].scramble*14; // Amps
	inf.do({
		|i|
		~index = i % 5;
		~speaker_index = i % 8;
		x = Synth(\Perc_panned, [freq: ~freqs[~index], ring_time: ~ring_times[~index], out: ~speakers[~speaker_index], level: ~hat_levels[~index]]);
		~hi_seq_panned_time.wait;
	});
});

~buffers = Array.fill(8, {Buffer.alloc(s, 44100 * 8.0)}); // Buffer length is set to 8.0 sec's
b = s.outputBus;

~record = { // Record function, to record all tracks in 8 different buffers
	~buffers = Array.fill(8, {Buffer.alloc(s, 44100 * 8.0)});
8.do({|i|
		{Out.ar(9, RecordBuf.ar(b.ar(1,i), ~buffers[i], doneAction: 2))}.play;
})
};

~playback = {(8.do({|i|~buffers[i].play});)}; // Playback function, to hear what's just recorded

~write = {(8.do({|i| ~buffers[i].write(~savepath+"Resonant_sounds_"+i+".aiff")}))}; // Write as audio files

SynthDef(\Perc_panned, { // The percussive sound
	|freq = 10000, ring_time = 4, level = 1, out = 0, bus|
	var noise, env, klank, env2, output;
	env = EnvGen.kr(Env.perc(0.00001, 0.01));
	env2 = EnvGen.kr(Env.linen(0.00000001, ring_time, 1), doneAction: 2);
	noise = GrayNoise.ar(env*0.1);
	klank = Klank.ar(`[[freq],[0.1],[ring_time]], noise);
	output = klank * level * env2;
	Out.ar(out, output);
}).add;
)