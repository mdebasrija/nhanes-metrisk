#mapping demographics (gender, age, race, ethnicity) to concept IDs

library(haven)
library(tidyverse)

demo <- read_xpt("data/raw/P_DEMO.xpt") #load demographics file

person <- demo |>
  filter(RIDAGEYR >= 18) |> #adults only
  transmute(
    person_id            = as.integer(SEQN),
    gender_concept_id    = case_when( #have checked only these two exist 
      RIAGENDR == 1 ~ 8507L, #OMOP gender concept ID male
      RIAGENDR == 2 ~ 8532L #OMOP gender concept ID female
    ),
    year_of_birth        = as.integer(2018 - RIDAGEYR), #approximation as most data comes from 2017-18 cycle
    age_years            = as.numeric(RIDAGEYR), #age
    sex_label            = case_when(
      RIAGENDR == 1 ~ "Male",
      RIAGENDR == 2 ~ "Female"
    ),
    race_concept_id      = case_when( 
      RIDRETH3 == 3 ~ 8527L,
      RIDRETH3 == 4 ~ 8516L,
      RIDRETH3 == 6 ~ 8515L,
      RIDRETH3 %in% c(1, 2) ~ 38003563L, #Hispanic or Latino, but there is no race concept ID for this, Hence ethnicity binary value is used
      .default = 0L
    ),
    race_label           = case_when(
      RIDRETH3 == 3 ~ "Non-Hispanic White",
      RIDRETH3 == 4 ~ "Non-Hispanic Black",
      RIDRETH3 == 6 ~ "Non-Hispanic Asian",
      RIDRETH3 %in% c(1, 2) ~ "Hispanic", #both are hispanic, 1 is mexican-american and 2 is other hispanic
      .default = "Other/Multiracial"
    ),
    ethnicity_concept_id = if_else(
      RIDRETH3 %in% c(1, 2), 38003563L, 38003564L #keeping these as ethnicity as mentioned in OMOP
    ),
    ridstatr             = as.integer(RIDSTATR), #interview only/interview and MEC
    exam_weight          = as.numeric(WTMECPRP) #full sample MEC exam weight
  )

message("person table: ", nrow(person), " rows")
glimpse(person)