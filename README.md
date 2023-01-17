# starBliss  <a href='https://github.com/benyamindsmith/starBliss'><img src='https://github.com/benyamindsmith/starBliss/blob/main/starBliss.png' align="right" height="300" /></a>

Initially inspired by an issue posted on the [`mapBliss`](https://github.com/benyamindsmith/mapBliss/issues/10) package. The goal of this package is to create print quality starmap art similar to what is available online on many websites like [Maps For Moments](https://mapsformoments.co.uk) and [Etsy](https://www.etsy.com/ca/market/star_map) within the R console.

As is the case with all projects. This one is a work in progress. So this repository will change over time!

<details>
<summary>
<h2>Table of Contents</h2>
</summary>

* [Installing this package](https://github.com/benyamindsmith/starBliss/main/README.md#installing-this-package)

* [Why this isn't included in `mapBliss`](https://github.com/benyamindsmith/starBliss/main/README.md#why-this-isnt-included-in-mapbliss)

* [Basic Usage](https://github.com/benyamindsmith/starBliss/main/README.md#basic-usage)

* [Dependencies](https://github.com/benyamindsmith/starBliss/main/README.md#dependencies)

* [Sample Visuals](https://github.com/benyamindsmith/starBliss/main/README.md#sample-visuals)

</details>

<details>
<summary>
<h3>Installing this package</h3>
</summary>
```
# install.packages("devtools")
devtools::install_github("benyamindsmith/starBliss")
```
</details>

<details>
<summary>
<h3>Why this isn't included in `mapBliss`</h3>
</summary>
(In progress)
</details>


<details>
<summary>
<h3>Basic Usage</h3>
</summary>
(In progress)
</details>


<details>
<summary>
<h3>Dependencies</h3>
</summary>
This package has the following dependencies:
 
 (In no particular order)
    * `dplyr`
    * `ggplot2`
    * `magrittr`
    * `tidygeocoder`
    * `sf`
    * `lubridate`
    * `tibble`
    * `grid`
</details>


<details>
<summary>
<h3>Sample Visuals</h3>
</summary>

<details>
<summary>
"Black" Style
</summary>

```r
library(ggplot2)
library(starBliss)
p<- plot_starmap(location= "Toronto, ON, Canada",
             date="2022-01-17",
             style="black",
             line1_text="Toronto",
             line2_text ="January 17th, 2023",
             line3_text="43.6532° N, 79.3832° W")
ggsave('toronto_black.png', plot = p, width = unit(10, 'in'), 
       height = unit(15, 'in'))
```

![](https://raw.githubusercontent.com/benyamindsmith/starBliss/main/toronto_black.png)
</details>

<details>
<summary>
"Green" Style
</summary>

```r
library(ggplot2)
library(starBliss)
p<- plot_starmap(location= "Toronto, ON, Canada",
             date="2022-01-17",
             style="green",
             line1_text="Toronto",
             line2_text ="January 17th, 2023",
             line3_text="43.6532° N, 79.3832° W")
ggsave('toronto_green.png', plot = p, width = unit(10, 'in'), 
       height = unit(15, 'in'))
```

![](https://raw.githubusercontent.com/benyamindsmith/starBliss/main/toronto_green.png)
</details>
</details>
