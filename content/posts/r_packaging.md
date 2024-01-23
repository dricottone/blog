---
title: R Packaging
date: "2023-12-02T23:28:42+00:00"
draft: false
---

Earlier this year,
I found a way to
[build packages for Alpine Linux within a Docker container](https://git.dominic-ricottone.com/~dricottone/simple-builder).
Specifically, I use that system to build packages for all of the Python and Go
programs underpinning my git server.
It was a fun project that taught me a lot about the Alpine Linux ecosystem.

I've been interested in expanding that tool to support more distributions.
Apart from Alpine Linux,
I make use of Fedora, Ubuntu, and Arch Linux.
I don't run anything directly on Fedora though,
and I'll probably migrate off of it in the near future.
And Red Hat's actions these past few years
(including but not limited to
[this](https://dev.intra.dominic-ricottone.com/posts/2023/06/disruption-from-google-and-red-hat/))
have erased any chance of me
deploying a *new* Fedora server.
So it's not a distro that I will ever be targeting in this project.

Ubuntu is an interesting prospect for me because my use case for that distro
is setting up a server without any configuration
(because I don't necessarily intend to keep it for long).
If I can move *away* from compiling software on those hosts,
and *towards* using pre-compiled binary packages,
I can forego configuration *and* installing compiler toolchains.

Arch Linux is an inherently interesting target because that's my go-to distro
for everything from long-term servers to personal computers.
But what software would I actually package,
when it's rather straightforward for me to maintain my toolchains on those
hosts?

----

Also earlier this year, I
[tried](https://dev.intra.dominic-ricottone.com/posts/2023/03/acs-data/)
to do some
[replication work](https://git.dominic-ricottone.com/~dricottone/chicago)
in R and SAS.
(By which I mean: in SAS, but I tried to use R for an API.)

At the time,
I consistently ran into stability issues with R.
So much of the R ecosystem depends on libraries with dozens of direct and
indirect dependencies.
Many of them are compiled libraries linked not only to each other but also to
other system libraries.
This network seems to be well supported on many distros...
but not so much on Arch Linux.

Shockingly the AUR does not offer much support in this specific area.
It seems there is literally one person trying to support the TidyVerse there.
Stepping out of the AUR,
you can find a few projects around PKGBUILD repositories for R packages with
*decent* support.
Even then,
a dead-simple C library wrapper was months out-of-date and required patching.
But that's skipping ahead...

----

I resolved to teach myself the Arch Linux packaging system so that I can
install R binary packages for a more stable experience.
There are PKGBUILDs floating around the internet,
but invariably a significant amount of work is required in updating these.
Many of them lag by major version upgrades.
At least one needed to be converted to an unreleased, git-fetched package.
All-in-all, it took me two weeks to package the TidyVerse.
(Yes, that two weeks included Thanksgiving and all of the corresponding
travel time. It's still a lot.)

What did I learn?
Quite a bit actually.
Importantly,
I learned that there's already an excellent toolchain for building Arch Linux
packages in clean chroots,
so there's not really a good reason to build in Docker containers.

I also learned that the Arch Linux packaging system is excellent for ARM64
hosts.
The cross-compilation story is less than ideal currently,
and I'm starting to see why Arch On Arm *wants* to be a separate project.
I remain unconvinced that it's qualitatively worse than the Alpine Linux
packaging system,
but honestly they are very similar in execution and design,
so I'd be willing to hear arguments either way.

Lastly, I've gained an appreciation for the TidyVerse.
I've always seen it as bloatware.
Too much functionality when less would have worked.
But given the R ecosystem of today,
'targeting less' means adopting a more complex dependency structure.
It means pinning the versions of several libraries instead of one.
It means supporting users as they struggle to install several packages
instead of just one that they *probably already have installed on their system
due to other, unrelated projects*.
Essentially, TidyVerse is an R distribution in the same way that Conda is a
Python distribution.

