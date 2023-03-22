---
title: ACS Data
date: "2023-03-21T20:34:24-05:00"
draft: false
---


American Community Survey 2021 5-year estimates were published in December.
I thought it would be fun to replicate the Census Bureau's profile of Chicago.
Thus begun an ordeal.


## Census Bureau's Data Platform

The Census Bureau has created a web portal for tabulation and dissemination of
ACS data, located at [data.census.gov](https://data.census.gov/).
It's a fantastic product and I highly recommend it for general purpose uses.

```bash
$ unzip ACSPUMS5Y2021_2023-03-06T184145.zip
$ wc -l ACSPUMS5Y2021_2023-03-06T174742.csv
101501 ACSPUMS5Y2021_2023-03-06T174742.csv
```

While the demographics section were a breeze to program,
I quickly ran into a major issue:
vacant housing units were not being exported.
(Quickly verifiable by running frequencies of `VACS`.)
I could not find a solution to this within the web portal,
so I began looking for an alternative.


## tidycensus

There's a fantastic project called `tidycensus` that seeks to build a unified
API to several Census Bureau surveys, including the ACS 5-year estimates for
PUMS.

The first step is, of course, to install R.
But the *trick* with using R packages is rather installing all of the
*libraries* that will be linked against.

```bash
$ sudo pacman -S r udunits gdal arrow cfitsio hdf5 netcdf`
[...]
$ R
[...]
> install.packages("tidyverse")
[...]
> library(tidyverse)
> warnings()
```

If there are warning, rinse and repeat.
Locate the missing shared objects, install them as well, and try again.


## An aside: PUMA

If you search for a list of PUMA codes, the first result will be the recently
finalized 2020 PUMA list.

After a fair bit of frustration, I realized that the 2020 PUMA names will
*not* be used until the 2022 ACS estimates are published.
In fact it is the 2010 PUMA list that I need, which can still be found on
[IPUMS](https://www2.census.gov/geo/pdfs/reference/puma/2010_PUMA_Names.pdf).


## Returning to tidycensus

The `tidycensus` package can be used like:

```R
#!/usr/bin/env Rscript

library(tidycensus)
library(tidyverse)
census_api_key("YOUR KEY HERE")

chicago <- get_pums(...)
```

*...however.*

I never managed to make this work.

I think it's a combination of limited system memory and the fact that
requesting vacant housing units through this package
[duplicates](https://github.com/walkerke/tidycensus/pull/441)
API calls.
Wouldn't be the first time my PC's age became a roadblock.
So I move on to a more reliable approach.


## IPUMS

I selected data through the
[IPUMS portal](https://usa.ipums.org/usa-action/variables/group).
Specifically I pulled a **rectangular** *(note the emphasis)*
fixed-width data file.

```bash
$ gunzip usa_00001.dat.gz
$ wc -l usa_00001.dat
15537785 usa_00001.dat
```

This is an export of the entire U.S., and I'm interested in just a tiny
portion.
A simple way to cut down the file is with `awk(1)`.

Then, using the basic codebook and a `bash(1)` one-liner, I constructed
a `FIELDWIDTHS` import instruction.

```bash
$ sed -e '11,61!d' usa_00001.cbk | awk '{ print $4 }' | xargs echo
4 4 6 8 13 10 13 2 5 12 1 5 2 7 7 3 2 1 1 7 1 1 2 4 10 3 2 1 1 3 2 2 1 1 1 1 1 1 1 1 1 1 2 1 2 4 1 7 7 3 1
```

Going forward, pretend that `$FW` is that sequence of space-delimited integers.
Test it on field 8: `STATEFP` (state FIPS code).

```bash
$ awk 'BEGIN {FIELDWIDTHS="$FW"} {print $8}' usa_00001.dat | sort -n | uniq -c
 233415 01
  32839 02
 335968 04
 145631 05
1826332 06
 275118 08
 173704 09
  44726 10
  32266 11
 942849 12
 463758 13
  72790 15
  84029 16
 621164 17
 327333 18
 163146 19
 147103 20
 221277 21
 206685 22
  66231 23
 291712 24
 339392 25
 497827 26
 280366 27
 136378 28
 307647 29
  52436 30
  97805 31
 139855 32
  67499 33
 428236 34
  92964 35
 956365 36
 487493 37
  39209 38
 580006 39
 188208 40
 202583 41
 645639 42
  50433 44
 238385 45
  44796 46
 323759 47
1245838 48
 158712 49
  32442 50
 409714 51
 372779 53
  85672 54
 298540 55
  28731 56
```

Now subset the data file using `STATEFP` and field 9 (`PUMA`).

```bash
$ awk 'BEGIN {FIELDWIDTHS="$FW"} $8=="17"' usa_00001.dat > usa_00001_il.dat
$ wc -l usa_00001_il.dat
621164 usa_00001_il.dat
$ awk 'BEGIN {FIELDWIDTHS="$FW"} $9~/035(0[1234]|2[0123456789]|3[012])/' usa_00001_il.dat > usa_00001_chi.dat
$ wc -l usa_00001_chi.dat
101501 usa_00001_chi.dat
```

But that number seems familiar...
Let's look at `VACS`, which happens to be in field 19.

```bash
$ awk 'BEGIN {FIELDWIDTHS="$FW"} {print $19}' usa_00001_chi.dat | sort -n | uniq -c
101501 B
```

I am back to square one.
I do not have vacant housing units.

A bit of sleuthing reveals a detail about the IPUMS extractions:

> By default, the extraction system rectangularizes the data: that is, it puts
> household information on the person records and does not retain the
> households as separate records. As a result, rectangular files will not
> contain vacant units, since there are no persons corresponding to these
> units. Researchers wishing to retain vacant units should instead choose a
> hierarchical file format when creating their extract.

*(see [here](https://usa.ipums.org/usa-action/variables/VACANCY#description_section))*

So I return to the portal and setup a **hierarchical** extract instead.

```bash
$ gunzip usa_00004.dat.gz
$ sed -e '11,68!d' usa_00004.cbk | awk '{ print $4 }' | xargs echo
1 4 4 6 8 13 10 13 2 5 12 1 5 2 7 7 3 2 1 1 7 1 1 2 1 4 4 6 8 13 4 10 3 2 1 1 3 2 2 1 1 1 1 1 1 1 1 1 1 2 1 2 4 1 7 7 3 1
$ awk 'BEGIN {FIELDWIDTHS="$FW"} $9=="17"' usa_00004.dat > usa_00004_il.dat
$ awk 'BEGIN {FIELDWIDTHS="$FW"} $10~/035(0[1234]|2[0123456789]|3[012])/' usa_00004_il.dat > usa_00004_chi.dat
$ awk 'BEGIN {FIELDWIDTHS="$FW"} {print $20}' usa_00004_chi.dat | sort -n | uniq -c
  47365 B
   1173 1
    135 2
    307 3
    126 4
    250 5
      6 6
   2735 7
```

Finally we've made some progress.


