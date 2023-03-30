---
title: Rate Limiting
date: "2023-03-29T23:55:56-05:00"
draft: false
---

In October, my public MoinMoin wiki started getting hammered with rapid
requests. It wasn't a major concern of mine at first.
 1. It was nowhere near the scale of a DOS attack.
 2. MoinMoin has built-in surge protection that always allows logged-in users
    access.
 3. As a principle, I'm in favor of public documents remaining truly *public*.
    Even to potentially bad actors.

But then it started impacting my uptime percentage.
*Oh boy* do I love seeing that perfect, bright-green 100%.
And it turns out, that's all the motivation I need to start walking back a
principle.

----

I've been using [upptime](https://github.com/upptime/upptime) for quite a while
as my uptime monitor/tracker.
It's an exceedingly simple system that can be hosted freely on GitHub Pages.
Well, as long as you are willing and able to tweak with the CI/CD limits.
It ships with some defaults that are a touch too far for an unpaid account.

The major advantage to upptime is that my monitor is 100% isolated from my true
production servers.
The CI/CD does all maintenance automatically.
Certificate expirations, host uptime, and end user error are all neatly folded
out of the equation.

The extra advantage is GitHub Issues as a web admin ticketing system.
For the most part, I host services by and for myself.
It would never be worthwhile to spin up a ticketing system just for server
administration.
But there are still *lessons learned* and *personal notes* that I would ideally
staple to incident reports, even just for myself.
GitHub Issues is a clunky beast, but it's more than enough for this use case.

This is all to say, you can find a timeline of events and a conversation I had
with myself at [#52](https://github.com/dricottone/upptime/issues/52).

----

I did *briefly* wonder if upptime was in error, and reporting a false positive.
I certainly could not replicate the issues.
And it wouldn't be the first time I needed to tweak the CI/CD due to GitHub's
race to the bottom on unpaid account limits.
As I now know, my inability to replicate was a result of MoinMoin's clever
surge protection.

I did a trial run with Uptime Robot but quickly realized that it reported the
same issues.
And if an uglier, paywalled monitor (*that has no ticketing system!*) was going
to give me the same outcomes, why would I give it another thought?
Haven't logged in since.

I then did some exploration into the realm of building my own monitor on
another cloud platform (*GCP?*).
That didn't make it even as far as a trial run.

----

While this all began in October, it took me several months to take this
seriously as a threat (to my uptime streak).

My first approach was to try to understand the spam.
I added more and more thorough connection logging, and even some HTTP headers.
I monitored logs in the hope that I could predict incidents--even intervene.
I tried to parse metrics in the aftermath of incidents to better predict the
next one.

This didn't really amount to anything.
As far as I can tell, I've randomly become the latest client (*victim?*) of a
particularly zealous spider.

My second approach was sticky rate limiting.
I have always sat my services behind an instance of HAProxy, because I'm a huge
fan of premature optimization and building for scale that never actualizes.
This made the introduction of rate limiting (and the aforementioned logging)
incredibly simple.

I started with limits that mirrored MoinMoin's own surge protection, figuring
that someone more intelligent that I probably came up with those defaults.
Those turned out to be a bit too loose, so I spent the next few months playing
a back-and-forth tuning game.

In the end, I've landed on a configuration that has staved off spam and
maintained uptime since mid-January.
(*Leaving aside a brief certificate expiration... oops.*)
I'm extremely pleased with this result, and my uptime streak is so beautiful.

