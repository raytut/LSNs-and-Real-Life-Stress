
##########################################################################
#   Summary functions to plot bars with sd, se, and CIs in them
##########################################################################

# Quick Summary
data_summary <- function(data, varname, groupnames){
    summary_func <- function(x, col){
        c(mean = mean(x[[col]], na.rm=TRUE),
          sd = sd(x[[col]], na.rm=TRUE), 
          se = (sd(x[[col]], na.rm=TRUE))/sqrt(length(x[[col]])))
    }
    data_sum <- ddply(data, groupnames, .fun=summary_func, varname)
    data_sum <- rename(data_sum, c("mean" = varname))
    return(data_sum)
}

# Summary with SE, SD, CIs
summarySE <- function(data=NULL, measurevar, groupvars=NULL, na.rm=FALSE, conf.interval=.95, .drop=TRUE) {

  
  # New version of length which can handle NA's: if na.rm==T, don't count them
  length2 <- function (x, na.rm=FALSE) {
    if (na.rm) sum(!is.na(x))
    else       length(x)
  }
  
  # This does the summary. For each group's data frame, return a vector with
  datac <- ddply(data, groupvars, .drop=.drop, .fun = function(xx, col) {
                   c(N    = length2(xx[[col]], na.rm=na.rm),
                     mean = mean   (xx[[col]], na.rm=na.rm),
                     sd   = sd     (xx[[col]], na.rm=na.rm)
                   )},
                 measurevar)
  
  # Rename the "mean" column    
  datac <- plyr::rename(datac, c("mean" = measurevar))
  datac$se <- datac$sd / sqrt(datac$N)  # Calculate standard error of the mean
  
  # Calculate t-statistic for confidence interval: 
  # e.g., if conf.interval is .95, use .975 (above/below), and use df=N-1
  ciMult <- qt(conf.interval/2 + .5, datac$N-1)
  datac$ci <- datac$se * ciMult
  
  return(datac)
}

### Norm within
normDataWithin <- function(data=NULL, idvar, measurevar, betweenvars=NULL, na.rm=FALSE, .drop=TRUE) {
  library(plyr)
  
  # Measure var on left, idvar + between vars on right of formula.
  data.subjMean <- ddply(data, c(idvar, betweenvars), .drop=.drop, .fun = function(xx, col, na.rm) {
    c(subjMean = mean(xx[,col], na.rm=na.rm))
  },
  measurevar,na.rm
  )
  
  # Put the subject means with original data
  data <- merge(data, data.subjMean)
  # Get the normalized data in a new column
  measureNormedVar <- paste(measurevar, "_norm", sep="")
  data[,measureNormedVar] <- data[,measurevar] - data[,"subjMean"] + mean(data[,measurevar], na.rm=na.rm)
  
  # Remove this subject mean column
  data$subjMean <- NULL
  return(data)
}

## Summary within Subjct
summarySEwithin <- function(data=NULL, measurevar, betweenvars=NULL, withinvars=NULL, idvar=NULL, na.rm=FALSE, conf.interval=.95, .drop=TRUE) {
  
  # Ensure that the betweenvars and withinvars are factors
  factorvars <- vapply(data[, c(betweenvars, withinvars), drop=FALSE], FUN=is.factor, FUN.VALUE=logical(1))
  
  if (!all(factorvars)) {
    nonfactorvars <- names(factorvars)[!factorvars]
    message("Automatically converting the following non-factors to factors: ", paste(nonfactorvars, collapse = ", "))
    data[nonfactorvars] <- lapply(data[nonfactorvars], factor)
  }
  
  # Get the means from the un-normed data
  datac <- summarySE(data, measurevar, groupvars=c(betweenvars, withinvars), na.rm=na.rm, conf.interval=conf.interval, .drop=.drop)
  
  # Drop all the unused columns (these will be calculated with normed data)
  datac$sd <- NULL
  datac$se <- NULL
  datac$ci <- NULL
  
  # Norm each subject's data, and rename norm variable
  ndata <- normDataWithin(data, idvar, measurevar, betweenvars, na.rm, .drop=.drop)
  measurevar_n <- paste(measurevar, "_norm", sep="")
  
  # Collapse the normed data - now we can treat between and within vars the same
  ndatac <- summarySE(data=ndata, measurevar=measurevar_n, groupvars=c(betweenvars, withinvars), na.rm=na.rm, conf.interval=conf.interval, .drop=.drop)
  
  # Apply correction from Morey (2008) to the standard error and confidence interval
  #  Get the product of the number of conditions of within-S variables
  nWithinGroups    <- prod(vapply(ndatac[,withinvars, drop=FALSE], FUN=nlevels, FUN.VALUE=numeric(1)))
  correctionFactor <- sqrt( nWithinGroups / (nWithinGroups-1) )
  
  # Apply the correction factor
  ndatac$sd <- ndatac$sd * correctionFactor
  ndatac$se <- ndatac$se * correctionFactor
  ndatac$ci <- ndatac$ci * correctionFactor
  
  # Combine the un-normed means with the normed results
  merge(datac, ndatac)
}


