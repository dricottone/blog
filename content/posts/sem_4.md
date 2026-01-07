---
title: A Series on SEM - Part 4
date: "2026-01-07T16:16:41-06:00"
draft: false
---

Building on the deep-dive into Stata's structural equation modeling (SEM)
facilities,
I turn now to R.

There were a few hiccups to picking up lavaan.
First and foremost,
strictly exogenous latent variables
(i.e., those on the right hand side only)
are *not* supported.
They all need to be defined by a measurement model.
Somewhat annoying since `Alpha` is fundamentally an error term,
but not really an issue since it is definitionally independent of all
predictors.
There's really no difference between regressing `Alpha` on `wage` vs.
regressing `wage` on `Alpha`.

----

Here's the setup code:

```
#Run only once
#install.packages("tidyverse")
#install.packages("lavaan")

library(tidyverse)
library(haven)
library(lavaan)

df1 <- subset(read_dta("wagework.dta"), select=-c(market, working))
df1$sq_age <- df1$age^2
```

Moving swiftly on...

My first attempt looked like this:

```
mod1 <- '
# Measurement model
Alpha =~ 1*wage

# Regression path
wage ~ age + sq_age + tenure

# E(Alpha) = 0
Alpha ~ 0

# Alpha is independent of all predictors, all other predictors do correlate
Alpha ~~ 0*age + 0*sq_age + 0*tenure
age ~~ sq_age + tenure
sq_age ~~ tenure

# Residuals freely vary
wage ~~ wage
'
mod1.fit <- sem(model=mod1, data=df1, estimator="ML", meanstructure=TRUE)
```

