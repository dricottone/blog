---
title: "Return to self-hosted form"
date: 2022-09-14T15:56:55-05:00
aliases:
  - "/posts/return_to_selfhosted_form"
draft: false
---

Happy to say that I'm back self-hosting (some of) my servers. Notably, I spent
a couple weeks spinning up an instance of Sourcehut on my Raspberry Pi. It was
a ton of fun getting that to work, especially since ARM architectures are
firmly unsupported by upstream.

Several of my servers remain off-premises. My blog, which I see as the entry
point for discovery of my web services, really ought to never go offline. I
can't realistically expect that sort of uptime with a residential network.
MoinMoin is still the bastard child of my deployment, being stuck in
unsupported versions of Python and Alpine Linux. (Planning to work on that
later this year.) And I'm planning on spinning up a WireGuard node in the
cloud, as some of my hardware depends on IPv6 while my home network can't fully
support it. Realistically, these servers are here to stay.

----

While I was slowly working on my server infrastructure these last few months,
I've been going through all of my older coding projects.
Upgrading the packaging to modern standards has helped me realize how much has
changed in the last decade. Another blog post to come shortly.

