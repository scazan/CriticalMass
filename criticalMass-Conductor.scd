s.waitForBoot({
		var w, f, distortionSlider, color, triggerButton, distortionText,
			broadcastAddr;

		var setBroadcastAddress = {
			var hostIPAddress = NetAddr.myIP,
				broadcastAddress = "";

			var broadcastAddressSplit = hostIPAddress.split($\.);
			broadcastAddressSplit.put(3,"255");

			// Concatenate the results together
			broadcastAddressSplit.do({|item, i|
				if(i > 0, {
					broadcastAddress = broadcastAddress ++  "." ++ item;
					}, {
					// first member of IP address doesn't need to have a dot attached to it
					broadcastAddress = item;
					})
				});

			NetAddr.broadcastFlag = true;

			broadcastAddr = NetAddr.new(broadcastAddress, 57120);
		};

		setBroadcastAddress.value();

		// GUI
		w = Window.new("Critical Mass (Conductor)", 800@700);
		w.background = Color.black;
		w.front;
		//w.fullScreen;

		f = FlowView.new(w, Rect(10,10, 800, 700), gap: Point(50, 50) );
		//f.moveTo(w.view.bounds.width/2, w.view.bounds.height/2);

		color = Color.new255(0,180,255);

		f.startRow;


		triggerButton = Button.new(f, Rect(0, 0, 300, 300))
			.states_([
				["click to block", Color.black, Color.new255(0,180,255)],
				["blocking...", Color.black, Color.red]
			]);


		f.startRow;

		distortionSlider = Slider.new(f, Rect(0, 0, 770, 110));

		distortionSlider.background = Color.new(0,0,0,0);
		triggerButton.background = Color.black;


		distortionSlider.knobColor = color;
		distortionSlider.focusColor = color;


		distortionSlider.action = {|slider|
			broadcastAddr.sendMsg('/distortion', slider.value);
		};
		triggerButton.action = {|button|
			if(button.value == 1, {
				broadcastAddr.sendMsg('/blockToggle', true);
			}, {
				broadcastAddr.sendMsg('/blockToggle', false);
			});

		};


		// Labels
		distortionText = StaticText(w, Rect(10, 520, 100, 50) );
		distortionText.string = "distortion";
		distortionText.stringColor = color;

		w.onClose_({  });

});
