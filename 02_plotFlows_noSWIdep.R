library(dplyr)
library(parsetR)
library(htmlwidgets)

###		SETTINGS   ###
data.sub.file <- "input/data.csv"
translation.file <- "input/translation_asylumFlowsEU.csv"

df <- read.csv(data.sub.file)
txt <- read.csv(translation.file, row.names = 1, stringsAsFactors = F)

for(lang in colnames(txt)) {
  dd <- df

  tmp_html <- paste0("flow_EU_tmp_", lang, ".html")
  output.html <- paste0("asylumApplicationsFlow_EU_", lang, ".html")

  # rename origin / citizen country names
  idx <- match(paste0("code.", gsub(" ", "", dd$citizen)), rownames(txt))
  stopifnot(all(!is.na(idx)))
  dd$citizen <- txt[idx, lang]

  # rename destination / geo names
  idx <- match(paste0("code.", gsub(" ", "", df$geo)), rownames(txt))
  stopifnot(all(!is.na(idx)))
  dd$geo <- txt[idx, lang]

  # rename dimensions
  colnames(dd)[match(c("citizen", "geo"), colnames(dd))] <- txt[c("origins", "destinations"), lang]
  colNums <- match(c("values", txt[c("origins", "destinations"), lang]), colnames(dd))

  ps.chart <- parset(select(dd, colNums),
    dimensions =  txt[c("origins", "destinations"), lang],
    # use some JavaScript to inform parset that Freq has the value
    # http://www.buildingwidgets.com/blog/2015/9/17/week-37-parsetr
    value = htmlwidgets::JS("function(d){return d.values}"),
    tension = 0.7, width = "100%", height = 400,
    spacing = 18, duration = 250
    )

  # overwite default padding
  ps.chart$sizingPolicy$browser$padding <- 4

  saveWidget(ps.chart, file = tmp_html, selfcontained = FALSE, libdir = "js")
}

