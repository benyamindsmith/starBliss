#' Plot A Custom Starmap
#'
#' Create a custom, print quality star map with `plot_starmap()`
#'
#' @param location Location of choice. Uses the ArGis geocoding API through via `tidygeocoder::geocode`. Used to extract latitude
#' @param date date. ymd format works best, other formats have not been tested.
#' @param style choice. Right now only accepts "black and green
#' @param line1_text Text you want to have in your image caption. There are 3 centered lines specified.
#' @param line2_text Ibid.
#' @param line3_text If `TRUE` default value is the geocoordinates (GPS form) otherwise you can add the text of your choosing.
#' @import magrittr
#' @import dplyr
#' @import lubridate
#' @import ggplot2
#' @import sf
#' @import tidygeocoder
#' @import tibble
#' @import grid
#' @import s2
#' @import withr
#' @export
#' @examples
#'
#' library(starBliss)
#' library(ggplot2)
#' p<- plot_starmap(location= "Toronto, ON, Canada",
#'                  date="2022-01-17",
#'                  style="black",
#'                  line1_text="Toronto",
#'                  line2_text ="January 17th, 2023",
#'                  line3_text="43.6532° N, 79.3832° W")
#'
#' ggsave('toronto_black.png', plot = p, width = unit(10, 'in'), height = unit(15, 'in'))
#'
#' p<- plot_starmap(location= "Toronto, ON, Canada",
#'                  date="2022-01-17",
#'                  style="green",
#'                  line1_text="Toronto",
#'                  line2_text ="January 17th, 2023",
#'                  line3_text="43.6532° N, 79.3832° W")
#'
#' ggsave('toronto_green.png', plot = p, width = unit(10, 'in'), height = unit(15, 'in'))



plot_starmap <- function(location,
                         date = today(),
                         style = c('black', 'green'),
                         line1_text = location,
                         line2_text = format(as.Date(date), "%B %d, %Y"),
                         line3_text=TRUE){

  # Using match.arg to avoid spelling errors with the argument specification
  style <- match.arg(style)
  # Cleaning up date arg
  date<- as.Date(date)
  # Suppress warnings within the function

  # Constellations Data
  url1 <- "https://raw.githubusercontent.com/benyamindsmith/starBliss/main/data/constellations.lines.json"

  # Stars Data
  url2 <- "https://raw.githubusercontent.com/benyamindsmith/starBliss/main/data/stars.6.json"

  # Formatted date
  dt<- lubridate::ymd(date)


  # Extract relevant latitude and logitude.

  # Latitude is dependent on location
  suppressMessages(
    capture.output(
      gocodeData <-  tibble(singlelineaddress = location) %>%
                     geocode(address=singlelineaddress,method = 'arcgis')
    )
  )

  lat <- gocodeData %>% .[["lat"]]
  lon_map <-gocodeData %>%  .[["long"]]

  if(line3_text==TRUE){
    line3_text <- paste0(abs(round(lat,4)), "° ", ifelse(lat > 0, "N", "S"), ", ",
                         abs(round(lon_map,4)), "° ", ifelse(lon_map > 0, "E", "W")
    )
  }
  ref_date <- paste0(year(dt),"01","01",sep="-") %>% ydm()
  # Resulting longitude
  lon <- (-as.numeric(difftime(ref_date,dt, units="days"))/365)*360 %>% round(4)

  # The CRS

  projString <- paste0("+proj=laea +x_0=0 +y_0=0 +lon_0=",lon, " +lat_0=", lat)


  # Data Transformation
  flip <- matrix(c(-1, 0, 0, 1), 2, 2)

  hemisphere_1 <- s2::s2_buffer_cells(
    s2::as_s2_geography(paste0("POINT(", lon, " ", lat, ")")),
    distance = 1e7,
    max_cells = 5000)

  hemisphere_2 <- st_sfc(st_point(c(lon, lat)), crs = 4326) %>%
    st_buffer(dist = 1e7) %>%
    st_transform(crs = projString)

  # Reading Data
  invisible(
    capture.output(
      constellation_lines_sf <- invisible(st_read(url1, stringsAsFactors = FALSE)) %>%
        st_wrap_dateline(options = c("WRAPDATELINE=YES", "DATELINEOFFSET=360")) %>%
        # Use s2 for the cut
        st_as_s2() %>%
        s2::s2_intersection(hemisphere_1) %>%
        # Back to sf
        st_as_sf() %>%
        st_transform(crs = projString) %>%
        filter(!is.na(st_is_valid(.))) %>%
        mutate(geometry = geometry * flip) %>%
        # Filter if empty, since the cut can produce empty geometries
        filter(!st_is_empty(.))
    )
  )


  st_crs(constellation_lines_sf) <- projString

  # Reading Data
  withr::with_options(list(warn=-1),
  invisible(
    capture.output(
      stars_sf <- st_read(url2,stringsAsFactors = FALSE) %>%
        st_transform(crs = projString) %>%
        st_intersection(hemisphere_2) %>%
        mutate(geometry = geometry * flip)
    )
  )
)
  st_crs(stars_sf) <- projString


  # Setting parameters to update map
  if(style=="black"){
    fillVal <-  '#191d29'
    colVal <- '#191d29'
    colorVal <- "white"
    majorGridCol <-"grey35"
    minorGridCol <- "grey20"
  }
  if(style == "green"){
    fillVal <-  '#164B58'
    colVal <- '#164B58'
    colorVal <- "white"
    majorGridCol <-"#FEFEFE"
    minorGridCol <- "#FEFEFE"
  }
  # Creating the frame
  mask <- polygonGrob(x = c(1, 1, 0, 0, 1, 1,
                            0.5 + 0.46 * cos(seq(0, 2 *pi, len = 100))),
                      y =  c(0.5, 0, 0, 1, 1, 0.5,
                             0.5 + 0.46 * sin(seq(0, 2*pi, len = 100))),
                      gp = gpar(fill = fillVal, col = colVal))

  p <- ggplot() +
    geom_sf(data = stars_sf, aes(size = -exp(mag), alpha = -exp(mag)),
            color = colorVal)+
    geom_sf(data = constellation_lines_sf, color = colorVal,
            size = 0.5) +
    annotation_custom(circleGrob(r = 0.46,
                                 gp = gpar(col = colorVal, lwd = 10, fill = NA))) +
    scale_y_continuous(breaks = seq(0, 90, 15)) +
    scale_size_continuous(range = c(0, 2)) +
    annotation_custom(mask) +
    labs(caption = paste0(line1_text,'\n',line2_text,'\n',line3_text)) +
    theme_void() +
    theme(legend.position = "none",
          panel.grid.major = element_line(color = majorGridCol, linewidth = 1),
          panel.grid.minor = element_line(color = minorGridCol, linewidth = 1),
          panel.border = element_blank(),
          plot.background = element_rect(fill = fillVal, color = colVal),
          plot.margin = margin(20, 20, 20, 20),
          plot.caption = element_text(color = colorVal, hjust = 0.5,
                                      face = 2, size = 20,
                                      margin = margin(150, 20, 20, 20),
          ))


  return(p)
}
