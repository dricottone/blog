---
title: Logging and Rate Limiting, Take 2
date: "2023-08-08T12:12:32-05:00"
aliases:
  - "/posts/logging_and_rate_limiting_take_2"
draft: false
---

*Effectively a sequel to [Rate Limiting](/posts/rate_limiting).*

----

Spamming and crawling on my servers has gotten to a problematic level again,
so I've been deploying a log aggregation system.
I had hoped to keep things simple but it seems there is no such thing as
*simple* logging.

So instead I've chosen a Grafana <-> Loki <- Promtail <- syslog stack.

----

The last time I wrote about rate limiting my servers,
I mentioned some of the challenges to blindly applying restrictions.
Uptime monitoring was my only real metric.
It took months of tuning to land in a decent place...
and clearly it was not a *lasting* peace.

I had experimented once before with Grafana and Prometheus,
but I quickly realized that it wasn't useful to me.
It sits in the awkward position of making lots of useless statistics
readily available for services that really don't need it.
The *sum total of requests* and *proportion of server error responses*
aren't meaningful for me,
especially when NGINX is the *last* piece in my stack that I'm worried about.
These can be useful monitors for major operations that have to worry about
contractual uptime or DOS attacks.
But for little old me,
I'm just trying to understand if there's any trends to the annoyances.
Such as, *would GeoIP blocks have a meaningful impact?*
*Are there obviously fake endpoints that I could monitor and ban requesters?*

It would certainly have been useful to know how close my
[wiki](https://wiki.dominic-ricottone.com) was to triggering surge protection
over time,
but that's a great example of a service that doesn't provide
Prometheus-compatible statistics.

So Grafana and Prometheus is just an uninteresting proposal to me.

But Grafana and *Loki* is another story.
I mean, Grafana is still overkill,
but I'm not going to write a zero-code dashboard frontend on a whim.
At least I have a new and pretty server to host it.
Loki and LogQL really are fantastic though,
the perfect compliment to Prometheus for log processing.

----

When I wrote about my decision to host a mail server,
I *did* mention there were many challenges along the way...
but nothing about how I tuned the security model.
That's because my security model was essentially obscurity,
and a blog post would be counter-intuitive to that model.

There's actually *zero* security.
The strategy was to make the server a *completely uninteresting* target.
The DMARC policy is so strict that it's impossible to pass.
(Being that the DKIM key is non-existent.)
The server is really only capable of relaying mail,
and I check the outbox every week to make sure that I tightened those rules
well enough.

Obviously not a long-term plan, but it worked.
Until it didn't.
Which is now.

I knew that I was getting hit *hard* by scanners.
But because Postfix is administered as a spaghetti mess of daemons,
the logging story is not a pretty one.
In the end I decided that all pegs fit in a square hole and funneled
*all* logs from the relevant Docker containers into a syslog server.
(Which *itself* is a problem, because Podman does not support this logging
driver... but the Dominic of tomorrow will solve this one.)

And what did I find?
Mr. `45.129.14.99` has been hammering my server every 3 minutes for days!
Probably weeks!
They don't even have a legitimate A or MX record for `burns.choletweb.com`.
Which was the first obvious win for me:
requiring a valid `HELO`/`EHLO`.
Such a simple requirement to put on clients,and it kills off 99% of the scanner
connections.
I never would have known about it if I wasn't processing logs this way.

Still, it revealed that scanners are quite clever about rate limiting.
3 minutes is actually quite a generous period.
I likely have nothing to gain from a more thorough timeout scheme.
And again, simple statistics about connection rates would have been completely
inactionable.

----

If I have one complaint,
it's how complicated the system is.
It isn't a terribly fun development cycle;

 1. re-configure Promtail with a new data pipeline
 2. test the configuration by re-launching the service, hoping it doesn't crash
 3. re-launch the Loki database to clear data
 4. try the query again in Grafana
 5. try a *different* query in Grafana hoping it isn't an issue in the pipeline
 6. realize it *is* an issue in the pipeline again
 7. repeat

This is just a natural consequence of an over-engineered,
too-clever-for-it's-own-good product.
But it really seems the only other option is ElasticSearch,
so here I am.

At least I still get to use syslog.

