---
title: A Series on SEM - Part 2
date: "2025-12-04T19:47:39-06:00"
draft: false
summary: >
    This is part of a series on structural equation modeling (SEM).
    Specifically, bumbling around with SEM to try and fit a random effects
    regression, because people smarter than I have said they can be equivalent.
---

*Update 12/12/2025:
On reflection, I've decided that it isn't appropriate to constrain the variance
of residuals to be equal in every year.
The output of my `-sem-` model has changed.
As well,
my `-gsem-` model is now called '`-gsem-` model 2'.
I've inserted a '`-gsem-` model 1' which helps to demonstrate the change in
approach.*

----

This is part of a series on structural equation modeling (SEM).
Specifically,
bumbling around with SEM to try and fit a random effects regression,
because people smarter than I have said they can be equivalent.

At the close of part 1,
I had collected the following results:

|                         |**Reference Model**|**`-gsem-` Model 1**|**`-gsem-` Model 2**|
|:-                       |-                  |-                   |-                   |
|**N obs**                |1,928              |1,928               |1,928               |
|**N groups**             |589                |589                 |                    |
|**intercept**            |7.6294             |7.6528              |7.6289              |
|                         |*p<0.0001*         |*p<0.0001*          |*p<0.0001*          |
|**age coef.**            |0.4860             |0.4848              |0.4860              |
|                         |*p<0.0001*         |*p<0.0001*          |*p<0.0001*          |
|**sq. age coef.**        |-0.0032            |-0.0032             |-0.0032             |
|                         |*p<0.0001*         |*p<0.0001*          |*p<0.0001*          |
|**tenure coef.**         |0.5889             |0.5900              |0.5888              |
|                         |*p<0.0001*         |*p<0.0001*          |*p<0.0001*          |
|**Var(ε)**               |4.2660             |                    |4.2660              |
|**Var(ε<sub>2013</sub>)**|                   |4.1397              |
|**Var(ε<sub>2014</sub>)**|                   |4.6110              |
|**Var(ε<sub>2015</sub>)**|                   |4.3479              |
|**Var(ε<sub>2016</sub>)**|                   |3.9745              |
|**Var(α)**               |2.1980             |2.1868              |2.1980              |
|**R-squared**            |0.6954             |                    |                    |

There's a notable gap here;
no R-squared is listed for the SEM models.
Why did I forget to include that?
Well...

```
. estimates restore m_sem
(results m_sem are active now)

. estat ic

Akaike's information criterion and Bayesian information criterion

-----------------------------------------------------------------------------
       Model |          N   ll(null)  ll(model)      df        AIC        BIC
-------------+---------------------------------------------------------------
       m_sem |        324          .  -22011.37       9   44040.75   44074.78
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
                 AIC |  44040.749   Akaike's information criterion
                 BIC |  44074.776   Bayesian information criterion
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

There are some red flags here.
Mostly, an R-squared statistic of 97% is *preposterous*.
And the inability to calculate a chi-squared test suggests that the model was
not correctly identified.
Did I accidentally regress wage on itself?

Referencing the
[Stata manual](https://www.stata.com/manuals/semexample3.pdf#semExample3),
there are recommendations to use a different post-estimation command.
`estat eqgof` reports mc-squared statistics in addition to R-squared,
and these should be preferred in non-recursive model.
(And I do believe this qualifies as a non-recursive model.)

```
. estat eqgof

Equation-level goodness of fit

------------------------------------------------------------------------------
   Dependent |             Variance            |
   variables |    Fitted  Predicted   Residual | R-squared        mc       mc2
-------------+---------------------------------+------------------------------
Observed     |                                 |
    wage2013 |  17.47366   13.40845   4.065212 |   .767352  .8759863   .767352
    wage2014 |  19.93624   15.14229   4.793952 |  .7595358  .8715135  .7595358
    wage2015 |  19.99059   15.77163    4.21896 |  .7889527  .8882301  .7889527
    wage2016 |  19.37285   15.46006   3.912792 |  .7980271  .8933236  .7980271
-------------+---------------------------------+------------------------------
     Overall |                                 |  .9742453
------------------------------------------------------------------------------
mc  = Correlation between dependent variable and its prediction.
mc2 = mc^2 is the Bentler–Raykov squared multiple correlation coefficient.
```

A measure around 76% seems more palateable.
So maybe no cause for concern.

What about `-gsem-`?
Well,
unfortunately very few post-estimation commands are actually supported right
now.

```
. estimates restore m_gsem1
(results m_gsem1 are active now)

. estat ic

Akaike's information criterion and Bayesian information criterion

-----------------------------------------------------------------------------
       Model |          N   ll(null)  ll(model)      df        AIC        BIC
-------------+---------------------------------------------------------------
     m_gsem1 |        589          .   -4418.32       9   8854.641   8894.046
-----------------------------------------------------------------------------
Note: BIC uses N = number of observations. See [R] BIC note.

. estimates restore m_gsem2
(results m_gsem2 are active now)

. estat ic

Akaike's information criterion and Bayesian information criterion

-----------------------------------------------------------------------------
       Model |          N   ll(null)  ll(model)      df        AIC        BIC
-------------+---------------------------------------------------------------
     m_gsem2 |      1,928          .  -4419.283       6   8850.565   8883.951
-----------------------------------------------------------------------------
Note: BIC uses N = number of observations. See [R] BIC note.
```

Once again,
Stata can't estimate the log likelihood of the null model...

As a result of red flags in the `-sem-` model,
general unavailability for fit statistics in the `-gsem-` model,
and the aforementioned
[thread on Statalist](https://www.statalist.org/forums/forum/general-stata-discussion/general/1328131-does-stata-s-gsem-command-assume-zero-covariance-between-latent-and-observed-exogenous-variables)
hinting at inappropriate assumptions in the implementation,
I am left with few options beyond re-implementing the model in another
framework.

Setting Stata aside,
the two most popular frameworks for fitting a SEM seem to be Mplus and lavaan.
You may recognize that first name;
the exceedingly brilliant *and* incomprehensible Bengt O. Muthén is *also*
the co-creator of this program.
Unfortunately Mplus is *far* from free software,
and my company does not have a license.
So lavaan it will be!

