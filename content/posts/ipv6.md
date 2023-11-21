---
title: IPv6
date: "2023-11-21T01:21:06+00:00"
draft: false
---

What follows is my journey on adopting IPv6-only addressing for my cloud
server.
And therefore, also a journey on adopting the dual stack for the ~~rest~~
*most* of my other hosts as well.

----

In all *important* ways, IPv6 begins with DHCPv6.
*(The format of an address really doesn't matter, I don't know why so many
people are hung up on the 'readability' of IPv6 addresses.)*
The big idea of IPv6 is that everyone and everything has a unique address.
So when I enable IPv6 on my router, where do the addresses come from?

If you follow the technical notes for your networking equipment,
you'll probably start seeing things about 'SLAAC' and 'prefixes'.
Don't let your eyes glaze over just yet!
It's all relatively simple.

*If* your ISP has provisioned an IPv6 address for routers, then your router
will receive it automatically.
*Otherwise*, your router assumes control over an IPv6 address based on SLAAC,
which basically just means that it's adopting an address built from the
supposedly unique MAC address.
then the router requests a prefix from the ISP,
and *if* that works *too*,
your router can start assigning IP addresses to LAN devices.

Sounds like a thoroughly dynamic system with half-dozen points of failure,
doesn't it?
My favorite.

----

The hardest part of adopting IPv6, unsurprisingly, is DNS.
Specifically any platforms that don't mirror the Unix resolver system.
No, that's not *just* a dig at Windows.
`systemd-resolved` in it's *infinite wisdom* has *also* eschewed decades of
expertise for a crusade against the windmills.

The crux of the issue is that,
on these systems,
DNS servers are not tried sequentially (i.e. per the resolver file).
The last successfully queried DNS server is sticky.
Split horizon networks need not apply.

This becomes much more complicated with IPv6 enabled.
IPv6 addressed DNS servers are prioritized *over* IPv4 addressed ones.
This is, I suppose, a reflection of IPv6 as a replacement for IPv4.
I can appreciate the rationale here.

Ultimately this comes down to the tooling available.
The systems surrounding IPv6 networks are still far from perfect.
For instance, while my network equipment supports *enabling* IPv6
(i.e. it ships with a DHCPv6 service installed),
I can't *reserve* a static IPv6 address for my personal DNS servers...
You can probably see where this is going.

My servers aren't durably addressable by IPv6, even within my VLAN.
On any machines running Windows or `systemd-resolved`, my DNS servers won't be
the first ones tried.
I'm stuck firing bad DNS queries at a public IPv6 DNS server until my machine
decides to cache them as non-functional.
And if I ever need to access an IPv6-only service, I'm brought back to square
one.
What a ridiculous situation.

----

My solution?
Undefined behavior.

There's a block of IPv6 addresses reserved for mapping to IPv4 addresses
through a mechanism called 6to4.
These are all found by appending (as hex) the IPv4 address to `2002::/16`.

Wikipedia says:

> Note that using a reserved IPv4 address,
> such as those provided by RFC 1918,
> is undefined, since these networks are disallowed from being routed on the
> public Internet.
> For example, using 192.168.1.1 ...

So it would definitely be a bad idea to set my IPv6 DNS server
to `2002:c0a8:5602::` (which maps to `192.168.86.2` FYI),
right?
Actually it seems to work just fine.
And that's what I'm going to stick with.

----

Next challenge is updating my services to listen on IPv6 addresses.
I start by looking into HAProxy and drafting some sample configuration lines
but...
a thought strikes me.
I don't usually worry about what address I set HAProxy to listen on because
I abstract all of that away through Docker/Podman.
Will that work here...?

Yes, it will.
I just have to add the IPv6 catch-all address to the publish option there.
Done.

----

One option available to me now that I'm switching (some of) my services to IPv6
hosting is to give each a dedicated IPv6 address to listen on.
AWS VPC offers a /56 block, after all.
Something similar seems to be available on GCP, too.
But I'm a bit concerned about the reliability of IPv6-only.
I don't know how many networks that I use are IPv4-only.
I might need to figure out some clever tunneling between my home network and
AWS.
I found a (decade old) question on StackExchange providing a recipe for such a
solution.

```
socat TCP4-LISTEN:22,fork,su=nobody TCP6:[2a01:198:79d:1::8]:22
```

I think something should be possible with HAProxy too.

But after sleeping on this problem for a few days, I recall another overlooked
option: Cloudflare proxying.
They have no problems with relaying IPv4 connections to an IPv6-only host.
And since I'm going to be indefinitely stuck on their mail relays,
I might as well jump in the deep end with reliance on their services.

One complication: I can't SSH into a proxied host name.
So this doesn't solve the problem that I need all of my other servers to
have a working IPv6 gateway.
Although realistically my final solution will be a dual stack jump box
and SSH proxying.

Also, it's incredibly strange to me that Cloudflare doesn't *default* to a
strict SSL/TLS configuration.
I had to go in and update that just to get my site back online.

