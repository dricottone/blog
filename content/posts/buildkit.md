---
title: BuildKit
date: "2023-05-29T21:29:33-05:00"
draft: false
---

Taking a few weeks to focus on DIY homekeeping and Eastern European history
has done wonders for my burnout and energy.
I moved through several of my longest-standing TODOs this weekend.
I'm a bit concerned I might overwork myself with this pace, so I'll
probably return to transcribing college notes in June.

----

I now have a fully functioning mail server on my LAN.
Will I ever expose it to the internet?
Probably.
But that's definitely back to the bottom of my TODO stack.

----

I setup a private (Alpine/Arch) package repository and a private container
image registry.
My scattered Dockerfiles and container recipes are being aggregated into a
single repository for centralized and standardized management.
This became possible because I also got around to testing and deploying
BuildKit for my infrastructure.
(More on this to come.)
A similar effort is under way with the build system for my package repository
but that's not quite ready yet.
I swear this won't sit on my desk as a TODO for the next year.

----

Leveraging this streamlined tooling, I upgraded my deployment of sr.ht to use
independent containers for **each** of the ~15 constituent services.

Security and feature releases were a major headache because they (a) required
me to rebuild the entire APK dependency tree, and (b) required a complete
tear-down and re-build of my monolithic container.
Now I can migrate and upgrade the services independently.
Better yet, the reliable `sshd(8)` and `postfix(1)` services never have to come
down.
I'll likely work on a fallback web server to denote that the services are down
for maintenance. Another TODO for the stack...

----

I, much like the majority of `docker(1)` users I'm sure, have been ignoring the
`docker build` deprecation notices for a long time.

For the most part I deploy containers to Raspberry Pi servers, on which I run
rootless `podman(1)`.
But I do most of my testing and development on my significantly more powerful
PC.
The discrepancy of `podman(1)` vs `docker(1)` is hardly insurmountable, and
if anything I appreciate the portability I've been forced to program into my
scripts.
But the architecture discrepancy has been a major headache for years.
It frustrated attempts to organize a private registry.
It has forced a massive degree of duplication upon me, for which I had to setup
*more* systems to account for user *(read: my)* error.

Last week I read about the multi-platform support in BuildKit and decided to
finally bite the bullet of upgrading the deprecated builder.
I did run into a series of strange bugs, for which the only remedy seemed to be
deleting the first builder container I initialize for any user.
It hasn't resurfaced so I guess I'll just let it slide.
Apart from that, I am pleasantly surprised by how seamless an upgrade it was!

Multi-platform builds were trivial to implement.
The non-local push is a brilliant change that I didn't realize would be so
useful until I was using it for everything.
And of course, the heavy caching and parallelism is greatly appreciated.
I've re-organized my entire workflow around BuildKit and a private registry,
with all container images being built on a single host.

```bash
docker buildx build --push --platform linux/arm64,linux/amd64 --tag $registry/example:latest .
```

My understanding is that this would all work well with `podman(1)` as well,
since they replaced their build system with Buildah a while ago.
Slightly bikeshedded names... although some comments suggest that you can use
`--tag` still.

```bash
podman build --push --platform linux/arm64,linux/amd64 --manifest $registry/example:latest .
```

Even more useful, they support manifest manipulation for cross-platform images
that genuinely require independent builds.

```bash
podman manifest create $registry/example:latest example:amd64 example:arm64
podman manifest push $registry/example:latest
docker manifest rm $registry/example:latest
```

But I don't have a powerful build server running `podman(1)`, and that's the
key factor to my decision.
Perhaps... that's another TODO for the bottom of my stack.

