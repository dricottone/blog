---
title: First x86 Server
date: "2023-07-27T12:20:19-05:00"
draft: false
---

After years of managing a hodgepodge of Raspberry Pis and EC2 micro instances,
I have finally built and deployed an x86 bare metal server.

----

Deploying an x86 server has been my goal for a long time,
but was primarily held up on practical concerns.
(That is, *money* and *moving between apartments*.)

While Raspberry Pis are very fun to play with,
they can be extremely unreliable for long-running and storage-intensive tasks.
SD cards are simply *not* meant to be the backbone of a highly-available
system.
(To the point that I have repeatedly considered switching to netboot...
and probably will after a few more cards fail on me.)

And I have had a miserable time of USB drives;
they are *at best* a strangling bottleneck and *at worst* a great way to
corrupt data.

For whatever reason,
ARM motherboards are rarely designed with SATA ports (emphasis on plural).
There's a small variety of niche options,
but I have sincere doubts about running a decent operating system on them.

So despite my preference for alternative/'weird' hardware,
I have always felt the need for an x86 server box.

----

So since I decided on building an x86 server with a focus on storage services,
I figured this was a fantastic opportunity to play around with filesystems.
I've heard so much about ZFS and always wanted to play with it.

Reading through some guides and manuals,
it all seemed really simple.
I whiteboarded a theoretical deployment and even drafted some maintenance
scripts while scanning those documents.
From the outside, ZFS really seems to nail its 'zero configuration' claim.

The consequence of deciding to use ZFS, however, is that
the decision on operating systems becomes somewhat constrained.
(And this feeds back into the above concerns about niche motherboards.)
FreeBSD of course has excellent support,
but I wanted to use this server to re-host containerized services.
And obviously that precluded any BSD-derived distributions.
I've heard some good things about Canonical's work to integrate ZFS on
Ubuntu,
but I'm hoping for this server to be a long-lived one,
and I really don't enjoy the upgrade path for Debian-derived distributions.

When in doubt, I always return to my most trustworthy tool:
the operating system that's been powering my personal PC for six years.
And while support for ZFS is far from *out-of-the-box*,
there's a very clearly-documented path forward.

----

So before I could learn about deploying ZFS,
I had to learn how to run a non-standard kernel on Arch Linux.
As I understand it,
the Arch approach to kernel management is somewhat controversial.
I've seen many comments and complaints about how upgrading the kernel by
replacement (as opposed to installation *alongside* the old kernel)
is inconvenient or even dangerous.
I've never personally understood that.
In fact I find it inconvenient that other distros fail to clean up the
bootloader automatically.

Well, as things turned out, I *did* manage to break my kernel on my first
run through.
But luckily my bootable installation USB was already at hand,
so it just took another 5 minutes to get that fixed.

Speaking of which,
I swear the Arch Linux installation process has gotten easier.
All those years ago,
my first two installation attempts were failures.
Given that I did everything according to defaults,
if the manual back then looked exactly like it does now,
I have *no idea* how I could have made a mistake.

In any case,
it was a quick fix (regenerating initramfs) and my new server was up.
Shockingly simple to get the ZFS module working.
So simple I went back and switched to the LTS kernel while I had all the
project documentation open.

----

The deployment is complete now.
I've actually been able to retire one of my RasPi 3B+'s.
(Don't worry, it will probably return to my stack in a couple of months.
Maybe I could try a CI/CD server...)

