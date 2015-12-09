library(dplyr)
library(htmlwidgets)
library(swiRcharts)
library(streamgraph)

data.file <- "input/orgin2015_ts.csv"
#translation.file <- "input/translation_asylumFlowsEU.csv"


df <- read.csv(data.file)
df$time <- as.Date(as.character(df$time))
#txt <- read.csv(translation.file, row.names = 1, stringsAsFactors = F)




lang <- 'fr'
tmp_html <- paste0("streamgraph_originAsylum_tmp_", lang, ".html")


schart <- df %>%
  streamgraph("citizen", "value", "time", interpolate="cardinal",
    right = 3, top = 5, bottom = 0, height = 500) %>%
  sg_axis_x(1, "year", "%Y") %>%
  sg_fill_manual(swi_rpal) %>%
  sg_legend(TRUE, "Pays d'origine: ")

# hack to make it responsive !!
schart$sizingPolicy$browser$padding <- 4
schart$sizingPolicy$browser$defaultWidth <- "100%"

saveWidget(schart, file = tmp_html, selfcontained = FALSE, libdir = "js")

swi_widget(tmp_html, "test.html")

