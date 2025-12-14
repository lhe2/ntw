# ntw

code associated with analysing data from various ntw-related expts 👍 repo contents below!

## general organisation

files are loosely organised by year of the field season that the data originated from. generally, look to the most recent year for the most recent + updated collation of data (bc i am not very consistent about how i do things lol).

overview of contents are below, but see year-specific `README`s for details about directory-specific contents and workflows.

-   [`2025/`](/2025/2025-readme.md)

    -   `ntw/`: summer 2025 update of ntw data analyses; collates all ntw data from 2023-25

    -   `tdt/`: summer 2025 recovery expts

-   [`2024/`](/2024/2024-readme.md)

    -   folders are split up into data processing steps (cleaning, wrangling, analysis, etc).

    -   expts for this year are split up thruout the folders:

        -   summer 2024 update of `ntw` analyses

        -   summer 2024 oxidative stress expts:

            -   `ox-growth`: larval development data

            -   `plates`: analyses of molecular assays

    -   some other outputs in this year (collating 2023-24 ntw data)

        -   `feasibility`: scripts + figs related to may 2025 feasibility exam

        -   `entsoc`: scripts + figs related to poster for nov 2024 entsoc meeting

        -   `bsft`: figs only; for may 2025 bsft talk

-   [`2023/`](/2023/2023-readme.md)

    -   scripts are named as `purpose_expt.ext` .

    -   expts are mainly all the flavors of the ntw expts from spring 2023, summer-fall 2024.

        -   `temps`: 2x2 (sp 2023)

        -   `acc`: examining damage accumulation (sp 2023)

        -   `NTs`: different NTs (aka what is referred to as `ntw` in following years) (spans all seasons)

        -   `F1s`: hatchlings from `NTs` expts (mainly fall 2024)

-   root:

    -   `set-paths.R`: uses `here()` to establish a bunch of convenience items for relative pathing through the project folder

    -   `notes/`: untracked directory, namely contains `todos.md` and other script wips/notes/etc. (but todos were replaced by a [gh project](https://github.com/users/lhe2/projects/2/) as of jul 2025)

## overall workflow

-   pathing throughout the project directory is achieved with the `set-paths.R` script at the root.

-   all year folders generally have the following folders (untracked), specific to the folder's year unless otherwise indicated.

    -   `data/`: raw and cleaned data

    -   `figs/`: manually exported figures (also tracked on google drive)

    -   `etc/`: archived figs/scripts

-   generally, purpose of the script can be identified in the file name; scripts should be run in the following order:

    -   cleaning (import) \> wrangling (tidying) \> analysis (viz/figures)

        -   `helper.R` or `util.R` scripts may either be associated to a specific script or multiple scripts.

        -   2024 onwards starts to make use of purled pre-wrangle scripts for ntw data.
