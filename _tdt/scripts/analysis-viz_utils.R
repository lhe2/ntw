# tdt viz utils.R
# 2026-01-06

# dump of viz stuff


# adding km vertical lines
# roadmap: df %>% calc times %>% scale to t0 %>% add geoms
#' usage: ggsurvplot() %++% AddKMLines() 
#' args:
#'  * df = probably same as km_df; but need to specify in the fn call.
#'         subset beforehand if using ggsurvplot_facet.
#'  * ... = grouping vars (based on ggsurv facet/groups)
#'  * t0 = dt.x, where x = from enter/rec/return subset. or set NA (see AddKMLines_NA (wip)).
#'         should match faceting vars so vlines only show up on relevant panels
#'         

AddKMLines <- function(df, t0, ...){
  #grp <- !!!rlang::ensyms(...) # TODO: figure out how this works lol
  #grp <- rlang::ensyms(...)
  
  ### calc vertical lines ###
  
  if(!missing(t0)){
    # & !is.na(t0) sorta works as a bypass if forcing t0=NA to define grouping vars
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
  
  #return(df) # troubleshooting
  
  ### plot ###
  
  if(missing(...)){
    grp <- NA
  } else {
    grp <- rlang::enquos(...)
  }
  
  return(
    list(geom_vline(data = df, aes(xintercept = dt.recover,
                                   #group = !!!grp
                                   ), 
                    color = "skyblue", lty = "dashed"),
         geom_vline(data = df, aes(xintercept = dt.return, 
                                   group = interaction(!!!grp), # TODO still doesnt work as intended
                                   #group = !!!grp
                                   ), color = "orange"),
         geom_vline(data = df, aes(xintercept = dt.enter,
                                   #group = !!!grp
                                   ), color = "red")
    )
    
    # TODO/TOFIX would be nice when faceting by cohort to somehow make distinct
    # the lines for trt.dur = 24/48 (otherwise theres multiple return lines)
  )
}
