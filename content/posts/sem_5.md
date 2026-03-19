---
title: A Series on SEM - Part 5
date: "2026-03-19T17:59:50-05:00"
draft: true
---

This is the final part of a series on structural equation modeling (SEM).
Previously I came to the conclusion that replicating my reference model in
lavaan will require declaring some covariances to be zero.
This is essentially an inappropriate assumption that the variables are
independent.
There had already been some suspicion that Stata was making assumptions like
this implicitly.

So if I'm to embark on a test like this,
where to start with the covariance structure?
How about...
assume *everything* is independent?

```
mod3 <- '
Alpha =~ 1*wage_2013 + 1*wage_2014 + 1*wage_2015 + 1*wage_2016

wage_2013 ~ b1*age_2013 + b2*sq_age_2013 + b3*tenure_2013
wage_2014 ~ b1*age_2014 + b2*sq_age_2014 + b3*tenure_2014
wage_2015 ~ b1*age_2015 + b2*sq_age_2015 + b3*tenure_2015
wage_2016 ~ b1*age_2016 + b2*sq_age_2016 + b3*tenure_2016

Alpha ~ 0

# Just to document that *by definition* Alpha must be independent.
Alpha ~~
  + 0*age_2013 + 0*sq_age_2013 + 0*tenure_2013
  + 0*age_2014 + 0*sq_age_2014 + 0*tenure_2014
  + 0*age_2015 + 0*sq_age_2015 + 0*tenure_2015
  + 0*age_2016 + 0*sq_age_2016 + 0*tenure_2016

wage_2013 ~ b0*1
wage_2014 ~ b0*1
wage_2015 ~ b0*1
wage_2016 ~ b0*1

wage_2013 ~~ wage_2013
wage_2014 ~~ wage_2014
wage_2015 ~~ wage_2015
wage_2016 ~~ wage_2016
'

mod3.fit <- sem(model=mod3, data=df2, estimator="ML", meanstructure=TRUE, missing="ML")

mod3r.fit <- sem(model=mod3, data=df2, estimator="MLR", meanstructure=TRUE, missing="ML")
```

This however still does not yield a satisfactory result.
Back in Stata,
things magically got better when I switched from `-sem-` to `-gsem-`.
Let's try multilevel modeling in lavaan.

Well right away I run into an issue:
lavaan cannot define a model like `wage ~ age + sq_age + tenure + Alpha`.
The first appearance of `Alpha` must be on the LHS.
This isn't too big a deal however,
since the cluster level equation is just between `Alpha` and `wage`.
I can just reverse the direction of implied causation.

So here’s my *second* try at a multilevel model.

```
mod5 <- '
# Within-cluster level
level: 1
    wage ~ age + sq_age + tenure

    # Covariance structure
    age ~~ sq_age + tenure
    age ~~ tenure
# Cluster level
level: 2
    Alpha =~ 1*wage

    # E(Alpha) = 0
    Alpha ~ 0
'

mod5.fit <- sem(model=mod5, data=df1, estimator="ML", meanstructure=TRUE, missing=TRUE, cluster="personid")
```

This spits out a series of warnings:
 * some observed variances are (at least) a factor 1000 times larger than others
 * some observed variances are larger than 1000000
 * Level-1 variable "tenure" has no variance within some clusters
 * Level-1 variable "wage" has no variance within some clusters
 * Could not compute standard errors! The information matrix could not be inverted.

Despite that last part,
the model was successfully estimated.
And actually quite close to the reference.
Take a look:

|                         |**Reference Model**|**`-gsem-` Model 1**|**`-gsem-` Model 2**|**lavaan Model 5**|
|:-                       |-                  |-                   |-                   |-                 |
|**N obs**                |1,928              |1,928               |1,928               |2,400             |
|**N groups**             |589                |589                 |                    |600               |
|**intercept**            |7.6294             |7.6528              |7.6289              |7.629             |
|                         |*p<0.0001*         |*p<0.0001*          |*p<0.0001*          |                  |
|**age coef.**            |0.4860             |0.4848              |0.4860              |0.486             |
|                         |*p<0.0001*         |*p<0.0001*          |*p<0.0001*          |                  |
|**sq. age coef.**        |-0.0032            |-0.0032             |-0.0032             |-0.003            |
|                         |*p<0.0001*         |*p<0.0001*          |*p<0.0001*          |                  |
|**tenure coef.**         |0.5889             |0.5900              |0.5888              |0.589             |
|                         |*p<0.0001*         |*p<0.0001*          |*p<0.0001*          |                  |
|**Var(ε)**               |4.2660             |                    |4.2660              |4.266             |
|**Var(ε<sub>2013</sub>)**|                   |4.1397              |                    |                  |
|**Var(ε<sub>2014</sub>)**|                   |4.6110              |                    |                  |
|**Var(ε<sub>2015</sub>)**|                   |4.3479              |                    |                  |
|**Var(ε<sub>2016</sub>)**|                   |3.9745              |                    |                  |
|**Var(α)**               |2.1980             |2.1868              |2.1980              |2.198             |
|**R-squared**            |0.6954             |                    |                    |                  |

