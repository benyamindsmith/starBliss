# Internal function, adaptation of
# https://github.com/ofrohn/d3-celestial/blob/7e720a3de062059d4c5400a379146a601d9010e0/celestial.js#L1215-L1250
get_mst <- function(dt, lng) {
  desired_date_utc <- lubridate::with_tz(dt, "UTC")


  yr <- lubridate::year(desired_date_utc)
  mo <- lubridate::month(desired_date_utc)
  dy <- lubridate::day(desired_date_utc)
  h <- lubridate::hour(desired_date_utc)
  m <- lubridate::minute(desired_date_utc)
  s <- lubridate::second(desired_date_utc)

  if ((mo == 1) || (mo == 2)) {
    yr <- yr - 1
    mo <- mo + 12
  }

  # Adjust times before Gregorian Calendar
  # See https://squarewidget.com/julian-day/
  if (lubridate::as_date(dt) > as.Date("1582-10-14")) {
    a <- floor(yr / 100)
    b <- 2 - a + floor(a / 4)
  } else {
    b <- 0
  }
  c <- floor(365.25 * yr)
  d <- floor(30.6001 * (mo + 1))

  # days since J2000.0
  jd <- b + c + d - 730550.5 + dy + (h + m / 60 + s / 3600) / 24
  jt <- jd / 36525

  # Rotation
  mst <- 280.46061837 + 360.98564736629 * jd +
    0.000387933 * jt^2 - jt^3 / 38710000.0 + lng

  # Modulo 360 degrees
  mst <- mst %% 360

  return(mst)
}
