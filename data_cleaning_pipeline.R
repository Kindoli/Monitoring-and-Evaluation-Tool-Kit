library(tidyverse)
library(readxl)
library(janitor)
library(openxlsx)


# LOAD DATA


file_path <- "NGO_M&E_Data_Template.xlsx"

projects <- read_excel(file_path, sheet = "Projects") %>% clean_names()
indicators <- read_excel(file_path, sheet = "Indicators") %>% clean_names()
targets <- read_excel(file_path, sheet = "Targets") %>% clean_names()
actuals <- read_excel(file_path, sheet = "Actuals") %>% clean_names()
beneficiaries <- read_excel(file_path, sheet = "Beneficiaries") %>% clean_names()


# CLEAN & TRANSFORM THE DATASETS


# Merge targets and actuals
performance <- targets %>%
  left_join(actuals, by = c("project_id", "indicator_id", "month")) %>%
  left_join(projects, by = "project_id") %>%
  left_join(indicators, by = "indicator_id") %>%
  mutate(
    achievement_rate = actual_value / target_value
  )


# Aggregate beneficiaries
beneficiary_summary <- beneficiaries %>%
  group_by(record_id, project_id, month, gender, age_group, disability) %>%
  summarise(total = sum(value, na.rm = TRUE), .groups = "drop")


# EXPORT CLEAN DATA

write.csv(performance, "performance_clean.csv")
write.csv(beneficiary_summary, "beneficiaries_clean.csv")

print("Data cleaned and exported successfully")
