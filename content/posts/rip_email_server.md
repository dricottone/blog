---
title: RIP Email Server
date: "2023-11-13T19:54:09+00:00"
draft: false
---

RIP my email server,
[2023](/posts/2023/06/disruption-from-google-and-red-hat/) - 2023

As you may have heard, Amazon will soon begin charging an hourly rate for
public IPv4 addresses.
*Fair enough*, you may say, *it is a scarce resource*.
It isn't $42/year scare.
I categorically refuse this highway robbery.

So, it seems I am embarking on a journey to the strange lands of IPv6.
A forthcoming blog post will discuss this in more detail.
In the meantime, there's a more pressing issue.

The only reason I've been able to run my email server is the permanent IP
address afforded to me by AWS Elastic IP (EIP).
I am otherwise stranded in the Midwestern world of awful ISPs that will
never sell me a static IP.
*Why does that matter?*
Even if I gave up on the dream of *sending* mail from a self-hosted server,
it isn't possible to even *receive* mail unless you have a PTR record
published.
Google's mail server
*(the only one that matters, as far as I'm concerned)*
will *not* talk to your server if your domain name and IP address fail the
round trip MX -> A -> PTR -> A lookup.

And it isn't just the static IPv4 addresses that are going to become a paid
feature.
No, this isn't as simple as 'the party being over' for everyone's single free
static address.
Even a *dynamically assigned* IPv4 address will incur the charge.
The only way around this is to convert your stack for IPv6.

*Experts have been saying for years that we need to adopt IPv6.
For decades even.
Time's up.*
Sure, and I'm fine with that.
I'll eat the cost of my own stubbornness.
But losing the PTR record means I have to shut down my mail server.

*Surely AWS supports IPv6 PTR records* you may protest.
No.
*Why?*
Great question.

----

*Warning: pure speculation fueled by dissatisfaction ahead.*

I don't think Amazon is trying to push customers onto their full-service mail
hosting offerings.
If they cared to turn a profit on those,
they'd invest just a bit of money into that engineering team to make the
product at least a little functional.
Also, I don't think enough people put mail servers on AWS to make a significant
impact in that direction.

I don't think that the cost of IPv4 addresses is actually high enough to
*require* charging for them.
Maybe this is a strategic pricing position?
Establish a price that will scare away non-corporate users early.
So that when costs *are* prohibitive,
and competitors are forced to introduce similar charges,
AWS can boast of 'cheaper' prices.

Maybe someone at Amazon is trying to force a mass migration to IPv6.
Could be a principled thing,
or maybe there is some way to profit off of IPv6 addressing.
I honestly can't imagine it, but behind every bad idea is a crypto bro with an
inflated job title.

I don't know too much about how Amazon's networking looks,
but maybe this is as simple as EIP's overhead?
EIP is a very powerful tool,
especially for large organization that have fleets of EC2 instances.
But maybe all that indirection makes for an unsustainable network?

----

I don't really know what the reasoning is, but it sucks.
I had a lot of TODO projects floating around that were going to build off of
this mail server.
I devoted a lot of time to figuring out how SMTP worked in theory,
and how it worked in practice,
and trying to defend my system from web crawlers.
I'm sad to see it go.
RIP.

