---
title: Disruption from Google and Red Hat
date: "2023-06-27T14:59:08-05:00"
draft: false
---

I was 10 minutes from boarding an airplane when I learned
(by way of a Fireship video)
that Google Domains was getting the ax.
That was a terrible way to kick off 3 hours offline.

I have been using Google Domains as my sole domain registry since I began
self-hosting seven years ago.
It had a dead-simple interface.
It offered every feature I needed without any click-throughs to authorize
'add ons' or 'premium services'.
It never tried to sell me a nonsense WYSIWYG site builder.
It was just a domain registry service.
For all of that, I was happy to pay the 'premium' over at-cost registries.

Google has unfortunately killed off yet another spin-off.
I've heard for years about Google's track record in this sphere, but I'd never
actually been *inconvenienced* by it.
(Okay, technically I had a Google+ account back in the day, but I assure you
that no tears were spilled on its behalf.)

So... *migrating registries*.
I re-researched the market and decided that it was time to join the Cloudflare
hype train.
Their interfaces are fine, they aren't too annoying with the upsell marketing.
It's not a terrible experience.
It actually was easier to do than I expected, including setting up dynamic DNS
for my home IP address.

Things that are *not* fun:
teaching myself how to host an email server on a deadline.
Google Domains made email relaying incredibly simple as long as you were
already using GMail.
So jump to today;
I have *dozens* of subscriptions and resumes using custom email addresses
that *actually* were being relayed by the Google monolith.
Even my PGP key would be affected by a DNS migration.

Luckily I have been playing with containerized MTAs for the last couple months
so I had some foundation to start with.
Not only could I configure and deploy a server rapidly, I knew how to debug it
with `telnet`.
That head start is probably what saved me.
All that was left to do was:
 * SPF
 * DMARC
 * reverse DNS
 * port forwarding and firewalling
 * Cyrus authentication
 * figuring out what Google wants from me before it's willing to just connect
   a server that is *definitely listening* and is *definitely doing STARTTLS
   correctly*, it's not like I'm asking you to *accept an email from my server*
   just *send an email to my server*, it can't be *that* complicated *please*

I still don't fully understand what ritual Google finally relented on.
Some people online suggested that *a* DMARC policy had to be published before
the GMail servers would be willing to acknowledge you.
Others suggested that the `EHLO` name really mattered.
I sent about 60 test emails over the course of 36 hours.
It took until the 14 hour mark for the first one to get through,
but I have no idea what I changed for that magical moment.
20+ hours later, some mysterious queue was just beginning to open the
floodgates on all the rest.

So I have fully migrated off of Google Domains and taken steps to migrate off
of GMail to boot.
I've learned my lesson, too.
Won't catch me dead on GCP.

----

Red Hat also seems to have decided to shoot themselves in the foot this week.
They seem to be fond of disruption over there, and I'm usually in favor.
Even if I don't like what they do (i.e. `systemd-resolvd`),
once in a blue moon they knock it out of the park (i.e. rootless `podman`).
They light a fire under other Linux projects to keep up-to-date with
emerging standards and optimizations (i.e. Python packaging backends).
They've also demonstrated a willingness to pick a fight when it should be
had (i.e. Google *(deja vu?)* cutting off Chromium)

Unlike many people (I'm sure),
I never had a problem with the idea of CentOS Stream.
Hard to fear a rolling release distro when you live on Arch, I suppose.
Losing the stable releases was unfortunate but heavy delays on version 8
guaranteed that some poor news was in the wind.
(For the record: RHEL 8 beta in 2018; RHEL 8 released May 7, 2019; CentOS 8
release *September 24th*, 2019.)
Better for the project to reform into something still useful,
than to buckle and fold under the pressure of maintaining such a major
piece of infrastructure.

That was the point of CentOS in my mind: infrastructure.
Am I ever going to buy a RHEL license for my personal projects?
Of course not.
But my employers are *(too?)* happy to shell out money for software with
security and support guarantees.
Having an open source, ABI-compatible project means that I can develop
tools and experience in a compatible environment.
It also enables developers to keep the RHEL audience in mind when testing
and deploying updates
The only thing better than using custom and purpose-built tooling
is using tooling that I didn't have to write.
All of these were powered by CentOS as infrastructure.

Losing CentOS stable releases was unfortunate, but we move on.
We try to understand what issues and scarcities caused the project to stumble,
and try to fix them in the next project.
Any many people were happy to step forward with their own ideas.
Rocky Linux and AlmaLinux are both great projects that I hope to try soon.

Red Hat now wants to close their source code.
It's a sad day and it's inevitable that RHEL will be the ultimate loser.
Downstream projects will probably migrate towards packaging CentOS Stream.
They will continue to work perfectly for everyone *outside* of enterprise.
Eventually enterprise users will have a mess on their hands,
but deep pockets are not endless pockets.
At some critical mass of developer hours spent,
RHEL will go the way of AIX and Solaris.
In a couple decades we will talk about RHEL the same way sages speak of
mainframes.

I can understand why the barrel was aimed at their own feet,
but I can't understand why no one stopped them from pulling the trigger.

