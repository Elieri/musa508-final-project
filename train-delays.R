# --- SETUP ---

# load libraries
library(tidyverse)
library(lubridate)
library(sf)
library(ggmap)
library(riem)

# prevent scientific notation
options(scipen = 999)

# set coordinate reference system: 
# nj_crs = "EPSG:3424" # NAD83/New Jersey
nj_crs = "EPSG:4326"

# define theme colors
theme_orange <- "#f15a24"
theme_red <- "#d4145a"
theme_blue <- "#29abe2"
theme_green <- "#22b573"
theme_scale <- c("#22b573", "#29abe2", "#d4145a", "#f15a24")
# theme_scale <- c("#f15a24", "#d4145a", "#29abe2", "#22b573")


# set map styling options
mapTheme <-
  theme(
    axis.text = element_blank(),
    axis.ticks = element_blank(),
    panel.background = element_blank(),
    plot.title = element_text(face = "bold"),
    plot.subtitle = element_text(face = "italic"),
    plot.caption = element_text(hjust = 0)
  )

# set plot styling options
plotTheme <-
  theme(
    axis.ticks = element_blank(),
    legend.title = element_blank(),
    panel.background = element_blank(),
    panel.grid.major = element_line(color = "gray75", size = 0.1),
    panel.grid.minor = element_line(color = "gray75", size = 0.1),
    plot.title = element_text(face = "bold"),
    plot.subtitle = element_text(face = "italic"),
    plot.caption = element_text(hjust = 0)
  )

# set basemap options
# set_defaults(map_service = "carto", map_type = "dark_no_labels")

# --- DATA WRANGLING ---

# read in data for training period
data_2019_09 <- read.csv("data/2019_09.csv") %>%
  mutate(set = "training")

# read in data for test period
data_2019_10 <- read.csv("data/2019_10.csv") %>%
  filter(as.Date(date) <= as.Date("2019-10-14")) %>%
  mutate(set = "test")

# read in station coordinates
stations <- read_csv("data/stops.csv") %>%
  st_as_sf(coords = c("stop_lon", "stop_lat")) %>%
  st_set_crs("EPSG:4326") %>%
  st_transform(nj_crs)

# merge data for further wrangling
data <- rbind(data_2019_09, data_2019_10) %>%
  # exclude Amtrak trains, which have no delay data
  filter(type == "NJ Transit") %>%
  mutate(
    # standardize datetime columns
    scheduled_time = ymd_hms(scheduled_time),
    actual_time = ymd_hms(actual_time),
    # create schedule intervals
    scheduled_hour = floor_date(scheduled_time, unit = "hour"),
    scheduled_15min = floor_date(scheduled_time, unit = "15 min"),
    # create week and day features
    week = week(scheduled_time),
    day_of_week = wday(scheduled_time, label = TRUE)
  ) %>%
  # drop trains with missing values
  drop_na() %>%
  # join station geometries
  left_join(stations, by = c("to_id" = "stop_id")) %>%
  dplyr::select(-c("stop_desc", "stop_code", "stop_name", "zone_id")) %>%
  st_sf()

# --- find two lines with worst delays ---

delays_by_line  <- data %>%
  filter(set == "training") %>%
  group_by(line) %>%
  summarize(total_delay_minutes = sum(delay_minutes),
            mean_delay_minutes = mean(delay_minutes),
            median_delay_minutes = median(delay_minutes)) %>%
  arrange(desc(total_delay_minutes))


delays_by_station  <- data %>%
  filter(set == "training", line %in% c("No Jersey Coast", "Northeast Corrdr")) %>%
  group_by(to, to_id) %>%
  summarize(total_delay_minutes = sum(delay_minutes),
            mean_delay_minutes = mean(delay_minutes),
            median_delay_minutes = median(delay_minutes),
            max_delay_minutes = max(delay_minutes)) %>%
  arrange(desc(total_delay_minutes))
  

