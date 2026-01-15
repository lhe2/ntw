# tdt wrangle utils
# 2026-01-09

# wrangling ----------------------------------------------------

# grouping
.GroupTDT <- function(df, ...){
  #group_vars <- !!!rlang::ensyms(...) # breaks?
  
  return(df %>% group_by(!!!rlang::ensyms(...)))
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
