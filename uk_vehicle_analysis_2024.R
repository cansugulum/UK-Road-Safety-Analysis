# ------------------------------------------------------------------
# Project: Analysis of Vehicles Involved in UK Road Casualties 2024
# Author: Cansu Gulum
# Date: 2025-09-21
#
# Description: This script loads, cleans, and performs an initial 
#              exploratory data analysis (EDA) on the provisional mid-year 
#              vehicles dataset from data.gov.uk (DfT).
# ------------------------------------------------------------------

# --- 1. SETUP: Load Libraries ---

library(tidyverse)
library(janitor)

# --- 2. LOAD DATA ---
# Note: The CSV file should be in the same folder as this R script.
# Make sure the filename in the quotes matches your downloaded file exactly.

vehicles_raw <- read_csv("DfT-road-casualty-statistics-vehicle-2024-mid-year-unvalidated.csv")

# --- 3. CLEAN DATA ---
# Description: This section takes the raw data and applies cleaning steps.
#              1. Standardize all column names to snake_case using janitor.
#              2. Replace all numeric -1 values (used as codes for missing/unknown data) with proper NA values.

vehicles_clean <- vehicles_raw %>%
  clean_names() %>%
  mutate(across(where(is.numeric), ~na_if(., -1))) %>%
  mutate(lsoa_of_driver = na_if(lsoa_of_driver, "-1"))

# --- 4. INITIAL CHECK ---
# Description: Take a first look at the cleaned data to ensure the steps above were successful.

# glimpse(vehicles_clean)
# summary(vehicles_clean)

# --- 5. EXPLORATORY DATA ANALYSIS (EDA) ---
# Question 1: What is the age distribution of drivers involved in collisions?

ggplot(data = vehicles_clean, aes(x = age_of_driver)) +
  geom_histogram()

# --- INTERPRETATION: Question 1 ---
# The histogram of driver ages reveals a right-skewed distribution, meaning
# accidents are more concentrated among younger and middle-aged drivers.
#
# Key Observations:
# 1. The highest frequency of accidents involves drivers aged between roughly 25-40.
# 2. A sharp increase is visible after the legal driving age (~17), with a secondary peak in the mid-20s, indicating a high risk for novice drivers.
# 3. The number of accidents steadily declines for older age groups, but a long tail shows that collisions still occur among elderly drivers.
#
# This initial finding gives us our primary group of interest: young to middle-aged drivers.

# ---
# Question 2: How does vehicle type differ across the identified age groups?
# To answer this, we first create the age groups and then count the occurrences 
# of each vehicle type within each age group.

# Step 2.1: Create age groups and count vehicle types in one chain

age_vehicle_summary <- vehicles_clean %>%
  mutate(
    age_group = case_when(
      age_of_driver >= 17 & age_of_driver <= 25 ~ "Young Driver (17-25)",
      age_of_driver >= 26 & age_of_driver <= 55 ~ "Middle-Aged (26-55)",
      age_of_driver > 55                      ~ "Older Driver (55+)",
      TRUE                                    ~ "Unknown"
    )
  ) %>%
  count(age_group, vehicle_type, sort = TRUE)

# Step 2.2: Display the result

print(age_vehicle_summary)

# ---
# Step 2.3: Recode the numeric 'vehicle_type' codes into meaningful labels.
# We use case_when() to create a new column with the descriptive names found
# in the official data dictionary.

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

# Step 2.4: Display the final, labelled summary table to check our work.

print(age_vehicle_summary_labelled)

# Final visualization to show vehicle types within each age group

ggplot(data = age_vehicle_summary_labelled, aes(x = age_group, y = n, fill = vehicle_type_label)) +
  geom_col() +
  labs(
    title = "Age Groups and Vehicle Types Involved in Collisions",
    x = "Driver Age Group",
    y = "Total Number of Accidents",
    fill = "Vehicle Type" 
  )
