# title: 2024 analyses helpers
# date: 2024-07-16
# purpose: does some pre-loading stuff for analysis scripts

# this worked well for 2023 lol so we'll do it again

# dependencies:
  ## outputs of `cleaning_ox.Rmd`, but see below

# 0. package and data loading ---------------------------------------------

library(tidyverse)
library(conflicted)
conflicts_prefer(dplyr::filter)

wide_all <- read.csv("~/Documents/repos/ntw/2024/data/ox.csv", header = TRUE)


# 1. wide manipulations ----------------------------------------------------

## formatting and labels
wide_all <- wide_all %>%
  mutate(labs.trt = case_when(trt == 267 ~ "26±7°C",
                              trt == 260 ~ "26±0°C",
                              trt == 330 ~ "33±0°C",
                              trt == 360 ~ "36±0°C",
                              trt == 380 ~ "38±0°C"),
         labs.trt = factor(labs.trt, levels = (c("26±7°C", "26±0°C", "33±0°C", "36±0°C", "38±0°C"))))

## calculations
wide_all <- wide_all %>%
  mutate(tt.3rd = jdate.3rd - jdate.hatch,
         tt.4th = jdate.4th - jdate.hatch,
         tt.5th = jdate.5th - jdate.hatch,
         tt.6th = jdate.6th - jdate.hatch,
         tt.wander = jdate.wander - jdate.hatch, 
         tt.died = jdate.pmd - jdate.hatch,
         tt.intrt = case_when(is.na(jdate.pmd) ~ jdate.pupa - jdate.3rd, ## i think intrt, pmdh, pmdt can be consolidated
                              TRUE ~ jdate.pmd - jdate.3rd),
         tt.pmd = jdate.pmd - jdate.hatch,
         
         ## dev times from 3rd (i.e. when enter trt) ##
         t3.pmd = jdate.pmd - jdate.3rd, 
         t3.4th = jdate.4th - jdate.3rd,
         t3.5th = jdate.5th - jdate.3rd,
         t3.6th = jdate.6th - jdate.3rd, 
         t3.wander = jdate.wander - jdate.3rd, 
         is.pmd = case_when(grepl("cull", fate) ~ 2,
                            is.na(jdate.pmd) ~ 0,
                            TRUE ~ 1)  # pmd stuff gets dropped in the pivot regardless
         )

# 2. pivot to long, formatting --------------------------------------------

# stats of major dev pts (i.e. day 0 of the instar)
long_major <- wide_all %>%
  pivot_longer(cols = starts_with(c("jdate", "mass", "tt", "t3")),
               names_to = c(".value", "instar"),
               values_drop_na = TRUE,
               names_pattern = ("([a-z]*\\d*)\\.(\\d*[a-z]*)")) %>%
  drop_na(jdate) %>%
  filter(instar != "2nd") # want to keep "hatch" for mathing
  #drop_na(tt) # drops NA's if an individual didnt reach a certain stage

# fine-scale stats for later instars only (e.g. 4th onward)
  # this allows for plotting of the day-by-day weight changes in the later instars

# separate out the 4ths, 5ths, 6ths to do math with
long_4ths <- wide_all %>%
  select(c("id", "jdate.hatch", "jdate.3rd", "jdate.4th", starts_with("mass.4"))) %>%
  rename(mass.4d0 = mass.4th,
         jdate = jdate.4th) %>%
  pivot_longer(cols = starts_with("mass.4"),
               #names_to = c(".value", "d4th"), names_sep = "\\."
               names_to = "dx", names_prefix = "mass.4d", names_transform = as.integer,
               values_to = "mass4th", values_drop_na = TRUE) %>%
  mutate(jdate_d = jdate + dx,
         instar = "4th") %>%
  select(-c("jdate", "dx")) %>%
  rename(jdate = jdate_d,
         mass = mass4th)

long_5ths <- wide_all %>%
  select(c("id", "jdate.hatch", "jdate.3rd", "jdate.5th", starts_with("mass.5"))) %>%
  rename(mass.5d0 = mass.5th,
         jdate = jdate.5th) %>%
  pivot_longer(cols = starts_with("mass.5"),
               names_to = "dx", names_prefix = "mass.5d", names_transform = as.integer,
               values_to = "mass5th", values_drop_na = TRUE) %>%
  mutate(jdate_d = jdate + dx,
         instar = "5th") %>%
  select(-c("jdate", "dx")) %>%
  rename(jdate = jdate_d,
         mass = mass5th)

long_6ths <- wide_all %>%
  select(c("id", "jdate.hatch", "jdate.3rd", "jdate.6th", starts_with("mass.6"))) %>%
  rename(mass.6d0 = mass.6th,
         jdate = jdate.6th) %>%
  pivot_longer(cols = starts_with("mass.6"),
               names_to = "dx", names_prefix = "mass.6d", names_transform = as.integer,
               values_to = "mass6th", values_drop_na = TRUE) %>%
  mutate(jdate_d = jdate + dx,
         instar = "6th") %>%
  select(-c("jdate", "dx")) %>%
  rename(jdate = jdate_d,
         mass = mass6th)

# merging
long_fine <- rbind(long_4ths, long_5ths, long_6ths)

long_all <- merge(long_fine, long_major, 
                  by = c("id", "instar", "jdate", "mass"),
                  all = TRUE)

# backfill and correct math
  # use tidyr::fill or zoo:na.locf to backfill: see
  # https://stackoverflow.com/questions/42915636/forward-and-backward-fill-data-frame-in-r

long_all <- long_all %>%
  arrange(id, jdate) %>% # make sure stuff is in order before backfilling
  zoo::na.locf(fromLast = TRUE, na.rm = FALSE) %>%
  mutate(tt = jdate - jdate.hatch,
         t3 = case_when(jdate >= jdate.3rd ~ jdate - jdate.3rd))
  
# cleanup
rm(long_4ths, long_5ths, long_6ths)
  

# 3. long calculations ----------------------------------------------------


# helper functions --------------------------------------------------------

## adding integer breaks to a plot (to add 24h breaks on dev time plots)
  # from: https://stackoverflow.com/a/62321155/17952236
  # ok this is not what i want LOL (n will determine the # of breaks u get)

# integer_breaks <- function(n, ...) {
#   fxn <- function(x) {
#     breaks <- floor(pretty(x, n = n, ...))
#     names(breaks) <- attr(breaks, "labels")
#     unique(breaks)
#   }
#   return(fxn)
# }