While we're throwing crazy ideas at the wall,
maybe floating point rounding errors are the problem!
It seems possible that squared values are too large.
So I scale it down by 100x
(and drop the cluster with no variation in the outcome variable)
and try again.

```
df3 <- df1[!(df1$personid %in% c(452)), ]
df3$sq_age <- df3$sq_age/100
mod5.fit2 <- sem(model=mod5, data=df3, estimator="ML", cluster="personid", meanstructure=TRUE)
```

<details>

<summary>Click here for the full execution log.</summary>

TODO: find a prettier way to include RMarkdown cells in my blog posts.

```
mod5.fit2 <- sem(model=mod5, data=df3, estimator="ML", cluster="personid", meanstructure=TRUE)
```

```
## Warning: lavaan->lav_data_full():
##    Level-1 variable "tenure" has no variance within some clusters . The
##    cluster ids with zero within variance are: 104, 134, 167, 198, 205, 245,
##    286, 342, 344, 353, 370, 372, 383, 418, 431, 438, 468, 499, 556, 560, 562.
```

```
## Warning in log(det(sigma.w)): NaNs produced
## Warning in log(det(sigma.w)): NaNs produced
```

```
summary(mod5.fit2, standardized=TRUE, fit.measures=TRUE, rsquare=TRUE)
```

```
## Warning: lavaan->lav_fit_cfi_lavobject():
##    computation of robust CFI resulted in NA values.
```

```
## Warning: lavaan->lav_fit_rmsea_lavobject():
##    computation of robust RMSEA resulted in NA values.
```

