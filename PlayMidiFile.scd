s.boot;
(
MIDIClient.init;
m = MIDIOut(0);

// ~buffer = Buffer.read(s, "/Users/Jildert/Desktop/03 Mama Otis (mastered 17-6).wav", action: ~buffer.play);
~tempo = 5.25;

~paths = [
"/Users/Jildert/Desktop/Batobe/JUNCTURE/Batobe_Juncture_ch16.mid",
"/Users/Jildert/Desktop/Batobe/JUNCTURE/Batobe_Juncture_ch8.mid",
"/Users/Jildert/Desktop/Batobe/JUNCTURE/Batobe_Juncture_ch7.mid",
"/Users/Jildert/Desktop/Batobe/JUNCTURE/Batobe_Juncture_ch6.mid",
"/Users/Jildert/Desktop/Batobe/JUNCTURE/Batobe_Juncture_ch4.mid",
"/Users/Jildert/Desktop/Batobe/JUNCTURE/Batobe_Juncture_ch2.mid",
"/Users/Jildert/Desktop/Batobe/JUNCTURE/Batobe_Juncture_Kick_1.mid"
];

~channels = [16,8,7,6,4,2, 1]-1;

~instruments = Array.fill(~paths.size, {|i| SimpleMIDIFile.read(~paths[i])});

~instruments.size.do({|i| ~instruments[i].setTempo(~tempo)});

~instruments[3].p.play;

~instruments.size.do({|i|
p = Pbindf(~instruments[i].p,
        \type, \midi,
        \midiout, m,
		\chan, ~channels[i];
).play;
	// ~instruments[i].p.play;
});
)

13028*(1/60)/60;
0.6*60;
