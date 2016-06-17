// CRITICAL MASS
// by Scott Cazan
// www.scottcazan.com

s.waitForBoot({
	var w, f, volumeSlider, varianceKnob, color, triggerButton, triggerTone, soundSelectMenu;
	var listener, detectedFreq = 820, variance = 0, currentSection = 0, volume = 0, distortion = 1,
		flop = true, maxVarianceText, minVarianceText, soundSelectText, volumeText, blocked = false;

	var sounds = [
		{
			(BPF.ar(PinkNoise.ar, detectedFreq * Rand(variance, 1), 0.0001) * 620)!2
			* EnvGen.ar(Env([0,1,0],[0.1, 4]), doneAction: 2) * volume;
			
		},
		{
			SinOsc.ar(detectedFreq * Rand(variance, 1), 2)!2
			* EnvGen.ar(Env([0,1,0],[0.1, 4]), doneAction: 2) * ( volume/4 );
		},
		{
			Blip.ar(detectedFreq * Rand(variance, 1), 2)!2
			* EnvGen.ar(Env([0,1,0],[0.1, 4]), doneAction: 2) * ( volume/4 );
		}
	],
	backgroundNoise = { |amp=0|
		GrayNoise.ar()!2 * 0.002;
	}.play,
	distortionSynth = { |freq=820, amp=0|
		BPF.ar((GrayNoise.ar * 9).wrap2, freq, 0.01, mul: 12).clip(-0.5,0.5) * ( amp * 2 );
	}.play;

	listener = {
		var freq, hasFreq;
		# freq, hasFreq = Pitch.kr(SoundIn.ar(0), initFreq: detectedFreq, minFreq: 100);

		SendReply.kr(Impulse.kr(6), '/detectedFreq', values: [freq, hasFreq]);
	}.play;

	OSCdef(\frequencyReceiver, { | msg |
		var freq = msg[3].asFloat,
			hasFreq = msg[4];

		if(hasFreq > 0 && (variance < 1), {
			detectedFreq = freq;
			distortionSynth.set(\freq, freq);

		});
	}, '/detectedFreq');

	OSCdef(\blockReceiver, { | msg |
		var blockingValue = msg[1];

		if(blockingValue == 1, {
			blocked = true;
			AppClock.sched(0, {
				triggerButton.states_([
					["", Color.white, Color.black]
				]);
			});
		}, {
			blocked = false;
			AppClock.sched(0, {
				triggerButton.states_([
					["", Color.white, Color.new255(0,180,255)]
				]);
			});

		});
	}, '/blockToggle');

	OSCdef(\distortionReceiver, { | msg |
		var volume = msg[1];

		distortionSynth.set(\amp, volume);

	}, '/distortion');

	triggerTone = {
		//detectedFreq.postln;

		if(blocked == false, {
			sounds[soundSelectMenu.value].play;

			if(flop,{
				w.background = Color.new255(variance * 255, 0, 0);
				flop = false;
			},{
				w.background = Color.black;
				flop = true;
			});
		});

	};

	// GUI
	w = Window.new("Critical Mass");
	w.background = Color.black;
	w.front;
	w.fullScreen;

	f = FlowView.new(w, 800@700, gap: Point(50, 50) );
	f.moveTo(w.view.bounds.width/2, w.view.bounds.height/2);

	color = Color.new255(0,180,255);

	f.startRow;

	varianceKnob = Knob.new(f, Rect(0, 0, 300, 300));
	varianceKnob.mode = \horiz;

	triggerButton = Button.new(f, Rect(0, 0, 300, 300))
		.states_([
			["", Color.white, Color.new255(0,180,255)]
		]);

	soundSelectMenu = ListView(f, Rect(0,0,70,286));
	soundSelectMenu.items = [1,2,3];
	soundSelectMenu.background = Color.black;
	soundSelectMenu.hiliteColor = color;
	soundSelectMenu.stringColor = color;
	soundSelectMenu.selectedStringColor = Color.black;
	soundSelectMenu.font_(Font("Helvetica", 65));

	f.startRow;

	volumeSlider = Slider.new(f, Rect(0, 0, 770, 110));

	volumeSlider.background = Color.new(0,0,0,0);
	triggerButton.background = Color.black;


	volumeSlider.knobColor = color;
	volumeSlider.focusColor = color;

	varianceKnob.color = [ color, color, Color.new(0,0,0,0), Color.new(0,0,0,1) ];

	volumeSlider.action = {|slider|
		volume = slider.value / 2;
	};
	varianceKnob.action = {| knob | variance = knob.value };
	triggerButton.action = triggerTone;

	// Labels
	maxVarianceText = StaticText(w, Rect(varianceKnob.absoluteBounds.top, varianceKnob.absoluteBounds.left, 100, 50) );
	maxVarianceText.string = "Maximum\nvariance";
	maxVarianceText.stringColor = Color.new(1,1,1,1);
	maxVarianceText.moveTo(w.view.bounds.width/2 + 10, (w.view.bounds.height/2) + 280);

	minVarianceText = StaticText(w, Rect(varianceKnob.absoluteBounds.top, varianceKnob.absoluteBounds.left, 100, 50) );
	minVarianceText.string = "Minimum\nvariance";
	minVarianceText.stringColor = Color.new(1,1,1,1);
	minVarianceText.moveTo(w.view.bounds.width/2 + 230, (w.view.bounds.height/2) + 280);

	soundSelectText = StaticText(w, Rect(varianceKnob.absoluteBounds.top, varianceKnob.absoluteBounds.left, 100, 50) );
	soundSelectText.string = "sound";
	soundSelectText.stringColor = Color.new(1,1,1,1);
	soundSelectText.moveTo((w.view.bounds.width/2)+700, (w.view.bounds.height/2) + 325);

	volumeText = StaticText(w, Rect(volumeSlider.absoluteBounds.top, volumeSlider.absoluteBounds.left, 100, 50) );
	volumeText.string = "volume";
	volumeText.stringColor = Color.new(1,1,1,1);
	volumeText.moveTo((w.view.bounds.width/2), (w.view.bounds.height/2) + 505);

	w.onClose_({ listener.free; backgroundNoise.free; OSCdef(\frequencyReceiver).free; OSCdef(\blockReceiver).free; distortionSynth.free; });


	// MIDI
	MIDIClient.init;
	MIDIIn.connectAll;


	CCResponder({ |src, chan, num, val|
		val = val / 127;

		switch (num,
			// AMP
			1, {
				AppClock.sched(0, {
					volumeSlider.valueAction = val;
				});
			},
			// Variance
			11, {
				AppClock.sched(0, {
					varianceKnob.valueAction = val;
				});
			},
			// Trigger
			21, {
				if(val == 0, {
					AppClock.sched(0, {
						triggerButton.valueAction = val;
					});
				});
			},
			// Selection of Sounds
			22, {
				AppClock.sched(0, {
					soundSelectMenu.valueAction = 0;
				});
			},
			49, {
				AppClock.sched(0, {
					soundSelectMenu.valueAction = 1;
				});
			},
			32, {
				AppClock.sched(0, {
					soundSelectMenu.valueAction = 2;
				});
			}
		)
	});

});

