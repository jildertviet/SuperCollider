~presetID = 0;
~numPresets = 1;
~noteOn = Array.fill(~numPresets, Array.newClear(64));
~cc = Array.fill(~numPresets, Array.newClear(9));

~synthIndex = 0;

~noteOn[0][0] = {
	"Function 0".postln;
	if(~globalFX.isRunning, {
		~globalFX.run(false);
	}, {
		~globalFX.run(true);
	});

};
~noteOn[0][1] = {"s.freeAll".postln; s.freeAll};

~noteOn[0][3] = {"Synth: Kay".postln; ~synthIndex = 0;};
~noteOn[0][11] = {"Synth: FM".postln; ~synthIndex = 1;};
~noteOn[0][19] = {"Synth: AM".postln; ~synthIndex = 2;};
~noteOn[0][27] = {"Synth: BPad".postln; ~synthIndex = 3;};
~noteOn[0][35] = {"Synth: Sine".postln; ~synthIndex = 4;};
~noteOn[0][43] = {"Synth: Sine2".postln; ~synthIndex = 5;};
~noteOn[0][51] = {"Synth: Sine3".postln; ~synthIndex = 6;};



~mapLin = {|val, min, max| val.linlin(0.0, 127.0, min, max)};
~mapExp = {|val, min, max| val.linexp(0, 127, min, max)};
~mapLin.value(100, 0, 1);

~cc[0][0] = {|val| "Amp".postln; val.postln; ~globalFX.set(\amp,  ~mapLin.value(val, 0, 1))};
~cc[0][1] = {|val| "Amp live3".postln; val.postln; ~live3.set(\amp, ~mapLin.value(val, 0, 1))};
~cc[0][2] = {|val| "Amp live1".postln; val.postln; ~delay.set(\amp, ~mapLin.value(val, 0, 1))};

~cc[0][3] = {|val| "MIDI synth amp".postln; val.postln; ~synthBusHandler.set(\amp, ~mapLin.value(val, 0, 1))};

~cc[0][4] = {|val| "MIDI synth amp".postln; val.postln; ~delay.set(\ratio, ~mapLin.value(val, 0.5, 2)); ~live3.set(\ratio, ~mapLin.value(val, 0.5, 2))};

~cc[0][5] = {|val| "LFO Freq".postln;
	~masterBusHandler.set(\lfoFreq, ~mapExp.value(val, 5, 0.1))
};

~cc[0][6] = {|val| "LFO Depth".postln;
	~masterBusHandler.set(\lfoDepth, ~mapLin.value(val, 0, 1));
};
~cc[0][7] = {|val| "Master amp".postln; ~masterBusHandler.set(\amp, ~mapLin.value(val, 0, 1))};
~cc[0][8] = {|val| "Filter".postln; ~globalFX.set(\freq, ~mapExp.value(val, 200, 20000));
	~masterBusHandler.set(\freq, ~mapExp.value(val, 200, 20000))
};