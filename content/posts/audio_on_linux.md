---
title: Audio on Linux
date: "2024-01-23T22:30:37+00:00"
draft: false
---

Why is audio on Linux so difficult?

----

Over the course of a decade,
I have experimented with just about every reasonable configuration for audio
on a Linux distribution.

It helps that I have very simple needs.
A single, analog output jack.
No worrying about stereo channels,
no worrying about specialty sound cards and drivers.
Pretty much any sink should be able to manage this job.

ALSA is an incredibly simple system.
Also a very inflexible one.
But it works very well, in a simple and straightforward way.
Once upon a time I ran my PC with just ALSA.
The ultimate killer for any such configuration is the inability to support
multiple concurrent audio streams.

PulseAudio has been the *de facto* for so long.
There's much said on the internet about the quality of code in the PulseAudio
project,
though I have to wonder if there's any fact to it.
I think people just love to complain about other coding styles.
What I do know is that PulseAudio is highly reliable,
highly configurable,
and easier to configure than JACK and ALSA.

Speaking of JACK:
I have used it before.
Actually I used it on a MacBook, rather than a Linux PC.
I think that's enough experience to say *it works*,
and also *it can be challenging to use* ***well***.
I would consider using it again.

Lastly: PipeWire.
The much-hyped newcomer.
I believe that it's meant to fill some gaps in the X11-Wayland transition.
I do technically use it,
as I've never bothered to re-configure my laptop running Manjaro.
I recently decided to try it on my PC as well.
That... is the topic of the next sections.

----

I had some issues with PulseAudio following my last system update.
Audio skipping every few seconds.
Barely noticeable in videos of human speech,
but highly irritating in any music playback.

I did some poking around with PulseAudio configurations and reboots.
I mucked around with ALSA utilities,
since Pulse's sink just sits on top of that device.
Finally I came to the conclusion that this was the kernel's fault.
Maybe there's a minute change to memory limits?
I resolved to wait a few days,
to see what kernel patches would do to solve the issue.
Still, I felt that the audio server should be able to compensate for any
issues that boiled down to memory usage.

----

But a kernel update came and went,
and the issue persisted.
At this point I became more than frustrated.
After much more fussing with configurations,
I decided that PulseAudio just wasn't up to that task.
But perhaps, I wondered,
PipeWire would prove to be?

The story for switching on Arch is remarkably simple.
Although I'm very much puzzled by the need for separate servers and session
managers.
I got things running,
hit play,
and... no improvement.

And actually, there was a major regression!
After about 10 minutes, audio would cut out completely and permanently.
I had to teach myself a great deal about the design of PipeWire just to begin
diagnosing the issue.
For some reason,
Firefox's node is being marked as idle,
and the driver node is killing off that process entirely.
There's an extremely unhelpful log message about an invalid command and some
I/O error.
But after reading through some of the source code and spending days reading
forums and bug trackers,
I still have no idea what is going on to cause this.

My only assumption is that PulseAudio is handling some erroneous state
(again, probably due to some memory tweak in the new kernel)
more gracefully than PipeWire.
Neither is offering me a solution,
but at least PulseAudio doesn't fall over itself.
So what's the point of the coupled session-manager-and-server design of
PipeWire if it doesn't actually achieve high availability?
It all seems like unnecessary and unhelpful complications.

----

So I'm moving on from PipeWire.
I'll leave it on any systems that come with it pre-configured,
but the majority of my installations are minimal Arch systems,
so that's effectively 'few and fewer'.
I'm more willing to give JACK a try at this point.

