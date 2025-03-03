---
title: Music File Metadata
date: "2025-03-03T01:18:51+00:00"
draft: false
---

`ffplay` told me that my music files had invalid tags,
so it was ignoring them.
What gives!

Well,
I *do* recall reading that ID3 tags were meant only for MP3 files,
but my workflow consisting of `id3tag` and `id3info` seemed to be working just
fine for my FLAC files,
too.
Apparently that wasn't a good thing though.
FLAC files really should use Vorbis tags,
actually.
Oops.

My bad,
what's the fix?

I found a
[2013 forum post](https://hydrogenaud.io/index.php/topic,36283.html#msg852884)
that prescribed a fix.
It boiled down to:

```
metaflac --export-tags-to=$temp.metaflac $input
id3v2 -D $input
metaflac --import-tags-from=$temp.metaflac $input
rm -v $temp.metaflac
```

First issue though,
`metaflac` was not appreciative of the character encoding of ID3 tags on my
files.
ID3 v2.4 was the first (and only) version of ID3 to use UTF-8.
Meanwhile `id3tag` uses (used?) v2.2 and v2.3,
and they effectively use UTF-16.
Actually UCS2,
but I'm comfortable enough saying that for all of *my* files the two are close
enough,
and I know enough about UCS2 to not want to know anything more.
Also `id3tag` sets v1 *and* v2 tags,
for maximum compatibility,
and *yes* these are duplicative.

You can see a running theme of tools not keeping up with the times.
This isn't actually surprising if you know that,
under the hood,
the `id3*` utilities are all CLI wrappers for id3lib,
which has effectively gone unmaintained for 1 or 2 decades--certainly has been
unmaintained for as long as v2.4 has been a thing.

I also didn't like the idea that my solution would require so many disparate
executables.
I would like a set-and-forget solution that I can compile once,
store somewhere,
and pull out of the dust bin anytime in the future.
I started counting:
`metaflac`, `id3v2`, something else to work around the above issue with
`metaflac`...
plus my existing workflow using `id3tag`, `id3info`...
plus something new for tagging FLAC files (probably `metaflac`, but still
hadn't tested it out)...
any probably a new script to wrap the old workflow and the new one safely...
This was becoming a real pile-up!

Let's see about replacing some of these executables with a custom tool.
As they say,
in for a penny,
in for a pound.

----

The successor to id3lib,
known as taglib,
did not prove helpful.
There are bindings for the library in most languages.
However, the library itself does a much better job of enforcing tag
specifications.
For one,
*only* ID3 v2.4 is directly supported,
so the library is heavily oriented around UTF-8-only strings.
You have to play around with initialization functions to use any other
character encoding.
At minimum two passes would be required to repair files,
because I would need to declare the 'wrong' encoding to export and then the
'right' encoding to import.
I've worked with text data enough to know this is already a code smell.

For another,
while there are bindings for the library,
they don't usually expose those initialization functions.
I went down a rabbit hole of using bindings,
then using the library directly
(sort of--taglib is a C++ project and by 'directly' I mean in plain C, through
a wrapper),
then finally forking the bindings to match my C implementation...
I did nonetheless decide that this demo was a good starting point for a
custom metadata exporter,
and kept the code.

Adding one final bit of trouble,
*only* ID3 v2.4 is directly supported,
so the fun flip-flop of v2 tags being **prepended** to a file blob
and v1 tags being **appended** isn't properly addressed.
Plainly,
there isn't an API for truly *stripping* tags from a file.
In the v2.4 world,
tags are in one place and removing a tag means unsetting it.

I decided that my best available options were:

 1. Parse the output of `id3info`
 2. Build my own metadata exporter on id3lib

Regarding (1),
I quickly realized that the output is only barely legible if you have the
source code open on another screen.
In for a penny,
in for a pound...

----

I was in for a rude awakening.
I knew by this time that the id3lib project was abandonware,
but I've honestly never had to use `cvs` to checkout a library.

It took considerable work to convert this to a Git repository
(which you can now browse
[here](https://git.sr.ht/~dricottone/id3lib) ),
but I learned a few things along the way.

Next stumbling block as actually compiling it.
This code base is *severely* out of date.
The Arch package incorporates almost a dozen patches.
I'm choosing to ignore most of them...
although it seems there is a concerning bug in the UCS2 processing.
But I have beaten code to death with `gcc` before,
and I was determined to do it again.
(Yes,
I could have used the package instead of compiling myself,
but this turned out to be very helpful.)

Final hurdle:
using the library!
I found bindings for taglib on GitHub and used them as a template to get
started.
I only needed to access three or four functions,
it was a breeze to write a simple API,
and it compiled first time.

Running it though... revealed a major flaw.
It wasn't doing *anything*.
As in,
the file was entirely unmodified.

I spent a couple days inserting `printf`s into the id3lib source code
(see, it was a good idea!)
just to convince myself that I was calling all of the functions correctly
and handling all of the realistic errors.
I won't describe it all,
because the issue was painfully trivial.

The documentation's 'getting started' is essentially:

```
#include <id3/tag.h>
ID3_Tag myTag;
myTag.Link("song.mp3");
```

And at the bottom of the page,
it says
"When you're ready to save your changes back to the file,
a single call to Update() is sufficient."

I had figured that all I needed to do was insert a call to `Strip()` in between
those steps and I would be all set.
Wrong!
Firstly,
if you have succeeding in stripping ID3 tags from a file,
calling `Update()` will **re-create** them.
*Fun!*
Secondly,
it is critical that you call `Clear()` on a `ID3_Tag` value after stripping it.
*Totally reasonable!*

But finally things are sorted out.
And between this and my taglib-based metadata exporter,
the fix is looking more like:

```
./tagger dump $input >$temp.metaflac
./tagger strip $input
metaflac --import-tags-from=$temp.metaflac $input
rm -v $temp.metaflac
```

But now I'm 2 for 3 on replacing tools;
you know what comes next.
In for a penny...

----

This is where the story ends.
(*For now...*)

I sat down with a range of FLAC tools,
to see how Vorbis tags are actually used and manipulated in the wild.
One oddity became apparent quickly:
`ffmpeg` appends an `ENCODER` tag to any file it touches.
Well,
actually it appends an `encoder` (lower case) tag.

This is something that taglib simply will not stand for.
Not to sound like a broken record,
but...
this library does a much better job of enforcing tag specifications.
For one,
taglib will *rewrite* the tags of any file it touches to enforce casing
conventions (i.e., all upper case).
This is a pretty big deviation from `ffmpeg`,
as noted above.

For another--and I'm not actually yet sure if this is part of the spec--
taglib insists on re-sorting all tags alphabetically.
There is no *live and let live* here.

I decided to circle around,
and--yep--taglib is similarly poorly behaved for ID3 tags.
Setting the artist of a song
(generally considered as the ID3 tag `TPE1`)
will also erase the album artist (`TPE2`).
And it is thoroughly displeased by the presence of embedded album art (`APIC`),
so naturally that will be silently stripped.

Altogether,
while taglib offers a helpful API for *reading* a file,
it is *not* the library to use for anything potentially destructive.

