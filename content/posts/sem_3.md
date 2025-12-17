---
title: A Series on SEM - Part 3
date: "2025-12-12T18:35:50-06:00"
draft: false
---

This is a relatively minor update on my saga of tacking the many-headed beast
that is structural equation modeling (SEM).

In the process of figuring out lavaan,
I've decided that it wasn't appropriate to constrain the variance of residuals
to be equal in every year.
Fine-tuned control over what is random is a pretty big selling point for SEM
(or mixed modeling in general)
over random effects modeling.
Fixing the residuals in that way just isn't a fair representation of the field.

----

So what does this decision actually mean?
First and foremost,
what I presented as the `-sem-` model has been updated.
The interpretation of the model has not changed in any meaningful way.
Actually I gained back more degrees of freedom,
which should make the model *more* identifiable.

As for the `-gsem-` model...
well I did keep it,
but it's now labeled '`-gsem-` model 2'.
This model is a multilevel SEM,
and owing to the way residuals are specified,
it's not exactly possible for me to change the covariance structure for them.

So I've added in the so-called '`-gsem-` model 1'.
This is actually a model that I had estimated in the process of writing part 1,
but had discarded.
It's only *barely* different from the multilevel SEM,
and in the context of my prior position about constraining residuals,
it was just simpler to present the latter as *the* model.