```
## lavaan 0.6-20 ended normally after 113 iterations
##
##   Estimator                                         ML
##   Optimization method                           NLMINB
##   Number of model parameters                        14
##
##   Number of observations                          2396
##   Number of clusters [personid]                    599
##   Number of missing patterns -- level 1              2
##
## Model Test User Model:
##
##   Test statistic                               258.439
##   Degrees of freedom                                 1
##   P-value (Chi-square)                           0.000
##
## Model Test Baseline Model:
##
##   Test statistic                             10819.294
##   Degrees of freedom                                 6
##   P-value                                        0.000
##
## User Model versus Baseline Model:
##
##   Comparative Fit Index (CFI)                    0.976
##   Tucker-Lewis Index (TLI)                       0.857
##
##   Robust Comparative Fit Index (CFI)                NA
##   Robust Tucker-Lewis Index (TLI)                   NA
##
## Loglikelihood and Information Criteria:
##
##   Loglikelihood user model (H0)             -25703.936
##   Loglikelihood unrestricted model (H1)     -25574.717
##
##   Akaike (AIC)                               51435.872
##   Bayesian (BIC)                             51516.814
##   Sample-size adjusted Bayesian (SABIC)      51472.333
##
## Root Mean Square Error of Approximation:
##
##   RMSEA                                          0.328
##   90 Percent confidence interval - lower         0.295
##   90 Percent confidence interval - upper         0.362
##   P-value H_0: RMSEA <= 0.050                    0.000
##   P-value H_0: RMSEA >= 0.080                    1.000
##
##   Robust RMSEA                                      NA
##   90 Percent confidence interval - lower            NA
##   90 Percent confidence interval - upper            NA
##   P-value H_0: Robust RMSEA <= 0.050                NA
##   P-value H_0: Robust RMSEA >= 0.080                NA
##
## Standardized Root Mean Square Residual (corr metric):
##
##   SRMR (within covariance matrix)                0.154
##   SRMR (between covariance matrix)               0.000
##
## Parameter Estimates:
##
##   Standard errors                             Standard
##   Information                                 Observed
##   Observed information based on                Hessian
##
##
## Level 1 [within]:
##
## Regressions:
##                    Estimate  Std.Err  z-value  P(>|z|)   Std.lv  Std.all
##   wage ~
##     age               0.486    0.040   12.205    0.000    0.486    1.627
##     sq_age           -0.322    0.044   -7.373    0.000   -0.322   -1.012
##     tenure            0.590    0.017   34.407    0.000    0.590    0.543
##
## Covariances:
##                    Estimate  Std.Err  z-value  P(>|z|)   Std.lv  Std.all
##   age ~~
##     sq_age          176.824    5.142   34.389    0.000  176.824    0.988
##     tenure            1.134    0.173    6.543    0.000    1.134    0.022
##
## Intercepts:
##                    Estimate  Std.Err  z-value  P(>|z|)   Std.lv  Std.all
##     age              43.241    0.282  153.444    0.000   43.241    3.135
##     sq_age           20.627    0.265   77.843    0.000   20.627    1.590
##     tenure            5.571    0.077   71.905    0.000    5.571    1.469
##
## Variances:
##                    Estimate  Std.Err  z-value  P(>|z|)   Std.lv  Std.all
##    .wage              4.267    0.164   26.043    0.000    4.267    0.251
##     age             190.276    5.507   34.553    0.000  190.276    1.000
##     sq_age          168.235    4.861   34.612    0.000  168.235    1.000
##     tenure           14.384    0.416   34.612    0.000   14.384    1.000
##
## R-Square:
##                    Estimate
##     wage              0.749
##
##
## Level 2 [personid]:
##
## Latent Variables:
##                    Estimate  Std.Err  z-value  P(>|z|)   Std.lv  Std.all
##   Alpha =~
##     wage              1.000                               1.476    1.000
##
## Intercepts:
##                    Estimate  Std.Err  z-value  P(>|z|)   Std.lv  Std.all
##     Alpha             0.000                               0.000    0.000
##    .wage              7.612    0.848    8.975    0.000    7.612    5.158
##
## Variances:
##                    Estimate  Std.Err  z-value  P(>|z|)   Std.lv  Std.all
##    .wage              0.000                               0.000    0.000
##     Alpha             2.178    0.211   10.313    0.000    1.000    1.000
##
## R-Square:
##                    Estimate
##     wage              1.000
```

```
mod5.fit2r <- sem(model=mod5, data=df3, estimator="MLR", meanstructure=TRUE, missing="ML", cluster="personid")
```

```
## Warning: lavaan->lav_data_full():
##    Level-1 variable "tenure" has no variance within some clusters . The
##    cluster ids with zero within variance are: 104, 134, 167, 198, 205, 245,
##    286, 342, 344, 353, 370, 372, 383, 418, 431, 438, 468, 499, 556, 560, 562.
```

```
## Warning in log(det(sigma.w)): NaNs produced
## Warning in log(det(sigma.w)): NaNs produced
```

```
summary(mod5.fit2r, standardized=TRUE, fit.measures=TRUE, rsquare=TRUE)
```

```
## Warning: lavaan->lav_fit_cfi_lavobject():
##    computation of robust CFI resulted in NA values.
```

```
## Warning: lavaan->lav_fit_rmsea_lavobject():
##    computation of robust RMSEA resulted in NA values.
```

