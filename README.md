# Critical Mass
---------------

This is the code and score for the piece Critical Mass.

##Requirements
The code is written for SuperCollider 3 and has been tested on SuperCollider 3.7.
You can obtain that at [http://supercollider.github.io/](the SuperCollider website)

In addition this patch requires one external library, [https://github.com/supercollider-quarks/NetLib](the NetLib quark).

The easiest way to install the NetLib quark is to open SuperCollider and then run this command:
```
Quarks.gui;
```

Then click on "Update Quark Listing."
Scroll down to find "NetLib" in the list.
If you already have the library then it will appear as a green "+" in which case you don't need to do anything more.
If you do not see a green "+" next to "NetLib" then click the "-" icon to the left of it (it will turn into a star).
Lastly, click "Apply" at the top, close the window and then exit SuperCollider.

## Getting the Code
Just run this on your command line to download everything to your computer:
```
git clone https://github.com/scazan/CriticalMass.git
```

If you previously downloaded this code and want the latest version, go to the directory you cloned it into and run:
```
git pull
```

##Running
There are two ways to run this patch.

To start the patch without having to load anything else just type this at the command line:
```
./start.sh
```
You will also need to start the Conductor's patch:
```
./startConductor.sh
```

If you prefer to load this directly in SuperCollider, just open up criticalMass.scd or criticalMass-Conductor.scd, select all, then execute.

Check the score for information on performance and if I wasn't the one to send you this link and you have decided to perform the work, shoot me a line and let me know!


