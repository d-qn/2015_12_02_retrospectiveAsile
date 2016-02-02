## 2015: when the wave of migrants reached Europe

This repository contains all the R code used for [this data-driven story](http://www.swissinfo.ch/eng/data-story_2015--when-the-wave-of-migrants-reached-europe/41844230).

* The script _01_getMonthlyAsyslum.R_ 
  * fetches monhtly asylum data from Eurostat bulk download facility. 
  * performs a series of filtering and aggregations to shape the data for the visualisations
* _02_plotFlows.R_
  * plots an interactive (htmlwidget) parset / sankey diagram showing flows of asylum origin & destination for the current year 
* _03_plotStreamgraphOrigin.R_
  * plots an interactive streamgraph (with 0 origin) of asylum origins over time with htmlwidget. 
* _04_asylumDataSoFar_dw.R_
  * fetch data from World Bank on GDP and population to compute different relative asylum statistcs




### Exclusion of liability

The published information has been collated carefully, but no guarantee is offered of its completeness, correctness or up-to-date nature. No liability is accepted for damage or loss incurred from the use of this script or the information drawn from it. This exclusion of liability also applies to third-party content that is accessible via this offer.

### License

<a rel="license" href="http://creativecommons.org/licenses/by-nc-sa/4.0/"><img alt="Creative Commons License" style="border-width:0" src="https://i.creativecommons.org/l/by-nc-sa/4.0/88x31.png" /></a><br /><span xmlns:dct="http://purl.org/dc/terms/" property="dct:title">Licensed under a <a rel="license" href="http://creativecommons.org/licenses/by-nc-sa/4.0/">Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License</a>.

### Contact details

If you have questions please write an email to ducquang.nguyen(at)swissinfo.ch or  on [Twitter](https://twitter.com/duc_qn)
   