```
## lavaan 0.6-20 ended normally after 113 iterations
##
##   Estimator                                         ML
##   Optimization method                           NLMINB
##   Number of model parameters                        14
##
##   Number of observations                          2396
##   Number of clusters [personid]                    599
##   Number of missing patterns -- level 1              2
##
## Model Test User Model:
##                                               Standard      Scaled
##   Test Statistic                               258.439          NA
##   Degrees of freedom                                 1           1
##   P-value (Chi-square)                           0.000          NA
##   Scaling correction factor                                     NA
##     Yuan-Bentler correction (Mplus variant)
##
## Model Test Baseline Model:
##
##   Test statistic                             10819.294    3514.718
##   Degrees of freedom                                 6           6
##   P-value                                        0.000       0.000
##   Scaling correction factor                                  3.078
##
## User Model versus Baseline Model:
##
##   Comparative Fit Index (CFI)                    0.976          NA
##   Tucker-Lewis Index (TLI)                       0.857          NA
##
##   Robust Comparative Fit Index (CFI)                            NA
##   Robust Tucker-Lewis Index (TLI)                               NA
##
## Loglikelihood and Information Criteria:
##
##   Loglikelihood user model (H0)             -25703.936  -25703.936
##   Scaling correction factor                                 10.808
##       for the MLR correction
##   Loglikelihood unrestricted model (H1)     -25574.717  -25574.717
##   Scaling correction factor                                  2.630
##       for the MLR correction
##
##   Akaike (AIC)                               51435.872   51435.872
##   Bayesian (BIC)                             51516.814   51516.814
##   Sample-size adjusted Bayesian (SABIC)      51472.333   51472.333
##
## Root Mean Square Error of Approximation:
##
##   RMSEA                                          0.328       0.000
##   90 Percent confidence interval - lower         0.295       0.000
##   90 Percent confidence interval - upper         0.362       0.000
##   P-value H_0: RMSEA <= 0.050                    0.000          NA
##   P-value H_0: RMSEA >= 0.080                    1.000          NA
##
##   Robust RMSEA                                                  NA
##   90 Percent confidence interval - lower                        NA
##   90 Percent confidence interval - upper                        NA
##   P-value H_0: Robust RMSEA <= 0.050                            NA
##   P-value H_0: Robust RMSEA >= 0.080                            NA
##
## Standardized Root Mean Square Residual (corr metric):
##
##   SRMR (within covariance matrix)                0.154       0.154
##   SRMR (between covariance matrix)               0.000       0.000
##
## Parameter Estimates:
##
##   Standard errors                             Sandwich
##   Information bread                           Observed
##   Observed information based on                Hessian
##
##
## Level 1 [within]:
##
## Regressions:
##                    Estimate  Std.Err  z-value  P(>|z|)   Std.lv  Std.all
##   wage ~
##     age               0.486    0.421    1.155    0.248    0.486    1.627
##     sq_age           -0.322    0.445   -0.723    0.470   -0.322   -1.012
##     tenure            0.590    0.019   31.460    0.000    0.590    0.543
##
## Covariances:
##                    Estimate  Std.Err  z-value  P(>|z|)   Std.lv  Std.all
##   age ~~
##     sq_age          176.824    8.817   20.055    0.000  176.824    0.988
##     tenure            1.134    0.281    4.034    0.000    1.134    0.022
##
## Intercepts:
##                    Estimate  Std.Err  z-value  P(>|z|)   Std.lv  Std.all
##     age              43.241    0.598   72.316    0.000   43.241    3.135
##     sq_age           20.627    0.555   37.172    0.000   20.627    1.590
##     tenure            5.571    0.139   40.028    0.000    5.571    1.469
##
## Variances:
##                    Estimate  Std.Err  z-value  P(>|z|)   Std.lv  Std.all
##    .wage              4.267    0.175   24.415    0.000    4.267    0.251
##     age             190.276    8.367   22.740    0.000  190.276    1.000
##     sq_age          168.235    9.494   17.719    0.000  168.235    1.000
##     tenure           14.384    0.452   31.850    0.000   14.384    1.000
##
## R-Square:
##                    Estimate
##     wage              0.749
##
##
## Level 2 [personid]:
##
## Latent Variables:
##                    Estimate  Std.Err  z-value  P(>|z|)   Std.lv  Std.all
##   Alpha =~
##     wage              1.000                               1.476    1.000
##
## Intercepts:
##                    Estimate  Std.Err  z-value  P(>|z|)   Std.lv  Std.all
##     Alpha             0.000                               0.000    0.000
##    .wage              7.612    9.144    0.832    0.405    7.612    5.158
##
## Variances:
##                    Estimate  Std.Err  z-value  P(>|z|)   Std.lv  Std.all
##    .wage              0.000                               0.000    0.000
##     Alpha             2.178    0.212   10.295    0.000    1.000    1.000
##
## R-Square:
##                    Estimate
##     wage              1.000
```

</details>

