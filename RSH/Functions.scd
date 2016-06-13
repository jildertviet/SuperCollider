/*
NanoKontrol @ Scene 3
1: Low Groove
2: Tonal Groove
3: Clarinet Groove
4: Scape

5: Record loop (input 1)
6. Record loop (input 2)

7. Record piano (input 1)
8. Record sax (input 2)


TO DO
8. Control rates?

-- GROTE LIJN
-- DOORZETTEN IDEEEN
-- VOORGROND NEMEN


SoftKneeCompressor.ar( // makeUp=1
	// Highpass @ Input,  HighDC
	//
*/
// MIDIFunc.noteOn(fun, nn[key]); in Array gooien

MIDIClient.init;
~granNote = "c";

(
~granNote = "c";
MIDIIn.connectAll;
~lowGrooveBufIndex=0;
~tonalGrooveBufIndex=0;
~granScapeBufIndex=0;
~loopDuration=10;
~loopDuration2=10;

MIDIdef.noteOn(\note, { // kan ook met switch
	| val, note, chan, gate |
	"NoteOn".postln;
	// 1
	if(note==107, { ~doLowGroove.value([~lowGrooveBuf.bufnum, ~recBuf[0].bufnum, ~recBuf[1].bufnum].at(~lowGrooveBufIndex)) });
	if(note==116, { ~stopLowGroove.value() });
	// 2
	if(note==108, { ~doTonalGroove.value([b.bufnum, ~recBuf[0].bufnum, ~recBuf[1].bufnum].at(~tonalGrooveBufIndex)) });
	if(note==117, { ~stopTonalGroove.value() });
	// 3
	if(note==109, { ~doClarinetGroove.value() });
	if(note==118, { ~stopClarinetGroove.value() });
	// 4
	if(note==110, { ~doGranScape.value(~granNote, [b.bufnum, ~recBuf[0].bufnum, ~recBuf[1].bufnum].at(~granScapeBufIndex)) });
	if(note==119, { ~stopGranScape.value() });

	// 5
	if(note==111, { ~loop.value(~loopDuration, 5, 1, ~loopAmpBus) }); // Arg[0]: Duration
	if(note==120, { ~setLoopDuration.value() });
	// 6
	if(note==112, { ~loop.value(~loopDuration2, 5, 2, ~loop2AmpBus) }); // Arg[0]: Duration, Arg[2] = input
	if(note==121, { ~setLoopDuration.value() });

	// 7
	if(note==113, { ~recordToBuf.value(0, 1) });
	if(note==122, { ~recordToBuf.value(1, 1) });
	// 8
	if(note==114, { ~recordToBuf.value(0, 2) });
	if(note==123, { ~recordToBuf.value(1, 2) });

	// note.postln;
});

MIDIdef.cc(\CC,{
	|val, note|
		// BufIndex selecting
	if(note==94, {~lowGrooveBufIndex = val.linlin(0, 127, 0, 2).asInt});
	if(note==95, {~tonalGrooveBufIndex = val.linlin(0, 127, 0, 2).asInt});
	if(note==97, {~granScapeBufIndex = val.linlin(0, 127, 0, 2).asInt;
		~addTemp = [[50.9, 17.16, 7.56, 7.3, 8.6], [~recBuf[0].duration.rand], [~recBuf[1].duration.rand]].at(~granScapeBufIndex);
	});
	if(note==102, {~loopDuration = val.linlin(0,127,1, 60)});
	if(note==103, {~loopDuration2 = val.linlin(0,127, 1, 60)});

	val = val.linlin(0, 127, 0, 1);
		// Volumes
	if(note==85, { ~controlVolumeLowGroove.value(val) });
	if(note==86, { ~controlVolumeTonalGroove.value(val) });
	if(note==87, { ~controlVolumeClarinet.value(val) });
	if(note==88, { ~controlVolumeGran.value(val) });

	if(note==89, { ~controlVolumeLoop.value(val) });
	if(note==90, { ~controlVolumeLoop2.value(val) });

	// note.postln;
} );
)

// Deze nog mappen aan CC knobs
~controlRateTonalGroove.value(1);
~controlRateClarinet.value(1);
~controlRateLowGroove.value(1);

// To do:
// Tap tempo
// tonalGroove - begintijden anders maken als ie op RecBuf staat...