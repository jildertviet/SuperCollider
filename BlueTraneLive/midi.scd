(
"Midi config starts".postln;
MIDIClient.init;
MIDIIn.connectAll;

m = MIDIOut(2);

~setToGreen = {[3, 11, 19, 27, 35, 43, 51].do{|i| m.noteOn(16, i, 01)}};
~setToGreen.value(); // All to green @ init
m.noteOn(16, 3, 03); // Set first preset to RED

MIDIdef.noteOn(\noteakai, srcID: -457367486, func: {
	| val, note, chan, gate |
	// note.postln;
	// if(~noteOn[~presetID][note] !== nil,{
	~setToGreen.value();
	m.noteOn(16, note, 03);
	~noteOn[~presetID][note].value();
// });
});


MIDIdef.cc(\akai, srcID: -457367486, func: {
	|val, note|
	note = note - 48;
	note.postln;
	// "Akai".postln;

	~cc[~presetID][note].value(val);
} );

~voices = Array.newClear(127);
~sustainPressed = false;
~sustainNotes = List[];
MIDIdef.noteOn(\noteOn, srcID: 1206000991, func: {
	| val, note, chan, gate |
	"On".post; note.postln;
	if(note==108, {"Reset!"; ~voices.do{|v| v.set(\gate, 0)}}, {
		~voices[note].set(\gate, 0); ~voices[note] = Synth(~synthNames[~synthIndex], [freq: note.midicps, amp: val.linlin(0, 127, 0.4, 1)]);
	});
	if(~sustainPressed==true,{
		// ~sustainNotes.add(~voices[note]);
	});

});

MIDIdef.noteOff(\noteOff, srcID: 1206000991, func: {
	| val, note, chan, gate |
	"Off".post; note.postln;
	if(~sustainPressed!==true,{

		~voices[note].set(\gate, 0);
		~voices[note] = nil;
	}, {
		~sustainNotes.add(~voices[note]);
	});
});

MIDIdef.cc(\cc, srcID: 1206000991, func: {
	|val, note|
	"CC".postln;
	// val.post;
	if(note==64 && val==127, {
		"Sustain pressed".postln;
		~sustainNotes = List[];
		~sustainPressed = true;
		~voices.do{
			|voice|
			if(voice!==nil,{
			voice.postln;
				// ~sustainNotes.add(voice);
			});
		}
	});
	if(note==64 && val==0, {
		"Sustain released".postln;
		~sustainPressed = false;
		~sustainNotes.do{
		|voice|
			voice.set(\gate, 0);
			~voices.size.do{
				|i|
				if(~voices[i]==voice, {
					"Set nil".postln;
					~voices[i] = nil;
				});
			}
		};
	});
	// note.post;
});
)