|                         |**Reference Model**|**`-gsem-` Model 1**|**`-gsem-` Model 2**|**lavaan Model 5**|
|:-                       |-                  |-                   |-                   |-                 |
|**N obs**                |1,928              |1,928               |1,928               |1,926             |
|**N groups**             |589                |589                 |                    |588               |
|**intercept**            |7.6294             |7.6528              |7.6289              |7.629             |
|                         |*p<0.0001*         |*p<0.0001*          |*p<0.0001*          |*p<0.0001*        |
|**age coef.**            |0.4860             |0.4848              |0.4860              |0.486             |
|                         |*p<0.0001*         |*p<0.0001*          |*p<0.0001*          |*p<0.0001*        |
|**sq. age coef.**        |-0.0032            |-0.0032             |-0.0032             |-0.322<sup>†</sup>|
|                         |*p<0.0001*         |*p<0.0001*          |*p<0.0001*          |*p<0.0001*        |
|**tenure coef.**         |0.5889             |0.5900              |0.5888              |0.590             |
|                         |*p<0.0001*         |*p<0.0001*          |*p<0.0001*          |*p<0.0001*        |
|**Var(ε)**               |4.2660             |                    |4.2660              |4.267             |
|**Var(ε<sub>2013</sub>)**|                   |4.1397              |                    |                  |
|**Var(ε<sub>2014</sub>)**|                   |4.6110              |                    |                  |
|**Var(ε<sub>2015</sub>)**|                   |4.3479              |                    |                  |
|**Var(ε<sub>2016</sub>)**|                   |3.9745              |                    |                  |
|**Var(α)**               |2.1980             |2.1868              |2.1980              |2.178             |
|**R-squared**            |0.6954             |                    |                    |                  |

`† = scaled by 0.01`

Well I'll be.
On one hand,
the R-squared is again preposterous.
But the model has reproduced.
This leaves me to ponder why rewriting a model to be multilevel makes it
estimable without taking on inappropriate assumptions...

----

It's at this point I remember how multilevel models take on assumptions that
sometimes are not appropriate.
I have accidentally erased serial correlation.

Let's quickly double-check that.

```
df4 <- pivot_wider(df3, id_cols=personid, names_from=year, values_from=c(wage, age, sq_age, tenure))

mod6 <- '
Alpha =~ 1*wage_2013 + 1*wage_2014 + 1*wage_2015 + 1*wage_2016

wage_2013 ~ b1*age_2013 + b2*sq_age_2013 + b3*tenure_2013
wage_2014 ~ b1*age_2014 + b2*sq_age_2014 + b3*tenure_2014
wage_2015 ~ b1*age_2015 + b2*sq_age_2015 + b3*tenure_2015
wage_2016 ~ b1*age_2016 + b2*sq_age_2016 + b3*tenure_2016

Alpha ~ 0

Alpha ~~
  + 0*age_2013 + 0*sq_age_2013 + 0*tenure_2013
  + 0*age_2014 + 0*sq_age_2014 + 0*tenure_2014
  + 0*age_2015 + 0*sq_age_2015 + 0*tenure_2015
  + 0*age_2016 + 0*sq_age_2016 + 0*tenure_2016

age_2013 ~~ sq_age_2013 + tenure_2013
sq_age_2013 ~~ tenure_2013

age_2014 ~~ sq_age_2014 + tenure_2014
sq_age_2014 ~~ tenure_2014

age_2015 ~~ sq_age_2015 + tenure_2015
sq_age_2015 ~~ tenure_2015

age_2016 ~~ sq_age_2016 + tenure_2016
sq_age_2016 ~~ tenure_2016

wage_2013 ~ b0*1
wage_2014 ~ b0*1
wage_2015 ~ b0*1
wage_2016 ~ b0*1

wage_2013 ~~ wage_2013
wage_2014 ~~ wage_2014
wage_2015 ~~ wage_2015
wage_2016 ~~ wage_2016
'

mod6.fit <- sem(model=mod6, data=df4, estimator="ML", meanstructure=TRUE, missing="ML")
```

<details>

<summary>Click here for the full execution log.</summary>

```
mod6.fit <- sem(model=mod6, data=df4, estimator="ML", meanstructure=TRUE, missing="ML")
```

```
## Warning: lavaan->lav_data_full():
##    some observed variables are perfectly correlated; please check your data;
##    variables involved are: age_2013 age_2014 age_2015 age_2016
```

```
## Warning: lavaan->lav_mvnorm_missing_h1_estimate_moments():
##    Maximum number of iterations reached when computing the sample moments
##    using EM; use the em.h1.iter.max= argument to increase the number of
##    iterations
```

