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

# read in data
data_2019_09 <- read.csv("data/2019_09.csv")
data_2019_10 <- read.csv("data/2019_09.csv")
