library(eurostat)
library(dplyr)
library(magrittr)

######      This download the very large monthly asylum data with country of origin!
dataID <- "migr_asyappctzm"

############################################################################################
###		Get data
############################################################################################

dat <- get_eurostat(dataID, time_format = "raw", cache = F)
data <- cbind(label_eurostat(dat), iso2 = dat$geo)

# transform dates efficiently!
times <- unique(data$time)
times <- structure(eurostat:::eurotime2date(times, last = FALSE), names = as.character(times))
data$time <- times[match(data$time, names(times))]

# subset columns - get First time applicant and not all 'Asylum applicant'!
data %<>% filter(asyl_app == 'First time applicant', sex == 'Total', age == 'Total') %>%
  select(one_of(c('citizen', 'geo', 'time', 'values', 'iso2')))

# subset the data for year 2015
df <- data %>% filter(time >= as.Date("2014-01-01"), time <= as.Date("2015-09-01"))
df$year <- format(df$time, "%Y")

###
filter(df, citizen == "Afghanistan", iso2 == 'TOTAL') %>%
  group_by(year) %>% dplyr::summarise(tot = sum(values, na.rm = T))

df %>% filter(citizen == "Iraq", iso2 == 'TOTAL') %>%
  group_by(year) %>% dplyr::summarise(tot = sum(values, na.rm = T))

df %>% filter(citizen == "Kosovo (under United Nations Security Council Resolution 1244/99)", iso2 == 'TOTAL') %>%
  group_by(year) %>% dplyr::summarise(tot = sum(values, na.rm = T))