```
## Warning: lavaan->lav_mvnorm_missing_h1_estimate_moments():
##    The smallest eigenvalue of the EM estimated variance-covariance matrix
##    (Sigma) is smaller than 1e-05; this may cause numerical instabilities;
##    interpret the results with caution.
```

```
summary(mod6.fit, standardized=TRUE, fit.measures=TRUE, rsquare=TRUE)
```

```
## Warning in pchisq(X2, df = df, ncp = ncp): NaNs produced
```

```
## Warning in pchisq(X2, df = df, ncp = ncp): NaNs produced
```

```
## lavaan 0.6-20 ended normally after 301 iterations
##
##   Estimator                                         ML
##   Optimization method                           NLMINB
##   Number of model parameters                        57
##   Number of equality constraints                    12
##
##   Number of observations                           599
##   Number of missing patterns                        16
##
## Model Test User Model:
##
##   Test statistic                              64527.000
##   Degrees of freedom                                107
##   P-value (Chi-square)                            0.000
##
## Model Test Baseline Model:
##
##   Test statistic                             76636.624
##   Degrees of freedom                               120
##   P-value                                        0.000
##
## User Model versus Baseline Model:
##
##   Comparative Fit Index (CFI)                    0.158
##   Tucker-Lewis Index (TLI)                       0.056
##
##   Robust Comparative Fit Index (CFI)             0.011
##   Robust Tucker-Lewis Index (TLI)               -0.109
##
## Loglikelihood and Information Criteria:
##
##   Loglikelihood user model (H0)             -25339.140
##   Loglikelihood unrestricted model (H1)       6924.360
##
##   Akaike (AIC)                               50768.280
##   Bayesian (BIC)                             50966.066
##   Sample-size adjusted Bayesian (SABIC)      50823.204
##
## Root Mean Square Error of Approximation:
##
##   RMSEA                                          1.003
##   90 Percent confidence interval - lower         0.996
##   90 Percent confidence interval - upper         1.009
##   P-value H_0: RMSEA <= 0.050                    0.000
##   P-value H_0: RMSEA >= 0.080                    1.000
##
##   Robust RMSEA                                  97.894
##   90 Percent confidence interval - lower         0.000
##   90 Percent confidence interval - upper         0.000
##   P-value H_0: Robust RMSEA <= 0.050               NaN
##   P-value H_0: Robust RMSEA >= 0.080               NaN
##
## Standardized Root Mean Square Residual:
##
##   SRMR                                           0.558
##
## Parameter Estimates:
##
##   Standard errors                             Standard
##   Information                                 Observed
##   Observed information based on                Hessian
##
## Latent Variables:
##                    Estimate  Std.Err  z-value  P(>|z|)   Std.lv  Std.all
##   Alpha =~
##     wage_2013         1.000                               1.472    0.312
##     wage_2014         1.000                               1.472    0.305
##     wage_2015         1.000                               1.472    0.303
##     wage_2016         1.000                               1.472    0.313
##
## Regressions:
##                    Estimate  Std.Err  z-value  P(>|z|)   Std.lv  Std.all
##   wage_2013 ~
##     age_2013  (b1)    0.485    0.040   12.194    0.000    0.485    1.425
##     sq_g_2013 (b2)   -0.321    0.044   -7.364    0.000   -0.321   -0.852
##     tenr_2013 (b3)    0.592    0.017   34.429    0.000    0.592    0.328
##   wage_2014 ~
##     age_2014  (b1)    0.485    0.040   12.194    0.000    0.485    1.398
##     sq_g_2014 (b2)   -0.321    0.044   -7.364    0.000   -0.321   -0.854
##     tenr_2014 (b3)    0.592    0.017   34.429    0.000    0.592    0.457
##   wage_2015 ~
##     age_2015  (b1)    0.485    0.040   12.194    0.000    0.485    1.383
##     sq_g_2015 (b2)   -0.321    0.044   -7.364    0.000   -0.321   -0.863
##     tenr_2015 (b3)    0.592    0.017   34.429    0.000    0.592    0.517
##   wage_2016 ~
##     age_2016  (b1)    0.485    0.040   12.194    0.000    0.485    1.414
##     sq_g_2016 (b2)   -0.321    0.044   -7.364    0.000   -0.321   -0.901
##     tenr_2016 (b3)    0.592    0.017   34.429    0.000    0.592    0.530
##
## Covariances:
##                    Estimate  Std.Err  z-value  P(>|z|)   Std.lv  Std.all
##   Alpha ~~
##     age_2013          0.000                               0.000    0.000
##     sq_age_2013       0.000                               0.000    0.000
##     tenure_2013       0.000                               0.000    0.000
##     age_2014          0.000                               0.000    0.000
##     sq_age_2014       0.000                               0.000    0.000
##     tenure_2014       0.000                               0.000    0.000
##     age_2015          0.000                               0.000    0.000
##     sq_age_2015       0.000                               0.000    0.000
##     tenure_2015       0.000                               0.000    0.000
##     age_2016          0.000                               0.000    0.000
##     sq_age_2016       0.000                               0.000    0.000
##     tenure_2016       0.000                               0.000    0.000
##   age_2013 ~~
##     sq_age_2013     171.662   10.005   17.158    0.000  171.662    0.988
##     tenure_2013      22.422    1.747   12.837    0.000   22.422    0.618
##   sq_age_2013 ~~
##     tenure_2013      19.129    1.556   12.297    0.000   19.129    0.583
##   age_2014 ~~
##     sq_age_2014     177.180   10.421   17.001    0.000  177.180    0.989
##     tenure_2014      17.226    2.252    7.649    0.000   17.226    0.332
##   sq_age_2014 ~~
##     tenure_2014      15.048    2.070    7.269    0.000   15.048    0.314
##   age_2015 ~~
##     sq_age_2015     179.431   10.457   17.160    0.000  179.431    0.989
##     tenure_2015      17.021    2.510    6.781    0.000   17.021    0.289
##   sq_age_2015 ~~
##     tenure_2015      15.690    2.365    6.633    0.000   15.690    0.282
##   age_2016 ~~
##     sq_age_2016     179.602   10.258   17.508    0.000  179.602    0.989
##     tenure_2016      15.163    2.420    6.266    0.000   15.163    0.262
##   sq_age_2016 ~~
##     tenure_2016      14.030    2.326    6.031    0.000   14.030    0.252
##
## Intercepts:
##                    Estimate  Std.Err  z-value  P(>|z|)   Std.lv  Std.all
##     Alpha             0.000                               0.000    0.000
##    .wage_2013 (b0)    7.636    0.847    9.015    0.000    7.636    1.618
##    .wage_2014 (b0)    7.636    0.847    9.015    0.000    7.636    1.580
##    .wage_2015 (b0)    7.636    0.847    9.015    0.000    7.636    1.570
##    .wage_2016 (b0)    7.636    0.847    9.015    0.000    7.636    1.622
##     age_2013         41.741    0.566   73.707    0.000   41.741    3.012
##     sq_g_2013        19.340    0.512   37.759    0.000   19.340    1.543
##     tenr_2013         6.229    0.107   58.202    0.000    6.229    2.378
##     age_2014         42.741    0.569   75.119    0.000   42.741    3.069
##     sq_g_2014        20.185    0.526   38.385    0.000   20.185    1.568
##     tenr_2014         5.506    0.152   36.138    0.000    5.506    1.477
##     age_2015         43.741    0.566   77.220    0.000   43.741    3.155
##     sq_g_2015        21.049    0.535   39.365    0.000   21.049    1.608
##     tenr_2015         4.873    0.174   28.063    0.000    4.873    1.147
##     age_2016         44.741    0.561   79.781    0.000   44.741    3.260
##     sq_g_2016        21.934    0.540   40.583    0.000   21.934    1.658
##     tenr_2016         5.678    0.172   32.957    0.000    5.678    1.347
##
## Variances:
##                    Estimate  Std.Err  z-value  P(>|z|)   Std.lv  Std.all
##    .wage_2013         4.144    0.333   12.429    0.000    4.144    0.186
##    .wage_2014         4.616    0.359   12.849    0.000    4.616    0.198
##    .wage_2015         4.355    0.347   12.536    0.000    4.355    0.184
##    .wage_2016         3.964    0.324   12.237    0.000    3.964    0.179
##     age_2013        192.107   11.128   17.263    0.000  192.107    1.000
##     sq_age_2013     157.145    9.103   17.263    0.000  157.145    1.000
##     tenure_2013       6.860    0.397   17.291    0.000    6.860    1.000
##     age_2014        193.922   11.340   17.101    0.000  193.922    1.000
##     sq_age_2014     165.634    9.686   17.101    0.000  165.634    1.000
##     tenure_2014      13.904    0.805   17.279    0.000   13.904    1.000
##     age_2015        192.197   11.138   17.256    0.000  192.197    1.000
##     sq_age_2015     171.264    9.925   17.256    0.000  171.264    1.000
##     tenure_2015      18.063    1.044   17.301    0.000   18.063    1.000
##     age_2016        188.384   10.702   17.602    0.000  188.384    1.000
##     sq_age_2016     174.981    9.941   17.602    0.000  174.981    1.000
##     tenure_2016      17.778    1.026   17.334    0.000   17.778    1.000
##     Alpha             2.165    0.211   10.286    0.000    1.000    1.000
##
## R-Square:
##                    Estimate
##     wage_2013         0.814
##     wage_2014         0.802
##     wage_2015         0.816
##     wage_2016         0.821
```

