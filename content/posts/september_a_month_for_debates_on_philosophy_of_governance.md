---
title: September, a month for debates on philosophy of governance
date: "2025-10-10T20:55:05+00:00"
draft: false
---

Open source software communities have been having a tough time with governance lately.
September saw several crises, namely:
 1. The community-maintained projects under the RubyGems umbrella were taken over by Ruby Central,
a corporate entity entirely beholden to a single sponsor.
 2. The Nix community imploded over power clashes between the steering council and moderation team.

I can recognize up-front that there's a lot of nuance in these situations.
I've only wandered into these debates,
not really caring about either community personally.
But I want to comment on a recurring theme I've run into on these wanders:
*who has the democratic mandate?*
This is most evident in the Nix community,
where a call for clean slate elections has collected substantial support.
(Ordinarily,
only four of seven seats on the steering council are up for election.
There is an additional seat up for election now due to an early resignation.)
I've seen assertions that resigning early is a betrayal of constituents,
accusations that confidence has been lost among the polity,
and so on...
and above all else:
a baseless assumption that a democratic mandate is required.

Separately but related,
there's been joking references to 'Rustaceans' jumping into the debate,
just to suggest adopting the Rust governance model.
This may or may not be a false flag operation.
For one, Rust is an extremely successful open source project.
For another, the systems for accountability that they've innovated have proven themselves in past
[incidents](https://blog.rust-lang.org/2024/11/06/trademark-update/).
At the same time,
such a deeply institutional governance model is off-putting
(uncomfortable?)
to more anarchic communities.

----

Stepping into an aside for a moment...

I've been reading a recent article by
[Niessen, Mueller, and Reuchamps](https://doi.org/10.1017/S175577392510009X).
They write about preferences toward democratic innovations in states with salient subnational identities.
Put more plainly,
they try to explain why people don't necessarily want referenda and direct democracy.

I explained the premise to my wife,
and to paraphrase her reaction:
'Duh. But *someone* has to prove the obvious.'
In the academic fields of political science and international relations,
I can hardly imagine a more lukewarm take than 'perhaps a democratic mandate does not always offer legitimacy'.

I could perform a large survey of such theories and frameworks.
In fact I started to.
But it quickly became superfluous to the point I am trying to make.

Instrumentalism is a durable motivation.
People who will 'win' a referendum prefer referenda.
People who will 'lose' it prefer the status quo.
Whether or not the status quo is legitimate,
and whether or not a referendum is legitimate,
are *subjective*.
There is no *objective* value to a democratic mandate.
I don't think this is a hard concept to get behind.

Ramble over...

----

There have been novel academic efforts to classify governance models in open source software;
see
[Ritvo, Hessekiel, and Bavitz (2017)](https://clinic.cyber.harvard.edu/wp-content/uploads/2017/03/2017-03_governance-FINAL.pdf)
for example.
The authors identify 4 classes based on a number of criteria.
There are a set of projects they identify as having non-democratic governance models.
Sometimes they prefer the label of 'meritocracy'.
In others, the concept of a 'benevolent dictator for life' or BDFL is not strange.
But I want to focus on is the prominence of conflict resolution in this classification scheme.
Are decisions handed down from above?
Is decision-making delegated?
Are decisions subject to formal voting rules,
or informal consensus norms?

The fact is that all large communities involve delegation of moderation.
In open source software,
the software comes first;
the cultivation of a community follows.
The skills that enable someone to make good software do not translate to those subsequent community-oriented challenges.
Moreover,
those community-oriented challenges are a *slog*.
Turnover and burnout are real issues.
There must be delegation of moderation to a large and dedicated team.

I point first to the tragedy of the python-dev mail list.
The list was
[practically moderated by a single core developer](https://mail.python.org/archives/list/python-dev@python.org/message/PYRZRPDJRVVJVICEC3N4YLR2XG2A7SEC/)
before
[Discourse was selected as an official replacement](https://mail.python.org/archives/list/python-dev@python.org/thread/VHFLDK43DSSLHACT67X4QA3UZU73WYYJ/#7BKLNTBUYLXY2WONH6AD2L3XMU6AYTGK).
A major factor in that selection was moderation.
There was a
[sizable team](https://discuss.python.org/about)
already in place.
There were absolutely complaints at the time,
and I have no doubt that some people have been pushed out of the community.
It just doesn't matter, though.

I point now to Tiny Tiny RSS (a.k.a. tt-rss).
Fox, the project's founder, is famously controversial and inflammatory.
He also 'moderated' the forum
(which doubled as the project's technical support platform)
personally.
After **two decades** of open source work,
he announced that he had lost the energy to continue,
and so the whole project would be taken offline.
(Another developer has since taken on leadership and moved things over to GitHub.)
It is clear to me that even the most irreverently autocratic of projects cannot sustain itself without delegation.

----

People need to stop looking at open source governance with the assumption that democracy will resolve all conflicts.
Fundamentally these are challenges of team-building and project management.
There are many plausible solutions,
and many (sometimes conflicting) goals.
Some of those solutions may happen to coincide with a democratic mandate!
But they are not solutions *because* of it.
Above all else,
the priority must be maintaining cohesion between the people who are already in the room,
putting in the long hours,
keeping the lights on.

I am not proposing a solution to either of the crises listed above.
I just want to state that interfering with the mods is *not* the solution.
Filippo Valsorda
[said](https://bsky.app/profile/filippo.abyssdomain.expert/post/3lxpaf6przj2r)
it best,
"an unpopular opinion of mine is that mods are always right."

(Do note that his statement was incited by another, completely unrelated event,
also in the open source sphere,
but in *August*.)

