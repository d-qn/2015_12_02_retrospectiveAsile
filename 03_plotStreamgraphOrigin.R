library(dplyr)
library(htmlwidgets)
library(swiRcharts)
library(streamgraph)

data.file <- "input/orgin2015_ts.csv"
translation.file <- "input/translationStream.csv"

# read data files
df <- read.csv(data.file)
df$time <- as.Date(as.character(df$time))

txt <- read.csv(translation.file, row.names = 1, stringsAsFactors = F)

# reorder factor citizen
# df$citizen <- factor(df$citizen, levels = df %>% group_by(citizen) %>%
#   dplyr:::summarise(tot = sum(value)) %>% select(citizen) %>%
#   unlist(use.names = FALSE) %>% as.character())

lang <- 'fr'

for(lang in colnames(txt)) {
  dd <- df

  tmp_html <- paste0("streamgraph_originAsylum_tmp_", lang, ".html")
  output.html <- paste0("originAsylum_streamgraph_", lang, ".html")

  # rename origin / citizen country names
  idx <- match(paste0("code.", gsub(" ", "", dd$citizen)), rownames(txt))
  stopifnot(all(!is.na(idx)))
  dd$citizen <- txt[idx, lang]

  schart <- dd %>% filter(df$time >= as.Date("2008-01-01")) %>%
    streamgraph("citizen", "value", "time", interpolate="cardinal", offset="zero",
      right = 4, top = 10, bottom = 25, height = 430) %>%
    sg_axis_x(1, "year", "%Y") %>%
    sg_fill_manual(swi_rpal) %>%
    sg_legend(TRUE, txt['select', lang])

  # hack to make it responsive !!
  schart$sizingPolicy$browser$padding <- 5
  schart$sizingPolicy$browser$defaultWidth <- "100%"

  saveWidget(schart, file = tmp_html, selfcontained = FALSE, libdir = "js")

  # add title, source, ...
  swi_widget(tmp_html, output.html,
    h2 = txt["title",lang],
    descr = txt["descr", lang],
    h3 =  txt["subtitle",lang],
    source = paste0(
      txt["source",lang], ": ",
      htmlLink(
        "http://ec.europa.eu/eurostat/en/web/products-datasets/-/MIGR_ASYAPPCTZM",
        txt["eurostat",lang]
      )
    ),
    author = paste0(txt["credit",lang], ": ",
      htmlLink("https://github.com/hrbrmstr/streamgraph", "streamgraphR"))
    )

}