</details>

Leaving aside the warning that a greater number of iterations is required to converge...
since this exercise is purely to test the theory that serial convergence is present...
here's the final table.

|                         |**Reference Model**|**`-gsem-` Model 1**|**`-gsem-` Model 2**|**lavaan Model 5**|**lavaan Model 6**|
|:-                       |-                  |-                   |-                   |-                 |-                 |
|**N obs**                |1,928              |1,928               |1,928               |1,926             |599               |
|**N groups**             |589                |589                 |                    |588               |                  |
|**intercept**            |7.6294             |7.6528              |7.6289              |7.629             |7.636             |
|                         |*p<0.0001*         |*p<0.0001*          |*p<0.0001*          |*p<0.0001*        |*p<0.0001*        |
|**age coef.**            |0.4860             |0.4848              |0.4860              |0.486             |0.485             |
|                         |*p<0.0001*         |*p<0.0001*          |*p<0.0001*          |*p<0.0001*        |*p<0.0001*        |
|**sq. age coef.**        |-0.0032            |-0.0032             |-0.0032             |-0.322<sup>†</sup>|-0.321<sup>†</sup>|
|                         |*p<0.0001*         |*p<0.0001*          |*p<0.0001*          |*p<0.0001*        |*p<0.0001*        |
|**tenure coef.**         |0.5889             |0.5900              |0.5888              |0.590             |0.592             |
|                         |*p<0.0001*         |*p<0.0001*          |*p<0.0001*          |*p<0.0001*        |*p<0.0001*        |
|**Var(ε)**               |4.2660             |                    |4.2660              |4.267             |                  |
|**Var(ε<sub>2013</sub>)**|                   |4.1397              |                    |                  |4.144             |
|**Var(ε<sub>2014</sub>)**|                   |4.6110              |                    |                  |4.616             |
|**Var(ε<sub>2015</sub>)**|                   |4.3479              |                    |                  |4.355             |
|**Var(ε<sub>2016</sub>)**|                   |3.9745              |                    |                  |3.964             |
|**Var(α)**               |2.1980             |2.1868              |2.1980              |2.178             |2.165             |
|**R-squared**            |0.6954             |                    |                    |                  |                  |
|**R-squared (2013)**     |                   |                    |                    |                  |0.814             |
|**R-squared (2014)**     |                   |                    |                    |                  |0.802             |
|**R-squared (2015)**     |                   |                    |                    |                  |0.816             |
|**R-squared (2016)**     |                   |                    |                    |                  |0.821             |

So indeed I have a disappointment sandwich.
But the fault lies in my random effects model that I took as a reference,
not in my self-taught structural equation model.
Serial correlation is a failure of assumptions that exists completely in the
blind spot of random effects estimation.
lavaan meanwhile screamed that I was wrong from the very beginning.
Frank Harrell
[wrote](https://www.fharrell.com/post/re/)
about this specific issue.
He advises:
"Above all,
don't default to only using random intercepts to handle within-subject
correlations of serial measurements.
This is unlikely to fit the correlation structure in play."

----

Now, does `-gsem-` make inappropriate assumptions?
Maybe.
Can't conclude either way with this example.
Might come back to that investigation eventually.
But let's consider this series on SEM finished.

