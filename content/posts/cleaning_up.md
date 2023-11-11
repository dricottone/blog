---
title: Cleaning Up
date: "2023-11-11T20:22:52+00:00"
draft: false
---

I've restructured the way permalinks are generated.
While I do prefer underscores for file names,
URLS are decidedly cleaner when using dashes.
Luckily Hugo already has a concept for this (`:slug`) so it's as simple as
setting the permalink template with that 'variable'.

To prevent breakage of existing links, I've set up aliases.
That's another very convenient feature of Hugo.
I've also seens some recipes online for creating aliases automatically.
I'm not currently sold on the idea of setting up named aliases for all posts
going forward,
but I'll revisit that in the new year.

And since I'm doing all of that, I decided it's also time to organize
permalinks based on publication date.

----

I've significantly reworked my development workflow in the last couple months.
It's become a headache to try and keep all of my internal toolchains,
script interpretters, and document processors up-to-date across all of the
hosts I use.
For a long time, I liked to think that I sidestepped this issue by using POSIX
scripts.
But *apparently several distros feel otherwise*.

It's not even Red Hat that I'm specifically frustrated at right now.
It's come to my attention that `ed` isn't installed by default on Ubuntu.
Now I know, few people care about `ed`, I'm in an extreme minority.
It's still POSIX.

So I've centralized all of those installations to a single host
*(on public internet,
but without any compromisable servers running,
and requiring an SSH key for login)*,
and it `rsync`s built files to a separate web server only accessible on my
VLAN.

Anyway, that's prompted a gradual revisiting of all of my `Makefile`s.
It's sometimes interesting to see how my approach to those has changed over
time.
Clearly 4 years ago I was obsessed with parameterizing them.
I think my current attitude is to keep them file-oriented, and anything more
complicated is pulled out into a separate script.
Many of my projects now feature a top-level `scripts` folder.
*(This is also why keeping my script interpreters up-to-date was such a
hastle.)*

