---
title: "Playing with Web Services"
date: 2020-04-15T12:24:13-04:00
aliases:
  - "/posts/playing-with-web-services"
draft: false
---

There's been very little movement on this website in the last couple
months. Not because I've dropped its development, and certainly not because
I've been lacking for free time. Rather, I've been playing with my private
network.

I'm generally uncomfortable with standing up web services if I don't thoroughly
understand the risks and consequences. (That's the single biggest reason for
my selection of CGit over GitLab, gitea, etc.) And this posed a significant
challenge to running PHP. *The configuration file was thousands of lines long!*

So I did the only reasonable thing and wrote my own `php.ini` while skimming
the entire PHP manual.

By now, I've stood up a DNS server (via dnsmasq), a SQL server (including
MariaDB and phpMyAdmin), RainLoop, and NextCloud. I'm generally satisfied where
things stand now, so I'm moving on.

Next steps?

1. Encapsulation through Ubuntu Core and snaps.
2. Custom web APIs, probably using Flask. Namely, I want to build a bridge
   between my SQL server and a FullCalendar-compatible JSON feed.
3. Document *everything* on my wiki, in *at least* two ways (system
   configuration and snap configuration).

