library(dplyr)
library(htmlwidgets)
library(swiRcharts)
#library(streamgraph)

data.file <- "input/orgin2015_ts.csv"
translation.file <- "input/translationStream.csv"
chartHeight <- 450

# read data files
df <- read.csv(data.file)
df$time <- as.Date(as.character(df$time))
df <- rename(df, y = value)
txt <- read.csv(translation.file, row.names = 1, stringsAsFactors = F)

lang <- 'fr'

for(lang in colnames(txt)) {
  ddd <- df

  output.html <- paste("EU_origin_ayslum_areaspline_", lang, ".html", sep ="")

  # rename origin / citizen country names
  idx <- match(paste0("code.", gsub(" ", "", ddd$citizen)), rownames(txt))
  stopifnot(all(!is.na(idx)))
  ddd$citizen <- txt[idx, lang]

  ## create fancy tooltip as html table
  ddd$name <- paste0(
    '<table cellpadding="1" style="line-height:1.4">',
    '<tr><td><div style="font-size:0.85em"><b>', format(ddd$time, "%Y-%m"), '</b></td></div>',
    '<td></td><td></td></tr>',
    '<tr><td colspan="3"><div style="font-size:0.8em">', ddd$y, " ",
    txt["tooltip.ayslumdemand",lang], '</div></td></tr>',
    '<tr><td align="left" colspan="3"><div style="font-size:0.85em">', ddd$citizen,'</div></td></tr>',
    '</table>')

  ## CHART
  a <- Highcharts$new()
  a$chart(zoomType = "xy", type = 'areaspline', height = chartHeight, spacing = 5)
  hSeries <- hSeries2(data.frame(x = ddd$time, y = ddd$y, name = ddd$name, series = ddd$citizen), "series")
#   h2 <- lapply(hSeries, function(series) {
#     c(series, index = unname(legendIndex[ddd[match(series$name, ddd$geo),'iso2']]))
#   })

  a$series(hSeries)
  a$colors(swi_pal)
  a$plotOptions(area = list(stacking = "normal", lineWidth = 0.1,
    marker = list(enabled = FALSE, symbol = "circle", radius = 1)),
    series = list(fillOpacity = 1))

  a$legend(borderWidth= 0, itemMarginTop = 3, itemMarginBottom = 5, itemHoverStyle = list(color = '#996666'),
    itemStyle = list(fontWeight = "normal", fontSize = "0.8em"),
     title = list(style = list(fontWeight ='normal'),
     text = paste0(trad['legend.country',lang], ' <span style="font-size: 9px; color: #666; font-weight: normal">',
    trad['legend.descr',lang], '</span><br>')), style = list(fontStyle = 'italic'))

  a$xAxis(title = list(text = ""), max = max(dd$time), min = min(dd$time),
          plotLines = list(
            list(color = plotLinesColor, value = 1991.4, width = widthLine, zIndex = zIndex, dashStyle = styleLine,
                 label = list(text = trad['annotation.exYougoslavia',lang], rotation = 0, y = yoffset,
                              style = list( color = textColor, fontSize = fontSize))),
            list(color = plotLinesColor, value = 1998.2, width = widthLine, zIndex = zIndex, dashStyle = styleLine,
                 label = list(text = trad['annotation.Kosovo',lang], rotation = 0, y = yoffset * 2,
                              style = list( color = textColor, fontSize = fontSize))),
            list(color = plotLinesColor, value = 2011.3, width = widthLine, zIndex = zIndex, dashStyle = styleLine,
                 label = list(text = trad['annotation.Syria',lang], rotation = 0, x = -5, y = yoffset * 3, align = 'right',
                              style = list( color = textColor, fontSize = fontSize)))
          )
  )

  a$lang( numericSymbols= NULL)
  a$yAxis(title = list(text = trad['y.lab',lang]), gridLineColor = "#EFEFEF",
          labels = list(formatter = "#! function () {return this.value / 1000;} !#"))

  a$tooltip(formatter = "#! function() { return this.point.name; } !#", useHTML = T , borderWidth = 3, style = list(padding = 1.5))
  #a

  hChart.html <- tempfile("hChart_area")
  a$save(hChart.html)

  # Convert highcharts-rCharts html chart into a responsive one
  hChart2responsiveHTML(hChart.html, output.html = output.html, h2 = trad['title',lang], descr = trad['descr',lang],
                        source = trad['source',lang], h3 = "", author = 'Duc-Quang Nguyen | <a href = "http://www.swissinfo.ch" target="_blank">swissinfo.ch</a>')


}