# --- map delays by station ---

# read in rail line map
rail_lines <- st_read("https://opendata.arcgis.com/datasets/e6701817be974795aecc7f7a8cc42f79_0.geojson") %>%
  # filter(LINE_CODE %in% c("NC", "NE")) %>%
  st_transform(nj_crs)


ggmap_center <- c(lon = -74.4, lat = 40.4)
g <- ggmap(get_googlemap(center = ggmap_center, maptype = "terrain", color = "bw", zoom = 9, scale = 4))

g2 <- ggmap(get_googlemap(center = system_centroid, maptype = "terrain", color = "bw", zoom = 9, scale = 4))

g + geom_sf(data = rail_lines, inherit.aes = FALSE)

test <- stations





m +
  geom_sf(data = rail_lines, inherit.aes = FALSE)

# 
g +
  #geom_sf(data = rail_lines, inherit.aes = FALSE, color = "gray10") +
  geom_sf(data = filter(rail_lines, LINE_CODE == "NC"),
          color = theme_red, size = 2, inherit.aes = FALSE) +
  geom_sf(data = filter(rail_lines, LINE_CODE == "NE"),
          color = theme_orange, size = 2, inherit.aes = FALSE) +
  labs(x = "", y = "") +
  mapTheme
  

g +
  geom_sf(data = filter(rail_lines, LINE_CODE %in% c("NC", "NE")),
          color = "gray40", size = 1, inherit.aes = FALSE, show.legend = FALSE) +
  geom_sf(data = delays_by_station,
          aes(size = mean_delay_minutes,
              color = mean_delay_minutes),
          inherit.aes = FALSE, show.legend = FALSE) +
  scale_color_stepsn(n.breaks = 4, colors = theme_scale) +
  scale_size_continuous(range = c(0.5, 8)) +
  labs(x = "", y = "") +
  mapTheme



g +
  geom_sf(data = filter(rail_lines, LINE_CODE %in% c("NC", "NE")),
          color = "gray40", size = 1, inherit.aes = FALSE, show.legend = FALSE) +
  geom_sf(data = filter(data, train_id %in% c("3722", "7224")) %>% arrange(delay_minutes),
          aes(size = delay_minutes,
              color = delay_minutes),
          inherit.aes = FALSE, show.legend = FALSE) +
  scale_color_stepsn(n.breaks = 5, colors = theme_scale) +
  scale_size_continuous(range = c(1, 10)) +
  labs(x = "", y = "") +
  mapTheme


+
  scale_size_continuous() +
  scale_color_stepsn(n.breaks = 3, colors = c("green", "orange", "red")) +
  mapTheme
  




map_bbox <- st_as_sfc(st_bbox(st_union(rail_lines))) %>% st_sf() %>% st_transform("EPSG:4326")
map_centroid <- st_coordinates(st_centroid(map_bbox))

system_bbox <- st_as_sfc(st_bbox(st_union(rail_lines))) %>% st_sf() %>% st_transform("EPSG:4326")
system_centroid <- st_coordinates(st_centroid(system_bbox))




ggplot() +
  geom_sf(data = map_bbox) +
  geom_sf(data = rail_lines) +
  #geom_sf(data = stations) +
  geom_sf(data = st_centroid(st_union(rail_lines)), color = "red") +
  geom_sf(data = st_centroid(st_convex_hull(st_union(rail_lines))), color = "blue") +
  geom_sf(data = st_centroid(map_bbox), color = "green")





data %>%
  ggplot(aes(scheduled_hour, delay_minutes, colour = line)) + geom_line() +
  # geom_vline(data = mondays, aes(xintercept = monday)) +
  labs(title="Rideshare trips by week: November-December",
       subtitle="Dotted lines for Thanksgiving & Christmas", 
       x="Day", y="Trip Count") +
  plotTheme() + theme(panel.grid.major = element_blank()) 