This did not work.
Leaving aside a litany of warnings about the variances being too large
(I'm guessing a floating point precision issue?),
the matrix is non-invertible.
No good.

I turned my attention towards fitting a model on wide data.
Some more setup code:

```
df2 <- pivot_wider(df1, id_cols=personid, names_from=year, values_from=c(wage, age, sq_age, tenure))
df3 <- df2[complete.cases(df2), ]
```

And here's what the second attempt looks like:

```
mod2 <- '
# Measurement model
Alpha =~ 1*wage_2013 + 1*wage_2014 + 1*wage_2015 + 1*wage_2016

# Regression paths
wage_2013 ~ b1*age_2013 + b2*sq_age_2013 + b3*tenure_2013
wage_2014 ~ b1*age_2014 + b2*sq_age_2014 + b3*tenure_2014
wage_2015 ~ b1*age_2015 + b2*sq_age_2015 + b3*tenure_2015
wage_2016 ~ b1*age_2016 + b2*sq_age_2016 + b3*tenure_2016

# E(Alpha) = 0
Alpha ~ 0

# Covariance structure
Alpha ~~ 
  + 0*age_2013 + 0*sq_age_2013 + 0*tenure_2013
  + 0*age_2014 + 0*sq_age_2014 + 0*tenure_2014
  + 0*age_2015 + 0*sq_age_2015 + 0*tenure_2015
  + 0*age_2016 + 0*sq_age_2016 + 0*tenure_2016
age_2013 ~~
  + sq_age_2013 + tenure_2013
  + age_2014 + sq_age_2014 + tenure_2014
  + age_2015 + sq_age_2015 + tenure_2015
  + age_2016 + sq_age_2016 + tenure_2016
sq_age_2013 ~~
  + tenure_2013
  + age_2014 + sq_age_2014 + tenure_2014
  + age_2015 + sq_age_2015 + tenure_2015
  + age_2016 + sq_age_2016 + tenure_2016
tenure_2013 ~~
  + age_2014 + sq_age_2014 + tenure_2014
  + age_2015 + sq_age_2015 + tenure_2015
  + age_2016 + sq_age_2016 + tenure_2016
age_2014 ~~
  + sq_age_2014 + tenure_2014
  + age_2015 + sq_age_2015 + tenure_2015
  + age_2016 + sq_age_2016 + tenure_2016
sq_age_2014 ~~
  + tenure_2014
  + age_2015 + sq_age_2015 + tenure_2015
  + age_2016 + sq_age_2016 + tenure_2016
tenure_2014 ~~
  + age_2015 + sq_age_2015 + tenure_2015
  + age_2016 + sq_age_2016 + tenure_2016
age_2015 ~~
  + sq_age_2015 + tenure_2015
  + age_2016 + sq_age_2016 + tenure_2016
sq_age_2015 ~~
  + tenure_2015
  + age_2016 + sq_age_2016 + tenure_2016
tenure_2015 ~~
  + age_2016 + sq_age_2016 + tenure_2016
age_2016 ~~
  + sq_age_2016 + tenure_2016
sq_age_2016 ~~
  + tenure_2016

# Intercepts equal across years
wage_2013 ~ b0*1
wage_2014 ~ b0*1
wage_2015 ~ b0*1
wage_2016 ~ b0*1

# Residuals freely vary across years
# I am 90% sure this is unnecessary, but a helpful reminder that FE vs. RE is all which of these blocks is fixed
wage_2013 ~~ wage_2013
wage_2014 ~~ wage_2014
wage_2015 ~~ wage_2015
wage_2016 ~~ wage_2016
'

mod2.fit <- sem(model=mod2, data=df3, estimator="ML", meanstructure=TRUE)
```

Still not working,
matrix is not positive definite.
Now I'm starting to worry about the variance warnings.
If the scale of my variables is an issue for R's floating point arithmetic,
I could easily be accruing massive errors that would cause negative terms.

```
df1$sq_age_sc <- df1$sq_age/100
df4 <- pivot_wider(df1, id_cols=personid, names_from=year, values_from=c(wage, age, sq_age_sc, tenure))
df5 <- df4[complete.cases(df4), ]
```

<details>

<summary>Click here for the model specification:</summary>

```
mod2a <- '
Alpha =~ 1*wage_2013 + 1*wage_2014 + 1*wage_2015 + 1*wage_2016

wage_2013 ~ b1*age_2013 + b2*sq_age_sc_2013 + b3*tenure_2013
wage_2014 ~ b1*age_2014 + b2*sq_age_sc_2014 + b3*tenure_2014
wage_2015 ~ b1*age_2015 + b2*sq_age_sc_2015 + b3*tenure_2015
wage_2016 ~ b1*age_2016 + b2*sq_age_sc_2016 + b3*tenure_2016

Alpha ~ 0

Alpha ~~ 
  + 0*age_2013 + 0*sq_age_sc_2013 + 0*tenure_2013
  + 0*age_2014 + 0*sq_age_sc_2014 + 0*tenure_2014
  + 0*age_2015 + 0*sq_age_sc_2015 + 0*tenure_2015
  + 0*age_2016 + 0*sq_age_sc_2016 + 0*tenure_2016
age_2013 ~~
  + sq_age_sc_2013 + tenure_2013
  + age_2014 + sq_age_sc_2014 + tenure_2014
  + age_2015 + sq_age_sc_2015 + tenure_2015
  + age_2016 + sq_age_sc_2016 + tenure_2016
sq_age_sc_2013 ~~
  + tenure_2013
  + age_2014 + sq_age_sc_2014 + tenure_2014
  + age_2015 + sq_age_sc_2015 + tenure_2015
  + age_2016 + sq_age_sc_2016 + tenure_2016
tenure_2013 ~~
  + age_2014 + sq_age_sc_2014 + tenure_2014
  + age_2015 + sq_age_sc_2015 + tenure_2015
  + age_2016 + sq_age_sc_2016 + tenure_2016
age_2014 ~~
  + sq_age_sc_2014 + tenure_2014
  + age_2015 + sq_age_sc_2015 + tenure_2015
  + age_2016 + sq_age_sc_2016 + tenure_2016
sq_age_sc_2014 ~~
  + tenure_2014
  + age_2015 + sq_age_sc_2015 + tenure_2015
  + age_2016 + sq_age_sc_2016 + tenure_2016
tenure_2014 ~~
  + age_2015 + sq_age_sc_2015 + tenure_2015
  + age_2016 + sq_age_sc_2016 + tenure_2016
age_2015 ~~
  + sq_age_sc_2015 + tenure_2015
  + age_2016 + sq_age_sc_2016 + tenure_2016
sq_age_sc_2015 ~~
  + tenure_2015
  + age_2016 + sq_age_sc_2016 + tenure_2016
tenure_2015 ~~
  + age_2016 + sq_age_sc_2016 + tenure_2016
age_2016 ~~
  + sq_age_sc_2016 + tenure_2016
sq_age_sc_2016 ~~
  + tenure_2016

wage_2013 ~ b0*1
wage_2014 ~ b0*1
wage_2015 ~ b0*1
wage_2016 ~ b0*1

wage_2013 ~~ wage_2013
wage_2014 ~~ wage_2014
wage_2015 ~~ wage_2015
wage_2016 ~~ wage_2016
'

mod2a.fit <- sem(model=mod2a, data=df5, estimator="ML", meanstructure=TRUE)
```

</details>

Nope,
not the fix I needed.

The only other cause for non-identification I can imagine is insufficient data,
or at least an inefficient estimator.
After some quick searching I find that lavaan *does* support fitting a model
with incomplete cases.
It's a close thing though,
apparently a new development for the project.

```
mod2b.fit <- sem(model=mod2, data=df2, estimator="ML", meanstructure=TRUE, missing="ML")
```

On one hand,
a model was successfully identified this time.
On the other hand,
there are several concerning warnings.
 + the variances again
 + some observed variables are perfectly correlated:
   `age_2013`, `age_2014`, `age_2015`, and `age_2016`
 + variance-covariance matrix is not positive definite based on an eigenvalue
   test
So this is a big step forward but some further refinement is called for.

----

Around this time I found the work of Richard Williams, Paul D. Allison, and
Enrique Moral-Benito:
chiefly the user-written Stata program known as `-xtdpdml-`.
Not only does it wrap `-sem-` for my specific use case
(panel data analysis),
it also can output *supposedly* equivalent R syntax.
So of course I thought this to be a perfect tool for double-checking my lavaan
model specifications.
What's more,
it demonstrates a method for actually making `-sem-` work with incomplete data
after all!
Turns out that an alternative estimator can be selected by passing
`method(mlmv)`.

Here's the kicker though.
 1. My (second) lavaan model matches theirs.
    Hooray!
 2. The `-sem-` model generated by `-xtdpdml-` don't converge.
    Boo!

<details>

<summary>Click here for the full execution log.</summary>

```
. xtdpdml wage age sq_age tenure, re ylag(0) constinv fiml
initial values not feasible
initial values not feasible

Highlights: Dynamic Panel Data Model using ML for outcome variable wage
------------------------------------------------------------------------------
             |                 OIM
        wage | Coefficient  std. err.      z    P>|z|     [95% conf. interval]
-------------+----------------------------------------------------------------
wage         |
         age |   .4823344          .        .       .            .           .
      sq_age |  -.0031507          .        .       .            .           .
      tenure |   .5892509          .        .       .            .           .
------------------------------------------------------------------------------
# of units = 600. # of periods = 4. First dependent variable is from period 1. 
Constants are invariant across time periods
Warning: LR test of model vs saturated could not be computed
IC Measures: BIC =   23478.36  AIC =   23372.83
Warning: Wald test of all coeff = 0 could not be computed
Warning! Convergence not achieved
```

</details>

What's the difference between this model and the ones I designed in part 1?
Well...
the estimators of course.

The default estimation method for `-sem-`,
maximum likelihood (ML),
listwise deletes cases if they have missing data.
We know this.
It was a problem discussed in part 1,
and the motivation for moving to `-gsem-`.
Maximum likelihood for missing values (MLMV;
sometimes called full information maximum likelihood or FIML)
is an alternative method that instead
"aims to retrieve as much information as possible from observations containing
missing values".
But it's still just an ML algorithm

`-gsem-` does *not* actually use ML.
Or you could say that it doesn't use the *normal* ML,
but that would cause confusion,
because really it's ML with a **conditional normality** assumption instead of
a **joint normality** assumption.
In plainer language:
`-sem-` depends on all of the variables being normal and independent,
whereas `-gsem-` depends on the variables being normal and independent
**given the observations**.

What is the consequence of violating joint normality?
For one,
I'm guessing,
you can't fit models that assume it.
This could very well explain why `-gsem-` mysteriously outperforms both
`-sem-` and lavaan in this case.

One approach to the non-normality challenge that comes highly recommended
(Yuan, Chan, & Bentler, 2000)
is Santorra-Bentler adjusted estimators.
Stata
[advertises](https://www.stata.com/features/overview/sem-satorra-bentler/)
support since
[Stata 14](https://www.stata.com/stata14/sem-satorra-bentler/)
by passing `vce(sbentler)`.
The ugly truth is that this is yet another feature that the `-gsem-` facility
can't support right now.
And unfortunately,
with incomplete data,
I just can't get `-sem-` to converge.

----

This is not the end of the road.
While I hope the above *towers* of syntax demonstrate that the lavaan model
specification is annoying and verbose and pedantic...
it also exposes the bells and whistles.
And if the key is just forcing my predictors to be independent,
then that's what I'll do.
It's actually pretty easy.

At the end of this road is a great big disappointment sandwich,
nonetheless.
Because as far as I'm concerned,
this validates the concern I noted in part 1.
Exogenous variables that should correlate are being treated as independent.

