"Setup".postln;
{
	var soundcard = "Saffire";
	("Selected soundcard: " + soundcard).postln;
	("MemSize: " + (8192*0)).postln;
	s.options.device = soundcard;
	s.options.memSize = 8192*10;
	s.boot;
}.fork;