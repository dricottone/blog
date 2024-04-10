---
title: Control Your Dependencies
date: "2024-04-08T17:00:10+00:00"
draft: false
---

I spent a few weeks hacking on an OSS project that I used to follow very
closely:
[ncspot](https://github.com/hrkfdn/ncspot) .
The tl;dr is that it is a curses-interface to Spotify.

It's a great program but it's also become quite bloated in the last few years.
Dozens of feature requests--
and to be clear, they often do come with contributions and PRs--
have grown the scope of `ncspot` enormously.

And that necessarily means that startup takes longer.
There's an annoying 3 or 4 second freeze on a black screen while `ncspot`
synchronously fetches *everything*.
The search functionality,
which runs across *all* indexes (artists, albums, songs, etc.),
has a similarly-jarring pause.

And the memory consumption has ballooned.
I think that `ncspot`'s runtime would probably be negligible for anyone who
*doesn't* have 6,000+ saved songs,
to be fair.
But `ncspot` eagerly fetches everything, and maintains a `serde` sort-of
database in-memory and on-disk.

And there are so many dependency crates now.
Compilation takes *forever*.
The repo,
with all the debug and release build artifacts,
is large enough to show up when I run `dust` to try and recapture some drive
space.

And the network-facing clients are increasingly brittle,
as Spotify continues to evolve and impose new restrictions on the API,
while `ncspot` is stuck operating on the only API wrappers that can offer the
maximal set of features.
There have been several tickets requesting support for the Spotify Connect API,
enabling a daemonized player decoupled from the interface application.
These have been closed as impossible given where the project stands.

For a long while, I maintained a tiny private fork.
All I did was kill the functionality for modifying my Spotify saves.
Effectively I made `ncspot` read-only.
I was eternally bothered by the hassle in tracking down a song that I
accidentally 'deleted'.
My patch was essentially just killing code that I didn't want to ever run.
And that was sufficient for a long time.

----

Recently I decided to aim higher.
I killed dozens of the features I did not want.
I won't bother listing them here, because the story does not end happily...

The next phase of my plan was to simplify the operational data model.
Almost all function calls require a *copy* of the in-memory database
(`library`),
the event manager (`events`),
and the playback queue manager (`queue`).
`events` also wraps the input sink.
`library` also wraps the Spotify API client.
`queue` has a reference to *both* `library` and `events`.

Most components of the user interface also call for references to these core
objects,
sometimes just for the sake of storing them so that child interfaces can be
initialized with their own references.

These core objects are `clone`d *everywhere*, **over and over again**.
It's a massive pile of code smell.

A long time ago,
in a ticket I won't try to track down,
someone suggested that global variables be used instead.
They recognized that it's not best practice but argued that the codebase was
becoming too complex for any other solution.

The 'real solution',
I said to myself back then and again now,
was to intelligently pass a reference to a core struct.
Be mindful of access and mutability and use mutexes as needed.
That's what I started to implement.

----

Where does this adventure lead?
Lifetimes.
It's always about lifetimes.

The codebase is, of course, making use of the `tokio` crate.
Not extensively of course;
there's still plenty of synchronous API calls.
In fact it's mostly just used for authentication and search.
But the runtime is there, baked into a mutexed global variable.

I realize now that significant bartering had to be done by arcane wizards to
make the `tokio` runtime play well with the `cursive` crate.
Arcane, awful spell-crafting that make it fundamentally *impossible* to pass
anything (else) as a reference.

(It's not actually impossible.
But it would require re-implementing many traits that I barely understand.)

----

I made another, similar pass at converting the API client to be entirely
asynchronous.
This attempt died young.
I recognize now that asynchronous programming in Rust is hard.
I'll stick to Go, thank you very much.

----

The title is a reference to Tsoding's
[Control your dependencies](https://www.youtube.com/watch?v=A_g6jfLx3ws&t=1288s)
.

My fundamental problem with trying to hack on this codebase is that I did not
have control over the dependencies.
I tried to kill as many of them as I could,
and it still wasn't enough.

I realized that I needed to start from scratch with a dependency chain I
*could* control.

----

When it comes to curses-like libraries,
my first pick is and always will be `tcell` and the derivative 'widget'
libraries (`tview` and `cview`).
I have implemented my own widgets from scratch before;
it's a remarkably simply process.
But other (smarter?) people have written general-purpose widgets that will
almost certainly cover a new project's needs.
It also helps that there's such a wealth of demo and example programs to
borrow from,
between the three codebases.

In three days,
I had a working replacement for `ncspot`.
Compared to it, new features include:

 + Asynchronous Spotify Connect API.
 + Lazily fetching songs from Spotify as the user interface is scrolled,
   cutting down on memory and computation resources.
 + Unbelievably fast compilation time.

There's some functionality I still need to re-implement, like:

 + Logging to a file.
 + Showing the playback queue as a third 'tab', and showing help information
   on a fourth 'tab'.
 + Functionality for clearing the playback queue.

Eventually I'll also get around to styling the user interface.
But black and white is perfectly serviceable for now.

And probably a little `bash` script to startup a
[spotifyd](https://github.com/Spotifyd/spotifyd)
or
[go-librespot](https://github.com/devgianlu/go-librespot)
daemon if one isn't running,
to more completely emulate the old behavior of the embedded player.

There's plenty else that I've purposefully removed and will not be re-
implementing.

----

I also have this idea in the back of my head.
Sometimes I run into a Spotify playlist on the internet.
It would be cool to have a separate mode of operation that,
instead of reading the saved songs library,
it reads that playlist alone.
This would probably be gated behind a CLI flag like `playlist=foobarbaz`.
I don't know,
I'm still thinking about it.

----

Oh, and there's been a huge mess on the internet in the last couple weeks.

`redis` went nuclear.
Everyone who wasn't controlling their key-value storage dependencies must be
sad.
I'll be ready to jump into
[redict](https://redict.io/)
or
[placeholderkv](https://github.com/PatrickJS/placeholderkv),
whichever emerges as the popular replacement,
at any time.

`xz` was backdoored by a long-time contributor.
Pretty scary.
Luckily this was caught by a bunch of people who
(on behalf of the wider Debian and Fedora ecosystems)
were controlling their dependencies.

Crazy times we live in.

