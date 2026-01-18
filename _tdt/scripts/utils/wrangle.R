# tdt wrangle utils
# 2026-01-09

### SUMMARY STATS ###
# se <- function(x){ 
#   sd(na.omit(x))/sqrt(length(na.omit(x)))
# }

# wrangling ----------------------------------------------------

# grouping
# does not work very well bc idk how to internally specify the group vars consistently...
# .GroupTDT <- function(df, ...){
#   #group_vars <- !!!rlang::ensyms(...) # breaks?
#   
#   return(df %>% group_by(!!!rlang::ensyms(...)))
# }

#' args:
#'  - df: wide format and pre-subsetted if needed(?)
#'  - ...: variables to group by later

CalcSurvProps <- function(df, ...){
  #grp <- rlang::ensyms(...) # works with !!!grp later but doesnt show vars
  #grp <- enquos(...)
  
  # assign survival status
  df %>%
    #dfs_tidy$wide %>%
    mutate(
      ## TODO (NEED TO RETHINK A LITTLE...)
      # stdise timepts to the slowest trt group
      ## by enter time (to expts)
      st.enter0 = case_when(trt.duration == 0 ~ dt.enter + 24,
                            TRUE ~ dt.enter),
      st.enter24 = st.enter0 + 24,

      ## by return time (to 48h rec)
      ## TODO need to adjust times here if subsetting rec 24 only/48 only
      st.ret0 = case_when(trt.duration == 0 ~ dt.return + 48,
                          trt.duration == 24 ~ dt.return + 24,
                          TRUE ~ dt.return),
      st.ret24 = st.ret0 + 24,
      st.ret48 = st.ret24 + 24,
      st.ret72 = st.ret48 + 24,
      #st.ret96 = st.ret72 + 24
    ) %>%

    ## code survival status at each timept
    mutate(
      across(starts_with("st."), ~ case_when(dt.exit > . ~ 1,
                                             TRUE ~ NA_real_),
             .names = "{sub('st', 'status', col)}"),
    ) %>%
    select(-starts_with(c("st.", "dh."))) %>% #View()

    #group_by(!!!grp) %>% # works with rlang::enquo but doesnt show names
    #.GroupTDT(...) %>% # meh
    group_by(...) %>%
    #group_by(cohort) %>% # for troubleshooting

    # calc survival props
    summarise(
      across(starts_with("status."), ~ sum(., na.rm = TRUE),
             .names = "{sub('status', 'n.surv', col)}"),
      n.initial.enter0 = n(), # still confused abt this..
      n.initial.enter24 = n.surv.enter0,
      n.initial.ret0 = n.surv.enter24,
      n.initial.ret24 = n.surv.ret0,
      n.initial.ret48 = n.surv.ret24,
      n.initial.ret72 = n.surv.ret48,
  
      # n.surv.enter0 = n.initial.enter24,
      # n.surv.enter24 = n.initial.ret0,
      # n.surv.ret0 = n.initial.ret24,
      # n.surv.ret24 = n.initial.ret48,
      # n.surv.ret48 = n.initial.ret72,
      # n.surv.ret72 = n.initial.ret96
    ) %>%
    pivot_longer(starts_with(c("n.initial", "n.surv")),
                 names_to = c(".value", "timept"),
                 names_pattern = "(n\\.[a-z]*)\\.([a-z]*\\d*)") %>%
    mutate(n.died = n.initial - n.surv,
           p.surv = n.surv/n.initial,
           p.died = n.died/n.initial) %>%
    #filter(timept != "ret96") %>%
    pivot_longer(starts_with(c("n.", "p.")),
                 names_to = c(".value", "status"), names_sep = "\\."
    ) #%>% View()
}