##########################################################################
#   lmer Cohens D
##########################################################################
cal_lm_effect <- function(x, paired_test){
    require (jtools)
    require (effectsize)
    if(missing(paired_test)) {
        paired_test=TRUE
    }
    summary_model <- summ(x, digits=4)
    test_list <- summary_model$coeftable[,0]
    test_df <- data.frame(nrow=test_list)
    test_df$CohensD <- 0
    for (i in (1:length(test_df$CohensD))){
        t_value <- summary_model$coeftable[i,3]
        df_val <-  summary_model$coeftable[i,4]
        cohen_d <- t_to_d(t_value, df_val)
        cohen_d <- abs(cohen_d$d)
        test_df[i,1] <- cohen_d
    }
    print(test_df)
}

##########################################################################
#   Utility function to plot lmer models in html 
##########################################################################

tab_lmer <- function(model){
    require(sjPlot)
    tab_model(model, transform=NULL, show.se=T, show.stat=TRUE, digits=3) %>%
        return() %$%
        knitr %>%
        asis_output()
}

##########################################################################
#   Utility function to print lmer results and dist.
##########################################################################

model_output <- function(model){
    print(summary(model))
    print(check_collinearity(model))
    # try(print(r2beta(model)))
    
    qqnorm(residuals(model)); qqline(residuals(model))
}


##########################################################################
#   Lagvar
##########################################################################

lag_var <- function(x, id, obs, day, data, lag) {
    x="time"
    id="subject_number"
    obs="obs"
    day="day"
    data=cort_scan
    lag=1
    
    # Code characters for later use
    id_mer <- as.character(id)
    obs_mer <- as.character(obs)
    x_lag <- (paste(as.character(x),"lag", sep="."))
    
    # get 'x', 'id', 'obs', 'day', and 'time' arguments (will be NULL when unspecified)
    x    <- data[[x]]
    id   <- data[[id]]
    obs  <- data[[obs]]
    day  <- data[[day]]
    ind <- as.numeric(rownames(data))
    
    # Lagging Section
    #########################################################################
    # Intialize Data frames
    dat <- data.frame(ind=ind,x=x, id=id, day=day, obs=obs)
    sub_append <- data.frame()
    # Lag at subject level
    for (subjects in (unique(dat$id))){
        sub <- subset(dat, id==subjects)
        # Now we lag each day
        for (days in 1:length(unique(day))){
            # Arrange by obs and lag
            sub_day <- subset(sub, day==days)
            sub_day <- sub_day %>% arrange(obs) 
            sub_day[[x_lag]] <- Lag(sub_day$x, lag)
            sub_append <- rbind(sub_append, sub_day)
        }
    }
    # Reorder rows so that they much original dataframe
    lag_df <- data.frame(ind=sub_append$ind, lag=sub_append[[x_lag]])
    rownames(lag_df) <- (lag_df$ind)
    lag_vec <- lag_df$lag[order(lag_df$ind)]
    #########################################################################
    return(lag_vec)
}

