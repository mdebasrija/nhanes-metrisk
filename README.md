# nhanes-metrisk

Cardiovascular and metabolic risk analytics in R using NHANES 2017–2020 data, converting to OMOP CDM (v5.4) and storage and querying with DuckDB.

## What this is now (version 1)

A reproducible clinical data pipeline that maps NHANES survey data to OMOP CDM conventions, stores it in DuckDB, and generates a parameterised analytical report. 

**Current version:** Has 9,693 adults, biomarkers starting with blood pressure and cholesterol to convert to CDM. 

## Data

NHANES 2017–2020 pre-pandemic combined files (CDC). In public domain, so can be downloaded with a simple `download.file()`.

Run `R/01_download.R` to download them from CDC.

| File | Domain |
|---|---|
| `P_DEMO.xpt` | Demographics |
| `P_BPXO.xpt` | Blood pressure (oscillometric) |
| `P_TCHOL.xpt` | Total cholesterol + HDL |

Later, I realised HDL lives in a different file. So the final list is now - 
| File | Domain |
|---|---|
| `P_DEMO.xpt` | Demographics |
| `P_BPXO.xpt` | Blood pressure (oscillometric) |
| `P_TCHOL.xpt` | Total cholesterol |
| `P_HDL.xpt` | HDL |
| `P_TRIGLY.xpt` | LDL and Triglycerides |

NHANES switched from auscultatory measurement in 2017–2018. No auscultatory data exists for 2019–2020.


## Setup

```r
git clone https://github.com/mdebasrija/nhanes-metrisk.git
cd nhanes-metrisk
Rscript -e "renv::restore()"
Rscript R/01_download.R
```

R ≥ 4.5 (I used 4.5.3, and in RStudio) packages managed by renv


## What's been built

```
R/01_download.R to download CDC files
R/02_map_person.R for adding concept IDs in OMOP format for 9693 adults
R/03_map_measurement.R  (in progress, mapping lab measurements to LOINC codes)
```

Ideally, I would map LOINC codes and concept IDs using the full vocabulary database and validate using Athena, but since this is on a smaller scale, I am choosing to do this manually while ensuring the codes are correct by manually looking them up in Athena. 

## Limitations

- Survey weights not applied, so estimates describe the sample
- 728 adults (7.5%) are interview-only (RIDSTATR=1), so there are no physical measurements
- `year_of_birth` is approximate (2018 - age)
- BP oscillometric method and not comparable to pre-2017 auscultatory NHANES cycles
