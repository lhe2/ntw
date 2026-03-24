# tdt wrangle utils
# 2026-01-09

# load math
source(here("scripts/math_utils.R"))

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
  
  # assign survival status at 24h intervals
  df <- df %>%
    #df <- dfs_tidy$wide %>% # for troubleshooting
    mutate(
      ## from enter time
      st.enter0 = dt.enter,
      st.enter24 = st.enter0 + 24, # start of rec time, aka dt.recovery

      ## from return time 
      st.ret0 = dt.return, # end of rec time, aka dt.enter+0, 24, 48
      st.ret24 = st.ret0 + 24,
      st.ret48 = st.ret24 + 24,
      st.ret72 = st.ret48 + 24,
      st.ret96 = st.ret72 + 24
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
    # group_by(cohort,
    #          trt.duration, trt.recover) %>% # for troubleshooting

    # calc survival props
    summarise(
      n.total = n(),
      across(starts_with("status."), ~ sum(., na.rm = TRUE),
             .names = "{sub('status', 'n.initial', col)}")) %>% #View()
    # rename(n.surv.enter = n.initial.enter0,
    #        n.initial.rec = n.initial.enter24
    #       ) %>%
    mutate(
      #n.total = n.initial.enter0,
      n.surv.enter0 = n.initial.enter24,
      n.initial.rec = n.initial.enter24,
      n.surv.rec = n.initial.ret0,
      
      #n.surv.enter0 = n.initial.enter24,
      #n.initial.rec0 = n.initial.enter24,
      #n.surv.rec0 = n.initial.ret0, 
      n.surv.ret0 = n.initial.ret24,
      n.surv.ret24 = n.initial.ret48,
      n.surv.ret48 = n.initial.ret72,
      n.surv.ret72 = n.initial.ret96
      ) %>%
    ungroup()
    
  ## fix calcs in 40C @ 0h, if cols exist
    if(rlang::has_name(df, "trt.duration") & rlang::has_name(df, "trt.recover")){
      df <- df %>%
        mutate(n.initial.rec = case_when(trt.duration == 0 & trt.recover == 40 ~ n.initial.enter0,
                                         TRUE ~ n.initial.rec),
               n.surv.rec = case_when(trt.duration == 0 & trt.recover == 40 ~ n.initial.enter24,
                                      TRUE ~ n.surv.rec))
    } else if(rlang::has_name(df, "trt")){
      df <- df %>%
        mutate(n.initial.rec = case_when(trt == 40 ~ n.initial.enter0,
                                         TRUE ~ n.initial.rec),
               n.surv.rec = case_when(trt == 40 ~ n.initial.enter24,
                                      TRUE ~ n.surv.rec))
    } else return(df)
    
  df %>%
    pivot_longer(starts_with(c("n.initial", "n.surv")),
                 names_to = c(".value", "timept"),
                 names_pattern = "(n\\.[a-z]*)\\.([a-z]*\\d*)") %>% #View()
    filter(!(timept %in% c("enter24", "ret96"))) %>%
    mutate(n.died = n.initial - n.surv,
           # % individuals per timept
           p.surv = n.surv/n.initial,
           p.died = n.died/n.initial,
           # % individials overall
           P.surv = n.surv/n.total,
           P.died = n.died/n.total,
           timept = case_when(timept == "enter0" ~ "enter",
                              TRUE ~ timept)
           ) %>% #View()
    pivot_longer(#starts_with(c("n.", "p.", "P.")),
                 contains(c("surv", "died")), # = at the end of the timept
                 names_to = c(".value", "status"), names_sep = "\\."
    ) %>% #View()
    #mutate(timept = factor(timept, levels = c("enter", "rec", "ret0", "ret24", "ret48", "ret72"))) %>% View()
  
  ## omit "enter" and "rec" timepts for ctrls bc otherwise its a pita to get the math right lol
  ## (you get negatives at 40C @ 0h bc of how initial vs surv counts are done)
  # if(rlang::has_name(df, "trt.duration")){
  #   #filter(df, !(trt.duration == 0 & timept %in% c("enter", "rec"))) %>%
  #   mutate(n = case_when(timept %in% c("enter", "rec") ~ ))
  #     return()
  # } else if(rlang::has_name(df, "trt")){
  #   filter(df, !(trt < 100 & timept %in% c("enter", "rec"))) %>%
  #     return()
  # } else return(df)
    
    ungroup()
  
}


CalcDevSS <- function(wide_df){
  # calcs and pivot
  long_df <- wide_df %>%
    mutate(# breaking so omit for now...
      # status.3rd = case_when(!is.na(jdate.3rd) ~ 1, # revisit..
      #                        TRUE ~ 0),
      
      # TODO: stdise by enter or hatch date?? (probably enter right...)
      tt.return = jdate.return - jdate.enter,
      tt.3rd = jdate.3rd - jdate.enter,
      tt.4th = jdate.4th - jdate.enter,
      tt.5th = jdate.5th - jdate.enter) %>%
    pivot_longer(starts_with(c("tt", "mass")),
                 names_to = c(".value", "instar"),
                 names_sep = "\\.") %>%
    drop_na(tt)
  
  # ss calcs
  long_df %>%
    mutate(logmass = log(mass)) %>%
    group_by(across(c(starts_with("trt"), instar))) %>%
    summarise(n = n(),
              #n = sum(!is.na(.)),
              across(.cols = c(mass, logmass, tt),
                     .fns = list(avg = ~ mean(.x, na.rm = TRUE),
                                 se = se),
                     .names = "{.fn}.{.col}")
              
              # TODO: breaking.. omit for now
              # # props dont work w cold ctrls (only) bc everyones alive lol
              # # also bc i think this needs to be done wide...
              # prop.surv = sum(status.3rd == 1)/n,
              # se.surv = seprop(prop.surv, n)
    ) %>%
    ungroup()
}
