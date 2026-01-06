# ntw

code associated with analysing data from various ntw-related expts 👍

this repo compiles multiple projects, so see also project-specific readmes.

## projects

this repo is primarily organised into three main `<project>/` directories; the [here](https://here.r-lib.org/) package is used for relative pathfinding throughout the repo.

-   [`_ntw`](/_ntw/readme.md): ntw expts from 2023-25.

-   [`_ox`](/_ox/readme.md): ox stress expts from 2024.

-   [`_tdt`](/_tdt/readme.md): tdt/recovery expts from 2025.

### project directory organisation

each `<project>/` directory has the following structure (untracked (UT) directories are indicated):

-   `data/`: (UT) raw and cleaned data; grouped by year.

-   `figs/`: (UT, but tracked on google drive) manually exported figures. grouped by year; most up-to-date figs are in the most recent year.

-   `scripts/`: data import, cleaning, and analysis scripts.

    -   `R/`: `tidy*.R` and `wrangle*.R` scripts generated from their `.Rmd` counterparts by the [knitr](https://yihui.org/knitr/) package. (UT)

    -   `*-util.R`: custom utility functions.

    -   `import*`: data import and mild cleaning.

    -   `tidy*`: converting data to tidy format.

    -   `wrangle*`: generation of summary statistics, etc (usually for downstream visualisations).

    -   `analysis*`: primary scripts for statistical analyses and data visualisations (stats/viz are usually separate scripts). sources tidying/wrangle scripts from `scripts/R/`.

the following untracked directories recur at multiple levels of the repo, primarily serving administrative functions:

-   `archive/`: catch-all archive for code, figures, notes, etc.

-   `dump/`: generally, wip files/experimenting.

-   `etc/`: generally, administrative files (notes, todos, etc) or aliases to related, external files not in the repo.

## outputs

scripts related to generating outputs (talks, writing, etc) from the three main projects are stored the `outputs/` directory in the repo root; outputs draw across different projects.

the structure of each `<output>/` directory loosely follows the structure of the `<project>/` directories, but tend to have more files related to wrangling/analysis.

| directory             | product/contents | data sources              |
|-----------------------|------------------|---------------------------|
| `2025-05_bsft`        | ppt (figs only)  | ntw 23-24/feasibility viz |
| `2025-05_feasibility` | document, ppt    | ntw 23-24                 |
| `2024-11_entsoc`      | poster           | ntw 23-24                 |

## script update status

⚠️ as of 2026-01-05: some files in `.../scripts/` are not yet up-to-date/compatible/standardised to the 2025 workflow (above) after [major repo reorganisation](https://github.com/lhe2/ntw/tree/c6d51d2d20742d4ad07bfc9145b36ca47caef3c7). see below for issues/status.

|   | import | wrangle | analysis | comments |
|---------------|---------------|---------------|---------------|---------------|
| `_ox/dev` | needs overhaul (minor?) | needs separation from analysis scripts | outdated paths; broken helper scripts | uses 2024 ntw workflow |
| `_ox/plates` | -- | -- | import/wrangle/analysisin single script | uses 2024 ntw workflow |
| `_tdt/dev` | needs overhaul (minor) | outdated paths | outdated paths; needs overhaul (major) | close to current workflow |
| `output/feasibility/` | n/a | -- | wrangle/analysis in single script | check data compatibility |
| `output/entsoc/` | n/a | outdated paths | outdated paths | check data compatibility |
