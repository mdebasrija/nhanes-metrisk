#mapping biomarkers to LOINC codes

library(haven)
library(tidyverse)

bpxo   <- read_xpt("data/raw/P_BPXO.xpt")
tchol  <- read_xpt("data/raw/P_TCHOL.xpt")
hdl    <- read_xpt("data/raw/P_HDL.xpt")
trigly <- read_xpt("data/raw/P_TRIGLY.xpt")

LOINC <- list(
  sbp   = "96608-5",
  dbp   = "96609-3",
  tc    = "2093-3",
  hdl   = "2085-9",
  tg    = "3048-6",
  ldl   = "13457-7"
)

#BP occurs as 3 readings. I did not explicitly correct for the arm used or the cuff size. This is a simplification I have used.
bp_long <- bpxo |>
  mutate(
    sbp = rowMeans(across(c(BPXOSY1, BPXOSY2, BPXOSY3)), na.rm = TRUE), #mean of three systolic BP readings, removing NAs to keep the remaining values usable
    dbp = rowMeans(across(c(BPXODI1, BPXODI2, BPXODI3)), na.rm = TRUE) #mean of three diastolic BP readings, removing NAs for the same reason
  ) |>
  select(person_id = SEQN, sbp, dbp) |>
  pivot_longer(c(sbp, dbp),
               names_to  = "measure",
               values_to = "value_as_number") |>
  mutate(
    measurement_concept_id = if_else(measure == "sbp", LOINC$sbp, LOINC$dbp),
    measurement_label      = if_else(measure == "sbp",
                                     "Systolic blood pressure",
                                     "Diastolic blood pressure"),
    unit = "mm[Hg]"
  )

lipid_long <- list(
  tchol  |> select(SEQN, LBXTC), #in mg/dL
  hdl    |> select(SEQN, LBDHDD), #in mg/dL
  trigly |> select(SEQN, LBXTR, LBDLDL) #in mg/dL, in mg/dL Friedelwald method
) |>
  reduce(full_join, by = "SEQN") |>
  transmute(
    person_id = SEQN,
    tc  = LBXTC,
    hdl = LBDHDD,
    tg  = LBXTR,
    ldl = LBDLDL
  ) |>
  pivot_longer(c(tc, hdl, tg, ldl),
               names_to  = "measure",
               values_to = "value_as_number") |>
  mutate(
    measurement_concept_id = case_when(
      measure == "tc"  ~ LOINC$tc,
      measure == "hdl" ~ LOINC$hdl,
      measure == "tg"  ~ LOINC$tg,
      measure == "ldl" ~ LOINC$ldl
    ),
    measurement_label = case_when(
      measure == "tc"  ~ "Total cholesterol",
      measure == "hdl" ~ "HDL cholesterol",
      measure == "tg"  ~ "Triglycerides",
      measure == "ldl" ~ "LDL cholesterol (Friedewald)"
    ),
    unit = case_when(
      measure %in% c("tc", "hdl", "tg", "ldl") ~ "mg/dL"
    )
  )

measurement <- bind_rows(bp_long, lipid_long) |>
  filter(!is.na(value_as_number), !is.nan(value_as_number)) |>
  mutate(
    measurement_id   = row_number(),
    measurement_date = as.Date("2018-06-01")
  ) |>
  select(measurement_id, person_id, measurement_concept_id,
         measurement_label, measurement_date, value_as_number, unit)

message("measurement table: ", nrow(measurement), " rows")
glimpse(measurement)