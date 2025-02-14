# ntw

code associated with analysing data from various ntw-related expts 👍 repo contents below!

work is generally being grouped by field season they originated from.

## 2024/...

`2024/` includes code for summer-fall 2024 ntw repeat expts (growth & fecundity) + ox str molecular expts (pilot + final). sorta similarly structured/named as `2023/` with a few differences.

### relevant scripts

generally categorised as `[type]_[expt]`:

-   `[type]`:

    -   `cleaning`: cleans raw gsheets and outputs into `./data/...`

    -   `helpers`: does some additional data cleaning/data & lib loading/convenience function defining for analysis scripts

        -   `helpers_aesthetics.R` is a general aesthetics loader

    -   `analyses`: generally takes cleaned data from corresponding `helpers` and generates outputs for `./figs/...` or modeling

-   `[expt]`: `*` = active. others are sorta for ref/temporary while 2024 data was being generated

    -   `entsoc`: 2023 data only. for entsoc 2024 poster

    -   `ntw-compare*`: 2023 + 2024 data. for main growth/dev/fertility stats.

    -   `ntw`: 2024 data only. for growth/dev

    -   `ox*`: 2024 data only. for analysis of mol assays from bugs used in actual ox growth expt

    -   `ox-growth*`: 2024 data only. for growth/dev of bugs used for ox str molecular work (pilot + actual expt)

    -   `tents`: 2024 data only. for fertility stats

### 2024/figs/...

instead of by date like in `2023/`, loosely grouped by general project (see `[expt]`s above) \> response (responses grouped in subfolders if there's a lot). versions indicated by the appended date in the file name (`_yymmdd`)

### 2024/data...

top level contains cleaned outputs from `cleaning_[expt].Rmd` scripts that go into the `helpers` and `analyses` scripts. upon cleaning, a copy of the output is automatically saved into `./archive/` with date (`yymmdd`) prepended into filename.

`./plates/` contains plate data of molecular ox str assays.

## 2023/...

`2023/` includes code for spring 2022-fall 2023 ntw experiments. organisation in this is messy bc i didnt rlly plan ahead 😎

### relevant scripts

(listed in the order they should be used)

-   `cleaning_[EXPT].Rmd`: data cleaning scripts (pulls data from the gsheets); outputs into `./data/`

    -   `ntw`: larval growth/dev stuff for the big 3 expts + F1s

    -   `tents`: parsing out adult/tents stuff (longevity, parents, hatching)

-   `helpers_[EXPT].R`: data/library loading & pre-wrangling for the analysis scripts; defines some convenience functions/aesthetic objects to be used for analyses

    -   `ntw` and `tents` usage is same as the above

-   `analyses_[EXPT].Rmd`: analysis scripts for different types of expts (modeling stuff, figure generation). data/things is loaded from the corresponding `helper` script

    -   the big 3 (in order of when i ran them during that time period mentioned above). larval growth/dev data collected for all; adult fertility/F1 data collected for `NTs` only

        -   `temps`: 2x2 temps
        -   `acc`: looking for damage accumulation
        -   `NTs`: diff nts

    -   bonus/followups

        -   `ctrls`: ntw expt-wide & internal controls for the big 3 expts
        -   `tents`: adult fertility followups for `NT` bugs
        -   `F1s`: 2nd gen development/growth stuff for `NT` bugs

### 2023/figs/...

generally these are grouped by the date they were created bc i usually only use the most recent version of a figure. good luck navigating this folder

they are vaguely labeled as `[expt]_[response]`

## archive/...

`archive/` includes old versions of data, code, and figures for reference (from 2023/when this repo was first set up). new figures are tracked on google drive and are in the corresponding `figs/` directory for each year (see above)

labeling in `archive/figs/...`:

-   instar/temp: experiment type
-   a/l: adult or larva
-   growth/surv: growth or survival analyses
-   A/B: cohort
