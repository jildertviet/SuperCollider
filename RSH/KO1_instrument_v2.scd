SerialPort.listDevices;

(
~numSensors = 2;

~sensorBussesLinks = Array.fill(~numSensors, 0);

~sensorBussesLinks[0] = ["freq1", 0, 40, 1, 50];
~sensorBussesLinks[1] = ["amp", 0, 20, 0, 1];

p = ArduinoSMS("/dev/tty.usbmodem1411", 9600); // was 9600 (changed by thor)
p.action = {
	|... msg|
	// msg.postln;
	~numSensors.do({
		|i|
		var val = msg[(i*2)+1];
		val = val.linlin(~sensorBussesLinks[i][1],~sensorBussesLinks[i][2],~sensorBussesLinks[i][3], ~sensorBussesLinks[i][4]);
		// val.post; " ".post;
		if(~scape!=nil,{ ~scape.set(~sensorBussesLinks[i][0], val)});
	});
	// "".postln;
};
)

p.close;













(~paths = ["/Users/Jildert/Music/Jildert/Samples/Regular/Undefined/Stone Roll.aiff",
	"/Users/Jildert/Music/Jildert/Samples/Regular/Undefined/Elevator.wav",
"/Users/Jildert/Music/Jildert/Samples/Regular/Efterklang - Piramida - Rollende kar fabriek .wav",
	"/Users/Jildert/Music/Jildert/Samples/Regular/Deep Metal Inpact/Metaalkabels.aiff"
];
~numSensors = 2;
b = Buffer.readChannel(s, ~paths[0], channels: 1);
)
(
~synth = SynthDef(\Test, {
	|amp=1, buf, rate=1, freq1=5, pos, dur=0.2, out=#[0,1]|
	var gran;
	var posV;
	gran = TGrains.ar(2, Impulse.ar(freq1), buf, rate: rate, centerPos: pos, dur: dur, pan: 0, amp: amp, interp: 4);
	gran = HPF.ar(gran,500);
	Out.ar(out, gran*amp);
}).play(s, [buf: b, dur:0.5, pos: 10]);
)

(
~numSensors = 2;
~sensorBusses = Array.fill(~numSensors, {|i| Bus.control(s, 1)});
~sensorBussesLinks = Array.fill(~numSensors, 0);

~sensorBussesLinks[0] = ["rate", 0, 40, 0, 2];
~sensorBussesLinks[1] = ["amp2", 0, 20, 0, 1];
// ~sensorBussesLinks[2] = ["\dur", 0.01, 2];
// ~sensorBussesLinks[3] = ["\freq1", 0.5, 20];


~switchBus = {|busID, newVar|
	// Unlink previous parameter
	if(~sensorBussesLinks[busID]!=nil){
		~test.get(~sensorBussesLinks[busID], { arg value; ~test.set(~sensorBussesLinks[busID], value); });
	};
	~test.set(newVar, ~sensorBusses[busID].asMap);

	~sensorBussesLinks[busID][0] = newVar;
};

// Linking Busses to values
// ~numSensors.do({|i| ~switchBus.value(i, ~sensorBussesLinks[i])});
)


( // GUI
w = Window.new("GUI", Rect(300,200,700,400));
x = Plotter("File", Rect(0,0,700,200), w);
b.loadToFloatArray(action: { arg array; a = array; {x.value = a;}.defer;});

~sliderColors = [[0,0,0,1], [1,0,0,1], [0,1,0,1]];
~sliders = Array.fill(~sensorBusses.size, {|i|
	Slider(w, Rect(0,200+(i*50),700,50))
	.background_(Color.gray(1,0.00000001))
	.knobColor_(Color.new(~sliderColors[i]))
	.thumbSize_(1)
	.value_(1.0.rand);
});
w.front;
)


// Test dingen

~sliders[0].value_(0.5);


~sliders[0].value_(1.linlin(~sensorBussesLinks[0][1],~sensorBussesLinks[0][2],0,1));

1.linlin(~sensorBussesLinks[i][1],~sensorBussesLinks[i][2],0,1);

~startPosistions = [50.9, 17.16, 7.56, 7.3, 8.6].choose;
~synth = Synth(\Gran, [buf: b.bufnum, amp: 1.0, add:~startPosistions, mul: 0.001, lowcut: 1000, freq1: 20, dur: 0.2, rate: Scale.minorPentatonic.ratios.choose*[0.5,1].choose, freq2: 0.001, pan: 1.0.rand-0.5]);