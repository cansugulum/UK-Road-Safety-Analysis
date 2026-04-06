# ------------------------------------------------------------
# Project: UK Road Casualty Vehicle Analysis
# Author: Cansu Gulum
# Description: Exploratory data analysis (EDA) of UK road casualty vehicle data (2024)
# ------------------------------------------------------------

# --- Setup: Load libraries ---

library(tidyverse)
library(janitor)

# --- Load data ---

vehicles_raw <- read_csv("data/road_safety_data.csv")

# --- Clean data ---

vehicles_clean <- vehicles_raw %>%
  clean_names() %>%
  mutate(across(where(is.numeric), ~na_if(., -1)))

# --- Exploratory data analysis ---

# Age distribution of drivers
vehicles_age_plot <- vehicles_clean %>%
  filter(!is.na(age_of_driver))

ggplot(data = vehicles_age_plot, aes(x = age_of_driver)) +
  geom_histogram(binwidth = 5, fill = "steelblue", color = "white") +
  labs(
    title = "Distribution of Driver Age in Road Collisions (UK, 2024)",
    x = "Driver Age",
    y = "Number of Drivers"
  ) +
  theme_classic()

ggsave("plots/driver_age_distribution.png", width = 8, height = 5)

# --- Interpretation ---

# The distribution peaks between ages 25–35, indicating the highest involvement in collisions.
# A secondary concentration is visible among younger drivers (late teens to mid-20s).
# The number of collisions decreases with age, though older drivers are still represented.

# --- Vehicle type by age group ---

age_vehicle_summary <- vehicles_clean %>%
  mutate(
    age_group = case_when(
      age_of_driver >= 17 & age_of_driver <= 25 ~ "Young (17-25)",
      age_of_driver >= 26 & age_of_driver <= 55 ~ "Middle (26-55)",
      age_of_driver > 55                        ~ "Older (55+)",
      TRUE                                      ~ NA_character_
    )
  ) %>%
  filter(!is.na(age_group)) %>%
  count(age_group, vehicle_type) %>%
  group_by(age_group) %>%
  mutate(proportion = n / sum(n)) %>%
  ungroup()

print(age_vehicle_summary)

# --- Recode vehicle types ---

age_vehicle_summary_labelled <- age_vehicle_summary %>%
  mutate(
    vehicle_type_label = case_when(
      vehicle_type == 9  ~ "Car",
      vehicle_type == 1  ~ "Pedal Cycle",
      vehicle_type == 19 ~ "Van / Goods Vehicle",
      vehicle_type == 3  ~ "Motorcycle (<=50cc)",
      vehicle_type == 8  ~ "Taxi",
      TRUE               ~ "Other / Unknown"
    )
  )

print(age_vehicle_summary_labelled)

# --- Visualisation: vehicle type by age group ---

ggplot(age_vehicle_summary_labelled, aes(x = age_group, y = proportion, fill = vehicle_type_label)) +
  geom_col() +
  labs(
    title = "Vehicle Type Composition Across Driver Age Groups",
    x = "Driver Age Group",
    y = "Proportion within Age Group",
    fill = "Vehicle Type"
  ) +
  theme_classic()

ggsave("plots/vehicle_type_by_age_group.png", width = 8, height = 5)