---
title: Systems Updates
date: "2022-11-12T18:32:12-06:00"
aliases:
  - "/posts/systems_updates"
draft: false
---

I've taken advantage of the long weekend to do some much-needed systems
updates.

----

Keeping my Sourcehut instance up-to-date and online has been a major task.
The database migrations *do* fail, and I haven't yet been able to figure out if
that's a result of errors upstream, or of running on unsupported architectures
(i.e. arm64).
Dependencies are heavily vendored, particularly for the services written in
Python.
There are about 16 damonized services in all, communicating through a central
postgreSQL database, an ephemeral Redis database, and a GraphQL API.

That's all fine though.
I have run into issues and they are tangential to (albeit exacerbated by) those
details.

Silent failure on database migrations is the devil's work.
SQLAlchemy's Alembic is a really cool framework but **if you hide migration
errors in the system journal then you are asking for systems to break**.
I sincerely hope that this isn't the *intended* use of Alembic.

It took me a few tries to figure out the creation of an Alpine Linux package
index.
The key is deleting packages *before* re-building, not *after*, when a package
needs to be downgraded.

And speaking of downgrading packages:
Building software for a fixed version operating system has reminded me of *why*
I switched to a rolling release operating system for my personal life.
And why I use containers for all of my long-running services.
Python modules move way too quickly on top of being a dependency hell.

----

OpenSSL is the trendy topic of the month.

There was the high (downgraded from critical) risk CVE to kick the month off.
That ended up being pretty innocuous, but it definitely got people's
attention on the version 3 branch.

Which lined up with Arch Linux pulling the trigger on the version 3 migration.
This has been a *long time coming*.
Several major distributions made that jump long ago.
But the team has been perfectly transparent about the slow progress on the mail
lists.
I have no doubt that such a major ABI-breaking migration on a rolling release
distribution was an engineering marvel, and I can happily say I experienced no
downtime.

----

I upgraded one of my Fedora servers, since version 35 is quickly coming to EOL
status.
I don't actually have much experience doing this.

I have *one* **poor** experience upgrading between Ubuntu versions.
(Now I just use the LTS releases and kill the server by the time support ends.)

I have spun up several CentOS servers with the express intention of *never*
updating *anything*.

I knew that choosing Fedora meant choosing to run release upgrades.
I was counting on Red Hat's reputation (and need to maintain a reputation) to
make this a good choice.
It might be a bit premature to judge Fedora after just one server upgrade, but
right now I'm pretty positive about their approach.
`dnf` and its release upgrade plugins seem to work well.

For the foreseeable future, I think Debian and Ubuntu have the lead on
`cloud-init`-based environments.
But I wouldn't turn down the opportunity (*challenge?*) to work with
Fedora/RHEL in the cloud either.

