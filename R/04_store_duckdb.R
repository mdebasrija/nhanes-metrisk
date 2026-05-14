library(duckdb)
library(DBI)
library(tidyverse)

# Run mapping scripts to get person and measurement in scope since assumption is download has completed (runs once at startup)
source("R/02_map_persona.R")
source("R/03_map_measurement.R")

# Filter to adults only, measurement wasn't filtered earlier
measurement <- measurement |>
  filter(person_id %in% person$person_id)

# Connect to DuckDB
con <- dbConnect(duckdb(), "data/metrisk.duckdb")

# Write tables in duckDB friendly format
dbWriteTable(con, "person", person, overwrite = TRUE)
dbWriteTable(con, "measurement", measurement, overwrite = TRUE)

# QC checks

# Row counts
message("person:", dbGetQuery(con, "SELECT COUNT(*) FROM person")[[1]])
message("measurement:", dbGetQuery(con, "SELECT COUNT(*) FROM measurement")[[1]])

# Zero duplicates
dups <- dbGetQuery(con, "SELECT person_id, measurement_concept_id, COUNT(*) AS n
  FROM measurement
  GROUP BY person_id, measurement_concept_id
  HAVING COUNT(*) > 1")
if (nrow(dups) > 0) {
  stop("DUPLICATE measurements found:\n",
       paste(capture.output(print(dups)), collapse = "\n"))
}
message("QC: zero duplicate person x measurement OK")

# Fasting subsample check by checking if TG and LDL have lower sample numbers
dbGetQuery(con, "SELECT measurement_concept_id, COUNT(*) AS n
  FROM measurement
  GROUP BY measurement_concept_id
  ORDER BY n DESC") |> print()

# Close connection to be able for other sessions to access the db
dbDisconnect(con, shutdown = TRUE)
message("metrisk.duckdb written and closed.")