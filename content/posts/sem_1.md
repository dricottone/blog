---
title: A Series on SEM - Part 1
date: "2025-10-27T01:30:34+00:00"
draft: true
---

Earlier this year,
while reading a textbook for applied data analysis in SAS,
I came across a peculiar claim.
The author stated as a well-established fact that a random effects model
can be fit using structural equation modeling (SEM).
This throw-away comment threw *me*.

And yet,
this is evidently not a novel idea.
I found at least
[one thread on Statalist](https://www.statalist.org/forums/forum/general-stata-discussion/general/1582798-why-can-t-sem-or-gsem-produce-fixed-effects-regressions)
that discussed fitting random and fixed effects models using Stata's `-sem-`
and `-gsem-` facility.

The problem is that I only know enough about SEM to know that I don't know
much.
The literature is also prohibitively dense.

I am nonetheless an applied statistician,
so when I am overcome by theory,
I reach for a demo.

The model I am targeting is:

```
. webuse wagework
(Wages for 20 to 77 year olds, 2013–2016)

. xtset personid year

Panel variable: personid (strongly balanced)
 Time variable: year, 2013 to 2016
         Delta: 1 unit

. xtreg wage c.age##c.age tenure, re

Random-effects GLS regression                   Number of obs     =      1,928
Group variable: personid                        Number of groups  =        589

R-squared:                                      Obs per group:
     Within  = 0.3157                                         min =          1
     Between = 0.8036                                         avg =        3.3
     Overall = 0.6954                                         max =          4

                                                Wald chi2(3)      =    2936.93
corr(u_i, X) = 0 (assumed)                      Prob > chi2       =     0.0000

------------------------------------------------------------------------------
        wage | Coefficient  Std. err.      z    P>|z|     [95% conf. interval]
-------------+----------------------------------------------------------------
         age |   .4860159   .0399453    12.17   0.000     .4077246    .5643073
             |
 c.age#c.age |  -.0032201   .0004375    -7.36   0.000    -.0040776   -.0023625
             |
      tenure |   .5888125   .0171743    34.28   0.000     .5551516    .6224735
       _cons |   7.629397    .850264     8.97   0.000      5.96291    9.295884
-------------+----------------------------------------------------------------
     sigma_u |  1.4814885
     sigma_e |  2.0681671
         rho |  .33911718   (fraction of variance due to u_i)
------------------------------------------------------------------------------
```

This is derived from the Stata manual entry for
[-xtheckman-](https://www.stata.com/manuals/xtxtheckman.pdf),
which more specifically is a modification of the random effects model accounting
for endogenous sample selection.
But the point is that this is a freely available dataset that is appropriate for
panel analysis.

----

Some fast facts for you:
 + 589 different individuals
 + annual measurements from 2013-2016 of wages, age, and tenure,
   among other things
 + average of 3.3 observations per individual
 + the fancy `c.age##c.age' syntax is just a shorthand that expands to age
   itself *and* the interaction of age by age,
   a.k.a. age squared
   + you can see `age#age` in the output,
     that's the interaction term on its own
   + the `c.` prefix just clarifies for the interpreter that this variable is
     as opposed to categorical,
     so the first level should not be omitted

```
. summ personid

    Variable |        Obs        Mean    Std. dev.       Min        Max
-------------+---------------------------------------------------------
    personid |      2,400       300.5    173.2409          1        600

. tab year

       Year |      Freq.     Percent        Cum.
------------+-----------------------------------
       2013 |        600       25.00       25.00
       2014 |        600       25.00       50.00
       2015 |        600       25.00       75.00
       2016 |        600       25.00      100.00
------------+-----------------------------------
      Total |      2,400      100.00

. summ age tenure wage

    Variable |        Obs        Mean    Std. dev.       Min        Max
-------------+---------------------------------------------------------
         age |      2,400      43.265    13.89185         20         77
      tenure |      2,400    5.580833    3.797408          0         15
        wage |      1,928    25.14351    4.612133      12.42       38.9
```

----

The first problem I faced with Stata's `-sem-` was that it can't seem to handle
unbalanced panels.
But there are 632 individuals with incomplete information across 2013-2016.
So for now,
I'm going to exclude those cases,
and try to converge on a linear model among the balanced panel only.

The second problem was that `-sem-` also can't do true multi-level models.
This can be worked around by regressing each year separately
with constraints to force equality across equations.
But really no big deal.

The equivalent random effects regression is:

```
webuse wagework
by personid, sort: egen ct = count(wage)
keep if ct==4
drop ct
xtset personid year
xtreg wage c.age##c.age tenure, re
```

And here's how those compare:

|                 |**Reference Model**|**Simplified Model**|
|:-               |-                  |-                   |
|**N obs**        |1,928              |1,296               |
|**N groups**     |589                |324                 |
|**intercept**    |7.6294             |8.4791              |
|                 |*p<0.0001*         |*p<0.0001*          |
|**age coef.**    |0.4860             |0.4520              |
|                 |*p<0.0001*         |*p<0.0001*          |
|**sq. age coef.**|-0.0032            |-0.0027             |
|                 |*p<0.0001*         |p=0.0001            |
|**tenure coef.** |0.5889             |0.5922              |
|                 |*p<0.0001*         |*p<0.0001*          |
|**R-squared**    |0.6954             |0.6666              |
|**σ~e~**         |2.0682             |2.0558              |
|**σ~u~**         |1.4815             |1.5176              |

----

This SEM model seems to replicate the model,
at least mostly.

```
webuse wagework
drop market working
generate sq_age = age^2
reshape wide wage age sq_age tenure, i(personid) j(year)
drop if wage2013==. | wage2014==. | wage2015==. | wage2016==.
sem (wage2013 <- age2013@b1 sq_age2013@b2 tenure2013@b3 _cons@b0) ///
    (wage2014 <- age2014@b1 sq_age2014@b2 tenure2014@b3 _cons@b0) ///
    (wage2015 <- age2015@b1 sq_age2015@b2 tenure2015@b3 _cons@b0) ///
    (wage2016 <- age2016@b1 sq_age2016@b2 tenure2016@b3 _cons@b0) ///
    (wage2013 <- re@1) (wage2014 <- re@1) (wage2015 <- re@1) (wage2016 <- re@1) ///
    , latent(re) means(re@0) covariance(re*_oexogenous@0) ///
    covstructure(e.wage*, identity)
estimates store m_sem
```

<details>

<summary><p>Click here to see the complete execution log.</p></summary>

```
. webuse wagework
(Wages for 20 to 77 year olds, 2013–2016)

. drop market working

. generate sq_age = age^2

. reshape wide wage age sq_age tenure, i(personid) j(year)
(j = 2013 2014 2015 2016)

Data                               Long   ->   Wide
-----------------------------------------------------------------------------
Number of observations            2,400   ->   600
Number of variables                   6   ->   17
j variable (4 values)              year   ->   (dropped)
xij variables:
                                   wage   ->   wage2013 wage2014 ... wage2016
                                    age   ->   age2013 age2014 ... age2016
                                 sq_age   ->   sq_age2013 sq_age2014 ... sq_age2016
                                 tenure   ->   tenure2013 tenure2014 ... tenure2016
-----------------------------------------------------------------------------

. drop if wage2013==. | wage2014==. | wage2015==. | wage2016==.
(276 observations deleted)

. sem (wage2013 <- age2013@b1 sq_age2013@b2 tenure2013@b3 _cons@b0) ///
      (wage2014 <- age2014@b1 sq_age2014@b2 tenure2014@b3 _cons@b0) ///
      (wage2015 <- age2015@b1 sq_age2015@b2 tenure2015@b3 _cons@b0) ///
      (wage2016 <- age2016@b1 sq_age2016@b2 tenure2016@b3 _cons@b0) ///
      (wage2013 <- re@1) (wage2014 <- re@1) (wage2015 <- re@1) (wage2016 <- re@1) ///
      , latent(re) means(re@0) covariance(re*_oexogenous@0) ///
      covstructure(e.wage*, identity)

Endogenous variables
  Observed: wage2013 wage2014 wage2015 wage2016

Exogenous variables
  Observed: age2013 sq_age2013 tenure2013 age2014 sq_age2014 tenure2014 age2015 sq_age2015 tenure2015 age2016 sq_age2016
            tenure2016
  Latent:   re

Fitting target model:
Iteration 0:   log likelihood = -22055.499
Iteration 1:   log likelihood = -22052.233
Iteration 2:   log likelihood = -22012.972
Iteration 3:   log likelihood = -22012.684
Iteration 4:   log likelihood =  -22012.68
Iteration 5:   log likelihood =  -22012.68

Structural equation model                                  Number of obs = 324
Estimation method: ml

Log likelihood = -22012.68

 ( 1)  [wage2013]age2013 - [wage2016]age2016 = 0
 ( 2)  [wage2013]sq_age2013 - [wage2016]sq_age2016 = 0
 ( 3)  [wage2013]tenure2013 - [wage2016]tenure2016 = 0
 ( 4)  [wage2013]re = 1
 ( 5)  [wage2014]age2014 - [wage2016]age2016 = 0
 ( 6)  [wage2014]sq_age2014 - [wage2016]sq_age2016 = 0
 ( 7)  [wage2014]tenure2014 - [wage2016]tenure2016 = 0
 ( 8)  [wage2014]re = 1
 ( 9)  [wage2015]age2015 - [wage2016]age2016 = 0
 (10)  [wage2015]sq_age2015 - [wage2016]sq_age2016 = 0
 (11)  [wage2015]tenure2015 - [wage2016]tenure2016 = 0
 (12)  [wage2015]re = 1
 (13)  [wage2016]re = 1
 (14)  [/]var(e.wage2013) - [/]var(e.wage2016) = 0
 (15)  [/]var(e.wage2014) - [/]var(e.wage2016) = 0
 (16)  [/]var(e.wage2015) - [/]var(e.wage2016) = 0
 (17)  [wage2013]_cons - [wage2016]_cons = 0
 (18)  [wage2014]_cons - [wage2016]_cons = 0
 (19)  [wage2015]_cons - [wage2016]_cons = 0
--------------------------------------------------------------------------------
               |                 OIM
               | Coefficient  std. err.      z    P>|z|     [95% conf. interval]
---------------+----------------------------------------------------------------
Structural     |
  wage2013     |
       age2013 |    .451463    .067817     6.66   0.000     .3185441    .5843819
    sq_age2013 |  -.0027395    .000787    -3.48   0.000     -.004282   -.0011969
    tenure2013 |   .5923246    .020662    28.67   0.000     .5518277    .6328214
            re |          1   1.97e-16  5.1e+15   0.000            1           1
         _cons |    8.49016   1.398321     6.07   0.000     5.749501    11.23082
  -------------+----------------------------------------------------------------
  wage2014     |
       age2014 |    .451463    .067817     6.66   0.000     .3185441    .5843819
    sq_age2014 |  -.0027395    .000787    -3.48   0.000     -.004282   -.0011969
    tenure2014 |   .5923246    .020662    28.67   0.000     .5518277    .6328214
            re |          1  (constrained)
         _cons |    8.49016   1.398321     6.07   0.000     5.749501    11.23082
  -------------+----------------------------------------------------------------
  wage2015     |
       age2015 |    .451463    .067817     6.66   0.000     .3185441    .5843819
    sq_age2015 |  -.0027395    .000787    -3.48   0.000     -.004282   -.0011969
    tenure2015 |   .5923246    .020662    28.67   0.000     .5518277    .6328214
            re |          1  (constrained)
         _cons |    8.49016   1.398321     6.07   0.000     5.749501    11.23082
  -------------+----------------------------------------------------------------
  wage2016     |
       age2016 |    .451463    .067817     6.66   0.000     .3185441    .5843819
    sq_age2016 |  -.0027395    .000787    -3.48   0.000     -.004282   -.0011969
    tenure2016 |   .5923246    .020662    28.67   0.000     .5518277    .6328214
            re |          1  (constrained)
         _cons |    8.49016   1.398321     6.07   0.000     5.749501    11.23082
---------------+----------------------------------------------------------------
var(e.wage2013)|   4.238807   .1924287                      3.877946    4.633248
var(e.wage2014)|   4.238807   .1924287                      3.877946    4.633248
var(e.wage2015)|   4.238807   .1924287                      3.877946    4.633248
var(e.wage2016)|   4.238807   .1924287                      3.877946    4.633248
        var(re)|   2.270894   .2668034                       1.80381    2.858927
--------------------------------------------------------------------------------
```

</details>

Some notes about this model:
 + I had to compute the squared age term directly;
   no factor notation allowed.
 + The `_oexogenous` keyword in the `covariance` option expands to the list of
   *o*bserved *exogenous* variables.
   I could have specified this constraint in 12 separate options like
   `cov(re\*age2013@0) ... cov(re\*tenure2016@0)',
   but personally speaking I hate that idea.

There are minor discrepencies compared to the (simplified) target model.
The intercept surprisingly is off by the most:
8.7941 vs. 8.4902.
Also notable that the variance of the random effect is much higher.
With that said,
very comparable results between the two.

Before I present those results,
note that I've squared σ~e~ and σ~u~ to give the variances of the residual and
of the random effect, respectively.

|                 |**Simplified Model**|**`-sem-` Model**|
|:-               |-                   |-                |
|**N obs**        |1,296               |324              |
|**N groups**     |324                 |                 |
|**intercept**    |8.4791              |8.4902           |
|                 |*p<0.0001*          |*p<0.0001*       |
|**age coef.**    |0.4520              |0.4515           |
|                 |*p<0.0001*          |*p<0.0001*       |
|**sq. age coef.**|-0.0027             |-0.0027          |
|                 |*p=0.0001*          |*p<0.0001*       |
|**tenure coef.** |0.5922              |0.5923           |
|                 |*p<0.0001*          |*p<0.0001*       |
|**R-squared**    |0.6666              |                 |
|**Var(error)**   |4.2264              |4.2388           |
|**Var(r.e.)**    |2.3031              |2.2709           |

----

Now,
it *is* possible to get around the unbalanced panel problem in Stata,
but it requires a jump into `-gsem-`.
As a bonus,
this re-enables use of factor notation!

```
webuse wagework
gsem (wage <- c.age##c.age tenure) ///
    (wage <- re[personid]@1) ///
    , latent(re) means(re[personid]@0)
estimates store m_gsem
```

<details>

<summary><p>Click here to see the complete execution log.</p></summary>

```
. webuse wagework
(Wages for 20 to 77 year olds, 2013–2016)

. gsem (wage <- c.age##c.age tenure) ///
>     (wage <- re[personid]@1) ///
>     , latent(re) means(re[personid]@0)

Fitting fixed-effects model:

Iteration 0:   log likelihood = -4536.3408
Iteration 1:   log likelihood = -4536.3408

Refining starting values:

Grid node 0:   log likelihood =  -4499.996

Fitting full model:

Iteration 0:   log likelihood =  -4499.996
Iteration 1:   log likelihood = -4423.4644
Iteration 2:   log likelihood =  -4419.547
Iteration 3:   log likelihood = -4419.2832
Iteration 4:   log likelihood = -4419.2826
Iteration 5:   log likelihood = -4419.2826

Generalized structural equation model                    Number of obs = 1,928
Response: wage....
Family:   Gaussian
Link:     Identity
Log likelihood = -4419.2826

  ( 1)  [wage]re[personid] = 1
-----------------------------------------------------------------------------------
                  | Coefficient  Std. err.      z    P>|z|     [95% conf. interval]
------------------+----------------------------------------------------------------
wage              |
              age |   .4860389   .0399379    12.17   0.000      .407762    .5643158
                  |
      c.age#c.age |  -.0032203   .0004374    -7.36   0.000    -.0040777   -.0023629
                  |
           tenure |   .5887982   .0171644    34.30   0.000     .5551566    .6224399
                  |
     re[personid] |          1  (constrained)
                  |
            _cons |   7.628877   .8501349     8.97   0.000     5.962643     9.29511
------------------+----------------------------------------------------------------
 var(re[personid])|   2.197979   .2125054                      1.818559    2.656559
------------------+----------------------------------------------------------------
       var(e.wage)|   4.266021   .1638204                      3.956725    4.599495
-----------------------------------------------------------------------------------
```

</details>

Fantastically,
this does a great job of replicating the target model.
Discrepancies in the estimated variances are measured in hundredths.
The same can be said of the intercept estimate.

As before,
note that I've squared σ~e~ and σ~u~ to report variances.

|                 |**Reference Model**|**`-gsem-` Model**|
|:-               |-                  |-                 |
|**N obs**        |1,928              |1,928             |
|**N groups**     |589                |                  |
|**intercept**    |7.6294             |7.6289            |
|                 |*p<0.0001*         |*p<0.0001*        |
|**age coef.**    |0.4860             |0.4860            |
|                 |*p<0.0001*         |*p<0.0001*        |
|**sq. age coef.**|-0.0032            |-0.0032           |
|                 |*p<0.0001*         |*p<0.0001*        |
|**tenure coef.** |0.5889             |0.5888            |
|                 |*p<0.0001*         |*p<0.0001*        |
|**R-squared**    |0.6954             |                  |
|**Var(error)**   |4.2660             |4.2660            |
|**Var(r.e.)**    |2.1980             |2.1980            |

----

I do have to disclose that I found a
[thread on Statalist](https://www.statalist.org/forums/forum/general-stata-discussion/general/1328131-does-stata-s-gsem-command-assume-zero-covariance-between-latent-and-observed-exogenous-variables)
suggesting that exogenous variables are assumed independent if any are latent.
This would pose a major problem for my model,
as age, squared age, and tenure are indeed expected to covary.
(To be clear, a random effect model assumes as a prerequisite that the random
effect is independent of all predictors.
It's just the covariances of observed variables that I need to be freely
estimated.)

I don't have a good way to test whether this faulty assumption is being
applied,
other than
(**foreshadowing**)
re-implementing the model in another SEM framework.

----

But before I close this out...
how well did those SEM models fit the data?
Here's the results of the `-sem-` model:

```
. estimates restore m_sem
(results m_sem are active now)

model degrees of freedom: 6
saturated model degrees of freedom: 152
baseline model degrees of freedom: 98

. estat ic

Akaike's information criterion and Bayesian information criterion

-----------------------------------------------------------------------------
       Model |          N   ll(null)  ll(model)      df        AIC        BIC
-------------+---------------------------------------------------------------
       m_sem |        324          .  -22012.68       6   44037.36   44060.04
-----------------------------------------------------------------------------
Note: BIC uses N = number of observations. See [R] BIC note.

. estat gof, stats(all)

----------------------------------------------------------------------------
Fit statistic        |      Value   Description
---------------------+------------------------------------------------------
                     |
          chi2_ms(.) |          .   model vs. saturated
            p > chi2 |          .
          chi2_bs(.) |          .   baseline vs. saturated
            p > chi2 |          .
---------------------+------------------------------------------------------
Population error     |
               RMSEA |          .   Root mean squared error of approximation
 90% CI, lower bound |      0.000
         upper bound |          .
              pclose |          .   Probability RMSEA <= 0.05
---------------------+------------------------------------------------------
Information criteria |
                 AIC |  44037.359   Akaike's information criterion
                 BIC |  44060.044   Bayesian information criterion
---------------------+------------------------------------------------------
Baseline comparison  |
                 CFI |          .   Comparative fit index
                 TLI |          .   Tucker–Lewis index
---------------------+------------------------------------------------------
Size of residuals    |
                SRMR |      0.025   Standardized root mean squared residual
                  CD |      0.974   Coefficient of determination
----------------------------------------------------------------------------
```

At this point,
I am seeing some red flags.
An R-squared of 97% is perposterous.
And the inability to calculate a chi-squared test suggests that the model was
not correctly identified.

There is one other postestimation command that I am pointed towards:

```
. estat eqgof

Equation-level goodness of fit

------------------------------------------------------------------------------
   Dependent |             Variance            |
   variables |    Fitted  Predicted   Residual | R-squared        mc       mc2
-------------+---------------------------------+------------------------------
Observed     |                                 |
    wage2013 |  17.72366   13.48486   4.238807 |  .7608391  .8722609  .7608391
    wage2014 |  19.45075   15.21195   4.238807 |  .7820749    .88435  .7820749
    wage2015 |  20.08207   15.84326   4.238807 |  .7889258  .8882149  .7889258
    wage2016 |  19.77338   15.53457   4.238807 |  .7856306  .8863581  .7856306
-------------+---------------------------------+------------------------------
     Overall |                                 |   .974397
------------------------------------------------------------------------------
mc  = Correlation between dependent variable and its prediction.
mc2 = mc^2 is the Bentler–Raykov squared multiple correlation coefficient.
```

That overall goodness-of-fit is just as suspicious as the R-squared reported
before.
But the
[Stata manual](https://www.stata.com/manuals/semexample3.pdf#semExample3)
suggests that mc-squared be referenced rather than R-squared in non-recursive
models.
And I do believe this qualifies as a non-recursive model.
A measure around 78% seems more palateable.

What about `-gsem-`?
Well,
unfortunately very few postestimation commands are actually supported right
now.

```
. estimates restore m_gsem
(results m_gsem are active now)

. estat ic

Akaike's information criterion and Bayesian information criterion

-----------------------------------------------------------------------------
       Model |          N   ll(null)  ll(model)      df        AIC        BIC
-------------+---------------------------------------------------------------
      m_gsem |      1,928          .  -4419.283       6   8850.565   8883.951
-----------------------------------------------------------------------------
Note: BIC uses N = number of observations. See [R] BIC note.
```

And in the context of such brevity,
these results suggest some...
problems.

