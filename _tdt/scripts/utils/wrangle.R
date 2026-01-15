# tdt wrangle utils
# 2026-01-09

# wrangling ----------------------------------------------------

# grouping
.GroupTDT <- function(df, ...){
  #group_vars <- !!!rlang::ensyms(...) # breaks?
  
  return(df %>% group_by(!!!rlang::ensyms(...)))
}

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


# (WIP) kms ---------------------------------------------------------------------

## 2026-01-12 GIVING UP! 
#' #' creating km fits:
#' #' `FitKMs` creates a survival fit for a subset of data to be used later
#' #' in ggsurvplot.
#' #' 
#' #' args: 
#' #'  * df: should have `tt.exit` and `fate` cols for Surv object fitting
#' #'  * var: response var for the Surv object
#' #' 
#' FitKMs <- function(df, var){
#'   # get the fit
#'   df <- filter(df, fate %in% c(0,1))
#'   var <- deparse(substitute(var)) 
#'     # or skip this by passing in "var"in quotes
#'   var <- df[[var]]
#'   
#'   surv <- Surv(df$tt.exit, df$fate)
#'   fit <- surv_fit(surv ~ var, data = df)
#'   
#'   #return(fit) # return only the fit for ggsurvfit
#'   #list(fit = fit, df = df)
#'   
#'   # plot
#'   ggsurv <- ggsurvplot(
#'     fit = fit, data = df)
#'   
#'   return(ggsurv)
#' }




# (WIP) adding km vertical lines
# df %>% calc times %>% scale to 0 %>% add geoms
#' usage: ggsurvplot() %++% AddKMLines() 
#' args:
#'  * df = probably same as km_df; need to specify
#'  * ... = grouping vars (based on ggsurv facet/groups)

# works, more or less
.AddKMLines0 <- function(df, t0 = NULL, ...){
  # get enter/recover/return times
  #df1 <- km_df %>%
  df %>%
    .GroupTDT() %>%
    #group_by(!!!rlang::ensyms(...)) %>%
    summarise(dt.enter, dt.recover, dt.return) %>% # times arent that even still..
    drop_na() %>% unique()

  # recalcs T0 if T0 =/= enter date
  # (doesnt work)
  if(!is.null(t0)){
    #t0 <- enquo(t0)
    #df <- df1 %>%
    df <- df %>%
      #mutate_all(~ . - !!t0) %>%
      mutate_all(~ . - {{t0}}) %>%
      mutate(across(everything(), ~ replace(.x, which(.x <0), NA))) %>%
      unique()
  }

  # plot
  return(
    list(geom_vline(data = df, aes(xintercept = dt.recover), color = "skyblue"),
         geom_vline(data = df, aes(xintercept = dt.return), color = "orange"),
         geom_vline(data = df, aes(xintercept = dt.enter), color = "red")
         )
  )
}

## uhhh this works now
AddKMLines <- function(df, t0, ...){
  if(!missing(t0)){
    df <- df %>%
      group_by(!!!rlang::ensyms(...)) %>%
      summarise(dt.enter, dt.recover, dt.return) %>% 
      drop_na() %>% unique() %>%
      mutate(across(starts_with("dt."), ~ . - {{t0}}),
             across(starts_with("dt."), ~ replace(.x, which(.x <0), NA))) %>%
      unique()
  } else {
    df <- df %>%
    group_by(!!!rlang::ensyms(...)) %>%
      summarise(dt.enter, dt.recover, dt.return) %>% 
      drop_na() %>% unique()
  }

  # plot
  return(
    list(geom_vline(data = df, aes(xintercept = dt.recover), color = "skyblue"),
         geom_vline(data = df, aes(xintercept = dt.return), color = "orange"),
         geom_vline(data = df, aes(xintercept = dt.enter), color = "red")
    )
  )
}


# ggsurvplot(fit = km_fit, data = km_df,
#            facet.by = "cohort"
# ) %++%
# AddKMLines2(df = km_df, 
#             t0 = dt.recover
#             ) %>% View()

# works as expected
# calc.kmtimes0 <- function(df, day0){
#   df %>%
#     summarise(dt.enter, dt.recover, dt.return) %>% 
#     drop_na() %>% unique() %>%
#     mutate_all(~ . - {{day0}}) %>%
#     mutate(across(everything(), function(x) replace(x, which(x<0), NA))) %>% unique()
# }
# 
# calc.kmtimes0(km_df, dt.recover)
