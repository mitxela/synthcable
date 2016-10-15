# Synth Cable: ATtiny85-based MIDI synthesizer
This is the source code to my original [Synth Cable using an ATtiny85](https://mitxela.com/projects/midi_on_the_attiny). It's also identical to the code that runs on my [World's Smallest MIDI Synthesizer](https://mitxela.com/projects/smallest_midi_synth) and almost identical to that used in the [Hardware Reverse Oscilloscope](https://mitxela.com/projects/hardware_reverse_oscilloscope). 

It has a monophonic square wave output and supports an arpeggiator, modulation/aftertouch and pitch-bend. 
* Responds to Note On / Note Off on Channel 1 only
* CC1/Aftertouch controls modulation depth
* CC5 controls modulation speed
* CC7 controls arpeggiator speed

Schematics and explanation here: https://mitxela.com/projects/midi_on_the_attiny

Video demos: 
* [Synth Cable](https://www.youtube.com/watch?v=FcsjieDfGno)
* [World's Smallest Midi Synthesizer](https://www.youtube.com/watch?v=tnm6agF8oog)

Code last modified 5th Aug 2015.
