---
title: "WireGuard"
date: 2022-09-28T20:05:20-05:00
aliases:
  - "/posts/wireguard"
draft: false
---

I am throwing in the towel.

For years I have *somewhat maintained* a VPN powered by WireGuard.
At first it was a simple configuration following the Arch wiki's section
on point-to-site.
That worked well enough, but didn't accomplish much.
Honestly, all I got from that setup was using a custom nameserver on
my carrier-locked phone.

Then I decided to set up a split tunnel that would forward WAN traffic
through a commercially-available VPN,
but forward LAN traffic into the WireGuard interface.
That naturally required a centralized bounce server that could forward packets.
That was ultimately an unsuccessful project.

The sticking point was my phone.
Every PC and laptop worked perfectly.
But the moment I stepped outside, my phone's DNS queries went into a black
hole.
Successful handshake;
I could ping the bounce server;
*absolutely nothing else worked*.
I'm 90% certain it had something to do with my carrier's IPv6 exchange messing
with the NATing I tried do within my VPN.
Which is difficult enough to research because entering "ipv6" and "nat" into
a Google search will *not* return anything helpful.

Amazingly, the closest I ever came to a functioning configuration was when I
setup a *second* bounce server in the cloud.
My phone could actually connect to AWS reliably
(*more cause to think it's IPv6? AWS certainly has working IPv6 routing...*)
and my WAN traffic was *definitely* going through the commercial VPN.
And *sometimes* I could even ping my other WireGuard clients.
But the times when it would fail were inexplicable, at least for me.

So I guess what I learned at the end of the day is *I don't understand
networks*.
I do *not* understand how IPv4 and IPv6 interact, or
how packets are forwarded between hosts, or
how to make the wheel-and-spoke VPN model work.

I have thrown in the towel;
my WireGuard network is now purely peer-to-peer connections.
It works well.

