# --- SETUP ---

# load libraries
library(tidyverse)
library(lubridate)
library(riem)

# prevent scientific notation
options(scipen = 999)

# set map styling options
mapTheme <- function() {
  theme(
    axis.text = element_blank(),
    axis.ticks = element_blank(),
    panel.background = element_blank(),
    plot.title = element_text(face = "bold"),
    plot.subtitle = element_text(face = "italic"),
    plot.caption = element_text(hjust = 0)
  )
}

# set plot styling options
plotTheme <- function() {
  theme(
    axis.ticks = element_blank(),
    legend.title = element_blank(),
    panel.background = element_blank(),
    panel.grid.major = element_line(color = "gray75", size = 0.1),
    panel.grid.minor = element_line(color = "gray75", size = 0.1),
    plot.title = element_text(face = "bold"),
    plot.subtitle = element_text(face = "italic"),
    plot.caption = element_text(hjust = 0))
}

# --- DATA WRANGLING

# read in data for training period
data_2019_09 <- read.csv("data/2019_09.csv") %>%
  mutate(set = "training")

# read in data for test period
data_2019_10 <- read.csv("data/2019_10.csv") %>%
  filter(as.Date(date) <= as.Date("2019-10-14")) %>%
  mutate(set = "test")

# merge data for further wrangling
data <- rbind(data_2019_09, data_2019_10) %>%
  # exclude Amtrak trains, which have no delay data
  filter(type == "NJ Transit") %>%
  mutate(
    # standardize datetime columns
    scheduled_time = ymd_hms(scheduled_time),
    actual_time = ymd_hms(actual_time)
  ) %>%
  # drop trains with missing values
  drop_na()

# --- temporal data wrangling with lubridate ---


