(
{
~this = thisProcess.nowExecutingPath.dirname;
(~this++"/setup.scd").load;
	2.wait;
(~this++"/globalFX.scd").load;

(~this++"/synth1.scd").load;
(~this++"/synth2.scd").load;
(~this++"/synth3.scd").load;
(~this++"/synthDefs.scd").load;
0.5.wait;
(~this++"/presets.scd").load;
0.5.wait;

(~this++"/midi.scd").load;
}.fork;
)

~globalFX.run(false);
~globalFX.run(true);
~globalFX.isRunning;q