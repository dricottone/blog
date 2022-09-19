---
title: "Progress and the lack thereof"
date: 2022-09-18T17:44:00-05:00
draft: false
---

I revisited some of my oldest coding projects this week. It started as an
effort to clean up old messes that really don't reflect my strengths. But
it was fun and nostalgic, and it also helped me appreciate how much has
changed.

----

Like many others, my oldest Python projects were loose Python files that had to
be called directly. Learning to use *main* functions and write modules with
*entrypoints* always comes later.

My oldest Python project *with a build process* used `setup.py` and targeted
sdist and bdist formats. Luckily that's a bunch of technical jargon that
has been thrown out the window in recent years.

`pyproject.toml` has been a long time coming and I welcome it. But I'm afraid
it took too long to get here. All the most searchable documentation for the
file's specification belongs to the *poetry* project, which has plenty of
incompatible extensions to the file.

I think the continued need for `setup.cfg` hampered interest in migration. But
as I coaxed this project into a `pyproject.toml`-based system, I realized that
*setuptools* finally merged support for PEP 621 earlier this year.
Goodbye, `setup.cfg`!

I'm happy with where Python packaging landed. It's a shame it took this long.
Or maybe it didn't take *time*, just the [seccession of the packaging
infrastructure team](https://peps.python.org/pep-0609/) from the rest of the
steering council...

----

Another familiar story: The biggest difference between my old and new projects
is type hints.

I used to typeguard all passed-in arguments as a debugging tool.
(If `int(myint)` fails then clearly `myint` isn't what I want it to be).
This made re-using code a *pain in the ass* at the best of times.

`mypy` does everything I need without adding brittle code. And it's only gotten
better over the years. Projects stopped using type stubs and started annotating
their own code.

I think that typing has also encouraged people to implement their own domain-
specific modules instead of becoming dependent on feature-creeped libraries.
(`npm`, anyone?) Type stubs were a hassle and it was much more feasible to fork
a module, kill everything you don't need, and add the three lines of
annotations that `mypy` needed to be happy.

I think that typing also helped people realize that *if code is hard to
annotate, it probably isn't good code*. Clever programming is and has never
been a good thing. A function does not need to have 11 optional arguments that
fully customize the returned data. *Meta-classes have never been a good idea.*
Sometimes we need a compiler to remind us of that. Unfortunately Python doesn't
have a compiler so we have to make do with static analysis.

Sadly a large population is convinced that typing is bad, and they've taken
over the show for all intents and purposes. Seeing as the steering keeps
getting
[in](https://peps.python.org/pep-0637/)
[the](https://peps.python.org/pep-0677/)
[way](https://mail.python.org/archives/list/python-dev@python.org/message/VIZEBX5EYMSYIJNDBF6DMUMZOCWHARSO/).

----

I came into the Golang community right around the time that modules became a
thing. Several of my oldest projects were not setup for modules, which
honestly surprised me. I don't remember when I started using them. It must have
been a truly seamless transition.

That seems all the more likely given how *easy* it was to update my oldest
projects to use modules.

With that said, I know that I use modules in a slightly unconventional way.
I purposefully do *not* commit `go.sum`. The intention behind that file is to
make build reproducible. Which is a fine goal and all, but it's not *my* goal.
Deleting `go.sum` and beginning every build with `go get -u` ensures that I am
always keeping up-to-date with upstream deprecations and minor version updates.

----

In many ways I consider Go to be the successor of Python. They both have
expressive syntax, and Go's compiler does a great job of type inference.
I've rewritten a few scripts by now and found it a pretty simple process.

There is one particular hiccup between the two. And it bridges two more things
that have changed about my projects over the years.

----

In some of my earliest Python projects, I struggled with module structure.
I was fascinated by the idea of managing multiple clients, servers, and higher-
level utility libraries in a single repo. With common libraries to de-duplicate
implementations.

Over time, I learned that this was a bad idea. It's more difficult to make
packaging work correctly. The imports become messy and code keeps moving
between modules, leading to even *messier* imports.

In Python, flat is always better.

----

When I began using Go, I tried to program in the exact same paradigm. But I
kept finding some difficulty in that pattern, because Go does *not* want a
module to be executable *and* importable.

This requires some context: In Go, a *main* package is something that can be
compiled and executed. And naturally all projects begin with a main package.
My primary workflow is to make changes to a codebase, insert debug logging
statements, and execute the module on test data. Rinse and repeat until the
changed code passes the visual unit test. But if a module contains a main
package, it *cannot* be used in other modules. So at a late stage of
development I have a hard choice: rewrite the module to use an importable
package, or move the importable code elsewhere.

My solution is creating a *common* submodule and moving all useful
functionality into that. The root module remains a main package and wraps
the common library.

I've noticed that the *more common* practice is the reverse of mine: create
a *cmd* submodule that contains one or more main packages. The advantages are
that imports are shorter (i.e. don't need to include `/common` in the package
path and don't need to provide a local name for that import) and that a repo
can host multiple executables. While I concede the former, I don't agree with
the latter. The traditional Unix method is to symlink a core binary to multiple
names, and check the name that was called at runtime to decide which code path
should be followed.

----

This ended up being more of a rant than a reflection, but after sitting on a
draft for a few days, I've decided to publish as-is.

