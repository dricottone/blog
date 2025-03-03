---
title: Why I have stopped hosting my own gitweb
date: "2025-02-02T03:59:52+00:00"
draft: false
---

In short,
it stopped being fun.

I *started* using sr.ht because it is an innovative and against-the-grain
technology.
It is bold in its simplicity.
And more trustworthy,
in my subjective opinion,
because of its simplicity.
It challenges norms of all-encompassing web services powered by user-generated
data and algorithmic feeds.

Also, it is very friendly to/compliant with low-power hardware.
We live in an era when people are accustomed to throwing an AWS account with a
corporate credit card at any and every problem.
My 10 year old PC is considered so obsolete,
Windows 11 is not installable.
I run all of my services on Raspberry Pis and dirt-cheap cloud instance.
Full-stack ARM,
regardless of premises.

As an aside...
I'm amazed at how quickly ARM went from *amateur hour* to *next-gen*,
but sadly it required the Apple price sticker.

I continue to be a huge fan of sr.ht,
which is why I have migrated my projects to the official instance.
But I will no longer run my own instance.

----

And no:
it's not *too hard* to run a sr.ht instance.
It was actually a lot of fun.

It *definitely* is a lot of work to setup.
(Especially when you insist on running with unsupported hardware,
virtualization, and init systems.)
Every step was a real challenge,
but also a learning opportunity.
Hosting email,
cross-compiling for ARM and musl libc,
making multi-platform and rootless Dockerfiles and containers,
etc.
I have taken a lot of great lessons from this experience.

But *keeping these things running* is the real challenge,
and a largely *un-fun* one.

Recently
(as in, the last year or so)
the challenge has been exacerbated by web crawlers.
I do not know the true reason but aggressive and `robots.txt`-ignoring crawlers
have become incessant.
Many people online assert confidently that AI training is the root cause;
take it with a grain of salt.
I can keep HAProxy and NGINX up despite this;
these are true production-line applications.
I cannot keep GraphQL APIs and Python-rendered web services up.
There are hundreds of downtime reports in my uptime monitor.

----

I had similar issues with my wiki,
powered by MoinMoin
(and thus also Python-rendered).
The situation only improved when I...

 1. blacklisted large IP blocks
 2. adopted Cloudflare tunnels

I implemented (2) only out of necessity.
AWS stopped offering free IPv4 addresses,
but I could use Cloudflare to proxy IPv4 over the still-free IPv6 address.
I don't actually *like* Cloudflare proxying.

I also don't like (1),
it is contrary to my ideals of open internet.

At some point,
I decided my wiki was a project more important than those hang-ups.
I *don't* think that gitweb hosting is, too.

----

My interests right now lead in other directions.
I will not muster through and maintain my sr.ht instance.

The instance will be taken down imminently.
The TLS certificate had already been allowed to expire.
All of my projects have migrated off of those URLs.
I am not aware of any downstream users,
but if there are any...
sorry!

