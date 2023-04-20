---
title: "Fedora 38"
date: "2023-04-19T21:59:07-05:00"
draft: false
---

Chores and housekeeping.

----

After deciding to skip Fedora 37, I decided to jump on the Fedora 38 wagon
early.
It was generally a smooth process, leaving aside the broken GRUB configs.
I *am* getting pretty good at diagnosing boot sequence issues though.

Note to future self: schedule 1 hour of downtime when upgrading the host OS.

----

A couple weeks ago I also updated my Sourcehut instance.
In part it was to mitigate a `git(1)` vulnerability.
*(Let this be the reminder you need to always use `--` to mark positional
arguments, especially when executing user input.)*
I also wanted to make the jump towards Alpine 3.17, now that the upstream
project has opened support for that release.

As always, migrating Alpine instances is a flawless experience.

I had momentarily thought it would be a good idea to update the PostgreSQL
cluster backing the instance.
Luckily I came to my senses not long after.
I should look into this eventually though.

----

I have put dozens of hours into my Wiki these last several weeks.
Articles about programs now consistently refer to them with the `man` page
section (i.e. `awk(1)`).
Additionally, 'See also' sections have been added with links to
{Arch,{Free,Open}BSD} `man` pages, reference documents, and other Wikis.

I standardized all of my articles about
[SAS](wiki.dominic-ricottone.com/SAS),
[SPSS](wiki.dominic-ricottone.com/SPSS), and
[Stata](wiki.dominic-ricottone.com/Stata).
I'm starting to stub out articles for R based on them.

I've made significant headway with populating my Wiki articles about
[shell](wiki.dominic-ricottone.com/Shell),
[bash](wiki.dominic-ricottone.com/Bash),
[Docker](wiki.dominic-ricottone.com/Docker),
[Podman](wiki.dominic-ricottone.com/Podman), and
[python](wiki.dominic-ricottone.com/Python).
The last one in particular has much work left.
Once that is complete, I'll look towards
[JavaScript](wiki.dominic-ricottone.com/JavaScript) and
[Node](wiki.dominic-ricottone.com/Node),
since there's so much overlap there.
I also consistently need to lookup the references for quick-and-dirty web
programming, so I think it will be a solid investment of time.

