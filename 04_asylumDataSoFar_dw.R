library(eurostat)
library(dplyr)
library(magrittr)
library(WDI)

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
data %<>% filter(time >= as.Date("2015-01-01"))

# consider only the months with full data (with NA less than 5%) !!
times <- round(tapply(data$values, data$time, function(v) (sum(is.na(v))/length(v)) ) * 100)
cat("% of missing country data by month\n", times)
max.date <- max(as.Date(names(times)[times < 5]))
cat("Month until no missing data\n", as.character(max.date), " filter missing data months")
data %<>% filter(time <= as.Date(max.date))

###		Shape the data
# get only the total country of origin and discard aggregated geo
dd <- data %>% filter(citizen == "Total", !iso2 %in% c("EU28", "TOTAL")) %>%
  group_by(iso2, geo) %>% summarise(total = sum(values)) %>% ungroup()

sum(dd$total)

############################################################################################
###		Get Eurostat population data
############################################################################################

dat <- get_eurostat('tps00001')
datl <- label_eurostat(dat)
datl$iso2 <- dat$geo
max(datl$time)

pop <- datl %>% filter(time == max(datl$time), iso2 %in% as.character(unique(dd$iso2))) %>%
  select(one_of(c('geo','values', 'iso2')))

############################################################################################
###		Get World Bank data
############################################################################################

isoES2WB <- structure(as.character(unique(dd$iso2)), names = as.character(unique(dd$iso2)))
# EL and UK are not used by the WB!
isoES2WB[which(isoES2WB == 'EL')] <- 'GR'
isoES2WB[which(isoES2WB == 'UK')] <- 'GB'

# GDP per capita, PPP (current international $) http://data.worldbank.org/indicator/NY.GDP.PCAP.PP.CD

idw <- c('NY.GDP.PCAP.PP.CD')

getwbData <- function (ind, countries = isoES2WB) {
  indicator <- WDI(indicator = ind, country = countries, start = 2013, end = 2015)
  colnames(indicator)[3] <- 'values'
  do.call(rbind, by(indicator, indicator$iso2c, function(ii) {
    rowx <- !is.na(ii[,3])
    if(all(!rowx)) {
      ii[1,]
    } else if (all(rowx)){
      ii[which.max(ii$year),]
    } else {
      ii[which(rowx),]
    }
  }))
}

gdp <- getwbData(idw[1], isoES2WB)

############################################################################################
###		Combine the data
############################################################################################

## COMBINE ASYLUM ABSOLUTE NUMBERS
# demande d'asile
asylum.df <- dd %>% select(iso2, geo, total)
colnames(asylum.df)[3] <- "Demandes d'asiles en 2015 (janvier à septembre)"


## match indicators to result data.frame
stopifnot(match(asylum.df$iso2, names(isoES2WB)) == 1:length(isoES2WB))

asy.pop <- pop[match(asylum.df$iso2, pop$iso2), 'values']
asy.gdp <- round(gdp[match(isoES2WB, gdp$iso2c), 'values'])

asylum.df$`Demandes d'asiles en 2015 par million d'habitants` <- round(
  (asylum.df$`Demandes d'asiles en 2015 (janvier à septembre)` / asy.pop) * 10^6)
asylum.df$`Demandes d'asile par 1 USD du PIB par habitant` <- round(
  (asylum.df$`Demandes d'asiles en 2015 (janvier à septembre)` / asy.gdp ), 3)


write.csv(asylum.df, file = "output/04_asylum2015_pop_gdp_DW.csv", row.names = F)
