# tdt readme

## field seasons and expts

| field season | expt | notes                                        |
|--------------|------|----------------------------------------------|
| 2025 summer  | tdt  | recovery expts (survival/larval development) |

## expt details

-   survival and dev are combined into 1 script! (probably should be split tho)

## workflow details (reference only)

⚠️ as of 2026-01-05: scripts will probably break, so reference only. see [repo update status](/README.md#script-update-status).

-   `cleaning.Rmd`: imports data from gsheets and preps for wrangling.

-   `wrangle.Rmd`: puts data into tidy format. is purled for use in analysis scripts.

-   `analysis_*.Rmd`: visualisation and statistics.

    -   use the most recent "round" of analysis for the stats/viz (reflects the most up-to-date analysis with all exptal cohorts)
